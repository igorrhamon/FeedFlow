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

QuerySort _$QuerySortFromJson(Map<String, dynamic> json) {
  return _QuerySort.fromJson(json);
}

/// @nodoc
mixin _$QuerySort {
  String get field =>
      throw _privateConstructorUsedError; // mesmos nomes de campo aceitos por Condition (ver rule.dart)
  bool get descending => throw _privateConstructorUsedError;

  /// Serializes this QuerySort to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuerySort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuerySortCopyWith<QuerySort> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuerySortCopyWith<$Res> {
  factory $QuerySortCopyWith(QuerySort value, $Res Function(QuerySort) then) =
      _$QuerySortCopyWithImpl<$Res, QuerySort>;
  @useResult
  $Res call({String field, bool descending});
}

/// @nodoc
class _$QuerySortCopyWithImpl<$Res, $Val extends QuerySort>
    implements $QuerySortCopyWith<$Res> {
  _$QuerySortCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuerySort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field = null, Object? descending = null}) {
    return _then(
      _value.copyWith(
            field:
                null == field
                    ? _value.field
                    : field // ignore: cast_nullable_to_non_nullable
                        as String,
            descending:
                null == descending
                    ? _value.descending
                    : descending // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuerySortImplCopyWith<$Res>
    implements $QuerySortCopyWith<$Res> {
  factory _$$QuerySortImplCopyWith(
    _$QuerySortImpl value,
    $Res Function(_$QuerySortImpl) then,
  ) = __$$QuerySortImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, bool descending});
}

/// @nodoc
class __$$QuerySortImplCopyWithImpl<$Res>
    extends _$QuerySortCopyWithImpl<$Res, _$QuerySortImpl>
    implements _$$QuerySortImplCopyWith<$Res> {
  __$$QuerySortImplCopyWithImpl(
    _$QuerySortImpl _value,
    $Res Function(_$QuerySortImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuerySort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field = null, Object? descending = null}) {
    return _then(
      _$QuerySortImpl(
        field:
            null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                    as String,
        descending:
            null == descending
                ? _value.descending
                : descending // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuerySortImpl implements _QuerySort {
  const _$QuerySortImpl({required this.field, this.descending = false});

  factory _$QuerySortImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuerySortImplFromJson(json);

  @override
  final String field;
  // mesmos nomes de campo aceitos por Condition (ver rule.dart)
  @override
  @JsonKey()
  final bool descending;

  @override
  String toString() {
    return 'QuerySort(field: $field, descending: $descending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuerySortImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.descending, descending) ||
                other.descending == descending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, field, descending);

  /// Create a copy of QuerySort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuerySortImplCopyWith<_$QuerySortImpl> get copyWith =>
      __$$QuerySortImplCopyWithImpl<_$QuerySortImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuerySortImplToJson(this);
  }
}

abstract class _QuerySort implements QuerySort {
  const factory _QuerySort({
    required final String field,
    final bool descending,
  }) = _$QuerySortImpl;

  factory _QuerySort.fromJson(Map<String, dynamic> json) =
      _$QuerySortImpl.fromJson;

  @override
  String get field; // mesmos nomes de campo aceitos por Condition (ver rule.dart)
  @override
  bool get descending;

  /// Create a copy of QuerySort
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuerySortImplCopyWith<_$QuerySortImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuerySpec _$QuerySpecFromJson(Map<String, dynamic> json) {
  return _QuerySpec.fromJson(json);
}

/// @nodoc
mixin _$QuerySpec {
  Condition get filter => throw _privateConstructorUsedError;
  List<QuerySort> get sort => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;

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
  $Res call({Condition filter, List<QuerySort> sort, int? limit});

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
    Object? sort = null,
    Object? limit = freezed,
  }) {
    return _then(
      _value.copyWith(
            filter:
                null == filter
                    ? _value.filter
                    : filter // ignore: cast_nullable_to_non_nullable
                        as Condition,
            sort:
                null == sort
                    ? _value.sort
                    : sort // ignore: cast_nullable_to_non_nullable
                        as List<QuerySort>,
            limit:
                freezed == limit
                    ? _value.limit
                    : limit // ignore: cast_nullable_to_non_nullable
                        as int?,
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
  $Res call({Condition filter, List<QuerySort> sort, int? limit});

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
    Object? sort = null,
    Object? limit = freezed,
  }) {
    return _then(
      _$QuerySpecImpl(
        filter:
            null == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                    as Condition,
        sort:
            null == sort
                ? _value._sort
                : sort // ignore: cast_nullable_to_non_nullable
                    as List<QuerySort>,
        limit:
            freezed == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuerySpecImpl implements _QuerySpec {
  const _$QuerySpecImpl({
    required this.filter,
    final List<QuerySort> sort = const <QuerySort>[],
    this.limit,
  }) : _sort = sort;

  factory _$QuerySpecImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuerySpecImplFromJson(json);

  @override
  final Condition filter;
  final List<QuerySort> _sort;
  @override
  @JsonKey()
  List<QuerySort> get sort {
    if (_sort is EqualUnmodifiableListView) return _sort;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sort);
  }

  @override
  final int? limit;

  @override
  String toString() {
    return 'QuerySpec(filter: $filter, sort: $sort, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuerySpecImpl &&
            (identical(other.filter, filter) || other.filter == filter) &&
            const DeepCollectionEquality().equals(other._sort, _sort) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    filter,
    const DeepCollectionEquality().hash(_sort),
    limit,
  );

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
    final List<QuerySort> sort,
    final int? limit,
  }) = _$QuerySpecImpl;

  factory _QuerySpec.fromJson(Map<String, dynamic> json) =
      _$QuerySpecImpl.fromJson;

  @override
  Condition get filter;
  @override
  List<QuerySort> get sort;
  @override
  int? get limit;

  /// Create a copy of QuerySpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuerySpecImplCopyWith<_$QuerySpecImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
