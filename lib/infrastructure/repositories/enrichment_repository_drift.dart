import 'package:drift/drift.dart';

import '../../domain/enrichment.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../db/database.dart';

class EnrichmentRepositoryDrift implements EnrichmentRepository {
  EnrichmentRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<void> create(Enrichment enrichment) async {
    await _db.into(_db.enrichments).insert(
          EnrichmentsCompanion(
            workItemId: Value(enrichment.workItemId),
            type: Value(enrichment.type.name),
            content: Value(enrichment.content),
            model: Value(enrichment.model),
            createdAt: Value(enrichment.createdAt),
          ),
          mode: InsertMode.insert,
        );
  }

  @override
  Future<List<Enrichment>> byWorkItemId(String workItemId) async {
    final rows = await (_db.select(_db.enrichments)
          ..where((t) => t.workItemId.equals(workItemId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.enrichments)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.enrichments).go();
  }

  @override
  Future<void> close() async {
    await _db.close();
  }

  Enrichment _toDomain(EnrichmentsData row) {
    final typeStr = row.type;
    final type = EnrichmentType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => EnrichmentType.summary,
    );

    return Enrichment(
      id: row.id,
      workItemId: row.workItemId,
      type: type,
      content: row.content,
      model: row.model,
      createdAt: row.createdAt,
    );
  }
}
