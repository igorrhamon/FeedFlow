// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WorkItem {
  String get id => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get articleId => throw _privateConstructorUsedError;
  String get feedId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  DateTime? get published => throw _privateConstructorUsedError;
  DateTime? get updated => throw _privateConstructorUsedError;
  TriageStatus get status => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isStarred => throw _privateConstructorUsedError;
  DateTime? get snoozedUntil => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get ingestedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Create a copy of WorkItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkItemCopyWith<WorkItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkItemCopyWith<$Res> {
  factory $WorkItemCopyWith(WorkItem value, $Res Function(WorkItem) then) =
      _$WorkItemCopyWithImpl<$Res, WorkItem>;
  @useResult
  $Res call({
    String id,
    String providerId,
    String articleId,
    String feedId,
    String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    TriageStatus status,
    Priority priority,
    List<String> tags,
    bool isRead,
    bool isStarred,
    DateTime? snoozedUntil,
    String? notes,
    DateTime ingestedAt,
    DateTime updatedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$WorkItemCopyWithImpl<$Res, $Val extends WorkItem>
    implements $WorkItemCopyWith<$Res> {
  _$WorkItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? articleId = null,
    Object? feedId = null,
    Object? title = null,
    Object? author = freezed,
    Object? summary = freezed,
    Object? content = freezed,
    Object? url = freezed,
    Object? published = freezed,
    Object? updated = freezed,
    Object? status = null,
    Object? priority = null,
    Object? tags = null,
    Object? isRead = null,
    Object? isStarred = null,
    Object? snoozedUntil = freezed,
    Object? notes = freezed,
    Object? ingestedAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
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
            author:
                freezed == author
                    ? _value.author
                    : author // ignore: cast_nullable_to_non_nullable
                        as String?,
            summary:
                freezed == summary
                    ? _value.summary
                    : summary // ignore: cast_nullable_to_non_nullable
                        as String?,
            content:
                freezed == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String?,
            url:
                freezed == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String?,
            published:
                freezed == published
                    ? _value.published
                    : published // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updated:
                freezed == updated
                    ? _value.updated
                    : updated // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as TriageStatus,
            priority:
                null == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as Priority,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isRead:
                null == isRead
                    ? _value.isRead
                    : isRead // ignore: cast_nullable_to_non_nullable
                        as bool,
            isStarred:
                null == isStarred
                    ? _value.isStarred
                    : isStarred // ignore: cast_nullable_to_non_nullable
                        as bool,
            snoozedUntil:
                freezed == snoozedUntil
                    ? _value.snoozedUntil
                    : snoozedUntil // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            ingestedAt:
                null == ingestedAt
                    ? _value.ingestedAt
                    : ingestedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            completedAt:
                freezed == completedAt
                    ? _value.completedAt
                    : completedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkItemImplCopyWith<$Res>
    implements $WorkItemCopyWith<$Res> {
  factory _$$WorkItemImplCopyWith(
    _$WorkItemImpl value,
    $Res Function(_$WorkItemImpl) then,
  ) = __$$WorkItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String providerId,
    String articleId,
    String feedId,
    String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    TriageStatus status,
    Priority priority,
    List<String> tags,
    bool isRead,
    bool isStarred,
    DateTime? snoozedUntil,
    String? notes,
    DateTime ingestedAt,
    DateTime updatedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$WorkItemImplCopyWithImpl<$Res>
    extends _$WorkItemCopyWithImpl<$Res, _$WorkItemImpl>
    implements _$$WorkItemImplCopyWith<$Res> {
  __$$WorkItemImplCopyWithImpl(
    _$WorkItemImpl _value,
    $Res Function(_$WorkItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? articleId = null,
    Object? feedId = null,
    Object? title = null,
    Object? author = freezed,
    Object? summary = freezed,
    Object? content = freezed,
    Object? url = freezed,
    Object? published = freezed,
    Object? updated = freezed,
    Object? status = null,
    Object? priority = null,
    Object? tags = null,
    Object? isRead = null,
    Object? isStarred = null,
    Object? snoozedUntil = freezed,
    Object? notes = freezed,
    Object? ingestedAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$WorkItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
        author:
            freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                    as String?,
        summary:
            freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                    as String?,
        content:
            freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String?,
        url:
            freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String?,
        published:
            freezed == published
                ? _value.published
                : published // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updated:
            freezed == updated
                ? _value.updated
                : updated // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as TriageStatus,
        priority:
            null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as Priority,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isRead:
            null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                    as bool,
        isStarred:
            null == isStarred
                ? _value.isStarred
                : isStarred // ignore: cast_nullable_to_non_nullable
                    as bool,
        snoozedUntil:
            freezed == snoozedUntil
                ? _value.snoozedUntil
                : snoozedUntil // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        ingestedAt:
            null == ingestedAt
                ? _value.ingestedAt
                : ingestedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        completedAt:
            freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$WorkItemImpl extends _WorkItem {
  const _$WorkItemImpl({
    required this.id,
    required this.providerId,
    required this.articleId,
    required this.feedId,
    required this.title,
    this.author,
    this.summary,
    this.content,
    this.url,
    this.published,
    this.updated,
    this.status = TriageStatus.novo,
    this.priority = Priority.none,
    final List<String> tags = const [],
    this.isRead = false,
    this.isStarred = false,
    this.snoozedUntil,
    this.notes,
    required this.ingestedAt,
    required this.updatedAt,
    this.completedAt,
  }) : _tags = tags,
       super._();

  @override
  final String id;
  @override
  final String providerId;
  @override
  final String articleId;
  @override
  final String feedId;
  @override
  final String title;
  @override
  final String? author;
  @override
  final String? summary;
  @override
  final String? content;
  @override
  final String? url;
  @override
  final DateTime? published;
  @override
  final DateTime? updated;
  @override
  @JsonKey()
  final TriageStatus status;
  @override
  @JsonKey()
  final Priority priority;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isStarred;
  @override
  final DateTime? snoozedUntil;
  @override
  final String? notes;
  @override
  final DateTime ingestedAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'WorkItem(id: $id, providerId: $providerId, articleId: $articleId, feedId: $feedId, title: $title, author: $author, summary: $summary, content: $content, url: $url, published: $published, updated: $updated, status: $status, priority: $priority, tags: $tags, isRead: $isRead, isStarred: $isStarred, snoozedUntil: $snoozedUntil, notes: $notes, ingestedAt: $ingestedAt, updatedAt: $updatedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.articleId, articleId) ||
                other.articleId == articleId) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.published, published) ||
                other.published == published) &&
            (identical(other.updated, updated) || other.updated == updated) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            (identical(other.snoozedUntil, snoozedUntil) ||
                other.snoozedUntil == snoozedUntil) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.ingestedAt, ingestedAt) ||
                other.ingestedAt == ingestedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    providerId,
    articleId,
    feedId,
    title,
    author,
    summary,
    content,
    url,
    published,
    updated,
    status,
    priority,
    const DeepCollectionEquality().hash(_tags),
    isRead,
    isStarred,
    snoozedUntil,
    notes,
    ingestedAt,
    updatedAt,
    completedAt,
  ]);

  /// Create a copy of WorkItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkItemImplCopyWith<_$WorkItemImpl> get copyWith =>
      __$$WorkItemImplCopyWithImpl<_$WorkItemImpl>(this, _$identity);
}

abstract class _WorkItem extends WorkItem {
  const factory _WorkItem({
    required final String id,
    required final String providerId,
    required final String articleId,
    required final String feedId,
    required final String title,
    final String? author,
    final String? summary,
    final String? content,
    final String? url,
    final DateTime? published,
    final DateTime? updated,
    final TriageStatus status,
    final Priority priority,
    final List<String> tags,
    final bool isRead,
    final bool isStarred,
    final DateTime? snoozedUntil,
    final String? notes,
    required final DateTime ingestedAt,
    required final DateTime updatedAt,
    final DateTime? completedAt,
  }) = _$WorkItemImpl;
  const _WorkItem._() : super._();

  @override
  String get id;
  @override
  String get providerId;
  @override
  String get articleId;
  @override
  String get feedId;
  @override
  String get title;
  @override
  String? get author;
  @override
  String? get summary;
  @override
  String? get content;
  @override
  String? get url;
  @override
  DateTime? get published;
  @override
  DateTime? get updated;
  @override
  TriageStatus get status;
  @override
  Priority get priority;
  @override
  List<String> get tags;
  @override
  bool get isRead;
  @override
  bool get isStarred;
  @override
  DateTime? get snoozedUntil;
  @override
  String? get notes;
  @override
  DateTime get ingestedAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of WorkItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkItemImplCopyWith<_$WorkItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
