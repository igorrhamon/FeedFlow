import 'package:drift/drift.dart';

import 'connection/connection_stub.dart' if (dart.library.io) 'connection/connection_native.dart';
import 'fts5_helpers.dart';
import 'tables.dart';

part 'database.g.dart';

/// Banco local do FeedFlow (fonte de verdade dos [WorkItem]s e da trilha de
/// eventos/enriquecimentos). Suporte nativo (Android/iOS/desktop) apenas
/// nesta fase — web/WASM fica para uma iteração futura (ver EVOLUTION-PLAN,
/// Fase 1: "web via WASM/OPFS" listado como risco a validar cedo no CI).
@DriftDatabase(tables: [WorkItems, WorkItemEvents, Enrichments, OutboxEntries, Rules, Queues])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // v1 -> v2: Fase 2 introduziu OutboxEntries. Instalações que só
        // viram a Fase 1 (schemaVersion 1, sem essa tabela) precisam
        // dessa migração — sem ela, o insert no outbox falha com
        // "no such table: outbox_entries" na primeira tentativa de
        // marcar como lido/favoritar depois do upgrade.
        if (from < 2) {
          await m.createTable(outboxEntries);
        }
        // v2 -> v3: busca full-text local via FTS5 (work_items_fts) — ver
        // [_migrateV2toV3] para o backfill.
        if (from < 3) {
          await _migrateV2toV3(m);
        }
        // v3 -> v4: motor de regras (Fase 3) introduziu a tabela Rules.
        if (from < 4) {
          await m.createTable(rules);
        }
        // v4 -> v5: filas customizadas (Onda 2/WS-9) introduziu a tabela Queues.
        if (from < 5) {
          await m.createTable(queues);
        }
        // v5 -> v6: gatilho de schedule (RuleScheduler) introduziu
        // intervalMinutes/lastRunAt em Rules.
        if (from < 6) {
          await m.addColumn(rules, rules.intervalMinutes);
          await m.addColumn(rules, rules.lastRunAt);
        }
      },
      // `beforeOpen` é aguardado internamente pelo drift antes de processar
      // qualquer query do chamador (sequenciado após onCreate/onUpgrade).
      // É aqui — e não no construtor — que garantimos a existência da
      // tabela virtual FTS5 e dos triggers de sincronização: um `Future`
      // disparado no construtor sem `await` ("fire-and-forget") corria em
      // paralelo com o primeiro INSERT/SELECT do chamador (ex.: o primeiro
      // insert de um teste), então a tabela/triggers às vezes ainda não
      // existiam quando o primeiro item era inserido — o índice FTS5 ficava
      // vazio e toda busca subsequente retornava nada. Usar `beforeOpen`
      // elimina essa condição de corrida, pois faz parte da sequência de
      // abertura que o drift garante rodar por completo antes de liberar o
      // banco para uso.
      beforeOpen: (details) async {
        await _ensureFtsSchemaObjects(customStatement);
      },
    );
  }

  /// Cria (idempotentemente) a tabela virtual FTS5 e os triggers de
  /// sincronização (`work_items_ai`/`_au`/`_ad`) usados para manter
  /// `work_items_fts` espelhando `work_items`.
  ///
  /// A coluna `tags_plaintext` é populada a partir de `new.tags_json`
  /// (JSON, ex.: `["a","b"]`) achatado em texto plano (`"a b"`) via
  /// `json_each` (função JSON1 nativa do SQLite — ver
  /// `test/fts5_validation_test.dart` para a validação de disponibilidade).
  /// Bug corrigido aqui: os triggers antigos gravavam o JSON bruto direto
  /// na coluna do FTS5 (`COALESCE(new.tags_json, '')`), então o índice
  /// indexava o texto literal `["a","b"]` (colchetes/aspas inclusos) em vez
  /// de tokens `a`/`b` — buscas por uma tag isolada nunca casavam.
  static Future<void> _ensureFtsSchemaObjects(
    Future<void> Function(String sql, [List<Object?>? args]) run,
  ) async {
    const tagsPlaintextExpr =
        "(SELECT COALESCE(GROUP_CONCAT(je.value, ' '), '') FROM json_each(COALESCE(new.tags_json, '[]')) je)";

    // CREATE TABLE IF NOT EXISTS não funciona com tabelas virtuais, mas
    // CREATE VIRTUAL TABLE IF NOT EXISTS sim.
    await run(
      '''
      CREATE VIRTUAL TABLE IF NOT EXISTS work_items_fts USING fts5(
        title,
        content,
        author,
        tags_plaintext
      )
      ''',
    );

    // Nota: Drift usa snake_case para nomes de colunas no SQLite (ex: tags_json).
    await run(
      '''
      CREATE TRIGGER IF NOT EXISTS work_items_ai AFTER INSERT ON work_items BEGIN
        INSERT INTO work_items_fts(rowid, title, content, author, tags_plaintext)
        VALUES (
          new.rowid,
          COALESCE(new.title, ''),
          COALESCE(new.content, ''),
          COALESCE(new.author, ''),
          $tagsPlaintextExpr
        );
      END
      ''',
    );

    await run(
      '''
      CREATE TRIGGER IF NOT EXISTS work_items_au AFTER UPDATE ON work_items BEGIN
        DELETE FROM work_items_fts WHERE rowid = old.rowid;
        INSERT INTO work_items_fts(rowid, title, content, author, tags_plaintext)
        VALUES (
          new.rowid,
          COALESCE(new.title, ''),
          COALESCE(new.content, ''),
          COALESCE(new.author, ''),
          $tagsPlaintextExpr
        );
      END
      ''',
    );

    await run(
      '''
      CREATE TRIGGER IF NOT EXISTS work_items_ad AFTER DELETE ON work_items BEGIN
        DELETE FROM work_items_fts WHERE rowid = old.rowid;
      END
      ''',
    );
  }

  /// Migração de schema v2 → v3: cria tabela virtual FTS5 para busca full-text
  /// e faz backfill dos dados já existentes em `work_items` (bancos novos não
  /// têm o que popular aqui). Os triggers em si — que mantêm o índice
  /// sincronizado dali em diante — são criados de forma idempotente por
  /// [_ensureFtsSchemaObjects], chamado a partir de `beforeOpen` logo depois
  /// desta migração (ver [migration]).
  static Future<void> _migrateV2toV3(Migrator m) async {
    // Cria a tabela virtual FTS5 antes do backfill (o backfill insere
    // diretamente nela).
    await _ensureFtsSchemaObjects(m.database.customStatement);

    // Popula o índice FTS5 com dados existentes da tabela work_items,
    // se houver. (Em um banco novo, work_items pode estar vazio — e nesse
    // caso onCreate é usado, não onUpgrade, então este método nem roda.)
    // O stripping de HTML é feito aqui no Dart, onde temos acesso aos
    // helpers. (Novos inserts via triggers não têm HTML strippado — TODO
    // para refatoração futura, ex.: adicionar coluna `content_stripped` à
    // tabela principal.)
    try {
      // Nota: a coluna real no SQLite e `tags_json` (snake_case) - ver
      // `database.g.dart` (`GeneratedColumn` usa o segundo argumento como
      // nome SQL). Usar o nome Dart camelCase aqui faria a query falhar
      // silenciosamente dentro do `try` (nenhum teste cobre este caminho:
      // testes em memoria sempre passam por `onCreate`, nunca por
      // `onUpgrade`/este backfill).
      final rows = await m.database
          .customSelect('SELECT rowid, title, content, author, tags_json FROM work_items')
          .get();

      for (final row in rows) {
        final rowid = row.data['rowid'] as int;
        final title = row.data['title'] as String? ?? '';
        final content = stripHtmlTags(row.data['content'] as String?);
        final author = row.data['author'] as String? ?? '';
        final tagsPlaintext = tagsJsonToPlaintext(row.data['tags_json'] as String? ?? '[]');

        await m.database.customStatement(
          'INSERT INTO work_items_fts(rowid, title, content, author, tags_plaintext) VALUES (?, ?, ?, ?, ?)',
          [rowid, title, content, author, tagsPlaintext],
        );
      }
    } catch (e) {
      // Se work_items não existe ou está vazio, ignora. Os triggers cuidarão
      // de sincronizar novos inserts a partir daqui.
    }
  }

  static QueryExecutor _openConnection() => openConnection();
}
