import 'dart:developer' as developer;

import '../domain/events/domain_event.dart';
import '../domain/repositories/rule_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
import 'condition_evaluator.dart';
import 'event_bus.dart';

/// Motor de avaliação de regras. Assina eventos de domínio (ArticleIngested,
/// StatusChanged) e, quando uma regra tem um gatilho que bate, avalia a árvore
/// de condições. Se todas casarem, publica um evento [RuleMatched] para
/// auditoria.
///
/// **Execução de ações é stubada nesta rodada** — apenas logs. Integração com
/// [ActionRegistry] vem em fase posterior (ver plano de evolução § Onda 3).
class RuleEngine {
  RuleEngine({
    required WorkItemRepository workItemRepository,
    required RuleRepository ruleRepository,
    required EventBus eventBus,
  })  : _workItemRepository = workItemRepository,
        _ruleRepository = ruleRepository,
        _eventBus = eventBus,
        _conditionEvaluator = ConditionEvaluator() {
    _initialize();
  }

  final WorkItemRepository _workItemRepository;
  final RuleRepository _ruleRepository;
  final EventBus _eventBus;
  final ConditionEvaluator _conditionEvaluator;

  void _initialize() {
    // Inscreve no event bus para reagir a eventos de domínio
    _eventBus.subscribe(_onEvent);
  }

  void _onEvent(DomainEvent event) async {
    // Filtra apenas eventos que trigram avaliação de regras
    final workItemId = _extractWorkItemId(event);
    final trigger = _extractTrigger(event);

    if (workItemId == null || trigger == null) {
      return; // Evento não requer avaliação de regra
    }

    // Busca as regras habilitadas
    final rules = await _ruleRepository.list();
    final enabledRules = rules.where((r) => r.enabled && r.trigger == trigger).toList();

    if (enabledRules.isEmpty) {
      return; // Nenhuma regra habilitada para este gatilho
    }

    // Busca o WorkItem para avaliar condições
    final workItem = await _workItemRepository.byId(workItemId);
    if (workItem == null) {
      developer.log('RuleEngine: WorkItem não encontrado: $workItemId',
          name: 'feedflow.rule_engine');
      return;
    }

    // Avalia regras em ordem
    for (final rule in enabledRules) {
      if (_conditionEvaluator.evaluate(rule.conditions, workItem)) {
        // Regra casa — publica evento de auditoria
        _eventBus.publish(
          RuleMatched(
            ruleId: rule.id,
            workItemId: workItemId,
            ruleName: rule.name,
            actionId: rule.actions.isNotEmpty ? rule.actions.first.actionId : null,
            payload: {
              'status': workItem.status.name,
              'priority': workItem.priority.name,
              'tags': workItem.tags,
              'triggerType': trigger.name,
            },
            timestamp: DateTime.now(),
          ),
        );

        // Log da regra que casou
        developer.log(
          'RuleEngine: Regra casou — ${rule.name} (${rule.id}) '
          'disparada por ${trigger.name} em $workItemId',
          name: 'feedflow.rule_engine',
        );

        // **Execução real de ações é stub** — apenas logs por enquanto
        for (final action in rule.actions) {
          developer.log(
            'RuleEngine: Ação STUB — ${action.actionId} '
            'com parâmetros ${action.params}',
            name: 'feedflow.rule_engine',
          );
        }

        if (rule.stopOnMatch) {
          break; // Para de avaliar outras regras
        }
      }
    }
  }

  /// Extrai o [WorkItem] ID do evento, se aplicável.
  String? _extractWorkItemId(DomainEvent event) {
    if (event is ArticleIngested) return event.workItemId;
    if (event is StatusChanged) return event.workItemId;
    if (event is ItemSnoozed) return event.workItemId;
    if (event is ActionExecuted) return event.workItemId;
    return null;
  }

  /// Extrai o [RuleTrigger] do evento.
  RuleTrigger? _extractTrigger(DomainEvent event) {
    if (event is ArticleIngested) return RuleTrigger.onIngested;
    if (event is StatusChanged) return RuleTrigger.onStatusChanged;
    return null;
  }


  /// Para o motor (remove a inscrição do event bus).
  void dispose() {
    _eventBus.unsubscribe(_onEvent);
  }
}
