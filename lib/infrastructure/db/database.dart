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
@DriftDatabase(tables: [WorkItems, WorkItemEvents, Enrichments, OutboxEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'feedflow_workitems.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
