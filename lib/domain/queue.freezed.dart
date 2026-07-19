// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Queue _$QueueFromJson(Map<String, dynamic> json) {
  return _Queue.fromJson(json);
}

/// @nodoc
mixin _$Queue {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  QuerySpec get spec => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;

  /// Serializes this Queue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueueCopyWith<Queue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueCopyWith<$Res> {
  factory $QueueCopyWith(Queue value, $Res Function(Queue) then) =
      _$QueueCopyWithImpl<$Res, Queue>;
  @useResult
  $Res call({
    String id,
    String name,
    QuerySpec spec,
    int order,
    String? iconName,
  });

  $QuerySpecCopyWith<$Res> get spec;
}

/// @nodoc
class _$QueueCopyWithImpl<$Res, $Val extends Queue>
    implements $QueueCopyWith<$Res> {
  _$QueueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? spec = null,
    Object? order = null,
    Object? iconName = freezed,
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
            spec:
                null == spec
                    ? _value.spec
                    : spec // ignore: cast_nullable_to_non_nullable
                        as QuerySpec,
            order:
                null == order
                    ? _value.order
                    : order // ignore: cast_nullable_to_non_nullable
                        as int,
            iconName:
                freezed == iconName
                    ? _value.iconName
                    : iconName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuerySpecCopyWith<$Res> get spec {
    return $QuerySpecCopyWith<$Res>(_value.spec, (value) {
      return _then(_value.copyWith(spec: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QueueImplCopyWith<$Res> implements $QueueCopyWith<$Res> {
  factory _$$QueueImplCopyWith(
    _$QueueImpl value,
    $Res Function(_$QueueImpl) then,
  ) = __$$QueueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    QuerySpec spec,
    int order,
    String? iconName,
  });

  @override
  $QuerySpecCopyWith<$Res> get spec;
}

/// @nodoc
class __$$QueueImplCopyWithImpl<$Res>
    extends _$QueueCopyWithImpl<$Res, _$QueueImpl>
    implements _$$QueueImplCopyWith<$Res> {
  __$$QueueImplCopyWithImpl(
    _$QueueImpl _value,
    $Res Function(_$QueueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? spec = null,
    Object? order = null,
    Object? iconName = freezed,
  }) {
    return _then(
      _$QueueImpl(
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
        spec:
            null == spec
                ? _value.spec
                : spec // ignore: cast_nullable_to_non_nullable
                    as QuerySpec,
        order:
            null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                    as int,
        iconName:
            freezed == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueImpl implements _Queue {
  const _$QueueImpl({
    required this.id,
    required this.name,
    required this.spec,
    required this.order,
    this.iconName,
  });

  factory _$QueueImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final QuerySpec spec;
  @override
  final int order;
  @override
  final String? iconName;

  @override
  String toString() {
    return 'Queue(id: $id, name: $name, spec: $spec, order: $order, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.spec, spec) || other.spec == spec) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, spec, order, iconName);

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueImplCopyWith<_$QueueImpl> get copyWith =>
      __$$QueueImplCopyWithImpl<_$QueueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueImplToJson(this);
  }
}

abstract class _Queue implements Queue {
  const factory _Queue({
    required final String id,
    required final String name,
    required final QuerySpec spec,
    required final int order,
    final String? iconName,
  }) = _$QueueImpl;

  factory _Queue.fromJson(Map<String, dynamic> json) = _$QueueImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  QuerySpec get spec;
  @override
  int get order;
  @override
  String? get iconName;

  /// Create a copy of Queue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueueImplCopyWith<_$QueueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
