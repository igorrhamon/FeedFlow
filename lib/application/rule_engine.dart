import 'dart:developer' as developer;

import '../domain/events/domain_event.dart';
import '../domain/repositories/rule_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
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
        _eventBus = eventBus {
    _initialize();
  }

  final WorkItemRepository _workItemRepository;
  final RuleRepository _ruleRepository;
  final EventBus _eventBus;

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
      if (_evaluateCondition(rule.conditions, workItem)) {
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

  /// Avalia recursivamente uma árvore de [Condition] contra um [WorkItem].
  /// Retorna `true` se a condição casa com o item.
  bool _evaluateCondition(Condition condition, WorkItem item) {
    if (condition is SimpleCondition) {
      return _evaluateSimpleCondition(condition, item);
    } else if (condition is CompoundCondition) {
      return _evaluateCompoundCondition(condition, item);
    }
    return false;
  }

  bool _evaluateSimpleCondition(SimpleCondition cond, WorkItem item) {
    final fieldValue = _getFieldValue(cond.field, item);
    if (fieldValue == null && cond.operator != 'exists' && cond.operator != 'notExists') {
      return false;
    }

    switch (cond.operator) {
      case 'equals':
        return fieldValue == cond.value;

      case 'notEquals':
        return fieldValue != cond.value;

      case 'contains':
        if (fieldValue is String) {
          return fieldValue.contains(cond.value.toString());
        } else if (fieldValue is List) {
          return fieldValue.contains(cond.value);
        }
        return false;

      case 'notContains':
        if (fieldValue is String) {
          return !fieldValue.contains(cond.value.toString());
        } else if (fieldValue is List) {
          return !fieldValue.contains(cond.value);
        }
        return false;

      case 'in':
        if (cond.value is List) {
          return (cond.value as List).contains(fieldValue);
        }
        return false;

      case 'notIn':
        if (cond.value is List) {
          return !(cond.value as List).contains(fieldValue);
        }
        return false;

      case 'startsWith':
        if (fieldValue is String) {
          return fieldValue.startsWith(cond.value.toString());
        }
        return false;

      case 'endsWith':
        if (fieldValue is String) {
          return fieldValue.endsWith(cond.value.toString());
        }
        return false;

      case 'greaterThan':
        if (fieldValue is num && cond.value is num) {
          return fieldValue > cond.value;
        }
        return false;

      case 'lessThan':
        if (fieldValue is num && cond.value is num) {
          return fieldValue < cond.value;
        }
        return false;

      case 'exists':
        return fieldValue != null;

      case 'notExists':
        return fieldValue == null;

      default:
        developer.log(
          'RuleEngine: operador desconhecido — ${cond.operator}',
          name: 'feedflow.rule_engine',
          level: 900, // WARNING
        );
        return false;
    }
  }

  bool _evaluateCompoundCondition(CompoundCondition cond, WorkItem item) {
    switch (cond.combinator) {
      case 'all': // AND lógico
        return cond.conditions.every((c) => _evaluateCondition(c, item));

      case 'any': // OR lógico
        return cond.conditions.any((c) => _evaluateCondition(c, item));

      case 'not': // NÃO lógico (nega a primeira sub-condition)
        if (cond.conditions.isEmpty) return true;
        return !_evaluateCondition(cond.conditions.first, item);

      default:
        developer.log(
          'RuleEngine: combinador desconhecido — ${cond.combinator}',
          name: 'feedflow.rule_engine',
          level: 900, // WARNING
        );
        return false;
    }
  }

  /// Extrai o valor de um campo do [WorkItem] por nome.
  dynamic _getFieldValue(String field, WorkItem item) {
    switch (field) {
      case 'status':
        return item.status.name;

      case 'priority':
        return item.priority.name;

      case 'tags':
        return item.tags;

      case 'feedId':
        return item.feedId;

      case 'providerId':
        return item.providerId;

      case 'title':
        return item.title;

      case 'author':
        return item.author;

      case 'summary':
        return item.summary;

      case 'content':
        return item.content;

      case 'url':
        return item.url;

      case 'isRead':
        return item.isRead;

      case 'isStarred':
        return item.isStarred;

      case 'isSnoozed':
        return item.isSnoozed;

      default:
        developer.log(
          'RuleEngine: campo desconhecido — $field',
          name: 'feedflow.rule_engine',
          level: 900, // WARNING
        );
        return null;
    }
  }

  /// Para o motor (remove a inscrição do event bus).
  void dispose() {
    _eventBus.unsubscribe(_onEvent);
  }
}
