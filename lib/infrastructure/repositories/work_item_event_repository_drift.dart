import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/repositories/work_item_event_repository.dart';
import '../db/database.dart';

class WorkItemEventRepositoryDrift implements WorkItemEventRepository {
  WorkItemEventRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<List<WorkItemEventLog>> findSince(DateTime since, {String? type}) async {
    final query = _db.select(_db.workItemEvents)
      ..where((t) => t.timestamp.isBiggerOrEqualValue(since));
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.timestamp)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  WorkItemEventLog _toDomain(WorkItemEvent row) => WorkItemEventLog(
        id: row.id,
        workItemId: row.workItemId,
        timestamp: row.timestamp,
        type: row.type,
        actor: row.actor,
        payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
      );
}
