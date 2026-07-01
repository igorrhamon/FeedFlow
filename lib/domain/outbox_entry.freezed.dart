// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OutboxEntry {
  int get id => throw _privateConstructorUsedError;
  String get workItemId => throw _privateConstructorUsedError;
  String get articleId => throw _privateConstructorUsedError;
  OutboxAction get action => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;

  /// Create a copy of OutboxEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutboxEntryCopyWith<OutboxEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutboxEntryCopyWith<$Res> {
  factory $OutboxEntryCopyWith(
    OutboxEntry value,
    $Res Function(OutboxEntry) then,
  ) = _$OutboxEntryCopyWithImpl<$Res, OutboxEntry>;
  @useResult
  $Res call({
    int id,
    String workItemId,
    String articleId,
    OutboxAction action,
    DateTime createdAt,
    int attempts,
    String? lastError,
  });
}

/// @nodoc
class _$OutboxEntryCopyWithImpl<$Res, $Val extends OutboxEntry>
    implements $OutboxEntryCopyWith<$Res> {
  _$OutboxEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutboxEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workItemId = null,
    Object? articleId = null,
    Object? action = null,
    Object? createdAt = null,
    Object? attempts = null,
    Object? lastError = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            articleId:
                null == articleId
                    ? _value.articleId
                    : articleId // ignore: cast_nullable_to_non_nullable
                        as String,
            action:
                null == action
                    ? _value.action
                    : action // ignore: cast_nullable_to_non_nullable
                        as OutboxAction,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            attempts:
                null == attempts
                    ? _value.attempts
                    : attempts // ignore: cast_nullable_to_non_nullable
                        as int,
            lastError:
                freezed == lastError
                    ? _value.lastError
                    : lastError // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OutboxEntryImplCopyWith<$Res>
    implements $OutboxEntryCopyWith<$Res> {
  factory _$$OutboxEntryImplCopyWith(
    _$OutboxEntryImpl value,
    $Res Function(_$OutboxEntryImpl) then,
  ) = __$$OutboxEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String workItemId,
    String articleId,
    OutboxAction action,
    DateTime createdAt,
    int attempts,
    String? lastError,
  });
}

/// @nodoc
class __$$OutboxEntryImplCopyWithImpl<$Res>
    extends _$OutboxEntryCopyWithImpl<$Res, _$OutboxEntryImpl>
    implements _$$OutboxEntryImplCopyWith<$Res> {
  __$$OutboxEntryImplCopyWithImpl(
    _$OutboxEntryImpl _value,
    $Res Function(_$OutboxEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OutboxEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workItemId = null,
    Object? articleId = null,
    Object? action = null,
    Object? createdAt = null,
    Object? attempts = null,
    Object? lastError = freezed,
  }) {
    return _then(
      _$OutboxEntryImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        articleId:
            null == articleId
                ? _value.articleId
                : articleId // ignore: cast_nullable_to_non_nullable
                    as String,
        action:
            null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                    as OutboxAction,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        attempts:
            null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                    as int,
        lastError:
            freezed == lastError
                ? _value.lastError
                : lastError // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$OutboxEntryImpl implements _OutboxEntry {
  const _$OutboxEntryImpl({
    required this.id,
    required this.workItemId,
    required this.articleId,
    required this.action,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  @override
  final int id;
  @override
  final String workItemId;
  @override
  final String articleId;
  @override
  final OutboxAction action;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int attempts;
  @override
  final String? lastError;

  @override
  String toString() {
    return 'OutboxEntry(id: $id, workItemId: $workItemId, articleId: $articleId, action: $action, createdAt: $createdAt, attempts: $attempts, lastError: $lastError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutboxEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.articleId, articleId) ||
                other.articleId == articleId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workItemId,
    articleId,
    action,
    createdAt,
    attempts,
    lastError,
  );

  /// Create a copy of OutboxEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutboxEntryImplCopyWith<_$OutboxEntryImpl> get copyWith =>
      __$$OutboxEntryImplCopyWithImpl<_$OutboxEntryImpl>(this, _$identity);
}

abstract class _OutboxEntry implements OutboxEntry {
  const factory _OutboxEntry({
    required final int id,
    required final String workItemId,
    required final String articleId,
    required final OutboxAction action,
    required final DateTime createdAt,
    final int attempts,
    final String? lastError,
  }) = _$OutboxEntryImpl;

  @override
  int get id;
  @override
  String get workItemId;
  @override
  String get articleId;
  @override
  OutboxAction get action;
  @override
  DateTime get createdAt;
  @override
  int get attempts;
  @override
  String? get lastError;

  /// Create a copy of OutboxEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutboxEntryImplCopyWith<_$OutboxEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
