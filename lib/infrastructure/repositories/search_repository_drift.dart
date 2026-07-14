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
  Future<List<WorkItem>> search(String query, {int limit = 50}) async {
    // Escapa a query para FTS5 MATCH (aspas duplas em torno para busca literal)
    final escapedQuery = query.trim();
    if (escapedQuery.isEmpty) {
      return [];
    }

    // Query SQL usa MATCH contra a tabela virtual FTS5 e join com work_items
    // para obter todos os dados necessários. Ordena por BM25 relevance.
    final results = await _db.customSelect(
      '''
      SELECT w.* FROM work_items w
      INNER JOIN work_items_fts fts ON w.rowid = fts.rowid
      WHERE work_items_fts MATCH ?
      ORDER BY bm25(work_items_fts) ASC
      LIMIT ?
      ''',
      variables: [Variable<String>(escapedQuery), Variable<int>(limit)],
      readsFrom: {_db.workItems},
    ).get();

    // Converte as rows para objetos WorkItem de domínio.
    //
    // Nota: `row.data` traz os valores *crus* do driver (ex.: um DateTime
    // vira um int de epoch, um bool vira 0/1) e as chaves são os nomes SQL
    // reais das colunas — snake_case (ex.: `provider_id`, `tags_json`), não
    // os nomes Dart camelCase dos getters do drift (`providerId`,
    // `tagsJson`). Por isso usamos `row.read<T>(...)`, que aplica a mesma
    // conversão de tipos (`typeMapping`) que o drift usa internamente em
    // queries tipadas, em vez de `row.data[...] as T` (que quebrava com
    // chave errada e/ou tipo cru errado).
    return results.map((row) {
      final id = row.read<String>('id');
      final providerId = row.read<String>('provider_id');
      final articleId = row.read<String>('article_id');
      final feedId = row.read<String>('feed_id');
      final title = row.read<String>('title');
      final author = row.read<String?>('author');
      final summary = row.read<String?>('summary');
      final content = row.read<String?>('content');
      final url = row.read<String?>('url');
      final published = row.read<DateTime?>('published');
      final updated = row.read<DateTime?>('updated');
      final status = row.read<String>('status');
      final priority = row.read<String>('priority');
      final tagsJson = row.read<String>('tags_json');
      final isRead = row.read<bool>('is_read');
      final isStarred = row.read<bool>('is_starred');
      final snoozedUntil = row.read<DateTime?>('snoozed_until');
      final notes = row.read<String?>('notes');
      final ingestedAt = row.read<DateTime>('ingested_at');
      final updatedAt = row.read<DateTime>('updated_at');
      final completedAt = row.read<DateTime?>('completed_at');

      final tags = (jsonDecode(tagsJson) as List).cast<String>();

      return WorkItem(
        id: id,
        providerId: providerId,
        articleId: articleId,
        feedId: feedId,
        title: title,
        author: author,
        summary: summary,
        content: content,
        url: url,
        published: published,
        updated: updated,
        status: TriageStatus.fromName(status),
        priority: Priority.fromName(priority),
        tags: tags,
        isRead: isRead,
        isStarred: isStarred,
        snoozedUntil: snoozedUntil,
        notes: notes,
        ingestedAt: ingestedAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
      );
    }).toList();
  }
}
