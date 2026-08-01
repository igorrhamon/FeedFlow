import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/note.dart';
import '../../domain/repositories/knowledge_base_repository.dart';
import '../db/database.dart';

/// Implementação Drift de [KnowledgeBaseRepository] — persistência de [Note]s
/// na tabela `Documents` (Onda 8). Uma `Note` é um `Document` com
/// `sourceConnectorId == 'local-note'`, permitindo que notas sejam indexadas,
/// versionadas e buscadas junto com conteúdo ingerido de outras fontes.
class KnowledgeBaseRepositoryDrift implements KnowledgeBaseRepository {
  KnowledgeBaseRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<Note> createNote(Note note) async {
    final now = DateTime.now();
    await _db.into(_db.documents).insert(
          DocumentsCompanion.insert(
            id: note.id,
            sourceConnectorId: 'local-note',
            sourceId: note.id,
            contentType: 'text/markdown',
            title: note.title,
            author: Value(note.author),
            rawContent: Value(note.content),
            capturedAt: now,
            metadataJson: Value(jsonEncode({
              'workItemId': note.workItemId,
              'tags': note.tags,
            })),
          ),
        );
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    await (_db.update(_db.documents)..where((d) => d.id.equals(note.id))).write(
      DocumentsCompanion(
        title: Value(note.title),
        rawContent: Value(note.content),
        author: Value(note.author),
        metadataJson: Value(jsonEncode({
          if (note.workItemId != null) 'workItemId': note.workItemId,
          'tags': note.tags,
        })),
      ),
    );
    return note;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await (_db.delete(_db.documents)..where((d) => d.id.equals(noteId))).go();
  }

  @override
  Future<Note?> byId(String noteId) async {
    final row = await (_db.select(_db.documents)
          ..where((d) => d.id.equals(noteId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<List<Note>> watchAll() {
    return (_db.select(_db.documents)
          ..where((d) => d.sourceConnectorId.equals('local-note'))
          ..orderBy([(d) => OrderingTerm.desc(d.capturedAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Note>> watchByWorkItem(String workItemId) {
    return (_db.select(_db.documents)
          ..where((d) =>
              d.sourceConnectorId.equals('local-note') &
              d.metadataJson.like('%$workItemId%'))
          ..orderBy([(d) => OrderingTerm.desc(d.capturedAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Note>> search(String query) {
    final escaped = query.replaceAll("'", "''");
    return (_db.select(_db.documents)
          ..where((d) =>
              d.sourceConnectorId.equals('local-note') &
              (d.title.like('%$escaped%') |
                  d.rawContent.like('%$escaped%')))
          ..orderBy([(d) => OrderingTerm.desc(d.capturedAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Note>> history(String documentId) async {
    final docRows = await (_db.select(_db.documents)
          ..where((d) => d.sourceConnectorId.equals('local-note') &
              d.id.equals(documentId)))
        .get();
    if (docRows.isEmpty) return [];
    return docRows.map(_toDomain).toList();
  }

  @override
  Future<void> attachFile(String documentId, String filePath, String fileName) async {
    await _db.into(_db.documents).insert(
          DocumentsCompanion.insert(
            id: '${documentId}:attachment:${DateTime.now().millisecondsSinceEpoch}',
            sourceConnectorId: 'local-note',
            sourceId: documentId,
            contentType: 'application/octet-stream',
            title: fileName,
            rawContent: Value(filePath),
            capturedAt: DateTime.now(),
            metadataJson: Value(jsonEncode({'attachedTo': documentId})),
          ),
        );
  }

  @override
  Future<void> close() => _db.close();

  Note _toDomain(DocumentRow row) {
    final metadata = jsonDecode(row.metadataJson ?? '{}') as Map<String, dynamic>;
    return Note(
      id: row.id,
      documentId: row.id,
      title: row.title,
      content: row.rawContent ?? '',
      author: row.author,
      workItemId: metadata['workItemId'] as String?,
      tags: (metadata['tags'] as List?)?.cast<String>() ?? [],
      createdAt: row.capturedAt,
      updatedAt: row.capturedAt,
    );
  }
}
