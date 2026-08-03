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
mixin _$DocumentIngested {
  String get workItemId => throw _privateConstructorUsedError;
  String get documentId => throw _privateConstructorUsedError;
  String get sourceConnectorId => throw _privateConstructorUsedError;
  String get sourceId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of DocumentIngested
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentIngestedCopyWith<DocumentIngested> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentIngestedCopyWith<$Res> {
  factory $DocumentIngestedCopyWith(
    DocumentIngested value,
    $Res Function(DocumentIngested) then,
  ) = _$DocumentIngestedCopyWithImpl<$Res, DocumentIngested>;
  @useResult
  $Res call({
    String workItemId,
    String documentId,
    String sourceConnectorId,
    String sourceId,
    String title,
    DateTime timestamp,
  });
}

/// @nodoc
class _$DocumentIngestedCopyWithImpl<$Res, $Val extends DocumentIngested>
    implements $DocumentIngestedCopyWith<$Res> {
  _$DocumentIngestedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentIngested
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? documentId = null,
    Object? sourceConnectorId = null,
    Object? sourceId = null,
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
            documentId:
                null == documentId
                    ? _value.documentId
                    : documentId // ignore: cast_nullable_to_non_nullable
                        as String,
            sourceConnectorId:
                null == sourceConnectorId
                    ? _value.sourceConnectorId
                    : sourceConnectorId // ignore: cast_nullable_to_non_nullable
                        as String,
            sourceId:
                null == sourceId
                    ? _value.sourceId
                    : sourceId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DocumentIngestedImplCopyWith<$Res>
    implements $DocumentIngestedCopyWith<$Res> {
  factory _$$DocumentIngestedImplCopyWith(
    _$DocumentIngestedImpl value,
    $Res Function(_$DocumentIngestedImpl) then,
  ) = __$$DocumentIngestedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String documentId,
    String sourceConnectorId,
    String sourceId,
    String title,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$DocumentIngestedImplCopyWithImpl<$Res>
    extends _$DocumentIngestedCopyWithImpl<$Res, _$DocumentIngestedImpl>
    implements _$$DocumentIngestedImplCopyWith<$Res> {
  __$$DocumentIngestedImplCopyWithImpl(
    _$DocumentIngestedImpl _value,
    $Res Function(_$DocumentIngestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentIngested
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? documentId = null,
    Object? sourceConnectorId = null,
    Object? sourceId = null,
    Object? title = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$DocumentIngestedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        documentId:
            null == documentId
                ? _value.documentId
                : documentId // ignore: cast_nullable_to_non_nullable
                    as String,
        sourceConnectorId:
            null == sourceConnectorId
                ? _value.sourceConnectorId
                : sourceConnectorId // ignore: cast_nullable_to_non_nullable
                    as String,
        sourceId:
            null == sourceId
                ? _value.sourceId
                : sourceId // ignore: cast_nullable_to_non_nullable
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

class _$DocumentIngestedImpl extends _DocumentIngested {
  const _$DocumentIngestedImpl({
    required this.workItemId,
    required this.documentId,
    required this.sourceConnectorId,
    required this.sourceId,
    required this.title,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String documentId;
  @override
  final String sourceConnectorId;
  @override
  final String sourceId;
  @override
  final String title;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'DocumentIngested(workItemId: $workItemId, documentId: $documentId, sourceConnectorId: $sourceConnectorId, sourceId: $sourceId, title: $title, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentIngestedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.sourceConnectorId, sourceConnectorId) ||
                other.sourceConnectorId == sourceConnectorId) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    documentId,
    sourceConnectorId,
    sourceId,
    title,
    timestamp,
  );

  /// Create a copy of DocumentIngested
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentIngestedImplCopyWith<_$DocumentIngestedImpl> get copyWith =>
      __$$DocumentIngestedImplCopyWithImpl<_$DocumentIngestedImpl>(
        this,
        _$identity,
      );
}

abstract class _DocumentIngested extends DocumentIngested {
  const factory _DocumentIngested({
    required final String workItemId,
    required final String documentId,
    required final String sourceConnectorId,
    required final String sourceId,
    required final String title,
    required final DateTime timestamp,
  }) = _$DocumentIngestedImpl;
  const _DocumentIngested._() : super._();

  @override
  String get workItemId;
  @override
  String get documentId;
  @override
  String get sourceConnectorId;
  @override
  String get sourceId;
  @override
  String get title;
  @override
  DateTime get timestamp;

  /// Create a copy of DocumentIngested
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentIngestedImplCopyWith<_$DocumentIngestedImpl> get copyWith =>
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
mixin _$WorkflowStepExecuted {
  String get workItemId => throw _privateConstructorUsedError;
  String get actionId => throw _privateConstructorUsedError;
  int get stepIndex => throw _privateConstructorUsedError;
  int get totalSteps => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowStepExecuted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowStepExecutedCopyWith<WorkflowStepExecuted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowStepExecutedCopyWith<$Res> {
  factory $WorkflowStepExecutedCopyWith(
    WorkflowStepExecuted value,
    $Res Function(WorkflowStepExecuted) then,
  ) = _$WorkflowStepExecutedCopyWithImpl<$Res, WorkflowStepExecuted>;
  @useResult
  $Res call({
    String workItemId,
    String actionId,
    int stepIndex,
    int totalSteps,
    bool success,
    DateTime timestamp,
  });
}

/// @nodoc
class _$WorkflowStepExecutedCopyWithImpl<
  $Res,
  $Val extends WorkflowStepExecuted
>
    implements $WorkflowStepExecutedCopyWith<$Res> {
  _$WorkflowStepExecutedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowStepExecuted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? actionId = null,
    Object? stepIndex = null,
    Object? totalSteps = null,
    Object? success = null,
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
            stepIndex:
                null == stepIndex
                    ? _value.stepIndex
                    : stepIndex // ignore: cast_nullable_to_non_nullable
                        as int,
            totalSteps:
                null == totalSteps
                    ? _value.totalSteps
                    : totalSteps // ignore: cast_nullable_to_non_nullable
                        as int,
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
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
abstract class _$$WorkflowStepExecutedImplCopyWith<$Res>
    implements $WorkflowStepExecutedCopyWith<$Res> {
  factory _$$WorkflowStepExecutedImplCopyWith(
    _$WorkflowStepExecutedImpl value,
    $Res Function(_$WorkflowStepExecutedImpl) then,
  ) = __$$WorkflowStepExecutedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    String actionId,
    int stepIndex,
    int totalSteps,
    bool success,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$WorkflowStepExecutedImplCopyWithImpl<$Res>
    extends _$WorkflowStepExecutedCopyWithImpl<$Res, _$WorkflowStepExecutedImpl>
    implements _$$WorkflowStepExecutedImplCopyWith<$Res> {
  __$$WorkflowStepExecutedImplCopyWithImpl(
    _$WorkflowStepExecutedImpl _value,
    $Res Function(_$WorkflowStepExecutedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowStepExecuted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? actionId = null,
    Object? stepIndex = null,
    Object? totalSteps = null,
    Object? success = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$WorkflowStepExecutedImpl(
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
        stepIndex:
            null == stepIndex
                ? _value.stepIndex
                : stepIndex // ignore: cast_nullable_to_non_nullable
                    as int,
        totalSteps:
            null == totalSteps
                ? _value.totalSteps
                : totalSteps // ignore: cast_nullable_to_non_nullable
                    as int,
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
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

class _$WorkflowStepExecutedImpl extends _WorkflowStepExecuted {
  const _$WorkflowStepExecutedImpl({
    required this.workItemId,
    required this.actionId,
    required this.stepIndex,
    required this.totalSteps,
    required this.success,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final String actionId;
  @override
  final int stepIndex;
  @override
  final int totalSteps;
  @override
  final bool success;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'WorkflowStepExecuted(workItemId: $workItemId, actionId: $actionId, stepIndex: $stepIndex, totalSteps: $totalSteps, success: $success, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowStepExecutedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            (identical(other.stepIndex, stepIndex) ||
                other.stepIndex == stepIndex) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    actionId,
    stepIndex,
    totalSteps,
    success,
    timestamp,
  );

  /// Create a copy of WorkflowStepExecuted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowStepExecutedImplCopyWith<_$WorkflowStepExecutedImpl>
  get copyWith =>
      __$$WorkflowStepExecutedImplCopyWithImpl<_$WorkflowStepExecutedImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkflowStepExecuted extends WorkflowStepExecuted {
  const factory _WorkflowStepExecuted({
    required final String workItemId,
    required final String actionId,
    required final int stepIndex,
    required final int totalSteps,
    required final bool success,
    required final DateTime timestamp,
  }) = _$WorkflowStepExecutedImpl;
  const _WorkflowStepExecuted._() : super._();

  @override
  String get workItemId;
  @override
  String get actionId;
  @override
  int get stepIndex;
  @override
  int get totalSteps;
  @override
  bool get success;
  @override
  DateTime get timestamp;

  /// Create a copy of WorkflowStepExecuted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowStepExecutedImplCopyWith<_$WorkflowStepExecutedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkflowCompleted {
  String get workItemId => throw _privateConstructorUsedError;
  int get totalSteps => throw _privateConstructorUsedError;
  int get succeededSteps => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowCompletedCopyWith<WorkflowCompleted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowCompletedCopyWith<$Res> {
  factory $WorkflowCompletedCopyWith(
    WorkflowCompleted value,
    $Res Function(WorkflowCompleted) then,
  ) = _$WorkflowCompletedCopyWithImpl<$Res, WorkflowCompleted>;
  @useResult
  $Res call({
    String workItemId,
    int totalSteps,
    int succeededSteps,
    DateTime timestamp,
  });
}

/// @nodoc
class _$WorkflowCompletedCopyWithImpl<$Res, $Val extends WorkflowCompleted>
    implements $WorkflowCompletedCopyWith<$Res> {
  _$WorkflowCompletedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? totalSteps = null,
    Object? succeededSteps = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            workItemId:
                null == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            totalSteps:
                null == totalSteps
                    ? _value.totalSteps
                    : totalSteps // ignore: cast_nullable_to_non_nullable
                        as int,
            succeededSteps:
                null == succeededSteps
                    ? _value.succeededSteps
                    : succeededSteps // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WorkflowCompletedImplCopyWith<$Res>
    implements $WorkflowCompletedCopyWith<$Res> {
  factory _$$WorkflowCompletedImplCopyWith(
    _$WorkflowCompletedImpl value,
    $Res Function(_$WorkflowCompletedImpl) then,
  ) = __$$WorkflowCompletedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String workItemId,
    int totalSteps,
    int succeededSteps,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$WorkflowCompletedImplCopyWithImpl<$Res>
    extends _$WorkflowCompletedCopyWithImpl<$Res, _$WorkflowCompletedImpl>
    implements _$$WorkflowCompletedImplCopyWith<$Res> {
  __$$WorkflowCompletedImplCopyWithImpl(
    _$WorkflowCompletedImpl _value,
    $Res Function(_$WorkflowCompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowCompleted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workItemId = null,
    Object? totalSteps = null,
    Object? succeededSteps = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$WorkflowCompletedImpl(
        workItemId:
            null == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        totalSteps:
            null == totalSteps
                ? _value.totalSteps
                : totalSteps // ignore: cast_nullable_to_non_nullable
                    as int,
        succeededSteps:
            null == succeededSteps
                ? _value.succeededSteps
                : succeededSteps // ignore: cast_nullable_to_non_nullable
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

class _$WorkflowCompletedImpl extends _WorkflowCompleted {
  const _$WorkflowCompletedImpl({
    required this.workItemId,
    required this.totalSteps,
    required this.succeededSteps,
    required this.timestamp,
  }) : super._();

  @override
  final String workItemId;
  @override
  final int totalSteps;
  @override
  final int succeededSteps;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'WorkflowCompleted(workItemId: $workItemId, totalSteps: $totalSteps, succeededSteps: $succeededSteps, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowCompletedImpl &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            (identical(other.succeededSteps, succeededSteps) ||
                other.succeededSteps == succeededSteps) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workItemId,
    totalSteps,
    succeededSteps,
    timestamp,
  );

  /// Create a copy of WorkflowCompleted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowCompletedImplCopyWith<_$WorkflowCompletedImpl> get copyWith =>
      __$$WorkflowCompletedImplCopyWithImpl<_$WorkflowCompletedImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkflowCompleted extends WorkflowCompleted {
  const factory _WorkflowCompleted({
    required final String workItemId,
    required final int totalSteps,
    required final int succeededSteps,
    required final DateTime timestamp,
  }) = _$WorkflowCompletedImpl;
  const _WorkflowCompleted._() : super._();

  @override
  String get workItemId;
  @override
  int get totalSteps;
  @override
  int get succeededSteps;
  @override
  DateTime get timestamp;

  /// Create a copy of WorkflowCompleted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowCompletedImplCopyWith<_$WorkflowCompletedImpl> get copyWith =>
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

/// @nodoc
mixin _$JobEnqueued {
  String get jobId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of JobEnqueued
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobEnqueuedCopyWith<JobEnqueued> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobEnqueuedCopyWith<$Res> {
  factory $JobEnqueuedCopyWith(
    JobEnqueued value,
    $Res Function(JobEnqueued) then,
  ) = _$JobEnqueuedCopyWithImpl<$Res, JobEnqueued>;
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class _$JobEnqueuedCopyWithImpl<$Res, $Val extends JobEnqueued>
    implements $JobEnqueuedCopyWith<$Res> {
  _$JobEnqueuedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobEnqueued
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
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
abstract class _$$JobEnqueuedImplCopyWith<$Res>
    implements $JobEnqueuedCopyWith<$Res> {
  factory _$$JobEnqueuedImplCopyWith(
    _$JobEnqueuedImpl value,
    $Res Function(_$JobEnqueuedImpl) then,
  ) = __$$JobEnqueuedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class __$$JobEnqueuedImplCopyWithImpl<$Res>
    extends _$JobEnqueuedCopyWithImpl<$Res, _$JobEnqueuedImpl>
    implements _$$JobEnqueuedImplCopyWith<$Res> {
  __$$JobEnqueuedImplCopyWithImpl(
    _$JobEnqueuedImpl _value,
    $Res Function(_$JobEnqueuedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobEnqueued
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$JobEnqueuedImpl(
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
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

class _$JobEnqueuedImpl extends _JobEnqueued {
  const _$JobEnqueuedImpl({
    required this.jobId,
    required this.type,
    required this.timestamp,
  }) : super._();

  @override
  final String jobId;
  @override
  final String type;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'JobEnqueued(jobId: $jobId, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobEnqueuedImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, jobId, type, timestamp);

  /// Create a copy of JobEnqueued
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobEnqueuedImplCopyWith<_$JobEnqueuedImpl> get copyWith =>
      __$$JobEnqueuedImplCopyWithImpl<_$JobEnqueuedImpl>(this, _$identity);
}

abstract class _JobEnqueued extends JobEnqueued {
  const factory _JobEnqueued({
    required final String jobId,
    required final String type,
    required final DateTime timestamp,
  }) = _$JobEnqueuedImpl;
  const _JobEnqueued._() : super._();

  @override
  String get jobId;
  @override
  String get type;
  @override
  DateTime get timestamp;

  /// Create a copy of JobEnqueued
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobEnqueuedImplCopyWith<_$JobEnqueuedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobStarted {
  String get jobId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of JobStarted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobStartedCopyWith<JobStarted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobStartedCopyWith<$Res> {
  factory $JobStartedCopyWith(
    JobStarted value,
    $Res Function(JobStarted) then,
  ) = _$JobStartedCopyWithImpl<$Res, JobStarted>;
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class _$JobStartedCopyWithImpl<$Res, $Val extends JobStarted>
    implements $JobStartedCopyWith<$Res> {
  _$JobStartedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobStarted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
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
abstract class _$$JobStartedImplCopyWith<$Res>
    implements $JobStartedCopyWith<$Res> {
  factory _$$JobStartedImplCopyWith(
    _$JobStartedImpl value,
    $Res Function(_$JobStartedImpl) then,
  ) = __$$JobStartedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class __$$JobStartedImplCopyWithImpl<$Res>
    extends _$JobStartedCopyWithImpl<$Res, _$JobStartedImpl>
    implements _$$JobStartedImplCopyWith<$Res> {
  __$$JobStartedImplCopyWithImpl(
    _$JobStartedImpl _value,
    $Res Function(_$JobStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobStarted
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$JobStartedImpl(
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
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

class _$JobStartedImpl extends _JobStarted {
  const _$JobStartedImpl({
    required this.jobId,
    required this.type,
    required this.timestamp,
  }) : super._();

  @override
  final String jobId;
  @override
  final String type;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'JobStarted(jobId: $jobId, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobStartedImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, jobId, type, timestamp);

  /// Create a copy of JobStarted
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobStartedImplCopyWith<_$JobStartedImpl> get copyWith =>
      __$$JobStartedImplCopyWithImpl<_$JobStartedImpl>(this, _$identity);
}

abstract class _JobStarted extends JobStarted {
  const factory _JobStarted({
    required final String jobId,
    required final String type,
    required final DateTime timestamp,
  }) = _$JobStartedImpl;
  const _JobStarted._() : super._();

  @override
  String get jobId;
  @override
  String get type;
  @override
  DateTime get timestamp;

  /// Create a copy of JobStarted
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobStartedImplCopyWith<_$JobStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobSucceeded {
  String get jobId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of JobSucceeded
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobSucceededCopyWith<JobSucceeded> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobSucceededCopyWith<$Res> {
  factory $JobSucceededCopyWith(
    JobSucceeded value,
    $Res Function(JobSucceeded) then,
  ) = _$JobSucceededCopyWithImpl<$Res, JobSucceeded>;
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class _$JobSucceededCopyWithImpl<$Res, $Val extends JobSucceeded>
    implements $JobSucceededCopyWith<$Res> {
  _$JobSucceededCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobSucceeded
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
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
abstract class _$$JobSucceededImplCopyWith<$Res>
    implements $JobSucceededCopyWith<$Res> {
  factory _$$JobSucceededImplCopyWith(
    _$JobSucceededImpl value,
    $Res Function(_$JobSucceededImpl) then,
  ) = __$$JobSucceededImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String jobId, String type, DateTime timestamp});
}

/// @nodoc
class __$$JobSucceededImplCopyWithImpl<$Res>
    extends _$JobSucceededCopyWithImpl<$Res, _$JobSucceededImpl>
    implements _$$JobSucceededImplCopyWith<$Res> {
  __$$JobSucceededImplCopyWithImpl(
    _$JobSucceededImpl _value,
    $Res Function(_$JobSucceededImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobSucceeded
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$JobSucceededImpl(
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
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

class _$JobSucceededImpl extends _JobSucceeded {
  const _$JobSucceededImpl({
    required this.jobId,
    required this.type,
    required this.timestamp,
  }) : super._();

  @override
  final String jobId;
  @override
  final String type;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'JobSucceeded(jobId: $jobId, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobSucceededImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, jobId, type, timestamp);

  /// Create a copy of JobSucceeded
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobSucceededImplCopyWith<_$JobSucceededImpl> get copyWith =>
      __$$JobSucceededImplCopyWithImpl<_$JobSucceededImpl>(this, _$identity);
}

abstract class _JobSucceeded extends JobSucceeded {
  const factory _JobSucceeded({
    required final String jobId,
    required final String type,
    required final DateTime timestamp,
  }) = _$JobSucceededImpl;
  const _JobSucceeded._() : super._();

  @override
  String get jobId;
  @override
  String get type;
  @override
  DateTime get timestamp;

  /// Create a copy of JobSucceeded
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobSucceededImplCopyWith<_$JobSucceededImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobFailed {
  String get jobId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get error => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of JobFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobFailedCopyWith<JobFailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobFailedCopyWith<$Res> {
  factory $JobFailedCopyWith(JobFailed value, $Res Function(JobFailed) then) =
      _$JobFailedCopyWithImpl<$Res, JobFailed>;
  @useResult
  $Res call({
    String jobId,
    String type,
    String error,
    int attempts,
    DateTime timestamp,
  });
}

/// @nodoc
class _$JobFailedCopyWithImpl<$Res, $Val extends JobFailed>
    implements $JobFailedCopyWith<$Res> {
  _$JobFailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? error = null,
    Object? attempts = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            error:
                null == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String,
            attempts:
                null == attempts
                    ? _value.attempts
                    : attempts // ignore: cast_nullable_to_non_nullable
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
abstract class _$$JobFailedImplCopyWith<$Res>
    implements $JobFailedCopyWith<$Res> {
  factory _$$JobFailedImplCopyWith(
    _$JobFailedImpl value,
    $Res Function(_$JobFailedImpl) then,
  ) = __$$JobFailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobId,
    String type,
    String error,
    int attempts,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$JobFailedImplCopyWithImpl<$Res>
    extends _$JobFailedCopyWithImpl<$Res, _$JobFailedImpl>
    implements _$$JobFailedImplCopyWith<$Res> {
  __$$JobFailedImplCopyWithImpl(
    _$JobFailedImpl _value,
    $Res Function(_$JobFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobFailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? error = null,
    Object? attempts = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$JobFailedImpl(
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        error:
            null == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String,
        attempts:
            null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
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

class _$JobFailedImpl extends _JobFailed {
  const _$JobFailedImpl({
    required this.jobId,
    required this.type,
    required this.error,
    required this.attempts,
    required this.timestamp,
  }) : super._();

  @override
  final String jobId;
  @override
  final String type;
  @override
  final String error;
  @override
  final int attempts;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'JobFailed(jobId: $jobId, type: $type, error: $error, attempts: $attempts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobFailedImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, jobId, type, error, attempts, timestamp);

  /// Create a copy of JobFailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobFailedImplCopyWith<_$JobFailedImpl> get copyWith =>
      __$$JobFailedImplCopyWithImpl<_$JobFailedImpl>(this, _$identity);
}

abstract class _JobFailed extends JobFailed {
  const factory _JobFailed({
    required final String jobId,
    required final String type,
    required final String error,
    required final int attempts,
    required final DateTime timestamp,
  }) = _$JobFailedImpl;
  const _JobFailed._() : super._();

  @override
  String get jobId;
  @override
  String get type;
  @override
  String get error;
  @override
  int get attempts;
  @override
  DateTime get timestamp;

  /// Create a copy of JobFailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobFailedImplCopyWith<_$JobFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobRetried {
  String get jobId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  DateTime get nextRunAt => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of JobRetried
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobRetriedCopyWith<JobRetried> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobRetriedCopyWith<$Res> {
  factory $JobRetriedCopyWith(
    JobRetried value,
    $Res Function(JobRetried) then,
  ) = _$JobRetriedCopyWithImpl<$Res, JobRetried>;
  @useResult
  $Res call({
    String jobId,
    String type,
    int attempts,
    DateTime nextRunAt,
    DateTime timestamp,
  });
}

/// @nodoc
class _$JobRetriedCopyWithImpl<$Res, $Val extends JobRetried>
    implements $JobRetriedCopyWith<$Res> {
  _$JobRetriedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobRetried
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? attempts = null,
    Object? nextRunAt = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            attempts:
                null == attempts
                    ? _value.attempts
                    : attempts // ignore: cast_nullable_to_non_nullable
                        as int,
            nextRunAt:
                null == nextRunAt
                    ? _value.nextRunAt
                    : nextRunAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
abstract class _$$JobRetriedImplCopyWith<$Res>
    implements $JobRetriedCopyWith<$Res> {
  factory _$$JobRetriedImplCopyWith(
    _$JobRetriedImpl value,
    $Res Function(_$JobRetriedImpl) then,
  ) = __$$JobRetriedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobId,
    String type,
    int attempts,
    DateTime nextRunAt,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$JobRetriedImplCopyWithImpl<$Res>
    extends _$JobRetriedCopyWithImpl<$Res, _$JobRetriedImpl>
    implements _$$JobRetriedImplCopyWith<$Res> {
  __$$JobRetriedImplCopyWithImpl(
    _$JobRetriedImpl _value,
    $Res Function(_$JobRetriedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobRetried
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? type = null,
    Object? attempts = null,
    Object? nextRunAt = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$JobRetriedImpl(
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        attempts:
            null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                    as int,
        nextRunAt:
            null == nextRunAt
                ? _value.nextRunAt
                : nextRunAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
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

class _$JobRetriedImpl extends _JobRetried {
  const _$JobRetriedImpl({
    required this.jobId,
    required this.type,
    required this.attempts,
    required this.nextRunAt,
    required this.timestamp,
  }) : super._();

  @override
  final String jobId;
  @override
  final String type;
  @override
  final int attempts;
  @override
  final DateTime nextRunAt;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'JobRetried(jobId: $jobId, type: $type, attempts: $attempts, nextRunAt: $nextRunAt, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobRetriedImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, jobId, type, attempts, nextRunAt, timestamp);

  /// Create a copy of JobRetried
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobRetriedImplCopyWith<_$JobRetriedImpl> get copyWith =>
      __$$JobRetriedImplCopyWithImpl<_$JobRetriedImpl>(this, _$identity);
}

abstract class _JobRetried extends JobRetried {
  const factory _JobRetried({
    required final String jobId,
    required final String type,
    required final int attempts,
    required final DateTime nextRunAt,
    required final DateTime timestamp,
  }) = _$JobRetriedImpl;
  const _JobRetried._() : super._();

  @override
  String get jobId;
  @override
  String get type;
  @override
  int get attempts;
  @override
  DateTime get nextRunAt;
  @override
  DateTime get timestamp;

  /// Create a copy of JobRetried
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobRetriedImplCopyWith<_$JobRetriedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NoteCreated {
  String get noteId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get workItemId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of NoteCreated
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteCreatedCopyWith<NoteCreated> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteCreatedCopyWith<$Res> {
  factory $NoteCreatedCopyWith(
    NoteCreated value,
    $Res Function(NoteCreated) then,
  ) = _$NoteCreatedCopyWithImpl<$Res, NoteCreated>;
  @useResult
  $Res call({
    String noteId,
    String title,
    String? workItemId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$NoteCreatedCopyWithImpl<$Res, $Val extends NoteCreated>
    implements $NoteCreatedCopyWith<$Res> {
  _$NoteCreatedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteCreated
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noteId = null,
    Object? title = null,
    Object? workItemId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            noteId:
                null == noteId
                    ? _value.noteId
                    : noteId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            workItemId:
                freezed == workItemId
                    ? _value.workItemId
                    : workItemId // ignore: cast_nullable_to_non_nullable
                        as String?,
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
abstract class _$$NoteCreatedImplCopyWith<$Res>
    implements $NoteCreatedCopyWith<$Res> {
  factory _$$NoteCreatedImplCopyWith(
    _$NoteCreatedImpl value,
    $Res Function(_$NoteCreatedImpl) then,
  ) = __$$NoteCreatedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String noteId,
    String title,
    String? workItemId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$NoteCreatedImplCopyWithImpl<$Res>
    extends _$NoteCreatedCopyWithImpl<$Res, _$NoteCreatedImpl>
    implements _$$NoteCreatedImplCopyWith<$Res> {
  __$$NoteCreatedImplCopyWithImpl(
    _$NoteCreatedImpl _value,
    $Res Function(_$NoteCreatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteCreated
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noteId = null,
    Object? title = null,
    Object? workItemId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$NoteCreatedImpl(
        noteId:
            null == noteId
                ? _value.noteId
                : noteId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        workItemId:
            freezed == workItemId
                ? _value.workItemId
                : workItemId // ignore: cast_nullable_to_non_nullable
                    as String?,
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

class _$NoteCreatedImpl extends _NoteCreated {
  const _$NoteCreatedImpl({
    required this.noteId,
    required this.title,
    this.workItemId,
    required this.timestamp,
  }) : super._();

  @override
  final String noteId;
  @override
  final String title;
  @override
  final String? workItemId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'NoteCreated(noteId: $noteId, title: $title, workItemId: $workItemId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteCreatedImpl &&
            (identical(other.noteId, noteId) || other.noteId == noteId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.workItemId, workItemId) ||
                other.workItemId == workItemId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, noteId, title, workItemId, timestamp);

  /// Create a copy of NoteCreated
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteCreatedImplCopyWith<_$NoteCreatedImpl> get copyWith =>
      __$$NoteCreatedImplCopyWithImpl<_$NoteCreatedImpl>(this, _$identity);
}

abstract class _NoteCreated extends NoteCreated {
  const factory _NoteCreated({
    required final String noteId,
    required final String title,
    final String? workItemId,
    required final DateTime timestamp,
  }) = _$NoteCreatedImpl;
  const _NoteCreated._() : super._();

  @override
  String get noteId;
  @override
  String get title;
  @override
  String? get workItemId;
  @override
  DateTime get timestamp;

  /// Create a copy of NoteCreated
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteCreatedImplCopyWith<_$NoteCreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NoteVersioned {
  String get noteId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get previousContent => throw _privateConstructorUsedError;
  String get newContent => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of NoteVersioned
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteVersionedCopyWith<NoteVersioned> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteVersionedCopyWith<$Res> {
  factory $NoteVersionedCopyWith(
    NoteVersioned value,
    $Res Function(NoteVersioned) then,
  ) = _$NoteVersionedCopyWithImpl<$Res, NoteVersioned>;
  @useResult
  $Res call({
    String noteId,
    String title,
    String previousContent,
    String newContent,
    DateTime timestamp,
  });
}

/// @nodoc
class _$NoteVersionedCopyWithImpl<$Res, $Val extends NoteVersioned>
    implements $NoteVersionedCopyWith<$Res> {
  _$NoteVersionedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteVersioned
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noteId = null,
    Object? title = null,
    Object? previousContent = null,
    Object? newContent = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            noteId:
                null == noteId
                    ? _value.noteId
                    : noteId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            previousContent:
                null == previousContent
                    ? _value.previousContent
                    : previousContent // ignore: cast_nullable_to_non_nullable
                        as String,
            newContent:
                null == newContent
                    ? _value.newContent
                    : newContent // ignore: cast_nullable_to_non_nullable
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
abstract class _$$NoteVersionedImplCopyWith<$Res>
    implements $NoteVersionedCopyWith<$Res> {
  factory _$$NoteVersionedImplCopyWith(
    _$NoteVersionedImpl value,
    $Res Function(_$NoteVersionedImpl) then,
  ) = __$$NoteVersionedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String noteId,
    String title,
    String previousContent,
    String newContent,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$NoteVersionedImplCopyWithImpl<$Res>
    extends _$NoteVersionedCopyWithImpl<$Res, _$NoteVersionedImpl>
    implements _$$NoteVersionedImplCopyWith<$Res> {
  __$$NoteVersionedImplCopyWithImpl(
    _$NoteVersionedImpl _value,
    $Res Function(_$NoteVersionedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteVersioned
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noteId = null,
    Object? title = null,
    Object? previousContent = null,
    Object? newContent = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$NoteVersionedImpl(
        noteId:
            null == noteId
                ? _value.noteId
                : noteId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        previousContent:
            null == previousContent
                ? _value.previousContent
                : previousContent // ignore: cast_nullable_to_non_nullable
                    as String,
        newContent:
            null == newContent
                ? _value.newContent
                : newContent // ignore: cast_nullable_to_non_nullable
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

class _$NoteVersionedImpl extends _NoteVersioned {
  const _$NoteVersionedImpl({
    required this.noteId,
    required this.title,
    required this.previousContent,
    required this.newContent,
    required this.timestamp,
  }) : super._();

  @override
  final String noteId;
  @override
  final String title;
  @override
  final String previousContent;
  @override
  final String newContent;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'NoteVersioned(noteId: $noteId, title: $title, previousContent: $previousContent, newContent: $newContent, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteVersionedImpl &&
            (identical(other.noteId, noteId) || other.noteId == noteId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.previousContent, previousContent) ||
                other.previousContent == previousContent) &&
            (identical(other.newContent, newContent) ||
                other.newContent == newContent) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    noteId,
    title,
    previousContent,
    newContent,
    timestamp,
  );

  /// Create a copy of NoteVersioned
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteVersionedImplCopyWith<_$NoteVersionedImpl> get copyWith =>
      __$$NoteVersionedImplCopyWithImpl<_$NoteVersionedImpl>(this, _$identity);
}

abstract class _NoteVersioned extends NoteVersioned {
  const factory _NoteVersioned({
    required final String noteId,
    required final String title,
    required final String previousContent,
    required final String newContent,
    required final DateTime timestamp,
  }) = _$NoteVersionedImpl;
  const _NoteVersioned._() : super._();

  @override
  String get noteId;
  @override
  String get title;
  @override
  String get previousContent;
  @override
  String get newContent;
  @override
  DateTime get timestamp;

  /// Create a copy of NoteVersioned
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteVersionedImplCopyWith<_$NoteVersionedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DocumentAttached {
  String get documentId => throw _privateConstructorUsedError;
  String get noteId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of DocumentAttached
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentAttachedCopyWith<DocumentAttached> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentAttachedCopyWith<$Res> {
  factory $DocumentAttachedCopyWith(
    DocumentAttached value,
    $Res Function(DocumentAttached) then,
  ) = _$DocumentAttachedCopyWithImpl<$Res, DocumentAttached>;
  @useResult
  $Res call({
    String documentId,
    String noteId,
    String fileName,
    DateTime timestamp,
  });
}

/// @nodoc
class _$DocumentAttachedCopyWithImpl<$Res, $Val extends DocumentAttached>
    implements $DocumentAttachedCopyWith<$Res> {
  _$DocumentAttachedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentAttached
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? noteId = null,
    Object? fileName = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            documentId:
                null == documentId
                    ? _value.documentId
                    : documentId // ignore: cast_nullable_to_non_nullable
                        as String,
            noteId:
                null == noteId
                    ? _value.noteId
                    : noteId // ignore: cast_nullable_to_non_nullable
                        as String,
            fileName:
                null == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DocumentAttachedImplCopyWith<$Res>
    implements $DocumentAttachedCopyWith<$Res> {
  factory _$$DocumentAttachedImplCopyWith(
    _$DocumentAttachedImpl value,
    $Res Function(_$DocumentAttachedImpl) then,
  ) = __$$DocumentAttachedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String documentId,
    String noteId,
    String fileName,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$DocumentAttachedImplCopyWithImpl<$Res>
    extends _$DocumentAttachedCopyWithImpl<$Res, _$DocumentAttachedImpl>
    implements _$$DocumentAttachedImplCopyWith<$Res> {
  __$$DocumentAttachedImplCopyWithImpl(
    _$DocumentAttachedImpl _value,
    $Res Function(_$DocumentAttachedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentAttached
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? noteId = null,
    Object? fileName = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$DocumentAttachedImpl(
        documentId:
            null == documentId
                ? _value.documentId
                : documentId // ignore: cast_nullable_to_non_nullable
                    as String,
        noteId:
            null == noteId
                ? _value.noteId
                : noteId // ignore: cast_nullable_to_non_nullable
                    as String,
        fileName:
            null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
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

class _$DocumentAttachedImpl extends _DocumentAttached {
  const _$DocumentAttachedImpl({
    required this.documentId,
    required this.noteId,
    required this.fileName,
    required this.timestamp,
  }) : super._();

  @override
  final String documentId;
  @override
  final String noteId;
  @override
  final String fileName;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'DocumentAttached(documentId: $documentId, noteId: $noteId, fileName: $fileName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentAttachedImpl &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.noteId, noteId) || other.noteId == noteId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, documentId, noteId, fileName, timestamp);

  /// Create a copy of DocumentAttached
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentAttachedImplCopyWith<_$DocumentAttachedImpl> get copyWith =>
      __$$DocumentAttachedImplCopyWithImpl<_$DocumentAttachedImpl>(
        this,
        _$identity,
      );
}

abstract class _DocumentAttached extends DocumentAttached {
  const factory _DocumentAttached({
    required final String documentId,
    required final String noteId,
    required final String fileName,
    required final DateTime timestamp,
  }) = _$DocumentAttachedImpl;
  const _DocumentAttached._() : super._();

  @override
  String get documentId;
  @override
  String get noteId;
  @override
  String get fileName;
  @override
  DateTime get timestamp;

  /// Create a copy of DocumentAttached
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentAttachedImplCopyWith<_$DocumentAttachedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
