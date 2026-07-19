import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/query_spec.dart';
import '../../domain/queue.dart';
import '../../domain/repositories/queue_repository.dart';
import '../db/database.dart';

class QueueRepositoryDrift implements QueueRepository {
  QueueRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<Queue?> byId(String id) async {
    final row = await (_db.select(_db.queues)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> create(Queue queue) async {
    await _db.into(_db.queues).insert(_toCompanion(queue));
  }

  @override
  Future<void> update(Queue queue) async {
    final success = await _db.update(_db.queues).replace(_toCompanion(queue));
    if (!success) {
      throw StateError('Queue não encontrada para atualização: ${queue.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.queues)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Queue>> list() async {
    final rows = await (_db.select(_db.queues)..orderBy([(t) => OrderingTerm.asc(t.order)])).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Queue>> watchAll() {
    final query = _db.select(_db.queues)..orderBy([(t) => OrderingTerm.asc(t.order)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.queues).go();
  }

  @override
  Future<void> close() async {
    await _db.close();
  }

  Queue _toDomain(QueueRow row) {
    return Queue(
      id: row.id,
      name: row.name,
      spec: QuerySpec.fromJson(jsonDecode(row.specJson) as Map<String, dynamic>),
      order: row.order,
      iconName: row.iconName,
    );
  }

  QueuesCompanion _toCompanion(Queue queue) {
    return QueuesCompanion(
      id: Value(queue.id),
      name: Value(queue.name),
      specJson: Value(jsonEncode(queue.spec.toJson())),
      order: Value(queue.order),
      iconName: Value(queue.iconName),
    );
  }
}
