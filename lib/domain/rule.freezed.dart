// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Condition _$ConditionFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'simple':
      return SimpleCondition.fromJson(json);
    case 'compound':
      return CompoundCondition.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'Condition',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$Condition {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field, String operator, dynamic value)
    simple,
    required TResult Function(String combinator, List<Condition> conditions)
    compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field, String operator, dynamic value)? simple,
    TResult? Function(String combinator, List<Condition> conditions)? compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field, String operator, dynamic value)? simple,
    TResult Function(String combinator, List<Condition> conditions)? compound,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimpleCondition value) simple,
    required TResult Function(CompoundCondition value) compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimpleCondition value)? simple,
    TResult? Function(CompoundCondition value)? compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimpleCondition value)? simple,
    TResult Function(CompoundCondition value)? compound,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Condition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionCopyWith<$Res> {
  factory $ConditionCopyWith(Condition value, $Res Function(Condition) then) =
      _$ConditionCopyWithImpl<$Res, Condition>;
}

/// @nodoc
class _$ConditionCopyWithImpl<$Res, $Val extends Condition>
    implements $ConditionCopyWith<$Res> {
  _$ConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SimpleConditionImplCopyWith<$Res> {
  factory _$$SimpleConditionImplCopyWith(
    _$SimpleConditionImpl value,
    $Res Function(_$SimpleConditionImpl) then,
  ) = __$$SimpleConditionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field, String operator, dynamic value});
}

/// @nodoc
class __$$SimpleConditionImplCopyWithImpl<$Res>
    extends _$ConditionCopyWithImpl<$Res, _$SimpleConditionImpl>
    implements _$$SimpleConditionImplCopyWith<$Res> {
  __$$SimpleConditionImplCopyWithImpl(
    _$SimpleConditionImpl _value,
    $Res Function(_$SimpleConditionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? operator = null,
    Object? value = freezed,
  }) {
    return _then(
      _$SimpleConditionImpl(
        field:
            null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                    as String,
        operator:
            null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                    as String,
        value:
            freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                    as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SimpleConditionImpl implements SimpleCondition {
  const _$SimpleConditionImpl({
    required this.field,
    required this.operator,
    required this.value,
    final String? $type,
  }) : $type = $type ?? 'simple';

  factory _$SimpleConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimpleConditionImplFromJson(json);

  @override
  final String field;
  // ex: 'status', 'priority', 'tags', 'feedId', 'title', 'content'
  @override
  final String operator;
  // ex: 'equals', 'contains', 'in', 'greaterThan', 'lessThan', 'startsWith', 'endsWith'
  @override
  final dynamic value;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Condition.simple(field: $field, operator: $operator, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimpleConditionImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    field,
    operator,
    const DeepCollectionEquality().hash(value),
  );

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimpleConditionImplCopyWith<_$SimpleConditionImpl> get copyWith =>
      __$$SimpleConditionImplCopyWithImpl<_$SimpleConditionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field, String operator, dynamic value)
    simple,
    required TResult Function(String combinator, List<Condition> conditions)
    compound,
  }) {
    return simple(field, operator, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field, String operator, dynamic value)? simple,
    TResult? Function(String combinator, List<Condition> conditions)? compound,
  }) {
    return simple?.call(field, operator, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field, String operator, dynamic value)? simple,
    TResult Function(String combinator, List<Condition> conditions)? compound,
    required TResult orElse(),
  }) {
    if (simple != null) {
      return simple(field, operator, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimpleCondition value) simple,
    required TResult Function(CompoundCondition value) compound,
  }) {
    return simple(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimpleCondition value)? simple,
    TResult? Function(CompoundCondition value)? compound,
  }) {
    return simple?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimpleCondition value)? simple,
    TResult Function(CompoundCondition value)? compound,
    required TResult orElse(),
  }) {
    if (simple != null) {
      return simple(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SimpleConditionImplToJson(this);
  }
}

abstract class SimpleCondition implements Condition {
  const factory SimpleCondition({
    required final String field,
    required final String operator,
    required final dynamic value,
  }) = _$SimpleConditionImpl;

  factory SimpleCondition.fromJson(Map<String, dynamic> json) =
      _$SimpleConditionImpl.fromJson;

  String
  get field; // ex: 'status', 'priority', 'tags', 'feedId', 'title', 'content'
  String
  get operator; // ex: 'equals', 'contains', 'in', 'greaterThan', 'lessThan', 'startsWith', 'endsWith'
  dynamic get value;

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimpleConditionImplCopyWith<_$SimpleConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompoundConditionImplCopyWith<$Res> {
  factory _$$CompoundConditionImplCopyWith(
    _$CompoundConditionImpl value,
    $Res Function(_$CompoundConditionImpl) then,
  ) = __$$CompoundConditionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String combinator, List<Condition> conditions});
}

