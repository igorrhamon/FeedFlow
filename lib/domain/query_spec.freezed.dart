// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'query_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuerySpec _$QuerySpecFromJson(Map<String, dynamic> json) {
  return _QuerySpec.fromJson(json);
}

/// @nodoc
mixin _$QuerySpec {
  Condition get filter =>
      throw _privateConstructorUsedError; // reusa Condition de lib/domain/rule.dart
  String? get sortField =>
      throw _privateConstructorUsedError; // ex: 'ingestedAt', 'updatedAt', 'title' — nullable = sem ordenação explícita
  bool get sortDescending => throw _privateConstructorUsedError;

  /// Serializes this QuerySpec to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuerySpecCopyWith<QuerySpec> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuerySpecCopyWith<$Res> {
  factory $QuerySpecCopyWith(QuerySpec value, $Res Function(QuerySpec) then) =
      _$QuerySpecCopyWithImpl<$Res, QuerySpec>;
  @useResult
  $Res call({Condition filter, String? sortField, bool sortDescending});

  $ConditionCopyWith<$Res> get filter;
}

/// @nodoc
class _$QuerySpecCopyWithImpl<$Res, $Val extends QuerySpec>
    implements $QuerySpecCopyWith<$Res> {
  _$QuerySpecCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
    Object? sortField = freezed,
    Object? sortDescending = null,
  }) {
    return _then(
      _value.copyWith(
            filter:
                null == filter
                    ? _value.filter
                    : filter // ignore: cast_nullable_to_non_nullable
                        as Condition,
            sortField:
                freezed == sortField
                    ? _value.sortField
                    : sortField // ignore: cast_nullable_to_non_nullable
                        as String?,
            sortDescending:
                null == sortDescending
                    ? _value.sortDescending
                    : sortDescending // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionCopyWith<$Res> get filter {
    return $ConditionCopyWith<$Res>(_value.filter, (value) {
      return _then(_value.copyWith(filter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuerySpecImplCopyWith<$Res>
    implements $QuerySpecCopyWith<$Res> {
  factory _$$QuerySpecImplCopyWith(
    _$QuerySpecImpl value,
    $Res Function(_$QuerySpecImpl) then,
  ) = __$$QuerySpecImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Condition filter, String? sortField, bool sortDescending});

  @override
  $ConditionCopyWith<$Res> get filter;
}

/// @nodoc
class __$$QuerySpecImplCopyWithImpl<$Res>
    extends _$QuerySpecCopyWithImpl<$Res, _$QuerySpecImpl>
    implements _$$QuerySpecImplCopyWith<$Res> {
  __$$QuerySpecImplCopyWithImpl(
    _$QuerySpecImpl _value,
    $Res Function(_$QuerySpecImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
    Object? sortField = freezed,
    Object? sortDescending = null,
  }) {
    return _then(
      _$QuerySpecImpl(
        filter:
            null == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                    as Condition,
        sortField:
            freezed == sortField
                ? _value.sortField
                : sortField // ignore: cast_nullable_to_non_nullable
                    as String?,
        sortDescending:
            null == sortDescending
                ? _value.sortDescending
                : sortDescending // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuerySpecImpl implements _QuerySpec {
  const _$QuerySpecImpl({
    required this.filter,
    this.sortField,
    this.sortDescending = false,
  });

  factory _$QuerySpecImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuerySpecImplFromJson(json);

  @override
  final Condition filter;
  // reusa Condition de lib/domain/rule.dart
  @override
  final String? sortField;
  // ex: 'ingestedAt', 'updatedAt', 'title' — nullable = sem ordenação explícita
  @override
  @JsonKey()
  final bool sortDescending;

  @override
  String toString() {
    return 'QuerySpec(filter: $filter, sortField: $sortField, sortDescending: $sortDescending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuerySpecImpl &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.sortField, sortField) ||
                other.sortField == sortField) &&
            (identical(other.sortDescending, sortDescending) ||
                other.sortDescending == sortDescending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, filter, sortField, sortDescending);

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuerySpecImplCopyWith<_$QuerySpecImpl> get copyWith =>
      __$$QuerySpecImplCopyWithImpl<_$QuerySpecImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuerySpecImplToJson(this);
  }
}

abstract class _QuerySpec implements QuerySpec {
  const factory _QuerySpec({
    required final Condition filter,
    final String? sortField,
    final bool sortDescending,
  }) = _$QuerySpecImpl;

  factory _QuerySpec.fromJson(Map<String, dynamic> json) =
      _$QuerySpecImpl.fromJson;

  @override
  Condition get filter; // reusa Condition de lib/domain/rule.dart
  @override
  String? get sortField; // ex: 'ingestedAt', 'updatedAt', 'title' — nullable = sem ordenação explícita
  @override
  bool get sortDescending;

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuerySpecImplCopyWith<_$QuerySpecImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
