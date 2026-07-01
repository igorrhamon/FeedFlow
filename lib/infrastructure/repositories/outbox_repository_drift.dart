import 'package:drift/drift.dart';

import '../../domain/outbox_entry.dart';
import '../../domain/repositories/outbox_repository.dart';
import '../db/database.dart';

class OutboxRepositoryDrift implements OutboxRepository {
  OutboxRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<int> enqueue({
    required String workItemId,
    required String articleId,
    required OutboxAction action,
  }) {
    return _db.into(_db.outboxEntries).insert(
          OutboxEntriesCompanion.insert(
            workItemId: workItemId,
            articleId: articleId,
            action: action.name,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<List<OutboxEntry>> pending() async {
    final rows = await (_db.select(_db.outboxEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> remove(int id) => (_db.delete(_db.outboxEntries)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> recordFailure(int id, String error) async {
    final row = await (_db.select(_db.outboxEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(id))).write(
      OutboxEntriesCompanion(
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  OutboxEntry _toDomain(OutboxEntryRow row) {
    return OutboxEntry(
      id: row.id,
      workItemId: row.workItemId,
      articleId: row.articleId,
      action: OutboxAction.fromName(row.action),
      createdAt: row.createdAt,
      attempts: row.attempts,
      lastError: row.lastError,
    );
  }
}