/// @nodoc
class __$$CompoundConditionImplCopyWithImpl<$Res>
    extends _$ConditionCopyWithImpl<$Res, _$CompoundConditionImpl>
    implements _$$CompoundConditionImplCopyWith<$Res> {
  __$$CompoundConditionImplCopyWithImpl(
    _$CompoundConditionImpl _value,
    $Res Function(_$CompoundConditionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? combinator = null, Object? conditions = null}) {
    return _then(
      _$CompoundConditionImpl(
        combinator:
            null == combinator
                ? _value.combinator
                : combinator // ignore: cast_nullable_to_non_nullable
                    as String,
        conditions:
            null == conditions
                ? _value._conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                    as List<Condition>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompoundConditionImpl implements CompoundCondition {
  const _$CompoundConditionImpl({
    required this.combinator,
    required final List<Condition> conditions,
    final String? $type,
  }) : _conditions = conditions,
       $type = $type ?? 'compound';

  factory _$CompoundConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompoundConditionImplFromJson(json);

  @override
  final String combinator;
  // 'all' (AND), 'any' (OR), 'not' (NOT)
  final List<Condition> _conditions;
  // 'all' (AND), 'any' (OR), 'not' (NOT)
  @override
  List<Condition> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Condition.compound(combinator: $combinator, conditions: $conditions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompoundConditionImpl &&
            (identical(other.combinator, combinator) ||
                other.combinator == combinator) &&
            const DeepCollectionEquality().equals(
              other._conditions,
              _conditions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    combinator,
    const DeepCollectionEquality().hash(_conditions),
  );

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompoundConditionImplCopyWith<_$CompoundConditionImpl> get copyWith =>
      __$$CompoundConditionImplCopyWithImpl<_$CompoundConditionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field, String operator, dynamic value)
    simple,
    required TResult Function(String combinator, List<Condition> conditions)
    compound,
  }) {
    return compound(combinator, conditions);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field, String operator, dynamic value)? simple,
    TResult? Function(String combinator, List<Condition> conditions)? compound,
  }) {
    return compound?.call(combinator, conditions);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field, String operator, dynamic value)? simple,
    TResult Function(String combinator, List<Condition> conditions)? compound,
    required TResult orElse(),
  }) {
    if (compound != null) {
      return compound(combinator, conditions);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimpleCondition value) simple,
    required TResult Function(CompoundCondition value) compound,
  }) {
    return compound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimpleCondition value)? simple,
    TResult? Function(CompoundCondition value)? compound,
  }) {
    return compound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimpleCondition value)? simple,
    TResult Function(CompoundCondition value)? compound,
    required TResult orElse(),
  }) {
    if (compound != null) {
      return compound(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CompoundConditionImplToJson(this);
  }
}

abstract class CompoundCondition implements Condition {
  const factory CompoundCondition({
    required final String combinator,
    required final List<Condition> conditions,
  }) = _$CompoundConditionImpl;

  factory CompoundCondition.fromJson(Map<String, dynamic> json) =
      _$CompoundConditionImpl.fromJson;

  String get combinator; // 'all' (AND), 'any' (OR), 'not' (NOT)
  List<Condition> get conditions;

  /// Create a copy of Condition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompoundConditionImplCopyWith<_$CompoundConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActionInvocation _$ActionInvocationFromJson(Map<String, dynamic> json) {
  return _ActionInvocation.fromJson(json);
}

/// @nodoc
mixin _$ActionInvocation {
  String get actionId => throw _privateConstructorUsedError;
  Map<String, dynamic> get params => throw _privateConstructorUsedError;

  /// Serializes this ActionInvocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionInvocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionInvocationCopyWith<ActionInvocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionInvocationCopyWith<$Res> {
  factory $ActionInvocationCopyWith(
    ActionInvocation value,
    $Res Function(ActionInvocation) then,
  ) = _$ActionInvocationCopyWithImpl<$Res, ActionInvocation>;
  @useResult
  $Res call({String actionId, Map<String, dynamic> params});
}

/// @nodoc
class _$ActionInvocationCopyWithImpl<$Res, $Val extends ActionInvocation>
    implements $ActionInvocationCopyWith<$Res> {
  _$ActionInvocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionInvocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? actionId = null, Object? params = null}) {
    return _then(
      _value.copyWith(
            actionId:
                null == actionId
                    ? _value.actionId
                    : actionId // ignore: cast_nullable_to_non_nullable
                        as String,
            params:
                null == params
                    ? _value.params
                    : params // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionInvocationImplCopyWith<$Res>
    implements $ActionInvocationCopyWith<$Res> {
  factory _$$ActionInvocationImplCopyWith(
    _$ActionInvocationImpl value,
    $Res Function(_$ActionInvocationImpl) then,
  ) = __$$ActionInvocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String actionId, Map<String, dynamic> params});
}

/// @nodoc
class __$$ActionInvocationImplCopyWithImpl<$Res>
    extends _$ActionInvocationCopyWithImpl<$Res, _$ActionInvocationImpl>
    implements _$$ActionInvocationImplCopyWith<$Res> {
  __$$ActionInvocationImplCopyWithImpl(
    _$ActionInvocationImpl _value,
    $Res Function(_$ActionInvocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionInvocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? actionId = null, Object? params = null}) {
    return _then(
      _$ActionInvocationImpl(
        actionId:
            null == actionId
                ? _value.actionId
                : actionId // ignore: cast_nullable_to_non_nullable
                    as String,
        params:
            null == params
                ? _value._params
                : params // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionInvocationImpl implements _ActionInvocation {
  const _$ActionInvocationImpl({
    required this.actionId,
    required final Map<String, dynamic> params,
  }) : _params = params;

  factory _$ActionInvocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionInvocationImplFromJson(json);

  @override
  final String actionId;
  final Map<String, dynamic> _params;
  @override
  Map<String, dynamic> get params {
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_params);
  }

  @override
  String toString() {
    return 'ActionInvocation(actionId: $actionId, params: $params)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionInvocationImpl &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            const DeepCollectionEquality().equals(other._params, _params));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    actionId,
    const DeepCollectionEquality().hash(_params),
  );

  /// Create a copy of ActionInvocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionInvocationImplCopyWith<_$ActionInvocationImpl> get copyWith =>
      __$$ActionInvocationImplCopyWithImpl<_$ActionInvocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionInvocationImplToJson(this);
  }
}

abstract class _ActionInvocation implements ActionInvocation {
  const factory _ActionInvocation({
    required final String actionId,
    required final Map<String, dynamic> params,
  }) = _$ActionInvocationImpl;

  factory _ActionInvocation.fromJson(Map<String, dynamic> json) =
      _$ActionInvocationImpl.fromJson;

  @override
  String get actionId;
  @override
  Map<String, dynamic> get params;

  /// Create a copy of ActionInvocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionInvocationImplCopyWith<_$ActionInvocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Rule _$RuleFromJson(Map<String, dynamic> json) {
  return _Rule.fromJson(json);
}

/// @nodoc
mixin _$Rule {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  RuleTrigger get trigger => throw _privateConstructorUsedError;
  Condition get conditions => throw _privateConstructorUsedError;
  List<ActionInvocation> get actions => throw _privateConstructorUsedError;
  bool get stopOnMatch => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Intervalo em minutos entre execuções, usado apenas quando
  /// [trigger] é [RuleTrigger.schedule]. `null` para os demais triggers.
  /// O agendamento real roda dentro do ciclo de background sync já
  /// existente (~15min via WorkManager no Android), então intervalos
  /// menores que isso não são garantidos — ver [RuleScheduler].
  int? get intervalMinutes => throw _privateConstructorUsedError;

  /// Última vez que uma regra de schedule foi executada (por
  /// [RuleScheduler]). `null` se nunca rodou. Não é tocado por outros
  /// triggers.
  DateTime? get lastRunAt => throw _privateConstructorUsedError;

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleCopyWith<Rule> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleCopyWith<$Res> {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) then) =
      _$RuleCopyWithImpl<$Res, Rule>;
  @useResult
  $Res call({
    String id,
    String name,
    bool enabled,
    RuleTrigger trigger,
    Condition conditions,
    List<ActionInvocation> actions,
    bool stopOnMatch,
    int order,
    int? intervalMinutes,
    DateTime? lastRunAt,
  });

  $ConditionCopyWith<$Res> get conditions;
}

/// @nodoc
class _$RuleCopyWithImpl<$Res, $Val extends Rule>
    implements $RuleCopyWith<$Res> {
  _$RuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? enabled = null,
    Object? trigger = null,
    Object? conditions = null,
    Object? actions = null,
    Object? stopOnMatch = null,
    Object? order = null,
    Object? intervalMinutes = freezed,
    Object? lastRunAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            enabled:
                null == enabled
                    ? _value.enabled
                    : enabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            trigger:
                null == trigger
                    ? _value.trigger
                    : trigger // ignore: cast_nullable_to_non_nullable
                        as RuleTrigger,
            conditions:
                null == conditions
                    ? _value.conditions
                    : conditions // ignore: cast_nullable_to_non_nullable
                        as Condition,
            actions:
                null == actions
                    ? _value.actions
                    : actions // ignore: cast_nullable_to_non_nullable
                        as List<ActionInvocation>,
            stopOnMatch:
                null == stopOnMatch
                    ? _value.stopOnMatch
                    : stopOnMatch // ignore: cast_nullable_to_non_nullable
                        as bool,
            order:
                null == order
                    ? _value.order
                    : order // ignore: cast_nullable_to_non_nullable
                        as int,
            intervalMinutes:
                freezed == intervalMinutes
                    ? _value.intervalMinutes
                    : intervalMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            lastRunAt:
                freezed == lastRunAt
                    ? _value.lastRunAt
                    : lastRunAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionCopyWith<$Res> get conditions {
    return $ConditionCopyWith<$Res>(_value.conditions, (value) {
      return _then(_value.copyWith(conditions: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RuleImplCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$$RuleImplCopyWith(
    _$RuleImpl value,
    $Res Function(_$RuleImpl) then,
  ) = __$$RuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    bool enabled,
    RuleTrigger trigger,
    Condition conditions,
    List<ActionInvocation> actions,
    bool stopOnMatch,
    int order,
    int? intervalMinutes,
    DateTime? lastRunAt,
  });

  @override
  $ConditionCopyWith<$Res> get conditions;
}

/// @nodoc
class __$$RuleImplCopyWithImpl<$Res>
    extends _$RuleCopyWithImpl<$Res, _$RuleImpl>
    implements _$$RuleImplCopyWith<$Res> {
  __$$RuleImplCopyWithImpl(_$RuleImpl _value, $Res Function(_$RuleImpl) _then)
    : super(_value, _then);

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? enabled = null,
    Object? trigger = null,
    Object? conditions = null,
    Object? actions = null,
    Object? stopOnMatch = null,
    Object? order = null,
    Object? intervalMinutes = freezed,
    Object? lastRunAt = freezed,
  }) {
    return _then(
      _$RuleImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        enabled:
            null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        trigger:
            null == trigger
                ? _value.trigger
                : trigger // ignore: cast_nullable_to_non_nullable
                    as RuleTrigger,
        conditions:
            null == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                    as Condition,
        actions:
            null == actions
                ? _value._actions
                : actions // ignore: cast_nullable_to_non_nullable
                    as List<ActionInvocation>,
        stopOnMatch:
            null == stopOnMatch
                ? _value.stopOnMatch
                : stopOnMatch // ignore: cast_nullable_to_non_nullable
                    as bool,
        order:
            null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                    as int,
        intervalMinutes:
            freezed == intervalMinutes
                ? _value.intervalMinutes
                : intervalMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        lastRunAt:
            freezed == lastRunAt
                ? _value.lastRunAt
                : lastRunAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleImpl implements _Rule {
  const _$RuleImpl({
    required this.id,
    required this.name,
    this.enabled = true,
    required this.trigger,
    required this.conditions,
    required final List<ActionInvocation> actions,
    this.stopOnMatch = false,
    required this.order,
    this.intervalMinutes,
    this.lastRunAt,
  }) : _actions = actions;

  factory _$RuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final RuleTrigger trigger;
  @override
  final Condition conditions;
  final List<ActionInvocation> _actions;
  @override
  List<ActionInvocation> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  @JsonKey()
  final bool stopOnMatch;
  @override
  final int order;

  /// Intervalo em minutos entre execuções, usado apenas quando
  /// [trigger] é [RuleTrigger.schedule]. `null` para os demais triggers.
  /// O agendamento real roda dentro do ciclo de background sync já
  /// existente (~15min via WorkManager no Android), então intervalos
  /// menores que isso não são garantidos — ver [RuleScheduler].
  @override
  final int? intervalMinutes;

  /// Última vez que uma regra de schedule foi executada (por
  /// [RuleScheduler]). `null` se nunca rodou. Não é tocado por outros
  /// triggers.
  @override
  final DateTime? lastRunAt;

  @override
  String toString() {
    return 'Rule(id: $id, name: $name, enabled: $enabled, trigger: $trigger, conditions: $conditions, actions: $actions, stopOnMatch: $stopOnMatch, order: $order, intervalMinutes: $intervalMinutes, lastRunAt: $lastRunAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            (identical(other.conditions, conditions) ||
                other.conditions == conditions) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.stopOnMatch, stopOnMatch) ||
                other.stopOnMatch == stopOnMatch) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.intervalMinutes, intervalMinutes) ||
                other.intervalMinutes == intervalMinutes) &&
            (identical(other.lastRunAt, lastRunAt) ||
                other.lastRunAt == lastRunAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    enabled,
    trigger,
    conditions,
    const DeepCollectionEquality().hash(_actions),
    stopOnMatch,
    order,
    intervalMinutes,
    lastRunAt,
  );

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      __$$RuleImplCopyWithImpl<_$RuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleImplToJson(this);
  }
}

