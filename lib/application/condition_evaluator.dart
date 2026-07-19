import 'dart:developer' as developer;

import '../domain/rule.dart';
import '../domain/work_item.dart';

/// Avaliador de condições contra [WorkItem]s. Encapsula toda a lógica de
/// matching de árvores de condições (simples e compostas), operadores
/// (equals, contains, in, startsWith, etc.) e combinadores (all, any, not).
///
/// Reutilizável em múltiplos contextos: [RuleEngine], editor de regras
/// com dry-run, validação, etc.
class ConditionEvaluator {
  /// Avalia recursivamente uma árvore de [Condition] contra um [WorkItem].
  /// Retorna `true` se a condição casa com o item.
  bool evaluate(Condition condition, WorkItem item) {
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
          'ConditionEvaluator: operador desconhecido — ${cond.operator}',
          name: 'feedflow.condition_evaluator',
          level: 900, // WARNING
        );
        return false;
    }
  }

  bool _evaluateCompoundCondition(CompoundCondition cond, WorkItem item) {
    switch (cond.combinator) {
      case 'all': // AND lógico
        return cond.conditions.every((c) => evaluate(c, item));

      case 'any': // OR lógico
        return cond.conditions.any((c) => evaluate(c, item));

      case 'not': // NÃO lógico (nega a primeira sub-condition)
        if (cond.conditions.isEmpty) return true;
        return !evaluate(cond.conditions.first, item);

      default:
        developer.log(
          'ConditionEvaluator: combinador desconhecido — ${cond.combinator}',
          name: 'feedflow.condition_evaluator',
          level: 900, // WARNING
        );
        return false;
    }
  }

  /// Extrai o valor de um campo do [WorkItem] por nome. Público para
  /// reutilização fora da avaliação de condições (ex.: ordenação de
  /// resultados em `QuerySpecCompiler`), mantendo os mesmos nomes de campo
  /// aceitos por [Condition].
  dynamic getFieldValue(String field, WorkItem item) => _getFieldValue(field, item);

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
          'ConditionEvaluator: campo desconhecido — $field',
          name: 'feedflow.condition_evaluator',
          level: 900, // WARNING
        );
        return null;
    }
  }
}
