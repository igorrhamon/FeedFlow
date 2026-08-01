import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/note.dart';
import '../db/database.dart';

/// Repositório de histórico de versões de [Document]s (Onda 8).
/// Mantém um append-only log de snapshots de conteúdo, permitindo
/// visualizar e restaurar versões antigas de uma nota.
class DocumentVersionRepositoryDrift {
  DocumentVersionRepositoryDrift(this._db);

  final AppDatabase _db;

  /// Retorna todas as versões (histórico) de um documento.
  Future<List<Note>> history(String documentId) async {
    final rows = await (_db.select(_db.documentVersions)
          ..where((v) => v.documentId.equals(documentId))
          ..orderBy([(v) => OrderingTerm.desc(v.createdAt)]))
        .get();
    return rows.map((row) => Note(
          id: row.id.toString(),
          documentId: row.documentId,
          title: '',
          content: row.contentSnapshot,
          createdAt: row.createdAt,
          updatedAt: row.createdAt,
        )).toList();
  }

  /// Cria uma nova versão (snapshot) de um documento.
  Future<void> addVersion(String documentId, String contentSnapshot,
      {String? changeNote}) async {
    await _db.into(_db.documentVersions).insert(
          DocumentVersionsCompanion.insert(
            documentId: documentId,
            contentSnapshot: contentSnapshot,
            createdAt: DateTime.now(),
            changeNote: Value(changeNote),
          ),
        );
  }

  Future<void> close() => _db.close();
}