abstract class _Rule implements Rule {
  const factory _Rule({
    required final String id,
    required final String name,
    final bool enabled,
    required final RuleTrigger trigger,
    required final Condition conditions,
    required final List<ActionInvocation> actions,
    final bool stopOnMatch,
    required final int order,
    final int? intervalMinutes,
    final DateTime? lastRunAt,
  }) = _$RuleImpl;

  factory _Rule.fromJson(Map<String, dynamic> json) = _$RuleImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get enabled;
  @override
  RuleTrigger get trigger;
  @override
  Condition get conditions;
  @override
  List<ActionInvocation> get actions;
  @override
  bool get stopOnMatch;
  @override
  int get order;

  /// Intervalo em minutos entre execuções, usado apenas quando
  /// [trigger] é [RuleTrigger.schedule]. `null` para os demais triggers.
  /// O agendamento real roda dentro do ciclo de background sync já
  /// existente (~15min via WorkManager no Android), então intervalos
  /// menores que isso não são garantidos — ver [RuleScheduler].
  @override
  int? get intervalMinutes;

  /// Última vez que uma regra de schedule foi executada (por
  /// [RuleScheduler]). `null` se nunca rodou. Não é tocado por outros
  /// triggers.
  @override
  DateTime? get lastRunAt;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
