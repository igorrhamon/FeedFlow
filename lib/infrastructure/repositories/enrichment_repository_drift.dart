import 'package:drift/drift.dart';

import '../../domain/enrichment.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../db/database.dart';

class EnrichmentRepositoryDrift implements EnrichmentRepository {
  EnrichmentRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Enrichment>> watchByWorkItemId(String workItemId) {
    final query = _db.select(_db.enrichments)
      ..where((t) => t.workItemId.equals(workItemId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Enrichment?> byId(int id) async {
    final row =
        await (_db.select(_db.enrichments)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Enrichment>> listByWorkItemId(String workItemId) async {
    final rows = await (_db.select(_db.enrichments)
          ..where((t) => t.workItemId.equals(workItemId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Enrichment> insert(Enrichment enrichment) async {
    final id = await _db.into(_db.enrichments).insert(
          EnrichmentsCompanion.insert(
            workItemId: enrichment.workItemId,
            type: enrichment.type.name,
            content: enrichment.content,
            model: Value(enrichment.model),
            createdAt: enrichment.createdAt,
          ),
        );
    return enrichment.copyWith(id: id);
  }

  @override
  Future<int> deleteByWorkItemId(String workItemId,
      [EnrichmentType? type]) async {
    final query = _db.delete(_db.enrichments)
      ..where((t) => t.workItemId.equals(workItemId));
    if (type != null) {
      query.where((t) => t.type.equals(type.name));
    }
    return query.go();
  }

  @override
  Future<void> close() async {}

  Enrichment _toDomain(EnrichmentsRow row) => Enrichment(
        id: row.id,
        workItemId: row.workItemId,
        type: EnrichmentType.fromName(row.type),
        content: row.content,
        model: row.model,
        createdAt: row.createdAt,
      );
}
