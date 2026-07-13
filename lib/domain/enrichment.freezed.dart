// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrichment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Enrichment {
  int? get id => throw _privateConstructorUsedError;
  String get workItemId => throw _privateConstructorUsedError;
  EnrichmentType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Enrichment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnrichmentCopyWith<Enrichment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnrichmentCopyWith<$Res> {
  factory $EnrichmentCopyWith(
    Enrichment value,
    $Res Function(Enrichment) then,
  ) = _$EnrichmentCopyWithImpl<$Res, Enrichment>;
  @useResult
  $Res call({
    int? id,
    String workItemId,
    EnrichmentType type,
    String content,
    String? model,
    DateTime createdAt,
  });
}

/// @nodoc
class _$EnrichmentCopyWithImpl<$Res, $Val extends Enrichment>
    implements $EnrichmentCopyWith<$Res> {
  _$EnrichmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Enrichment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? workItemId = null,
    Object? type = null,
    Object? content = null,
    Object? model = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as EnrichmentType,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            model:
                freezed == model
                    ? _value.model
                    : model // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnrichmentImplCopyWith<$Res>
    implements $EnrichmentCopyWith<$Res> {
  factory _$$EnrichmentImplCopyWith(
    _$EnrichmentImpl value,
    $Res Function(_$EnrichmentImpl) then,
  ) = __$$EnrichmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String workItemId,
    EnrichmentType type,
    String content,
    String? model,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$EnrichmentImplCopyWithImpl<$Res>
    extends _$EnrichmentCopyWithImpl<$Res, _$EnrichmentImpl>
    implements _$$EnrichmentImplCopyWith<$Res> {
  __$$EnrichmentImplCopyWithImpl(
    _$EnrichmentImpl _value,
    $Res Function(_$EnrichmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Enrichment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? workItemId = null,
    Object? type = null,
    Object? content = null,
    Object? model = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$EnrichmentImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as EnrichmentType,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        model:
            freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$EnrichmentImpl implements _Enrichment {
  const _$EnrichmentImpl({
    this.id,
    required this.workItemId,
    required this.type,
    required this.content,
    this.model,
    required this.createdAt,
  });

  @override
  final int? id;
  @override
  final String workItemId;
  @override
  final EnrichmentType type;
  @override
  final String content;
  @override
  final String? model;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Enrichment(id: $id, workItemId: $workItemId, type: $type, content: $content, model: $model, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnrichmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, workItemId, type, content, model, createdAt);

  /// Create a copy of Enrichment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnrichmentImplCopyWith<_$EnrichmentImpl> get copyWith =>
      __$$EnrichmentImplCopyWithImpl<_$EnrichmentImpl>(this, _$identity);
}

abstract class _Enrichment implements Enrichment {
  const factory _Enrichment({
    final int? id,
    required final String workItemId,
    required final EnrichmentType type,
    required final String content,
    final String? model,
    required final DateTime createdAt,
  }) = _$EnrichmentImpl;

  @override
  int? get id;
  @override
  String get workItemId;
  @override
  EnrichmentType get type;
  @override
  String get content;
  @override
  String? get model;
  @override
  DateTime get createdAt;

  /// Create a copy of Enrichment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnrichmentImplCopyWith<_$EnrichmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
