import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/repositories/work_item_repository.dart';
import '../../domain/triage_status.dart';
import '../../domain/work_item.dart';
import '../../models/article.dart';
import '../db/database.dart';

class WorkItemRepositoryDrift implements WorkItemRepository {
  WorkItemRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Stream<List<WorkItem>> watchByStatus(List<TriageStatus> statuses) {
    final names = statuses.map((s) => s.name).toList();
    final query = _db.select(_db.workItems)
      ..where((t) => t.status.isIn(names))
      ..orderBy([(t) => OrderingTerm.desc(t.ingestedAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<int> watchCountByStatus(TriageStatus status) {
    final countExp = _db.workItems.id.count();
    final query = _db.selectOnly(_db.workItems)
      ..addColumns([countExp])
      ..where(_db.workItems.status.equals(status.name));
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<WorkItem?> byId(String id) async {
    final row = await (_db.select(_db.workItems)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> upsertFromArticles(List<Article> articles, String providerId) async {
    if (articles.isEmpty) return;
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final article in articles) {
        final id = workItemIdFor(providerId, article.id);
        batch.insert(
          _db.workItems,
          WorkItemsCompanion.insert(
            id: id,
            providerId: providerId,
            articleId: article.id,
            feedId: article.feedId,
            title: article.title,
            author: Value(article.author),
            summary: Value(article.summary),
            content: Value(article.content),
            url: Value(article.url),
            published: Value(article.published),
            updated: Value(article.updated),
            isRead: Value(article.isRead),
            isStarred: Value(article.isStarred),
            ingestedAt: now,
            updatedAt: now,
          ),
          // status/priority/tagsJson/snoozedUntil/notes/completedAt/
          // ingestedAt propositalmente omitidos do update: preservam o
          // valor existente (upsert nunca sobrescreve triagem local).
          onConflict: DoUpdate(
            (old) => WorkItemsCompanion(
              title: Value(article.title),
              author: Value(article.author),
              summary: Value(article.summary),
              content: Value(article.content),
              url: Value(article.url),
              published: Value(article.published),
              updated: Value(article.updated),
              isRead: Value(article.isRead),
              isStarred: Value(article.isStarred),
              updatedAt: Value(now),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<void> save(WorkItem item) async {
    await _db.into(_db.workItems).insertOnConflictUpdate(_toCompanion(item));
  }

  @override
  Future<void> changeStatus(String id, TriageStatus newStatus) async {
    final current = await byId(id);
    if (current == null) {
      throw StateError('WorkItem não encontrado: $id');
    }
    if (!isValidTriageTransition(current.status, newStatus)) {
      throw StateError('Transição inválida: ${current.status} -> $newStatus');
    }
    final now = DateTime.now();
    final isTerminal = newStatus == TriageStatus.concluido || newStatus == TriageStatus.arquivado;
    await (_db.update(_db.workItems)..where((t) => t.id.equals(id))).write(
      WorkItemsCompanion(
        status: Value(newStatus.name),
        updatedAt: Value(now),
        completedAt: isTerminal ? Value(current.completedAt ?? now) : const Value(null),
      ),
    );
    await _db.into(_db.workItemEvents).insert(
          WorkItemEventsCompanion.insert(
            workItemId: id,
            timestamp: now,
            type: 'statusChanged',
            actor: 'user',
            payloadJson: Value(jsonEncode({'from': current.status.name, 'to': newStatus.name})),
          ),
        );
  }

  @override
  Future<int> purgeOlderThan(DateTime cutoff, {List<TriageStatus>? statuses}) async {
    final targetStatuses = statuses ?? const [TriageStatus.concluido, TriageStatus.arquivado];
    final names = targetStatuses.map((s) => s.name).toList();
    return (_db.delete(_db.workItems)
          ..where((t) => t.status.isIn(names) & t.updatedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  @override
  Future<void> close() => _db.close();

  WorkItem _toDomain(WorkItemRow row) {
    final tags = (jsonDecode(row.tagsJson) as List).cast<String>();
    return WorkItem(
      id: row.id,
      providerId: row.providerId,
      articleId: row.articleId,
      feedId: row.feedId,
      title: row.title,
      author: row.author,
      summary: row.summary,
      content: row.content,
      url: row.url,
      published: row.published,
      updated: row.updated,
      status: TriageStatus.fromName(row.status),
      priority: Priority.fromName(row.priority),
      tags: tags,
      isRead: row.isRead,
      isStarred: row.isStarred,
      snoozedUntil: row.snoozedUntil,
      notes: row.notes,
      ingestedAt: row.ingestedAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  WorkItemsCompanion _toCompanion(WorkItem item) {
    return WorkItemsCompanion.insert(
      id: item.id,
      providerId: item.providerId,
      articleId: item.articleId,
      feedId: item.feedId,
      title: item.title,
      author: Value(item.author),
      summary: Value(item.summary),
      content: Value(item.content),
      url: Value(item.url),
      published: Value(item.published),
      updated: Value(item.updated),
      status: Value(item.status.name),
      priority: Value(item.priority.name),
      tagsJson: Value(jsonEncode(item.tags)),
      isRead: Value(item.isRead),
      isStarred: Value(item.isStarred),
      snoozedUntil: Value(item.snoozedUntil),
      notes: Value(item.notes),
      ingestedAt: item.ingestedAt,
      updatedAt: item.updatedAt,
      completedAt: Value(item.completedAt),
    );
  }
}
