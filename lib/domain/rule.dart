import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule.freezed.dart';
part 'rule.g.dart';

/// Gatilho que inicia a avaliação de uma regra.
enum RuleTrigger {
  onIngested, // novo artigo ingerido
  onStatusChanged, // status de um item mudou
  manual, // acionado manualmente pelo usuário
  schedule; // acionado por agendamento (cron)
}

/// Uma [Condition] é uma árvore serializável que descreve um filtro sobre um
/// [WorkItem]. Pode ser simples (campo + operador + valor) ou composta
/// (todas/alguma/nenhuma de várias sub-conditions).
///
/// Exemplo simples:
/// ```
/// Condition.simple(field: 'status', operator: 'equals', value: 'novo')
/// ```
///
/// Exemplo composto:
/// ```
/// Condition.compound(
///   combinator: 'all',
///   conditions: [
///     Condition.simple(field: 'priority', operator: 'in', value: ['high', 'urgent']),
///     Condition.compound(
///       combinator: 'any',
///       conditions: [
///         Condition.simple(field: 'tags', operator: 'contains', value: 'breaking'),
///         Condition.simple(field: 'feedId', operator: 'equals', value: 'f123'),
///       ],
///     ),
///   ],
/// )
/// ```
@Freezed(fromJson: true, toJson: true)
class Condition with _$Condition {
  const factory Condition.simple({
    required String field, // ex: 'status', 'priority', 'tags', 'feedId', 'title', 'content'
    required String operator, // ex: 'equals', 'contains', 'in', 'greaterThan', 'lessThan', 'startsWith', 'endsWith'
    required dynamic value, // tipo depende do operador: String, int, List, bool, etc.
  }) = SimpleCondition;

  const factory Condition.compound({
    required String combinator, // 'all' (AND), 'any' (OR), 'not' (NOT)
    required List<Condition> conditions,
  }) = CompoundCondition;

  factory Condition.fromJson(Map<String, dynamic> json) => _$ConditionFromJson(json);
}

/// Uma ação a ser executada quando uma regra casa. Referencia um actionId
/// (ex: 'changePriority', 'addTag', 'markAsRead', 'snooze') e seus parâmetros.
///
/// Execução real das ações é stubada nesta rodada — apenas estrutura de dados.
@freezed
class ActionInvocation with _$ActionInvocation {
  const factory ActionInvocation({
    required String actionId,
    required Map<String, dynamic> params,
  }) = _ActionInvocation;

  factory ActionInvocation.fromJson(Map<String, dynamic> json) => _$ActionInvocationFromJson(json);
}

/// Uma regra de automação: gatilho → condições → ações.
///
/// Fluxo: quando um evento de domínio (ex: ArticleIngested, StatusChanged)
/// é publicado e seu tipo casa com [trigger], o RuleEngine busca o [WorkItem]
/// correspondente, avalia a árvore de [conditions], e se todas casarem:
/// - se [stopOnMatch] é true, para (não continua outras regras);
/// - grava um evento [RuleMatched] para auditoria;
/// - executa as [actions] (execução real é stub, apenas loga por enquanto).
@freezed
class Rule with _$Rule {
  const factory Rule({
    required String id,
    required String name,
    @Default(true) bool enabled,
    required RuleTrigger trigger,
    required Condition conditions,
    required List<ActionInvocation> actions,
    @Default(false) bool stopOnMatch,
    required int order,
  }) = _Rule;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
}
