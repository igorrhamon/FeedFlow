import '../domain/repositories/rule_repository.dart';
import '../domain/repositories/work_item_event_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';

/// Ações cujo efeito é revertido por [RuleUndoUseCase]. Demais `actionId`s
/// (side-effects externos como `webhook`/`notionExport`/`obsidianExport`/
/// `share`/`copyLink`, ou enriquecimentos de LLM como `summarize`/
/// `translate`/`classify`) nunca são revertidos — são side-effects já
/// disparados/consumidos. `snooze` também não é suportado nesta primeira
/// versão: `SnoozeUseCase` ainda não persiste evento algum em
/// `WorkItemEvents`, então não há `snoozedUntil` anterior a restaurar.
const _kReversibleActionIds = {'addTag', 'archive', 'complete', 'toggleStar'};

/// Motivo pelo qual uma ação individual não foi (ou não pôde ser) desfeita.
enum ActionUndoSkipReason {
  irreversibleAction,
  ruleDeletedCannotResolveParams,
  invalidReverseTransition,
  actionFailedOriginally,
}

class ActionUndoSkip {
  const ActionUndoSkip({required this.actionId, required this.reason});

  final String actionId;
  final ActionUndoSkipReason reason;
}

/// Motivo pelo qual um `WorkItem` inteiro foi pulado (nenhum campo revertido).
enum WorkItemUndoSkipReason {
  workItemNotFound,
  modifiedAfterMatch,
}

/// Resultado da tentativa de reversão de um `ruleMatched` específico.
class WorkItemUndoOutcome {
  const WorkItemUndoOutcome({
    required this.workItemId,
    required this.matchedAt,
    this.fieldsReverted = const [],
    this.actionsSkipped = const [],
    this.skipReason,
  });

  final String workItemId;
  final DateTime matchedAt;

  /// Campos de fato revertidos neste item (ex.: `['status', 'isStarred']`).
  final List<String> fieldsReverted;

  /// Ações que não puderam ser revertidas, com o motivo.
  final List<ActionUndoSkip> actionsSkipped;

  /// Preenchido apenas quando o item inteiro foi pulado (nenhuma reversão
  /// tentada) — guarda de segurança ou item não encontrado.
  final WorkItemUndoSkipReason? skipReason;
}

class RuleUndoResult {
  const RuleUndoResult({
    required this.ruleId,
    required this.matchesFound,
    this.reverted = const [],
    this.skipped = const [],
  });

  final String ruleId;

  /// Total de eventos `ruleMatched` dessa regra encontrados na janela.
  final int matchesFound;

  /// Itens onde pelo menos uma reversão foi tentada (mesmo que parcial).
  final List<WorkItemUndoOutcome> reverted;

  /// Itens pulados por completo (guarda de segurança / não encontrado).
  final List<WorkItemUndoOutcome> skipped;
}

/// Desfaz o efeito de uma regra de automação dentro de uma janela de tempo
/// (padrão: últimas 24h), lendo a trilha persistida em `WorkItemEvents`
/// (ver `RuleEngine`, que grava `type: 'ruleMatched'` após executar as ações
/// de uma regra que casou).
///
/// Reversão é best-effort e conservadora: nunca sobrescreve uma mudança
/// feita depois do match (ver [WorkItemUndoSkipReason.modifiedAfterMatch]),
/// e ações sem efeito reversível conhecido são reportadas, não ignoradas
/// silenciosamente.
class RuleUndoUseCase {
  RuleUndoUseCase({
    required WorkItemRepository workItemRepository,
    required WorkItemEventRepository eventRepository,
    required RuleRepository ruleRepository,
  })  : _workItemRepository = workItemRepository,
        _eventRepository = eventRepository,
        _ruleRepository = ruleRepository;

  final WorkItemRepository _workItemRepository;
  final WorkItemEventRepository _eventRepository;
  final RuleRepository _ruleRepository;

  /// Tolerância entre `matchedAt` e `item.updatedAt` para ainda considerar
  /// "nada mudou depois do match". O drift armazena `DateTime` com precisão
  /// de segundos (trunca sub-segundo), então dois timestamps a poucos ms um
  /// do outro podem cair em segundos inteiros diferentes após o round-trip
  /// pelo banco — sem essa folga, uma mudança causada pela própria regra
  /// (ex.: `changeStatus` seguido do `logEvent` do match, na mesma cadeia de
  /// `await`) poderia ser confundida com uma edição posterior.
  static const _kSafetyTolerance = Duration(seconds: 2);

