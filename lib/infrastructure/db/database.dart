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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
          // v2 -> v3: motor de regras (Fase 3) introduziu a tabela Rules.
          if (from < 3) {
            await m.createTable(rules);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'feedflow_workitems.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
