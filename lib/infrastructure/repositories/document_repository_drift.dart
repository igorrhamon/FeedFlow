import 'package:drift/drift.dart';

import '../../domain/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../db/database.dart';

/// Implementação Drift de [DocumentRepository] — persistência de [Document]s
/// na tabela `Documents`.
class DocumentRepositoryDrift implements DocumentRepository {
  DocumentRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<void> upsertAll(List<Document> documents) async {
    for (final doc in documents) {
      await _db.into(_db.documents).insertOnConflictUpdate(
            DocumentsCompanion(
              id: Value(doc.id),
              sourceConnectorId: Value(doc.sourceConnectorId),
              sourceId: Value(doc.sourceId),
              contentType: Value(doc.contentType),
              title: Value(doc.title),
              author: Value(doc.author),
              rawContent: Value(doc.rawContent),
              url: Value(doc.url),
              capturedAt: Value(doc.capturedAt),
              metadataJson: Value(doc.metadataJson),
            ),
          );
    }
  }

  @override
  Future<Document?> byId(String id) async {
    final row = await (_db.select(_db.documents)
          ..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<List<Document>> watchAll({String? sourceConnectorId}) {
    final query = _db.select(_db.documents);
    if (sourceConnectorId != null) {
      query.where((d) => d.sourceConnectorId.equals(sourceConnectorId));
    }
    return (query..orderBy([(d) => OrderingTerm.desc(d.capturedAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();
  }

  @override
  Future<void> close() => _db.close();

  Document _toDomain(DocumentRow row) {
    return Document(
      id: row.id,
      sourceConnectorId: row.sourceConnectorId,
      sourceId: row.sourceId,
      contentType: row.contentType,
      title: row.title,
      author: row.author,
      rawContent: row.rawContent,
      url: row.url,
      capturedAt: row.capturedAt,
      metadataJson: row.metadataJson,
    );
  }
}