  Future<RuleUndoResult> undoRule(String ruleId, {Duration window = const Duration(hours: 24)}) async {
    final cutoff = DateTime.now().subtract(window);
    final allMatches = await _eventRepository.findSince(cutoff, type: 'ruleMatched');
    final matches = allMatches.where((log) => log.payload['ruleId'] == ruleId).toList();

    // Só o match mais recente por workItemId dentro da janela — evita
    // reverter aplicações já sobrepostas por uma mais nova da mesma regra.
    final latestByWorkItem = <String, WorkItemEventLog>{};
    for (final log in matches) {
      final current = latestByWorkItem[log.workItemId];
      if (current == null || log.timestamp.isAfter(current.timestamp)) {
        latestByWorkItem[log.workItemId] = log;
      }
    }

    final rule = await _ruleRepository.byId(ruleId);

    final reverted = <WorkItemUndoOutcome>[];
    final skipped = <WorkItemUndoOutcome>[];

    for (final log in latestByWorkItem.values) {
      final outcome = await _undoOne(log, rule);
      if (outcome.skipReason != null) {
        skipped.add(outcome);
      } else {
        reverted.add(outcome);
      }
    }

    return RuleUndoResult(
      ruleId: ruleId,
      matchesFound: matches.length,
      reverted: reverted,
      skipped: skipped,
    );
  }

  Future<WorkItemUndoOutcome> _undoOne(WorkItemEventLog log, Rule? rule) async {
    final item = await _workItemRepository.byId(log.workItemId);
    if (item == null) {
      return WorkItemUndoOutcome(
        workItemId: log.workItemId,
        matchedAt: log.timestamp,
        skipReason: WorkItemUndoSkipReason.workItemNotFound,
      );
    }

    if (item.updatedAt.isAfter(log.timestamp.add(_kSafetyTolerance))) {
      return WorkItemUndoOutcome(
        workItemId: log.workItemId,
        matchedAt: log.timestamp,
        skipReason: WorkItemUndoSkipReason.modifiedAfterMatch,
      );
    }

    final before = (log.payload['before'] as Map?)?.cast<String, dynamic>() ?? const {};
    final actionIds = (log.payload['actionIds'] as List?)?.cast<String>() ?? const [];
    final actionResultsRaw = (log.payload['actionResults'] as List?) ?? const [];
    final successByActionId = <String, bool>{
      for (final r in actionResultsRaw)
        (r as Map)['actionId'] as String: r['success'] as bool,
    };

    final fieldsReverted = <String>[];
    final actionsSkipped = <ActionUndoSkip>[];

    for (final actionId in actionIds) {
      if (successByActionId[actionId] != true) {
        actionsSkipped.add(
          ActionUndoSkip(actionId: actionId, reason: ActionUndoSkipReason.actionFailedOriginally),
        );
        continue;
      }

      if (!_kReversibleActionIds.contains(actionId)) {
        actionsSkipped.add(
          ActionUndoSkip(actionId: actionId, reason: ActionUndoSkipReason.irreversibleAction),
        );
        continue;
      }

      switch (actionId) {
        case 'archive':
        case 'complete':
          final beforeStatus = TriageStatus.fromName(before['status'] as String? ?? 'novo');
          if (!isValidTriageTransition(item.status, beforeStatus)) {
            actionsSkipped.add(
              ActionUndoSkip(
                actionId: actionId,
                reason: ActionUndoSkipReason.invalidReverseTransition,
              ),
            );
            break;
          }
          await _workItemRepository.changeStatus(item.id, beforeStatus);
          fieldsReverted.add('status');
          break;

        case 'toggleStar':
          final beforeStarred = before['isStarred'] as bool? ?? item.isStarred;
          await _workItemRepository.save(item.copyWith(isStarred: beforeStarred));
          fieldsReverted.add('isStarred');
          break;

        case 'addTag':
          if (rule == null) {
            actionsSkipped.add(
              ActionUndoSkip(
                actionId: actionId,
                reason: ActionUndoSkipReason.ruleDeletedCannotResolveParams,
              ),
            );
            break;
          }
          final tag = _resolveAddTagParam(rule, actionId);
          if (tag == null) {
            actionsSkipped.add(
              ActionUndoSkip(
                actionId: actionId,
                reason: ActionUndoSkipReason.ruleDeletedCannotResolveParams,
              ),
            );
            break;
          }
          if (item.tags.contains(tag)) {
            final updatedTags = item.tags.where((t) => t != tag).toList();
            await _workItemRepository.save(item.copyWith(tags: updatedTags));
            fieldsReverted.add('tags');
          }
          break;
      }
    }

    return WorkItemUndoOutcome(
      workItemId: log.workItemId,
      matchedAt: log.timestamp,
      fieldsReverted: fieldsReverted,
      actionsSkipped: actionsSkipped,
    );
  }

  String? _resolveAddTagParam(Rule rule, String actionId) {
    for (final invocation in rule.actions) {
      if (invocation.actionId == actionId) {
        return invocation.params['tag'] as String?;
      }
    }
    return null;
  }
}
