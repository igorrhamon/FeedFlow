import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

/// Banco local do FeedFlow (fonte de verdade dos [WorkItem]s e da trilha de
/// eventos/enriquecimentos). Suporte nativo (Android/iOS/desktop) apenas
/// nesta fase — web/WASM fica para uma iteração futura (ver EVOLUTION-PLAN,
/// Fase 1: "web via WASM/OPFS" listado como risco a validar cedo no CI).
@DriftDatabase(tables: [WorkItems, WorkItemEvents, Enrichments, OutboxEntries, Rules])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Também cria a tabela virtual FTS5 no novo banco
          await _createFts5Index(m);
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2: Fase 2 introduziu OutboxEntries. Instalações que só
          // viram a Fase 1 (schemaVersion 1, sem essa tabela) precisam
          // dessa migração — sem ela, o insert no outbox falha com
          // "no such table: outbox_entries" na primeira tentativa de
          // marcar como lido/favoritar depois do upgrade.
          if (from < 2) {
            await m.createTable(outboxEntries);
          }
          // v2 -> v3: motor de regras (Fase 3) introduziu a tabela Rules.
          if (from < 3) {
            await m.createTable(rules);
          }
          // v3 -> v4: Busca full-text local (FTS5). Cria tabela virtual
          // work_items_fts indexando title, content, author, tagsPlaintext
          // (tags separadas por espaço para indexação). Sincroniza via
          // triggers SQL (AFTER INSERT/UPDATE/DELETE em WorkItems).
          if (from < 4) {
            await _createFts5Index(m);
          }
        },
      );

  /// Cria a tabela virtual FTS5 e triggers para sincronização.
  static Future<void> _createFts5Index(Migrator m) async {
    // Tabela virtual FTS5 com tokenizer padrão (Whitespace),
    // columns: title, content, author, tags_plaintext
    await m.customStatement(
      '''CREATE VIRTUAL TABLE IF NOT EXISTS work_items_fts
         USING fts5(
           title,
           content,
           author,
           tags_plaintext,
           content=work_items,
           content_rowid=rowid
         )''',
    );

    // AFTER INSERT trigger: popula FTS quando um WorkItem é inserido
    await m.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS work_items_ai AFTER INSERT ON work_items BEGIN
           INSERT INTO work_items_fts(rowid, title, content, author, tags_plaintext)
           VALUES (new.rowid, new.title, new.content, new.author, new.tags_json);
         END''',
    );

    // AFTER UPDATE trigger: atualiza FTS quando um WorkItem é atualizado
    await m.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS work_items_au AFTER UPDATE ON work_items BEGIN
           UPDATE work_items_fts
           SET title = new.title, content = new.content, author = new.author, tags_plaintext = new.tags_json
           WHERE rowid = new.rowid;
         END''',
    );

    // AFTER DELETE trigger: remove da FTS quando um WorkItem é deletado
    await m.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS work_items_ad AFTER DELETE ON work_items BEGIN
           DELETE FROM work_items_fts WHERE rowid = old.rowid;
         END''',
    );
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'feedflow_workitems.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
