import '../../application/event_bus.dart';
import '../../domain/events/domain_event.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../../domain/triage_status.dart';
import '../../domain/work_item.dart';
import '../../models/article.dart';

/// Decorator sobre [WorkItemRepository] que publica eventos de domínio
/// para cada mutação. Adotado como padrão no `DatabaseProvider` para garantir
/// que todo acessso ao repositório (direto ou indireto) publica eventos para
/// o [RuleEngine] e outros listeners.
///
/// Implementação: delega todas as chamadas ao repositório subjacente
/// (`_delegate`) e, adicionalmente, publica eventos:
/// - [ArticleIngested] após [upsertFromArticles] bem-sucedido
/// - [StatusChanged] após [changeStatus] bem-sucedido
class EventEmittingWorkItemRepository implements WorkItemRepository {
  EventEmittingWorkItemRepository(
    WorkItemRepository delegate,
    EventBus eventBus,
  )   : _delegate = delegate,
        _eventBus = eventBus;

  final WorkItemRepository _delegate;
  final EventBus _eventBus;

  @override
  Stream<List<WorkItem>> watchByStatus(List<TriageStatus> statuses) {
    return _delegate.watchByStatus(statuses);
  }

  @override
  Stream<int> watchCountByStatus(TriageStatus status) {
    return _delegate.watchCountByStatus(status);
  }

  @override
  Future<WorkItem?> byId(String id) {
    return _delegate.byId(id);
  }

  @override
  Future<void> upsertFromArticles(List<Article> articles, String providerId) async {
    await _delegate.upsertFromArticles(articles, providerId);

    // Publica evento de ingestão para cada artigo
    final now = DateTime.now();
    for (final article in articles) {
      _eventBus.publish(
        ArticleIngested(
          workItemId: '$providerId:${article.id}',
          providerId: providerId,
          articleId: article.id,
          feedId: article.feedId,
          title: article.title,
          timestamp: now,
        ),
      );
    }
  }

  @override
  Future<void> save(WorkItem item) {
    return _delegate.save(item);
  }

  @override
  Future<void> changeStatus(String id, TriageStatus newStatus) async {
    // Obtém o item antes da mudança para saber o status anterior
    final current = await _delegate.byId(id);
    if (current == null) {
      throw StateError('WorkItem não encontrado: $id');
    }

    final oldStatus = current.status;
    await _delegate.changeStatus(id, newStatus);

    // Publica evento de mudança de status
    _eventBus.publish(
      StatusChanged(
        workItemId: id,
        fromStatus: oldStatus.name,
        toStatus: newStatus.name,
        actor: 'user', // Mudanças via repositório são assumidas como do usuário
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<int> purgeOlderThan(DateTime cutoff, {List<TriageStatus>? statuses}) {
    return _delegate.purgeOlderThan(cutoff, statuses: statuses);
  }

  @override
  Future<void> close() {
    return _delegate.close();
  }

  @override
  Stream<List<WorkItem>> watchByFeedId(String feedId, {List<TriageStatus>? statuses}) {
    return _delegate.watchByFeedId(feedId, statuses: statuses);
  }

  @override
  Stream<List<WorkItem>> watchStarred() {
    return _delegate.watchStarred();
  }

  @override
  Stream<Map<String, int>> watchUnreadCountsByFeed() {
    return _delegate.watchUnreadCountsByFeed();
  }
}
