import '../domain/outbox_entry.dart';
import '../domain/repositories/outbox_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/work_item.dart';
import '../models/article.dart';
import '../providers/feed_provider.dart';

/// Orquestra ingestão local e mutações read/star através do outbox — a
/// única seam entre a UI e a persistência local (Fase 2 do plano de
/// evolução: docs/EVOLUTION-PLAN.md).
///
/// Filosofia local-first: `markAsRead`/`star`/`unstar` aplicam a mudança no
/// [WorkItemRepository] imediatamente (otimista) e enfileiram no
/// [OutboxRepository]; a tentativa de push ao provider remoto acontece em
/// seguida, mas uma falha de rede NÃO desfaz o estado local nem propaga erro
/// para a UI — a entrada fica pendente para [flushOutbox] tentar de novo
/// depois. Isso substitui o rollback manual que existia antes em
/// `feed_articles_page.dart`.
class SyncService {
  SyncService({
    required WorkItemRepository workItemRepository,
    required OutboxRepository outboxRepository,
  })  : _workItems = workItemRepository,
        _outbox = outboxRepository;

  final WorkItemRepository _workItems;
  final OutboxRepository _outbox;

  /// Ingestão: grava/atualiza os [WorkItem]s a partir de artigos recém
  /// carregados de um provider (shadow-write da Fase 1, agora centralizado
  /// aqui em vez de chamado diretamente pela página).
  Future<void> ingest(List<Article> articles, String providerId) {
    return _workItems.upsertFromArticles(articles, providerId);
  }

  Future<void> markAsRead(FeedProvider provider, String providerId, String articleId) =>
      _applyReadState(provider, providerId, articleId, read: true);

  Future<void> markAsUnread(FeedProvider provider, String providerId, String articleId) =>
      _applyReadState(provider, providerId, articleId, read: false);

  Future<void> star(FeedProvider provider, String providerId, String articleId) =>
      _applyStarState(provider, providerId, articleId, starred: true);

  Future<void> unstar(FeedProvider provider, String providerId, String articleId) =>
      _applyStarState(provider, providerId, articleId, starred: false);

  Future<void> _applyReadState(
    FeedProvider provider,
    String providerId,
    String articleId, {
    required bool read,
  }) async {
    final id = workItemIdFor(providerId, articleId);
    await _updateLocal(id, (item) => item.copyWith(isRead: read, updatedAt: DateTime.now()));
    final action = read ? OutboxAction.markRead : OutboxAction.markUnread;
    final entryId = await _outbox.enqueue(workItemId: id, articleId: articleId, action: action);
    await _pushOne(provider, entryId, action, articleId);
  }

  Future<void> _applyStarState(
    FeedProvider provider,
    String providerId,
    String articleId, {
    required bool starred,
  }) async {
    final id = workItemIdFor(providerId, articleId);
    await _updateLocal(id, (item) => item.copyWith(isStarred: starred, updatedAt: DateTime.now()));
    final action = starred ? OutboxAction.star : OutboxAction.unstar;
    final entryId = await _outbox.enqueue(workItemId: id, articleId: articleId, action: action);
    await _pushOne(provider, entryId, action, articleId);
  }

  Future<void> _updateLocal(String id, WorkItem Function(WorkItem) update) async {
    final current = await _workItems.byId(id);
    if (current == null) return;
    await _workItems.save(update(current));
  }

  Future<void> _pushOne(FeedProvider provider, int entryId, OutboxAction action, String articleId) async {
    try {
      switch (action) {
        case OutboxAction.markRead:
          await provider.markAsRead(articleId);
        case OutboxAction.markUnread:
          await provider.markAsUnread(articleId);
        case OutboxAction.star:
          await provider.starArticle(articleId);
        case OutboxAction.unstar:
          await provider.unstarArticle(articleId);
      }
      await _outbox.remove(entryId);
    } catch (e) {
      await _outbox.recordFailure(entryId, e.toString());
    }
  }

  /// Tenta reenviar todas as entradas pendentes do outbox — chamar
  /// oportunisticamente (ex.: ao abrir uma tela, ou quando a rede volta).
  Future<void> flushOutbox(FeedProvider provider) async {
    final entries = await _outbox.pending();
    for (final entry in entries) {
      await _pushOne(provider, entry.id, entry.action, entry.articleId);
    }
  }
}
