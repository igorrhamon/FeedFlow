import '../domain/events/domain_event.dart';
import '../domain/repositories/work_item_repository.dart';
import 'event_bus.dart';

/// Tipos de evento que já têm sua própria gravação manual em
/// `WorkItemEvents` — `RuleEngine` grava `'ruleMatched'` e `WorkflowRunner`
/// grava `'workflowCompleted'` diretamente, com payload mais rico que o
/// genérico. O [JournalListener] pula esses tipos para não duplicar linha.
const _kManuallyJournaledTypes = {'ruleMatched', 'workflowCompleted'};

/// Assina o [EventBus] e persiste **todo** [DomainEvent] recebido em
/// `WorkItemEvents`, generalizando o padrão que antes só cobria eventos com
/// gravação manual explícita (WS-16, WS-15). Eventos sem `workItemId` (ex.:
/// [SyncCompleted]/[SyncFailed], que são globais por provider, não por item)
/// são gravados com `workItemId` vazio — ainda não há um identificador
/// genérico de execução de sync (isso chega na Onda 7, com `Document`).
class JournalListener {
  JournalListener({required WorkItemRepository workItemRepository})
      : _workItemRepository = workItemRepository;

  final WorkItemRepository _workItemRepository;

  Future<void> call(DomainEvent event) async {
    final type = _typeOf(event);
    if (type == null || _kManuallyJournaledTypes.contains(type)) {
      return;
    }

    await _workItemRepository.logEvent(
      _workItemIdOf(event),
      type: type,
      actor: 'system',
      payload: _payloadOf(event),
    );
  }

  String? _typeOf(DomainEvent event) {
    if (event is ArticleIngested) return 'articleIngested';
    if (event is StatusChanged) return 'statusChanged';
    if (event is ItemSnoozed) return 'snoozed';
    if (event is SnoozeExpired) return 'snoozeExpired';
    if (event is ActionExecuted) return 'actionExecuted';
    if (event is RuleMatched) return 'ruleMatched';
    if (event is EnrichmentCompleted) return 'enrichmentCompleted';
    if (event is EnrichmentFailed) return 'enrichmentFailed';
    if (event is WorkflowStepExecuted) return 'workflowStepExecuted';
    if (event is WorkflowCompleted) return 'workflowCompleted';
    if (event is SyncCompleted) return 'syncCompleted';
    if (event is SyncFailed) return 'syncFailed';
    return null;
  }

  String _workItemIdOf(DomainEvent event) {
    if (event is ArticleIngested) return event.workItemId;
    if (event is StatusChanged) return event.workItemId;
    if (event is ItemSnoozed) return event.workItemId;
    if (event is SnoozeExpired) return event.workItemId;
    if (event is ActionExecuted) return event.workItemId;
    if (event is RuleMatched) return event.workItemId;
    if (event is EnrichmentCompleted) return event.workItemId;
    if (event is EnrichmentFailed) return event.workItemId;
    if (event is WorkflowStepExecuted) return event.workItemId;
    if (event is WorkflowCompleted) return event.workItemId;
    // SyncCompleted/SyncFailed são globais por provider, não por item.
    return '';
  }

  Map<String, dynamic> _payloadOf(DomainEvent event) {
    if (event is ArticleIngested) {
      return {
        'providerId': event.providerId,
        'articleId': event.articleId,
        'feedId': event.feedId,
        'title': event.title,
      };
    }
    if (event is StatusChanged) {
      return {
        'fromStatus': event.fromStatus,
        'toStatus': event.toStatus,
        'actor': event.actor,
      };
    }
    if (event is ItemSnoozed) {
      return {
        'snoozedUntil': event.snoozedUntil.toIso8601String(),
        'actor': event.actor,
      };
    }
    if (event is SnoozeExpired) {
      return {};
    }
    if (event is ActionExecuted) {
      return {'actionId': event.actionId, 'params': event.params};
    }
    if (event is EnrichmentCompleted) {
      return {
        'enrichmentType': event.enrichmentType,
        'model': event.model,
        'tokensUsed': event.tokensUsed,
      };
    }
    if (event is EnrichmentFailed) {
      return {'enrichmentType': event.enrichmentType, 'error': event.error};
    }
    if (event is WorkflowStepExecuted) {
      return {
        'actionId': event.actionId,
        'stepIndex': event.stepIndex,
        'totalSteps': event.totalSteps,
        'success': event.success,
      };
    }
    if (event is SyncCompleted) {
      return {
        'providerId': event.providerId,
        'itemsIngested': event.itemsIngested,
        'itemsUpdated': event.itemsUpdated,
      };
    }
    if (event is SyncFailed) {
      return {'providerId': event.providerId, 'error': event.error};
    }
    return {};
  }
}

/// Inscreve um [JournalListener] no [bus] para persistir eventos em
/// [workItemRepository]. Chamado uma única vez por `DatabaseProvider`.
JournalListener initializeJournalListener({
  required EventBus bus,
  required WorkItemRepository workItemRepository,
}) {
  final listener = JournalListener(workItemRepository: workItemRepository);
  bus.subscribe(listener.call);
  return listener;
}
