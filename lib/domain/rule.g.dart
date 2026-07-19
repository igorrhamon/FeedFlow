// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimpleConditionImpl _$$SimpleConditionImplFromJson(
  Map<String, dynamic> json,
) => _$SimpleConditionImpl(
  field: json['field'] as String,
  operator: json['operator'] as String,
  value: json['value'],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$SimpleConditionImplToJson(
  _$SimpleConditionImpl instance,
) => <String, dynamic>{
  'field': instance.field,
  'operator': instance.operator,
  'value': instance.value,
  'runtimeType': instance.$type,
};

_$CompoundConditionImpl _$$CompoundConditionImplFromJson(
  Map<String, dynamic> json,
) => _$CompoundConditionImpl(
  combinator: json['combinator'] as String,
  conditions:
      (json['conditions'] as List<dynamic>)
          .map((e) => Condition.fromJson(e as Map<String, dynamic>))
          .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$CompoundConditionImplToJson(
  _$CompoundConditionImpl instance,
) => <String, dynamic>{
  'combinator': instance.combinator,
  'conditions': instance.conditions.map((e) => e.toJson()).toList(),
  'runtimeType': instance.$type,
};

_$ActionInvocationImpl _$$ActionInvocationImplFromJson(
  Map<String, dynamic> json,
) => _$ActionInvocationImpl(
  actionId: json['actionId'] as String,
  params: json['params'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$ActionInvocationImplToJson(
  _$ActionInvocationImpl instance,
) => <String, dynamic>{
  'actionId': instance.actionId,
  'params': instance.params,
};

_$RuleImpl _$$RuleImplFromJson(Map<String, dynamic> json) => _$RuleImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  enabled: json['enabled'] as bool? ?? true,
  trigger: $enumDecode(_$RuleTriggerEnumMap, json['trigger']),
  conditions: Condition.fromJson(json['conditions'] as Map<String, dynamic>),
  actions:
      (json['actions'] as List<dynamic>)
          .map((e) => ActionInvocation.fromJson(e as Map<String, dynamic>))
          .toList(),
  stopOnMatch: json['stopOnMatch'] as bool? ?? false,
  order: (json['order'] as num).toInt(),
  intervalMinutes: (json['intervalMinutes'] as num?)?.toInt(),
  lastRunAt:
      json['lastRunAt'] == null
          ? null
          : DateTime.parse(json['lastRunAt'] as String),
);

Map<String, dynamic> _$$RuleImplToJson(_$RuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enabled': instance.enabled,
      'trigger': _$RuleTriggerEnumMap[instance.trigger]!,
      'conditions': instance.conditions.toJson(),
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'stopOnMatch': instance.stopOnMatch,
      'order': instance.order,
      'intervalMinutes': instance.intervalMinutes,
      'lastRunAt': instance.lastRunAt?.toIso8601String(),
    };

const _$RuleTriggerEnumMap = {
  RuleTrigger.onIngested: 'onIngested',
  RuleTrigger.onStatusChanged: 'onStatusChanged',
  RuleTrigger.manual: 'manual',
  RuleTrigger.schedule: 'schedule',
};
