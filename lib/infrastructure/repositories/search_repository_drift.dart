import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/repositories/search_repository.dart';
import '../../domain/triage_status.dart';
import '../../domain/work_item.dart';
import '../db/database.dart';

class SearchRepositoryDrift implements SearchRepository {
  SearchRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<List<WorkItem>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Query FTS5 com BM25 ranking: busca em title, content, author, tags_plaintext
      // Retorna rowids ordenados por relevância
      final results = await _db.customSelect(
        '''
        SELECT w.* FROM work_items w
        WHERE w.rowid IN (
          SELECT rowid FROM work_items_fts
          WHERE work_items_fts MATCH ?
          ORDER BY bm25(work_items_fts)
        )
        ORDER BY (
          SELECT bm25(work_items_fts)
          FROM work_items_fts
          WHERE work_items_fts.rowid = w.rowid
        )
        ''',
        variables: [query],
      ).get();

      // Converte rows para WorkItem domain objects
      return results
          .map((row) => _rowToWorkItem(row))
          .toList();
    } catch (e) {
      // Se FTS5 não estiver disponível (shouldn't happen, mas precavido)
      return [];
    }
  }

  /// Converte uma linha da query customizada para um [WorkItem] domain object.
  WorkItem _rowToWorkItem(QueryRow row) {
    final tagsJson = row.read<String>('tags_json') ?? '[]';
    final tags = (jsonDecode(tagsJson) as List).cast<String>();
    return WorkItem(
      id: row.read('id'),
      providerId: row.read('provider_id'),
      articleId: row.read('article_id'),
      feedId: row.read('feed_id'),
      title: row.read('title'),
      author: row.read('author'),
      summary: row.read('summary'),
      content: row.read('content'),
      url: row.read('url'),
      published: row.read('published'),
      updated: row.read('updated'),
      status: TriageStatus.fromName(row.read('status')),
      priority: Priority.fromName(row.read('priority')),
      tags: tags,
      isRead: row.read('is_read'),
      isStarred: row.read('is_starred'),
      snoozedUntil: row.read('snoozed_until'),
      notes: row.read('notes'),
      ingestedAt: row.read('ingested_at'),
      updatedAt: row.read('updated_at'),
      completedAt: row.read('completed_at'),
    );
  }
}
