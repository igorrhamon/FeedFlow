import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_event.freezed.dart';

/// Base abstrata para eventos de domínio — inspirada em Event Sourcing. Todos
/// os eventos carregam `timestamp` para trilha de auditoria.
abstract class DomainEvent {
  DateTime get timestamp;
}

/// Publicado quando um [Article] é ingerido do provider remoto e cria (ou
/// atualiza) um [WorkItem] local.
@freezed
class ArticleIngested with _$ArticleIngested implements DomainEvent {
  const ArticleIngested._();

  const factory ArticleIngested({
    required String workItemId,
    required String providerId,
    required String articleId,
    required String feedId,
    required String title,
    required DateTime timestamp,
  }) = _ArticleIngested;
}

/// Publicado quando o status de um [WorkItem] muda via [changeStatus].
@freezed
class StatusChanged with _$StatusChanged implements DomainEvent {
  const StatusChanged._();

  const factory StatusChanged({
    required String workItemId,
    required String fromStatus,
    required String toStatus,
    required String actor, // 'user', 'rule', 'sync'
    required DateTime timestamp,
  }) = _StatusChanged;
}

/// Publicado quando um item é adiado (snoozed).
@freezed
class ItemSnoozed with _$ItemSnoozed implements DomainEvent {
  const ItemSnoozed._();

  const factory ItemSnoozed({
    required String workItemId,
    required DateTime snoozedUntil,
    required String actor,
    required DateTime timestamp,
  }) = _ItemSnoozed;
}

/// Publicado quando um item acordado (snooze expirado) retorna às filas.
@freezed
class SnoozeExpired with _$SnoozeExpired implements DomainEvent {
  const SnoozeExpired._();

  const factory SnoozeExpired({
    required String workItemId,
    required DateTime timestamp,
  }) = _SnoozeExpired;
}

/// Publicado quando uma ação é executada. Execução real de ações é stubada
/// nesta rodada — apenas logs/auditoria.
@freezed
class ActionExecuted with _$ActionExecuted implements DomainEvent {
  const ActionExecuted._();

  const factory ActionExecuted({
    required String workItemId,
    required String actionId,
    required Map<String, dynamic> params,
    required DateTime timestamp,
  }) = _ActionExecuted;
}

/// Publicado pelo [RuleEngine] quando uma regra é avaliada e suas condições
/// casam com um item. Execução real da ação é stubada — apenas auditoria.
@freezed
class RuleMatched with _$RuleMatched implements DomainEvent {
  const RuleMatched._();

  const factory RuleMatched({
    required String ruleId,
    required String workItemId,
    required String ruleName,
    /// Identificador da primeira ação que seria executada (para undo futuro).
    required String? actionId,
    /// Payload para auditoria e undo (ex.: status anterior, tags antes/depois).
    required Map<String, dynamic> payload,
    required DateTime timestamp,
  }) = _RuleMatched;
}

/// Publicado quando enriquecimento (resumo, tradução, etc.) completa com sucesso.
@freezed
class EnrichmentCompleted with _$EnrichmentCompleted implements DomainEvent {
  const EnrichmentCompleted._();

  const factory EnrichmentCompleted({
    required String workItemId,
    required String enrichmentType, // 'summary', 'translation', 'classification', 'entities', 'suggestion'
    required String model,
    required int tokensUsed,
    required DateTime timestamp,
  }) = _EnrichmentCompleted;
}

/// Publicado quando enriquecimento falha.
@freezed
class EnrichmentFailed with _$EnrichmentFailed implements DomainEvent {
  const EnrichmentFailed._();

  const factory EnrichmentFailed({
    required String workItemId,
    required String enrichmentType,
    required String error,
    required DateTime timestamp,
  }) = _EnrichmentFailed;
}

/// Publicado ao fim de um ciclo de sincronização com sucesso.
@freezed
class SyncCompleted with _$SyncCompleted implements DomainEvent {
  const SyncCompleted._();

  const factory SyncCompleted({
    required String providerId,
    required int itemsIngested,
    required int itemsUpdated,
    required DateTime timestamp,
  }) = _SyncCompleted;
}

/// Publicado quando uma sincronização falha.
@freezed
class SyncFailed with _$SyncFailed implements DomainEvent {
  const SyncFailed._();

  const factory SyncFailed({
    required String providerId,
    required String error,
    required DateTime timestamp,
  }) = _SyncFailed;
}
