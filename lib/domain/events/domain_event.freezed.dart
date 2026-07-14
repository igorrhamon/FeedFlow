// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ArticleIngested {
  String get workItemId => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get articleId => throw _privateConstructorUsedError;
  String get feedId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of ArticleIngested
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleIngestedCopyWith<ArticleIngested> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleIngestedCopyWith<$Res> {
  factory $ArticleIngestedCopyWith(
    ArticleIngested value,
    $Res Function(ArticleIngested) then,
  ) = _$ArticleIngestedCopyWithImpl<$Res, ArticleIngested>;
  @useResult
  $Res call({
    String workItemId,
    String providerId,
    String articleId,
    String feedId,
    String title,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ArticleIngestedCopyWithImpl<$Res, $Val extends ArticleIngested>
    implements $ArticleIngestedCopyWith<$Res> {
  _$ArticleIngestedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleIngested
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? providerId = null,
    Object? articleId = null,
    Object? feedId = null,
    Object? title = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            articleId:
                null == articleId
                    ? _value.articleId
                    : articleId // ignore: cast_nullable_to_non_nullable
                        as String,
            feedId:
                null == feedId
                    ? _value.feedId
                    : feedId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleIngestedImplCopyWith<$Res>
    implements $ArticleIngestedCopyWith<$Res> {
  factory _$$ArticleIngestedImplCopyWith(
    _$ArticleIngestedImpl value,
    $Res Function(_$ArticleIngestedImpl) then,
  ) = __$$ArticleIngestedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String providerId,
    String articleId,
    String feedId,
    String title,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ArticleIngestedImplCopyWithImpl<$Res>
    extends _$ArticleIngestedCopyWithImpl<$Res, _$ArticleIngestedImpl>
    implements _$$ArticleIngestedImplCopyWith<$Res> {
  __$$ArticleIngestedImplCopyWithImpl(
    _$ArticleIngestedImpl _value,
    $Res Function(_$ArticleIngestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleIngested
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? providerId = null,
    Object? articleId = null,
    Object? feedId = null,
    Object? title = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ArticleIngestedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        articleId:
            null == articleId
                ? _value.articleId
                : articleId // ignore: cast_nullable_to_non_nullable
                    as String,
        feedId:
            null == feedId
                ? _value.feedId
                : feedId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ArticleIngestedImpl extends _ArticleIngested {
  const _$ArticleIngestedImpl({
    required this.workItemId,
    required this.providerId,
    required this.articleId,
    required this.feedId,
    required this.title,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String providerId;
  @override
  final String articleId;
  @override
  final String feedId;
  @override
  final String title;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ArticleIngested(workItemId: $workItemId, providerId: $providerId, articleId: $articleId, feedId: $feedId, title: $title, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleIngestedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.articleId, articleId) ||
                other.articleId == articleId) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    providerId,
    articleId,
    feedId,
    title,
    timestamp,
  );

  /// Create a copy of ArticleIngested
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleIngestedImplCopyWith<_$ArticleIngestedImpl> get copyWith =>
      __$$ArticleIngestedImplCopyWithImpl<_$ArticleIngestedImpl>(
        this,
        _$identity,
      );
}

abstract class _ArticleIngested extends ArticleIngested {
  const factory _ArticleIngested({
    required final String workItemId,
    required final String providerId,
    required final String articleId,
    required final String feedId,
    required final String title,
    required final DateTime timestamp,
  }) = _$ArticleIngestedImpl;
  const _ArticleIngested._() : super._();

  @override
  String get workItemId;
  @override
  String get providerId;
  @override
  String get articleId;
  @override
  String get feedId;
  @override
  String get title;
  @override
  DateTime get timestamp;

  /// Create a copy of ArticleIngested
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleIngestedImplCopyWith<_$ArticleIngestedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StatusChanged {
  String get workItemId => throw _privateConstructorUsedError;
  String get fromStatus => throw _privateConstructorUsedError;
  String get toStatus => throw _privateConstructorUsedError;
  String get actor =>
      throw _privateConstructorUsedError; // 'user', 'rule', 'sync'
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of StatusChanged
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusChangedCopyWith<StatusChanged> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusChangedCopyWith<$Res> {
  factory $StatusChangedCopyWith(
    StatusChanged value,
    $Res Function(StatusChanged) then,
  ) = _$StatusChangedCopyWithImpl<$Res, StatusChanged>;
  @useResult
  $Res call({
    String workItemId,
    String fromStatus,
    String toStatus,
    String actor,
    DateTime timestamp,
  });
}

/// @nodoc
class _$StatusChangedCopyWithImpl<$Res, $Val extends StatusChanged>
    implements $StatusChangedCopyWith<$Res> {
  _$StatusChangedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusChanged
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? fromStatus = null,
    Object? toStatus = null,
    Object? actor = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            fromStatus:
                null == fromStatus
                    ? _value.fromStatus
                    : fromStatus // ignore: cast_nullable_to_non_nullable
                        as String,
            toStatus:
                null == toStatus
                    ? _value.toStatus
                    : toStatus // ignore: cast_nullable_to_non_nullable
                        as String,
            actor:
                null == actor
                    ? _value.actor
                    : actor // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatusChangedImplCopyWith<$Res>
    implements $StatusChangedCopyWith<$Res> {
  factory _$$StatusChangedImplCopyWith(
    _$StatusChangedImpl value,
    $Res Function(_$StatusChangedImpl) then,
  ) = __$$StatusChangedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String fromStatus,
    String toStatus,
    String actor,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$StatusChangedImplCopyWithImpl<$Res>
    extends _$StatusChangedCopyWithImpl<$Res, _$StatusChangedImpl>
    implements _$$StatusChangedImplCopyWith<$Res> {
  __$$StatusChangedImplCopyWithImpl(
    _$StatusChangedImpl _value,
    $Res Function(_$StatusChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatusChanged
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? fromStatus = null,
    Object? toStatus = null,
    Object? actor = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$StatusChangedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        fromStatus:
            null == fromStatus
                ? _value.fromStatus
                : fromStatus // ignore: cast_nullable_to_non_nullable
                    as String,
        toStatus:
            null == toStatus
                ? _value.toStatus
                : toStatus // ignore: cast_nullable_to_non_nullable
                    as String,
        actor:
            null == actor
                ? _value.actor
                : actor // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$StatusChangedImpl extends _StatusChanged {
  const _$StatusChangedImpl({
    required this.workItemId,
    required this.fromStatus,
    required this.toStatus,
    required this.actor,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String fromStatus;
  @override
  final String toStatus;
  @override
  final String actor;
  // 'user', 'rule', 'sync'
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'StatusChanged(workItemId: $workItemId, fromStatus: $fromStatus, toStatus: $toStatus, actor: $actor, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusChangedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.fromStatus, fromStatus) ||
                other.fromStatus == fromStatus) &&
            (identical(other.toStatus, toStatus) ||
                other.toStatus == toStatus) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    fromStatus,
    toStatus,
    actor,
    timestamp,
  );

  /// Create a copy of StatusChanged
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusChangedImplCopyWith<_$StatusChangedImpl> get copyWith =>
      __$$StatusChangedImplCopyWithImpl<_$StatusChangedImpl>(this, _$identity);
}

abstract class _StatusChanged extends StatusChanged {
  const factory _StatusChanged({
    required final String workItemId,
    required final String fromStatus,
    required final String toStatus,
    required final String actor,
    required final DateTime timestamp,
  }) = _$StatusChangedImpl;
  const _StatusChanged._() : super._();

  @override
  String get workItemId;
  @override
  String get fromStatus;
  @override
  String get toStatus;
  @override
  String get actor; // 'user', 'rule', 'sync'
  @override
  DateTime get timestamp;

  /// Create a copy of StatusChanged
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusChangedImplCopyWith<_$StatusChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ItemSnoozed {
  String get workItemId => throw _privateConstructorUsedError;
  DateTime get snoozedUntil => throw _privateConstructorUsedError;
  String get actor => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of ItemSnoozed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemSnoozedCopyWith<ItemSnoozed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemSnoozedCopyWith<$Res> {
  factory $ItemSnoozedCopyWith(
    ItemSnoozed value,
    $Res Function(ItemSnoozed) then,
  ) = _$ItemSnoozedCopyWithImpl<$Res, ItemSnoozed>;
  @useResult
  $Res call({
    String workItemId,
    DateTime snoozedUntil,
    String actor,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ItemSnoozedCopyWithImpl<$Res, $Val extends ItemSnoozed>
    implements $ItemSnoozedCopyWith<$Res> {
  _$ItemSnoozedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemSnoozed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? snoozedUntil = null,
    Object? actor = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            snoozedUntil:
                null == snoozedUntil
                    ? _value.snoozedUntil
                    : snoozedUntil // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            actor:
                null == actor
                    ? _value.actor
                    : actor // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ItemSnoozedImplCopyWith<$Res>
    implements $ItemSnoozedCopyWith<$Res> {
  factory _$$ItemSnoozedImplCopyWith(
    _$ItemSnoozedImpl value,
    $Res Function(_$ItemSnoozedImpl) then,
  ) = __$$ItemSnoozedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    DateTime snoozedUntil,
    String actor,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ItemSnoozedImplCopyWithImpl<$Res>
    extends _$ItemSnoozedCopyWithImpl<$Res, _$ItemSnoozedImpl>
    implements _$$ItemSnoozedImplCopyWith<$Res> {
  __$$ItemSnoozedImplCopyWithImpl(
    _$ItemSnoozedImpl _value,
    $Res Function(_$ItemSnoozedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItemSnoozed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? snoozedUntil = null,
    Object? actor = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ItemSnoozedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        snoozedUntil:
            null == snoozedUntil
                ? _value.snoozedUntil
                : snoozedUntil // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        actor:
            null == actor
                ? _value.actor
                : actor // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ItemSnoozedImpl extends _ItemSnoozed {
  const _$ItemSnoozedImpl({
    required this.workItemId,
    required this.snoozedUntil,
    required this.actor,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final DateTime snoozedUntil;
  @override
  final String actor;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ItemSnoozed(workItemId: $workItemId, snoozedUntil: $snoozedUntil, actor: $actor, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemSnoozedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.snoozedUntil, snoozedUntil) ||
                other.snoozedUntil == snoozedUntil) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, workItemId, snoozedUntil, actor, timestamp);

  /// Create a copy of ItemSnoozed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemSnoozedImplCopyWith<_$ItemSnoozedImpl> get copyWith =>
      __$$ItemSnoozedImplCopyWithImpl<_$ItemSnoozedImpl>(this, _$identity);
}

abstract class _ItemSnoozed extends ItemSnoozed {
  const factory _ItemSnoozed({
    required final String workItemId,
    required final DateTime snoozedUntil,
    required final String actor,
    required final DateTime timestamp,
  }) = _$ItemSnoozedImpl;
  const _ItemSnoozed._() : super._();

  @override
  String get workItemId;
  @override
  DateTime get snoozedUntil;
  @override
  String get actor;
  @override
  DateTime get timestamp;

  /// Create a copy of ItemSnoozed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemSnoozedImplCopyWith<_$ItemSnoozedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SnoozeExpired {
  String get workItemId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of SnoozeExpired
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnoozeExpiredCopyWith<SnoozeExpired> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnoozeExpiredCopyWith<$Res> {
  factory $SnoozeExpiredCopyWith(
    SnoozeExpired value,
    $Res Function(SnoozeExpired) then,
  ) = _$SnoozeExpiredCopyWithImpl<$Res, SnoozeExpired>;
  @useResult
  $Res call({String workItemId, DateTime timestamp});
}

/// @nodoc
class _$SnoozeExpiredCopyWithImpl<$Res, $Val extends SnoozeExpired>
    implements $SnoozeExpiredCopyWith<$Res> {
  _$SnoozeExpiredCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnoozeExpired
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? workItemId = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnoozeExpiredImplCopyWith<$Res>
    implements $SnoozeExpiredCopyWith<$Res> {
  factory _$$SnoozeExpiredImplCopyWith(
    _$SnoozeExpiredImpl value,
    $Res Function(_$SnoozeExpiredImpl) then,
  ) = __$$SnoozeExpiredImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String workItemId, DateTime timestamp});
}

/// @nodoc
class __$$SnoozeExpiredImplCopyWithImpl<$Res>
    extends _$SnoozeExpiredCopyWithImpl<$Res, _$SnoozeExpiredImpl>
    implements _$$SnoozeExpiredImplCopyWith<$Res> {
  __$$SnoozeExpiredImplCopyWithImpl(
    _$SnoozeExpiredImpl _value,
    $Res Function(_$SnoozeExpiredImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnoozeExpired
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? workItemId = null, Object? timestamp = null}) {
    return _then(
      _$SnoozeExpiredImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SnoozeExpiredImpl extends _SnoozeExpired {
  const _$SnoozeExpiredImpl({required this.workItemId, required this.timestamp})
    : super._();

  @override
  final String workItemId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SnoozeExpired(workItemId: $workItemId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnoozeExpiredImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, workItemId, timestamp);

  /// Create a copy of SnoozeExpired
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnoozeExpiredImplCopyWith<_$SnoozeExpiredImpl> get copyWith =>
      __$$SnoozeExpiredImplCopyWithImpl<_$SnoozeExpiredImpl>(this, _$identity);
}

abstract class _SnoozeExpired extends SnoozeExpired {
  const factory _SnoozeExpired({
    required final String workItemId,
    required final DateTime timestamp,
  }) = _$SnoozeExpiredImpl;
  const _SnoozeExpired._() : super._();

  @override
  String get workItemId;
  @override
  DateTime get timestamp;

  /// Create a copy of SnoozeExpired
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnoozeExpiredImplCopyWith<_$SnoozeExpiredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActionExecuted {
  String get workItemId => throw _privateConstructorUsedError;
  String get actionId => throw _privateConstructorUsedError;
  Map<String, dynamic> get params => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of ActionExecuted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionExecutedCopyWith<ActionExecuted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionExecutedCopyWith<$Res> {
  factory $ActionExecutedCopyWith(
    ActionExecuted value,
    $Res Function(ActionExecuted) then,
  ) = _$ActionExecutedCopyWithImpl<$Res, ActionExecuted>;
  @useResult
  $Res call({
    String workItemId,
    String actionId,
    Map<String, dynamic> params,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ActionExecutedCopyWithImpl<$Res, $Val extends ActionExecuted>
    implements $ActionExecutedCopyWith<$Res> {
  _$ActionExecutedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionExecuted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? actionId = null,
    Object? params = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
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
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionExecutedImplCopyWith<$Res>
    implements $ActionExecutedCopyWith<$Res> {
  factory _$$ActionExecutedImplCopyWith(
    _$ActionExecutedImpl value,
    $Res Function(_$ActionExecutedImpl) then,
  ) = __$$ActionExecutedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String actionId,
    Map<String, dynamic> params,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ActionExecutedImplCopyWithImpl<$Res>
    extends _$ActionExecutedCopyWithImpl<$Res, _$ActionExecutedImpl>
    implements _$$ActionExecutedImplCopyWith<$Res> {
  __$$ActionExecutedImplCopyWithImpl(
    _$ActionExecutedImpl _value,
    $Res Function(_$ActionExecutedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionExecuted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? actionId = null,
    Object? params = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ActionExecutedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
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
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ActionExecutedImpl extends _ActionExecuted {
  const _$ActionExecutedImpl({
    required this.workItemId,
    required this.actionId,
    required final Map<String, dynamic> params,
    required this.timestamp,
  }) : _params = params,
       super._();

  @override
  final String workItemId;
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
  final DateTime timestamp;

  @override
  String toString() {
    return 'ActionExecuted(workItemId: $workItemId, actionId: $actionId, params: $params, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionExecutedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    actionId,
    const DeepCollectionEquality().hash(_params),
    timestamp,
  );

  /// Create a copy of ActionExecuted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionExecutedImplCopyWith<_$ActionExecutedImpl> get copyWith =>
      __$$ActionExecutedImplCopyWithImpl<_$ActionExecutedImpl>(
        this,
        _$identity,
      );
}

abstract class _ActionExecuted extends ActionExecuted {
  const factory _ActionExecuted({
    required final String workItemId,
    required final String actionId,
    required final Map<String, dynamic> params,
    required final DateTime timestamp,
  }) = _$ActionExecutedImpl;
  const _ActionExecuted._() : super._();

  @override
  String get workItemId;
  @override
  String get actionId;
  @override
  Map<String, dynamic> get params;
  @override
  DateTime get timestamp;

  /// Create a copy of ActionExecuted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionExecutedImplCopyWith<_$ActionExecutedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RuleMatched {
  String get ruleId => throw _privateConstructorUsedError;
  String get workItemId => throw _privateConstructorUsedError;
  String get ruleName => throw _privateConstructorUsedError;

  /// Identificador da primeira ação que seria executada (para undo futuro).
  String? get actionId => throw _privateConstructorUsedError;

  /// Payload para auditoria e undo (ex.: status anterior, tags antes/depois).
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of RuleMatched
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleMatchedCopyWith<RuleMatched> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleMatchedCopyWith<$Res> {
  factory $RuleMatchedCopyWith(
    RuleMatched value,
    $Res Function(RuleMatched) then,
  ) = _$RuleMatchedCopyWithImpl<$Res, RuleMatched>;
  @useResult
  $Res call({
    String ruleId,
    String workItemId,
    String ruleName,
    String? actionId,
    Map<String, dynamic> payload,
    DateTime timestamp,
  });
}

/// @nodoc
class _$RuleMatchedCopyWithImpl<$Res, $Val extends RuleMatched>
    implements $RuleMatchedCopyWith<$Res> {
  _$RuleMatchedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuleMatched
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? workItemId = null,
    Object? ruleName = null,
    Object? actionId = freezed,
    Object? payload = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            ruleId:
                null == ruleId
                    ? _value.ruleId
                    : ruleId // ignore: cast_nullable_to_non_nullable
                        as String,
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            ruleName:
                null == ruleName
                    ? _value.ruleName
                    : ruleName // ignore: cast_nullable_to_non_nullable
                        as String,
            actionId:
                freezed == actionId
                    ? _value.actionId
                    : actionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            payload:
                null == payload
                    ? _value.payload
                    : payload // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RuleMatchedImplCopyWith<$Res>
    implements $RuleMatchedCopyWith<$Res> {
  factory _$$RuleMatchedImplCopyWith(
    _$RuleMatchedImpl value,
    $Res Function(_$RuleMatchedImpl) then,
  ) = __$$RuleMatchedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ruleId,
    String workItemId,
    String ruleName,
    String? actionId,
    Map<String, dynamic> payload,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$RuleMatchedImplCopyWithImpl<$Res>
    extends _$RuleMatchedCopyWithImpl<$Res, _$RuleMatchedImpl>
    implements _$$RuleMatchedImplCopyWith<$Res> {
  __$$RuleMatchedImplCopyWithImpl(
    _$RuleMatchedImpl _value,
    $Res Function(_$RuleMatchedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RuleMatched
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? workItemId = null,
    Object? ruleName = null,
    Object? actionId = freezed,
    Object? payload = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$RuleMatchedImpl(
        ruleId:
            null == ruleId
                ? _value.ruleId
                : ruleId // ignore: cast_nullable_to_non_nullable
                    as String,
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        ruleName:
            null == ruleName
                ? _value.ruleName
                : ruleName // ignore: cast_nullable_to_non_nullable
                    as String,
        actionId:
            freezed == actionId
                ? _value.actionId
                : actionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        payload:
            null == payload
                ? _value._payload
                : payload // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$RuleMatchedImpl extends _RuleMatched {
  const _$RuleMatchedImpl({
    required this.ruleId,
    required this.workItemId,
    required this.ruleName,
    required this.actionId,
    required final Map<String, dynamic> payload,
    required this.timestamp,
  }) : _payload = payload,
       super._();

  @override
  final String ruleId;
  @override
  final String workItemId;
  @override
  final String ruleName;

  /// Identificador da primeira ação que seria executada (para undo futuro).
  @override
  final String? actionId;

  /// Payload para auditoria e undo (ex.: status anterior, tags antes/depois).
  final Map<String, dynamic> _payload;

  /// Payload para auditoria e undo (ex.: status anterior, tags antes/depois).
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'RuleMatched(ruleId: $ruleId, workItemId: $workItemId, ruleName: $ruleName, actionId: $actionId, payload: $payload, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleMatchedImpl &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.ruleName, ruleName) ||
                other.ruleName == ruleName) &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    ruleId,
    workItemId,
    ruleName,
    actionId,
    const DeepCollectionEquality().hash(_payload),
    timestamp,
  );

  /// Create a copy of RuleMatched
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleMatchedImplCopyWith<_$RuleMatchedImpl> get copyWith =>
      __$$RuleMatchedImplCopyWithImpl<_$RuleMatchedImpl>(this, _$identity);
}

abstract class _RuleMatched extends RuleMatched {
  const factory _RuleMatched({
    required final String ruleId,
    required final String workItemId,
    required final String ruleName,
    required final String? actionId,
    required final Map<String, dynamic> payload,
    required final DateTime timestamp,
  }) = _$RuleMatchedImpl;
  const _RuleMatched._() : super._();

  @override
  String get ruleId;
  @override
  String get workItemId;
  @override
  String get ruleName;

  /// Identificador da primeira ação que seria executada (para undo futuro).
  @override
  String? get actionId;

  /// Payload para auditoria e undo (ex.: status anterior, tags antes/depois).
  @override
  Map<String, dynamic> get payload;
  @override
  DateTime get timestamp;

  /// Create a copy of RuleMatched
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleMatchedImplCopyWith<_$RuleMatchedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EnrichmentCompleted {
  String get workItemId => throw _privateConstructorUsedError;
  String get enrichmentType =>
      throw _privateConstructorUsedError; // 'summary', 'translation', 'classification', 'entities', 'suggestion'
  String get model => throw _privateConstructorUsedError;
  int get tokensUsed => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of EnrichmentCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnrichmentCompletedCopyWith<EnrichmentCompleted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnrichmentCompletedCopyWith<$Res> {
  factory $EnrichmentCompletedCopyWith(
    EnrichmentCompleted value,
    $Res Function(EnrichmentCompleted) then,
  ) = _$EnrichmentCompletedCopyWithImpl<$Res, EnrichmentCompleted>;
  @useResult
  $Res call({
    String workItemId,
    String enrichmentType,
    String model,
    int tokensUsed,
    DateTime timestamp,
  });
}

/// @nodoc
class _$EnrichmentCompletedCopyWithImpl<$Res, $Val extends EnrichmentCompleted>
    implements $EnrichmentCompletedCopyWith<$Res> {
  _$EnrichmentCompletedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnrichmentCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? enrichmentType = null,
    Object? model = null,
    Object? tokensUsed = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            enrichmentType:
                null == enrichmentType
                    ? _value.enrichmentType
                    : enrichmentType // ignore: cast_nullable_to_non_nullable
                        as String,
            model:
                null == model
                    ? _value.model
                    : model // ignore: cast_nullable_to_non_nullable
                        as String,
            tokensUsed:
                null == tokensUsed
                    ? _value.tokensUsed
                    : tokensUsed // ignore: cast_nullable_to_non_nullable
                        as int,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnrichmentCompletedImplCopyWith<$Res>
    implements $EnrichmentCompletedCopyWith<$Res> {
  factory _$$EnrichmentCompletedImplCopyWith(
    _$EnrichmentCompletedImpl value,
    $Res Function(_$EnrichmentCompletedImpl) then,
  ) = __$$EnrichmentCompletedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String enrichmentType,
    String model,
    int tokensUsed,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$EnrichmentCompletedImplCopyWithImpl<$Res>
    extends _$EnrichmentCompletedCopyWithImpl<$Res, _$EnrichmentCompletedImpl>
    implements _$$EnrichmentCompletedImplCopyWith<$Res> {
  __$$EnrichmentCompletedImplCopyWithImpl(
    _$EnrichmentCompletedImpl _value,
    $Res Function(_$EnrichmentCompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnrichmentCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? enrichmentType = null,
    Object? model = null,
    Object? tokensUsed = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$EnrichmentCompletedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        enrichmentType:
            null == enrichmentType
                ? _value.enrichmentType
                : enrichmentType // ignore: cast_nullable_to_non_nullable
                    as String,
        model:
            null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                    as String,
        tokensUsed:
            null == tokensUsed
                ? _value.tokensUsed
                : tokensUsed // ignore: cast_nullable_to_non_nullable
                    as int,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$EnrichmentCompletedImpl extends _EnrichmentCompleted {
  const _$EnrichmentCompletedImpl({
    required this.workItemId,
    required this.enrichmentType,
    required this.model,
    required this.tokensUsed,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String enrichmentType;
  // 'summary', 'translation', 'classification', 'entities', 'suggestion'
  @override
  final String model;
  @override
  final int tokensUsed;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'EnrichmentCompleted(workItemId: $workItemId, enrichmentType: $enrichmentType, model: $model, tokensUsed: $tokensUsed, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnrichmentCompletedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.enrichmentType, enrichmentType) ||
                other.enrichmentType == enrichmentType) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    enrichmentType,
    model,
    tokensUsed,
    timestamp,
  );

  /// Create a copy of EnrichmentCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnrichmentCompletedImplCopyWith<_$EnrichmentCompletedImpl> get copyWith =>
      __$$EnrichmentCompletedImplCopyWithImpl<_$EnrichmentCompletedImpl>(
        this,
        _$identity,
      );
}

abstract class _EnrichmentCompleted extends EnrichmentCompleted {
  const factory _EnrichmentCompleted({
    required final String workItemId,
    required final String enrichmentType,
    required final String model,
    required final int tokensUsed,
    required final DateTime timestamp,
  }) = _$EnrichmentCompletedImpl;
  const _EnrichmentCompleted._() : super._();

  @override
  String get workItemId;
  @override
  String get enrichmentType; // 'summary', 'translation', 'classification', 'entities', 'suggestion'
  @override
  String get model;
  @override
  int get tokensUsed;
  @override
  DateTime get timestamp;

  /// Create a copy of EnrichmentCompleted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnrichmentCompletedImplCopyWith<_$EnrichmentCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EnrichmentFailed {
  String get workItemId => throw _privateConstructorUsedError;
  String get enrichmentType => throw _privateConstructorUsedError;
  String get error => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of EnrichmentFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnrichmentFailedCopyWith<EnrichmentFailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnrichmentFailedCopyWith<$Res> {
  factory $EnrichmentFailedCopyWith(
    EnrichmentFailed value,
    $Res Function(EnrichmentFailed) then,
  ) = _$EnrichmentFailedCopyWithImpl<$Res, EnrichmentFailed>;
  @useResult
  $Res call({
    String workItemId,
    String enrichmentType,
    String error,
    DateTime timestamp,
  });
}

/// @nodoc
class _$EnrichmentFailedCopyWithImpl<$Res, $Val extends EnrichmentFailed>
    implements $EnrichmentFailedCopyWith<$Res> {
  _$EnrichmentFailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnrichmentFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? enrichmentType = null,
    Object? error = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            enrichmentType:
                null == enrichmentType
                    ? _value.enrichmentType
                    : enrichmentType // ignore: cast_nullable_to_non_nullable
                        as String,
            error:
                null == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnrichmentFailedImplCopyWith<$Res>
    implements $EnrichmentFailedCopyWith<$Res> {
  factory _$$EnrichmentFailedImplCopyWith(
    _$EnrichmentFailedImpl value,
    $Res Function(_$EnrichmentFailedImpl) then,
  ) = __$$EnrichmentFailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String enrichmentType,
    String error,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$EnrichmentFailedImplCopyWithImpl<$Res>
    extends _$EnrichmentFailedCopyWithImpl<$Res, _$EnrichmentFailedImpl>
    implements _$$EnrichmentFailedImplCopyWith<$Res> {
  __$$EnrichmentFailedImplCopyWithImpl(
    _$EnrichmentFailedImpl _value,
    $Res Function(_$EnrichmentFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnrichmentFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? enrichmentType = null,
    Object? error = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$EnrichmentFailedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        enrichmentType:
            null == enrichmentType
                ? _value.enrichmentType
                : enrichmentType // ignore: cast_nullable_to_non_nullable
                    as String,
        error:
            null == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$EnrichmentFailedImpl extends _EnrichmentFailed {
  const _$EnrichmentFailedImpl({
    required this.workItemId,
    required this.enrichmentType,
    required this.error,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String enrichmentType;
  @override
  final String error;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'EnrichmentFailed(workItemId: $workItemId, enrichmentType: $enrichmentType, error: $error, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnrichmentFailedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.enrichmentType, enrichmentType) ||
                other.enrichmentType == enrichmentType) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, workItemId, enrichmentType, error, timestamp);

  /// Create a copy of EnrichmentFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnrichmentFailedImplCopyWith<_$EnrichmentFailedImpl> get copyWith =>
      __$$EnrichmentFailedImplCopyWithImpl<_$EnrichmentFailedImpl>(
        this,
        _$identity,
      );
}

abstract class _EnrichmentFailed extends EnrichmentFailed {
  const factory _EnrichmentFailed({
    required final String workItemId,
    required final String enrichmentType,
    required final String error,
    required final DateTime timestamp,
  }) = _$EnrichmentFailedImpl;
  const _EnrichmentFailed._() : super._();

  @override
  String get workItemId;
  @override
  String get enrichmentType;
  @override
  String get error;
  @override
  DateTime get timestamp;

  /// Create a copy of EnrichmentFailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnrichmentFailedImplCopyWith<_$EnrichmentFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SyncCompleted {
  String get providerId => throw _privateConstructorUsedError;
  int get itemsIngested => throw _privateConstructorUsedError;
  int get itemsUpdated => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of SyncCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncCompletedCopyWith<SyncCompleted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncCompletedCopyWith<$Res> {
  factory $SyncCompletedCopyWith(
    SyncCompleted value,
    $Res Function(SyncCompleted) then,
  ) = _$SyncCompletedCopyWithImpl<$Res, SyncCompleted>;
  @useResult
  $Res call({
    String providerId,
    int itemsIngested,
    int itemsUpdated,
    DateTime timestamp,
  });
}

/// @nodoc
class _$SyncCompletedCopyWithImpl<$Res, $Val extends SyncCompleted>
    implements $SyncCompletedCopyWith<$Res> {
  _$SyncCompletedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? itemsIngested = null,
    Object? itemsUpdated = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            itemsIngested:
                null == itemsIngested
                    ? _value.itemsIngested
                    : itemsIngested // ignore: cast_nullable_to_non_nullable
                        as int,
            itemsUpdated:
                null == itemsUpdated
                    ? _value.itemsUpdated
                    : itemsUpdated // ignore: cast_nullable_to_non_nullable
                        as int,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncCompletedImplCopyWith<$Res>
    implements $SyncCompletedCopyWith<$Res> {
  factory _$$SyncCompletedImplCopyWith(
    _$SyncCompletedImpl value,
    $Res Function(_$SyncCompletedImpl) then,
  ) = __$$SyncCompletedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String providerId,
    int itemsIngested,
    int itemsUpdated,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$SyncCompletedImplCopyWithImpl<$Res>
    extends _$SyncCompletedCopyWithImpl<$Res, _$SyncCompletedImpl>
    implements _$$SyncCompletedImplCopyWith<$Res> {
  __$$SyncCompletedImplCopyWithImpl(
    _$SyncCompletedImpl _value,
    $Res Function(_$SyncCompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? itemsIngested = null,
    Object? itemsUpdated = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SyncCompletedImpl(
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        itemsIngested:
            null == itemsIngested
                ? _value.itemsIngested
                : itemsIngested // ignore: cast_nullable_to_non_nullable
                    as int,
        itemsUpdated:
            null == itemsUpdated
                ? _value.itemsUpdated
                : itemsUpdated // ignore: cast_nullable_to_non_nullable
                    as int,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SyncCompletedImpl extends _SyncCompleted {
  const _$SyncCompletedImpl({
    required this.providerId,
    required this.itemsIngested,
    required this.itemsUpdated,
    required this.timestamp,
  }) : super._();

  @override
  final String providerId;
  @override
  final int itemsIngested;
  @override
  final int itemsUpdated;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SyncCompleted(providerId: $providerId, itemsIngested: $itemsIngested, itemsUpdated: $itemsUpdated, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncCompletedImpl &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.itemsIngested, itemsIngested) ||
                other.itemsIngested == itemsIngested) &&
            (identical(other.itemsUpdated, itemsUpdated) ||
                other.itemsUpdated == itemsUpdated) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    providerId,
    itemsIngested,
    itemsUpdated,
    timestamp,
  );

  /// Create a copy of SyncCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncCompletedImplCopyWith<_$SyncCompletedImpl> get copyWith =>
      __$$SyncCompletedImplCopyWithImpl<_$SyncCompletedImpl>(this, _$identity);
}

abstract class _SyncCompleted extends SyncCompleted {
  const factory _SyncCompleted({
    required final String providerId,
    required final int itemsIngested,
    required final int itemsUpdated,
    required final DateTime timestamp,
  }) = _$SyncCompletedImpl;
  const _SyncCompleted._() : super._();

  @override
  String get providerId;
  @override
  int get itemsIngested;
  @override
  int get itemsUpdated;
  @override
  DateTime get timestamp;

  /// Create a copy of SyncCompleted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncCompletedImplCopyWith<_$SyncCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SyncFailed {
  String get providerId => throw _privateConstructorUsedError;
  String get error => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of SyncFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncFailedCopyWith<SyncFailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncFailedCopyWith<$Res> {
  factory $SyncFailedCopyWith(
    SyncFailed value,
    $Res Function(SyncFailed) then,
  ) = _$SyncFailedCopyWithImpl<$Res, SyncFailed>;
  @useResult
  $Res call({String providerId, String error, DateTime timestamp});
}

/// @nodoc
class _$SyncFailedCopyWithImpl<$Res, $Val extends SyncFailed>
    implements $SyncFailedCopyWith<$Res> {
  _$SyncFailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? error = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            error:
                null == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncFailedImplCopyWith<$Res>
    implements $SyncFailedCopyWith<$Res> {
  factory _$$SyncFailedImplCopyWith(
    _$SyncFailedImpl value,
    $Res Function(_$SyncFailedImpl) then,
  ) = __$$SyncFailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String providerId, String error, DateTime timestamp});
}

/// @nodoc
class __$$SyncFailedImplCopyWithImpl<$Res>
    extends _$SyncFailedCopyWithImpl<$Res, _$SyncFailedImpl>
    implements _$$SyncFailedImplCopyWith<$Res> {
  __$$SyncFailedImplCopyWithImpl(
    _$SyncFailedImpl _value,
    $Res Function(_$SyncFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? error = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SyncFailedImpl(
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        error:
            null == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SyncFailedImpl extends _SyncFailed {
  const _$SyncFailedImpl({
    required this.providerId,
    required this.error,
    required this.timestamp,
  }) : super._();

  @override
  final String providerId;
  @override
  final String error;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SyncFailed(providerId: $providerId, error: $error, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncFailedImpl &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, providerId, error, timestamp);

  /// Create a copy of SyncFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncFailedImplCopyWith<_$SyncFailedImpl> get copyWith =>
      __$$SyncFailedImplCopyWithImpl<_$SyncFailedImpl>(this, _$identity);
}

abstract class _SyncFailed extends SyncFailed {
  const factory _SyncFailed({
    required final String providerId,
    required final String error,
    required final DateTime timestamp,
  }) = _$SyncFailedImpl;
  const _SyncFailed._() : super._();

  @override
  String get providerId;
  @override
  String get error;
  @override
  DateTime get timestamp;

  /// Create a copy of SyncFailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncFailedImplCopyWith<_$SyncFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
