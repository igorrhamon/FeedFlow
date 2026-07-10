// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkItemsTable extends WorkItems
    with TableInfo<$WorkItemsTable, WorkItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedMeta = const VerificationMeta(
    'published',
  );
  @override
  late final GeneratedColumn<DateTime> published = GeneratedColumn<DateTime>(
    'published',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('novo'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingestedAtMeta = const VerificationMeta(
    'ingestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ingestedAt = GeneratedColumn<DateTime>(
    'ingested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    tagsJson,
    isRead,
    isStarred,
    snoozedUntil,
    notes,
    ingestedAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('published')) {
      context.handle(
        _publishedMeta,
        published.isAcceptableOrUnknown(data['published']!, _publishedMeta),
      );
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('ingested_at')) {
      context.handle(
        _ingestedAtMeta,
        ingestedAt.isAcceptableOrUnknown(data['ingested_at']!, _ingestedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_ingestedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkItemRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      providerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}provider_id'],
          )!,
      articleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}article_id'],
          )!,
      feedId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}feed_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      published: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published'],
      ),
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      priority:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}priority'],
          )!,
      tagsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tags_json'],
          )!,
      isRead:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_read'],
          )!,
      isStarred:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_starred'],
          )!,
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      ingestedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ingested_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $WorkItemsTable createAlias(String alias) {
    return $WorkItemsTable(attachedDatabase, alias);
  }
}

class WorkItemRow extends DataClass implements Insertable<WorkItemRow> {
  final String id;
  final String providerId;
  final String articleId;
  final String feedId;
  final String title;
  final String? author;
  final String? summary;
  final String? content;
  final String? url;
  final DateTime? published;
  final DateTime? updated;
  final String status;
  final String priority;

  /// Lista de tags serializada como JSON (`["a","b"]`).
  final String tagsJson;
  final bool isRead;
  final bool isStarred;
  final DateTime? snoozedUntil;
  final String? notes;
  final DateTime ingestedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const WorkItemRow({
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
    required this.status,
    required this.priority,
    required this.tagsJson,
    required this.isRead,
    required this.isStarred,
    this.snoozedUntil,
    this.notes,
    required this.ingestedAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['article_id'] = Variable<String>(articleId);
    map['feed_id'] = Variable<String>(feedId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || published != null) {
      map['published'] = Variable<DateTime>(published);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['tags_json'] = Variable<String>(tagsJson);
    map['is_read'] = Variable<bool>(isRead);
    map['is_starred'] = Variable<bool>(isStarred);
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['ingested_at'] = Variable<DateTime>(ingestedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  WorkItemsCompanion toCompanion(bool nullToAbsent) {
    return WorkItemsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      articleId: Value(articleId),
      feedId: Value(feedId),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      summary:
          summary == null && nullToAbsent
              ? const Value.absent()
              : Value(summary),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      published:
          published == null && nullToAbsent
              ? const Value.absent()
              : Value(published),
      updated:
          updated == null && nullToAbsent
              ? const Value.absent()
              : Value(updated),
      status: Value(status),
      priority: Value(priority),
      tagsJson: Value(tagsJson),
      isRead: Value(isRead),
      isStarred: Value(isStarred),
      snoozedUntil:
          snoozedUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(snoozedUntil),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      ingestedAt: Value(ingestedAt),
      updatedAt: Value(updatedAt),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
    );
  }

  factory WorkItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkItemRow(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      feedId: serializer.fromJson<String>(json['feedId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String?>(json['summary']),
      content: serializer.fromJson<String?>(json['content']),
      url: serializer.fromJson<String?>(json['url']),
      published: serializer.fromJson<DateTime?>(json['published']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      notes: serializer.fromJson<String?>(json['notes']),
      ingestedAt: serializer.fromJson<DateTime>(json['ingestedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'articleId': serializer.toJson<String>(articleId),
      'feedId': serializer.toJson<String>(feedId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String?>(summary),
      'content': serializer.toJson<String?>(content),
      'url': serializer.toJson<String?>(url),
      'published': serializer.toJson<DateTime?>(published),
      'updated': serializer.toJson<DateTime?>(updated),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'isRead': serializer.toJson<bool>(isRead),
      'isStarred': serializer.toJson<bool>(isStarred),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'notes': serializer.toJson<String?>(notes),
      'ingestedAt': serializer.toJson<DateTime>(ingestedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  WorkItemRow copyWith({
    String? id,
    String? providerId,
    String? articleId,
    String? feedId,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<DateTime?> published = const Value.absent(),
    Value<DateTime?> updated = const Value.absent(),
    String? status,
    String? priority,
    String? tagsJson,
    bool? isRead,
    bool? isStarred,
    Value<DateTime?> snoozedUntil = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? ingestedAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => WorkItemRow(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    articleId: articleId ?? this.articleId,
    feedId: feedId ?? this.feedId,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    summary: summary.present ? summary.value : this.summary,
    content: content.present ? content.value : this.content,
    url: url.present ? url.value : this.url,
    published: published.present ? published.value : this.published,
    updated: updated.present ? updated.value : this.updated,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    tagsJson: tagsJson ?? this.tagsJson,
    isRead: isRead ?? this.isRead,
    isStarred: isStarred ?? this.isStarred,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    notes: notes.present ? notes.value : this.notes,
    ingestedAt: ingestedAt ?? this.ingestedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  WorkItemRow copyWithCompanion(WorkItemsCompanion data) {
    return WorkItemRow(
      id: data.id.present ? data.id.value : this.id,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      content: data.content.present ? data.content.value : this.content,
      url: data.url.present ? data.url.value : this.url,
      published: data.published.present ? data.published.value : this.published,
      updated: data.updated.present ? data.updated.value : this.updated,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      snoozedUntil:
          data.snoozedUntil.present
              ? data.snoozedUntil.value
              : this.snoozedUntil,
      notes: data.notes.present ? data.notes.value : this.notes,
      ingestedAt:
          data.ingestedAt.present ? data.ingestedAt.value : this.ingestedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemRow(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('articleId: $articleId, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('published: $published, ')
          ..write('updated: $updated, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notes: $notes, ')
          ..write('ingestedAt: $ingestedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    tagsJson,
    isRead,
    isStarred,
    snoozedUntil,
    notes,
    ingestedAt,
    updatedAt,
    completedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkItemRow &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.articleId == this.articleId &&
          other.feedId == this.feedId &&
          other.title == this.title &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.content == this.content &&
          other.url == this.url &&
          other.published == this.published &&
          other.updated == this.updated &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.tagsJson == this.tagsJson &&
          other.isRead == this.isRead &&
          other.isStarred == this.isStarred &&
          other.snoozedUntil == this.snoozedUntil &&
          other.notes == this.notes &&
          other.ingestedAt == this.ingestedAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class WorkItemsCompanion extends UpdateCompanion<WorkItemRow> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> articleId;
  final Value<String> feedId;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> summary;
  final Value<String?> content;
  final Value<String?> url;
  final Value<DateTime?> published;
  final Value<DateTime?> updated;
  final Value<String> status;
  final Value<String> priority;
  final Value<String> tagsJson;
  final Value<bool> isRead;
  final Value<bool> isStarred;
  final Value<DateTime?> snoozedUntil;
  final Value<String?> notes;
  final Value<DateTime> ingestedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const WorkItemsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.published = const Value.absent(),
    this.updated = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notes = const Value.absent(),
    this.ingestedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkItemsCompanion.insert({
    required String id,
    required String providerId,
    required String articleId,
    required String feedId,
    required String title,
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.published = const Value.absent(),
    this.updated = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime ingestedAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       articleId = Value(articleId),
       feedId = Value(feedId),
       title = Value(title),
       ingestedAt = Value(ingestedAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkItemRow> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? articleId,
    Expression<String>? feedId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? summary,
    Expression<String>? content,
    Expression<String>? url,
    Expression<DateTime>? published,
    Expression<DateTime>? updated,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? tagsJson,
    Expression<bool>? isRead,
    Expression<bool>? isStarred,
    Expression<DateTime>? snoozedUntil,
    Expression<String>? notes,
    Expression<DateTime>? ingestedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (articleId != null) 'article_id': articleId,
      if (feedId != null) 'feed_id': feedId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (published != null) 'published': published,
      if (updated != null) 'updated': updated,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (isRead != null) 'is_read': isRead,
      if (isStarred != null) 'is_starred': isStarred,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (notes != null) 'notes': notes,
      if (ingestedAt != null) 'ingested_at': ingestedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? articleId,
    Value<String>? feedId,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? summary,
    Value<String?>? content,
    Value<String?>? url,
    Value<DateTime?>? published,
    Value<DateTime?>? updated,
    Value<String>? status,
    Value<String>? priority,
    Value<String>? tagsJson,
    Value<bool>? isRead,
    Value<bool>? isStarred,
    Value<DateTime?>? snoozedUntil,
    Value<String?>? notes,
    Value<DateTime>? ingestedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkItemsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      articleId: articleId ?? this.articleId,
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      url: url ?? this.url,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tagsJson: tagsJson ?? this.tagsJson,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      notes: notes ?? this.notes,
      ingestedAt: ingestedAt ?? this.ingestedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (published.present) {
      map['published'] = Variable<DateTime>(published.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (ingestedAt.present) {
      map['ingested_at'] = Variable<DateTime>(ingestedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('articleId: $articleId, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('published: $published, ')
          ..write('updated: $updated, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notes: $notes, ')
          ..write('ingestedAt: $ingestedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkItemEventsTable extends WorkItemEvents
    with TableInfo<$WorkItemEventsTable, WorkItemEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkItemEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workItemIdMeta = const VerificationMeta(
    'workItemId',
  );
  @override
  late final GeneratedColumn<String> workItemId = GeneratedColumn<String>(
    'work_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorMeta = const VerificationMeta('actor');
  @override
  late final GeneratedColumn<String> actor = GeneratedColumn<String>(
    'actor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workItemId,
    timestamp,
    type,
    actor,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_item_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkItemEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_item_id')) {
      context.handle(
        _workItemIdMeta,
        workItemId.isAcceptableOrUnknown(
          data['work_item_id']!,
          _workItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workItemIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('actor')) {
      context.handle(
        _actorMeta,
        actor.isAcceptableOrUnknown(data['actor']!, _actorMeta),
      );
    } else if (isInserting) {
      context.missing(_actorMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkItemEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkItemEvent(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      workItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}work_item_id'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      actor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}actor'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
    );
  }

  @override
  $WorkItemEventsTable createAlias(String alias) {
    return $WorkItemEventsTable(attachedDatabase, alias);
  }
}

class WorkItemEvent extends DataClass implements Insertable<WorkItemEvent> {
  final int id;
  final String workItemId;
  final DateTime timestamp;

  /// statusChanged | snoozed | snoozeExpired | actionExecuted | ruleMatched | ingested
  final String type;

  /// user | rule | sync
  final String actor;
  final String payloadJson;
  const WorkItemEvent({
    required this.id,
    required this.workItemId,
    required this.timestamp,
    required this.type,
    required this.actor,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_item_id'] = Variable<String>(workItemId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['type'] = Variable<String>(type);
    map['actor'] = Variable<String>(actor);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  WorkItemEventsCompanion toCompanion(bool nullToAbsent) {
    return WorkItemEventsCompanion(
      id: Value(id),
      workItemId: Value(workItemId),
      timestamp: Value(timestamp),
      type: Value(type),
      actor: Value(actor),
      payloadJson: Value(payloadJson),
    );
  }

  factory WorkItemEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkItemEvent(
      id: serializer.fromJson<int>(json['id']),
      workItemId: serializer.fromJson<String>(json['workItemId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      type: serializer.fromJson<String>(json['type']),
      actor: serializer.fromJson<String>(json['actor']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workItemId': serializer.toJson<String>(workItemId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'type': serializer.toJson<String>(type),
      'actor': serializer.toJson<String>(actor),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  WorkItemEvent copyWith({
    int? id,
    String? workItemId,
    DateTime? timestamp,
    String? type,
    String? actor,
    String? payloadJson,
  }) => WorkItemEvent(
    id: id ?? this.id,
    workItemId: workItemId ?? this.workItemId,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    actor: actor ?? this.actor,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  WorkItemEvent copyWithCompanion(WorkItemEventsCompanion data) {
    return WorkItemEvent(
      id: data.id.present ? data.id.value : this.id,
      workItemId:
          data.workItemId.present ? data.workItemId.value : this.workItemId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
      actor: data.actor.present ? data.actor.value : this.actor,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemEvent(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('actor: $actor, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workItemId, timestamp, type, actor, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkItemEvent &&
          other.id == this.id &&
          other.workItemId == this.workItemId &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.actor == this.actor &&
          other.payloadJson == this.payloadJson);
}

class WorkItemEventsCompanion extends UpdateCompanion<WorkItemEvent> {
  final Value<int> id;
  final Value<String> workItemId;
  final Value<DateTime> timestamp;
  final Value<String> type;
  final Value<String> actor;
  final Value<String> payloadJson;
  const WorkItemEventsCompanion({
    this.id = const Value.absent(),
    this.workItemId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
    this.actor = const Value.absent(),
    this.payloadJson = const Value.absent(),
  });
  WorkItemEventsCompanion.insert({
    this.id = const Value.absent(),
    required String workItemId,
    required DateTime timestamp,
    required String type,
    required String actor,
    this.payloadJson = const Value.absent(),
  }) : workItemId = Value(workItemId),
       timestamp = Value(timestamp),
       type = Value(type),
       actor = Value(actor);
  static Insertable<WorkItemEvent> custom({
    Expression<int>? id,
    Expression<String>? workItemId,
    Expression<DateTime>? timestamp,
    Expression<String>? type,
    Expression<String>? actor,
    Expression<String>? payloadJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workItemId != null) 'work_item_id': workItemId,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
      if (actor != null) 'actor': actor,
      if (payloadJson != null) 'payload_json': payloadJson,
    });
  }

  WorkItemEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? workItemId,
    Value<DateTime>? timestamp,
    Value<String>? type,
    Value<String>? actor,
    Value<String>? payloadJson,
  }) {
    return WorkItemEventsCompanion(
      id: id ?? this.id,
      workItemId: workItemId ?? this.workItemId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      actor: actor ?? this.actor,
      payloadJson: payloadJson ?? this.payloadJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workItemId.present) {
      map['work_item_id'] = Variable<String>(workItemId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (actor.present) {
      map['actor'] = Variable<String>(actor.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemEventsCompanion(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('actor: $actor, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }
}

class $EnrichmentsTable extends Enrichments
    with TableInfo<$EnrichmentsTable, EnrichmentsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrichmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workItemIdMeta = const VerificationMeta(
    'workItemId',
  );
  @override
  late final GeneratedColumn<String> workItemId = GeneratedColumn<String>(
    'work_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workItemId,
    type,
    content,
    model,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrichments';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnrichmentsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_item_id')) {
      context.handle(
        _workItemIdMeta,
        workItemId.isAcceptableOrUnknown(
          data['work_item_id']!,
          _workItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workItemIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnrichmentsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnrichmentsData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      workItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}work_item_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $EnrichmentsTable createAlias(String alias) {
    return $EnrichmentsTable(attachedDatabase, alias);
  }
}

class EnrichmentsData extends DataClass implements Insertable<EnrichmentsData> {
  final int id;
  final String workItemId;

  /// summary | translation | classification | entities | suggestion
  final String type;
  final String content;
  final String? model;
  final DateTime createdAt;
  const EnrichmentsData({
    required this.id,
    required this.workItemId,
    required this.type,
    required this.content,
    this.model,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_item_id'] = Variable<String>(workItemId);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EnrichmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrichmentsCompanion(
      id: Value(id),
      workItemId: Value(workItemId),
      type: Value(type),
      content: Value(content),
      model:
          model == null && nullToAbsent ? const Value.absent() : Value(model),
      createdAt: Value(createdAt),
    );
  }

  factory EnrichmentsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnrichmentsData(
      id: serializer.fromJson<int>(json['id']),
      workItemId: serializer.fromJson<String>(json['workItemId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      model: serializer.fromJson<String?>(json['model']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workItemId': serializer.toJson<String>(workItemId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'model': serializer.toJson<String?>(model),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EnrichmentsData copyWith({
    int? id,
    String? workItemId,
    String? type,
    String? content,
    Value<String?> model = const Value.absent(),
    DateTime? createdAt,
  }) => EnrichmentsData(
    id: id ?? this.id,
    workItemId: workItemId ?? this.workItemId,
    type: type ?? this.type,
    content: content ?? this.content,
    model: model.present ? model.value : this.model,
    createdAt: createdAt ?? this.createdAt,
  );
  EnrichmentsData copyWithCompanion(EnrichmentsCompanion data) {
    return EnrichmentsData(
      id: data.id.present ? data.id.value : this.id,
      workItemId:
          data.workItemId.present ? data.workItemId.value : this.workItemId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnrichmentsData(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workItemId, type, content, model, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnrichmentsData &&
          other.id == this.id &&
          other.workItemId == this.workItemId &&
          other.type == this.type &&
          other.content == this.content &&
          other.model == this.model &&
          other.createdAt == this.createdAt);
}

class EnrichmentsCompanion extends UpdateCompanion<EnrichmentsData> {
  final Value<int> id;
  final Value<String> workItemId;
  final Value<String> type;
  final Value<String> content;
  final Value<String?> model;
  final Value<DateTime> createdAt;
  const EnrichmentsCompanion({
    this.id = const Value.absent(),
    this.workItemId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EnrichmentsCompanion.insert({
    this.id = const Value.absent(),
    required String workItemId,
    required String type,
    required String content,
    this.model = const Value.absent(),
    required DateTime createdAt,
  }) : workItemId = Value(workItemId),
       type = Value(type),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<EnrichmentsData> custom({
    Expression<int>? id,
    Expression<String>? workItemId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? model,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workItemId != null) 'work_item_id': workItemId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EnrichmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? workItemId,
    Value<String>? type,
    Value<String>? content,
    Value<String?>? model,
    Value<DateTime>? createdAt,
  }) {
    return EnrichmentsCompanion(
      id: id ?? this.id,
      workItemId: workItemId ?? this.workItemId,
      type: type ?? this.type,
      content: content ?? this.content,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workItemId.present) {
      map['work_item_id'] = Variable<String>(workItemId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrichmentsCompanion(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workItemIdMeta = const VerificationMeta(
    'workItemId',
  );
  @override
  late final GeneratedColumn<String> workItemId = GeneratedColumn<String>(
    'work_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workItemId,
    articleId,
    action,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_item_id')) {
      context.handle(
        _workItemIdMeta,
        workItemId.isAcceptableOrUnknown(
          data['work_item_id']!,
          _workItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workItemIdMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntryRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      workItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}work_item_id'],
          )!,
      articleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}article_id'],
          )!,
      action:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}action'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      attempts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attempts'],
          )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntryRow extends DataClass implements Insertable<OutboxEntryRow> {
  final int id;
  final String workItemId;
  final String articleId;

  /// markRead | markUnread | star | unstar
  final String action;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const OutboxEntryRow({
    required this.id,
    required this.workItemId,
    required this.articleId,
    required this.action,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_item_id'] = Variable<String>(workItemId);
    map['article_id'] = Variable<String>(articleId);
    map['action'] = Variable<String>(action);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      workItemId: Value(workItemId),
      articleId: Value(articleId),
      action: Value(action),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
    );
  }

  factory OutboxEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntryRow(
      id: serializer.fromJson<int>(json['id']),
      workItemId: serializer.fromJson<String>(json['workItemId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      action: serializer.fromJson<String>(json['action']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workItemId': serializer.toJson<String>(workItemId),
      'articleId': serializer.toJson<String>(articleId),
      'action': serializer.toJson<String>(action),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntryRow copyWith({
    int? id,
    String? workItemId,
    String? articleId,
    String? action,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntryRow(
    id: id ?? this.id,
    workItemId: workItemId ?? this.workItemId,
    articleId: articleId ?? this.articleId,
    action: action ?? this.action,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntryRow copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntryRow(
      id: data.id.present ? data.id.value : this.id,
      workItemId:
          data.workItemId.present ? data.workItemId.value : this.workItemId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      action: data.action.present ? data.action.value : this.action,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntryRow(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('articleId: $articleId, ')
          ..write('action: $action, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workItemId,
    articleId,
    action,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntryRow &&
          other.id == this.id &&
          other.workItemId == this.workItemId &&
          other.articleId == this.articleId &&
          other.action == this.action &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntryRow> {
  final Value<int> id;
  final Value<String> workItemId;
  final Value<String> articleId;
  final Value<String> action;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.workItemId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.action = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String workItemId,
    required String articleId,
    required String action,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : workItemId = Value(workItemId),
       articleId = Value(articleId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntryRow> custom({
    Expression<int>? id,
    Expression<String>? workItemId,
    Expression<String>? articleId,
    Expression<String>? action,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workItemId != null) 'work_item_id': workItemId,
      if (articleId != null) 'article_id': articleId,
      if (action != null) 'action': action,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? workItemId,
    Value<String>? articleId,
    Value<String>? action,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      workItemId: workItemId ?? this.workItemId,
      articleId: articleId ?? this.articleId,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workItemId.present) {
      map['work_item_id'] = Variable<String>(workItemId.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('workItemId: $workItemId, ')
          ..write('articleId: $articleId, ')
          ..write('action: $action, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _triggerTypeMeta = const VerificationMeta(
    'triggerType',
  );
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
    'trigger_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionsJsonMeta = const VerificationMeta(
    'conditionsJson',
  );
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
    'conditions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionsJsonMeta = const VerificationMeta(
    'actionsJson',
  );
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
    'actions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopOnMatchMeta = const VerificationMeta(
    'stopOnMatch',
  );
  @override
  late final GeneratedColumn<bool> stopOnMatch = GeneratedColumn<bool>(
    'stop_on_match',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stop_on_match" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    enabled,
    triggerType,
    conditionsJson,
    actionsJson,
    stopOnMatch,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
        _triggerTypeMeta,
        triggerType.isAcceptableOrUnknown(
          data['trigger_type']!,
          _triggerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
        _conditionsJsonMeta,
        conditionsJson.isAcceptableOrUnknown(
          data['conditions_json']!,
          _conditionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionsJsonMeta);
    }
    if (data.containsKey('actions_json')) {
      context.handle(
        _actionsJsonMeta,
        actionsJson.isAcceptableOrUnknown(
          data['actions_json']!,
          _actionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionsJsonMeta);
    }
    if (data.containsKey('stop_on_match')) {
      context.handle(
        _stopOnMatchMeta,
        stopOnMatch.isAcceptableOrUnknown(
          data['stop_on_match']!,
          _stopOnMatchMeta,
        ),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      enabled:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}enabled'],
          )!,
      triggerType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}trigger_type'],
          )!,
      conditionsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}conditions_json'],
          )!,
      actionsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}actions_json'],
          )!,
      stopOnMatch:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}stop_on_match'],
          )!,
      order:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}order'],
          )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class RuleRow extends DataClass implements Insertable<RuleRow> {
  final String id;
  final String name;
  final bool enabled;

  /// onIngested | onStatusChanged | manual | schedule
  final String triggerType;

  /// JSON serializado de Condition — desserializa com `Condition.fromJson`
  final String conditionsJson;

  /// JSON serializado de List<ActionInvocation> — desserializa com
  /// `jsonDecode` e `ActionInvocation.fromJson` em loop
  final String actionsJson;
  final bool stopOnMatch;
  final int order;
  const RuleRow({
    required this.id,
    required this.name,
    required this.enabled,
    required this.triggerType,
    required this.conditionsJson,
    required this.actionsJson,
    required this.stopOnMatch,
    required this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['enabled'] = Variable<bool>(enabled);
    map['trigger_type'] = Variable<String>(triggerType);
    map['conditions_json'] = Variable<String>(conditionsJson);
    map['actions_json'] = Variable<String>(actionsJson);
    map['stop_on_match'] = Variable<bool>(stopOnMatch);
    map['order'] = Variable<int>(order);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      name: Value(name),
      enabled: Value(enabled),
      triggerType: Value(triggerType),
      conditionsJson: Value(conditionsJson),
      actionsJson: Value(actionsJson),
      stopOnMatch: Value(stopOnMatch),
      order: Value(order),
    );
  }

  factory RuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      conditionsJson: serializer.fromJson<String>(json['conditionsJson']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      stopOnMatch: serializer.fromJson<bool>(json['stopOnMatch']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enabled': serializer.toJson<bool>(enabled),
      'triggerType': serializer.toJson<String>(triggerType),
      'conditionsJson': serializer.toJson<String>(conditionsJson),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'stopOnMatch': serializer.toJson<bool>(stopOnMatch),
      'order': serializer.toJson<int>(order),
    };
  }

  RuleRow copyWith({
    String? id,
    String? name,
    bool? enabled,
    String? triggerType,
    String? conditionsJson,
    String? actionsJson,
    bool? stopOnMatch,
    int? order,
  }) => RuleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    triggerType: triggerType ?? this.triggerType,
    conditionsJson: conditionsJson ?? this.conditionsJson,
    actionsJson: actionsJson ?? this.actionsJson,
    stopOnMatch: stopOnMatch ?? this.stopOnMatch,
    order: order ?? this.order,
  );
  RuleRow copyWithCompanion(RulesCompanion data) {
    return RuleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      conditionsJson:
          data.conditionsJson.present
              ? data.conditionsJson.value
              : this.conditionsJson,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
      stopOnMatch:
          data.stopOnMatch.present ? data.stopOnMatch.value : this.stopOnMatch,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('triggerType: $triggerType, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('stopOnMatch: $stopOnMatch, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    enabled,
    triggerType,
    conditionsJson,
    actionsJson,
    stopOnMatch,
    order,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.enabled == this.enabled &&
          other.triggerType == this.triggerType &&
          other.conditionsJson == this.conditionsJson &&
          other.actionsJson == this.actionsJson &&
          other.stopOnMatch == this.stopOnMatch &&
          other.order == this.order);
}

class RulesCompanion extends UpdateCompanion<RuleRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> enabled;
  final Value<String> triggerType;
  final Value<String> conditionsJson;
  final Value<String> actionsJson;
  final Value<bool> stopOnMatch;
  final Value<int> order;
  final Value<int> rowid;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enabled = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.stopOnMatch = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RulesCompanion.insert({
    required String id,
    required String name,
    this.enabled = const Value.absent(),
    required String triggerType,
    required String conditionsJson,
    required String actionsJson,
    this.stopOnMatch = const Value.absent(),
    required int order,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       triggerType = Value(triggerType),
       conditionsJson = Value(conditionsJson),
       actionsJson = Value(actionsJson),
       order = Value(order);
  static Insertable<RuleRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? enabled,
    Expression<String>? triggerType,
    Expression<String>? conditionsJson,
    Expression<String>? actionsJson,
    Expression<bool>? stopOnMatch,
    Expression<int>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enabled != null) 'enabled': enabled,
      if (triggerType != null) 'trigger_type': triggerType,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (stopOnMatch != null) 'stop_on_match': stopOnMatch,
      if (order != null) 'order': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RulesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? enabled,
    Value<String>? triggerType,
    Value<String>? conditionsJson,
    Value<String>? actionsJson,
    Value<bool>? stopOnMatch,
    Value<int>? order,
    Value<int>? rowid,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      triggerType: triggerType ?? this.triggerType,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      actionsJson: actionsJson ?? this.actionsJson,
      stopOnMatch: stopOnMatch ?? this.stopOnMatch,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (stopOnMatch.present) {
      map['stop_on_match'] = Variable<bool>(stopOnMatch.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('triggerType: $triggerType, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('stopOnMatch: $stopOnMatch, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkItemsTable workItems = $WorkItemsTable(this);
  late final $WorkItemEventsTable workItemEvents = $WorkItemEventsTable(this);
  late final $EnrichmentsTable enrichments = $EnrichmentsTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $RulesTable rules = $RulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workItems,
    workItemEvents,
    enrichments,
    outboxEntries,
    rules,
  ];
}

typedef $$WorkItemsTableCreateCompanionBuilder =
    WorkItemsCompanion Function({
      required String id,
      required String providerId,
      required String articleId,
      required String feedId,
      required String title,
      Value<String?> author,
      Value<String?> summary,
      Value<String?> content,
      Value<String?> url,
      Value<DateTime?> published,
      Value<DateTime?> updated,
      Value<String> status,
      Value<String> priority,
      Value<String> tagsJson,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<DateTime?> snoozedUntil,
      Value<String?> notes,
      required DateTime ingestedAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$WorkItemsTableUpdateCompanionBuilder =
    WorkItemsCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> articleId,
      Value<String> feedId,
      Value<String> title,
      Value<String?> author,
      Value<String?> summary,
      Value<String?> content,
      Value<String?> url,
      Value<DateTime?> published,
      Value<DateTime?> updated,
      Value<String> status,
      Value<String> priority,
      Value<String> tagsJson,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<DateTime?> snoozedUntil,
      Value<String?> notes,
      Value<DateTime> ingestedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$WorkItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ingestedAt => $composableBuilder(
    column: $table.ingestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ingestedAt => $composableBuilder(
    column: $table.ingestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get ingestedAt => $composableBuilder(
    column: $table.ingestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$WorkItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkItemsTable,
          WorkItemRow,
          $$WorkItemsTableFilterComposer,
          $$WorkItemsTableOrderingComposer,
          $$WorkItemsTableAnnotationComposer,
          $$WorkItemsTableCreateCompanionBuilder,
          $$WorkItemsTableUpdateCompanionBuilder,
          (
            WorkItemRow,
            BaseReferences<_$AppDatabase, $WorkItemsTable, WorkItemRow>,
          ),
          WorkItemRow,
          PrefetchHooks Function()
        > {
  $$WorkItemsTableTableManager(_$AppDatabase db, $WorkItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WorkItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$WorkItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WorkItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> ingestedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkItemsCompanion(
                id: id,
                providerId: providerId,
                articleId: articleId,
                feedId: feedId,
                title: title,
                author: author,
                summary: summary,
                content: content,
                url: url,
                published: published,
                updated: updated,
                status: status,
                priority: priority,
                tagsJson: tagsJson,
                isRead: isRead,
                isStarred: isStarred,
                snoozedUntil: snoozedUntil,
                notes: notes,
                ingestedAt: ingestedAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String articleId,
                required String feedId,
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime ingestedAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkItemsCompanion.insert(
                id: id,
                providerId: providerId,
                articleId: articleId,
                feedId: feedId,
                title: title,
                author: author,
                summary: summary,
                content: content,
                url: url,
                published: published,
                updated: updated,
                status: status,
                priority: priority,
                tagsJson: tagsJson,
                isRead: isRead,
                isStarred: isStarred,
                snoozedUntil: snoozedUntil,
                notes: notes,
                ingestedAt: ingestedAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkItemsTable,
      WorkItemRow,
      $$WorkItemsTableFilterComposer,
      $$WorkItemsTableOrderingComposer,
      $$WorkItemsTableAnnotationComposer,
      $$WorkItemsTableCreateCompanionBuilder,
      $$WorkItemsTableUpdateCompanionBuilder,
      (
        WorkItemRow,
        BaseReferences<_$AppDatabase, $WorkItemsTable, WorkItemRow>,
      ),
      WorkItemRow,
      PrefetchHooks Function()
    >;
typedef $$WorkItemEventsTableCreateCompanionBuilder =
    WorkItemEventsCompanion Function({
      Value<int> id,
      required String workItemId,
      required DateTime timestamp,
      required String type,
      required String actor,
      Value<String> payloadJson,
    });
typedef $$WorkItemEventsTableUpdateCompanionBuilder =
    WorkItemEventsCompanion Function({
      Value<int> id,
      Value<String> workItemId,
      Value<DateTime> timestamp,
      Value<String> type,
      Value<String> actor,
      Value<String> payloadJson,
    });

class $$WorkItemEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkItemEventsTable> {
  $$WorkItemEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkItemEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkItemEventsTable> {
  $$WorkItemEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkItemEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkItemEventsTable> {
  $$WorkItemEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get actor =>
      $composableBuilder(column: $table.actor, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$WorkItemEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkItemEventsTable,
          WorkItemEvent,
          $$WorkItemEventsTableFilterComposer,
          $$WorkItemEventsTableOrderingComposer,
          $$WorkItemEventsTableAnnotationComposer,
          $$WorkItemEventsTableCreateCompanionBuilder,
          $$WorkItemEventsTableUpdateCompanionBuilder,
          (
            WorkItemEvent,
            BaseReferences<_$AppDatabase, $WorkItemEventsTable, WorkItemEvent>,
          ),
          WorkItemEvent,
          PrefetchHooks Function()
        > {
  $$WorkItemEventsTableTableManager(
    _$AppDatabase db,
    $WorkItemEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WorkItemEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$WorkItemEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WorkItemEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workItemId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> actor = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
              }) => WorkItemEventsCompanion(
                id: id,
                workItemId: workItemId,
                timestamp: timestamp,
                type: type,
                actor: actor,
                payloadJson: payloadJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workItemId,
                required DateTime timestamp,
                required String type,
                required String actor,
                Value<String> payloadJson = const Value.absent(),
              }) => WorkItemEventsCompanion.insert(
                id: id,
                workItemId: workItemId,
                timestamp: timestamp,
                type: type,
                actor: actor,
                payloadJson: payloadJson,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkItemEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkItemEventsTable,
      WorkItemEvent,
      $$WorkItemEventsTableFilterComposer,
      $$WorkItemEventsTableOrderingComposer,
      $$WorkItemEventsTableAnnotationComposer,
      $$WorkItemEventsTableCreateCompanionBuilder,
      $$WorkItemEventsTableUpdateCompanionBuilder,
      (
        WorkItemEvent,
        BaseReferences<_$AppDatabase, $WorkItemEventsTable, WorkItemEvent>,
      ),
      WorkItemEvent,
      PrefetchHooks Function()
    >;
typedef $$EnrichmentsTableCreateCompanionBuilder =
    EnrichmentsCompanion Function({
      Value<int> id,
      required String workItemId,
      required String type,
      required String content,
      Value<String?> model,
      required DateTime createdAt,
    });
typedef $$EnrichmentsTableUpdateCompanionBuilder =
    EnrichmentsCompanion Function({
      Value<int> id,
      Value<String> workItemId,
      Value<String> type,
      Value<String> content,
      Value<String?> model,
      Value<DateTime> createdAt,
    });

class $$EnrichmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrichmentsTable> {
  $$EnrichmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnrichmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrichmentsTable> {
  $$EnrichmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnrichmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrichmentsTable> {
  $$EnrichmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EnrichmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnrichmentsTable,
          EnrichmentsData,
          $$EnrichmentsTableFilterComposer,
          $$EnrichmentsTableOrderingComposer,
          $$EnrichmentsTableAnnotationComposer,
          $$EnrichmentsTableCreateCompanionBuilder,
          $$EnrichmentsTableUpdateCompanionBuilder,
          (
            EnrichmentsData,
            BaseReferences<_$AppDatabase, $EnrichmentsTable, EnrichmentsData>,
          ),
          EnrichmentsData,
          PrefetchHooks Function()
        > {
  $$EnrichmentsTableTableManager(_$AppDatabase db, $EnrichmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EnrichmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$EnrichmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$EnrichmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workItemId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EnrichmentsCompanion(
                id: id,
                workItemId: workItemId,
                type: type,
                content: content,
                model: model,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workItemId,
                required String type,
                required String content,
                Value<String?> model = const Value.absent(),
                required DateTime createdAt,
              }) => EnrichmentsCompanion.insert(
                id: id,
                workItemId: workItemId,
                type: type,
                content: content,
                model: model,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnrichmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnrichmentsTable,
      EnrichmentsData,
      $$EnrichmentsTableFilterComposer,
      $$EnrichmentsTableOrderingComposer,
      $$EnrichmentsTableAnnotationComposer,
      $$EnrichmentsTableCreateCompanionBuilder,
      $$EnrichmentsTableUpdateCompanionBuilder,
      (
        EnrichmentsData,
        BaseReferences<_$AppDatabase, $EnrichmentsTable, EnrichmentsData>,
      ),
      EnrichmentsData,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String workItemId,
      required String articleId,
      required String action,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> workItemId,
      Value<String> articleId,
      Value<String> action,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workItemId => $composableBuilder(
    column: $table.workItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntryRow,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntryRow,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
          ),
          OutboxEntryRow,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$OutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workItemId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                workItemId: workItemId,
                articleId: articleId,
                action: action,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workItemId,
                required String articleId,
                required String action,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                workItemId: workItemId,
                articleId: articleId,
                action: action,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntryRow,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntryRow,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
      ),
      OutboxEntryRow,
      PrefetchHooks Function()
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({
      required String id,
      required String name,
      Value<bool> enabled,
      required String triggerType,
      required String conditionsJson,
      required String actionsJson,
      Value<bool> stopOnMatch,
      required int order,
      Value<int> rowid,
    });
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> enabled,
      Value<String> triggerType,
      Value<String> conditionsJson,
      Value<String> actionsJson,
      Value<bool> stopOnMatch,
      Value<int> order,
      Value<int> rowid,
    });

class $$RulesTableFilterComposer extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stopOnMatch => $composableBuilder(
    column: $table.stopOnMatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stopOnMatch => $composableBuilder(
    column: $table.stopOnMatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get stopOnMatch => $composableBuilder(
    column: $table.stopOnMatch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RulesTable,
          RuleRow,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RuleRow, BaseReferences<_$AppDatabase, $RulesTable, RuleRow>),
          RuleRow,
          PrefetchHooks Function()
        > {
  $$RulesTableTableManager(_$AppDatabase db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<String> conditionsJson = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<bool> stopOnMatch = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                name: name,
                enabled: enabled,
                triggerType: triggerType,
                conditionsJson: conditionsJson,
                actionsJson: actionsJson,
                stopOnMatch: stopOnMatch,
                order: order,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> enabled = const Value.absent(),
                required String triggerType,
                required String conditionsJson,
                required String actionsJson,
                Value<bool> stopOnMatch = const Value.absent(),
                required int order,
                Value<int> rowid = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                name: name,
                enabled: enabled,
                triggerType: triggerType,
                conditionsJson: conditionsJson,
                actionsJson: actionsJson,
                stopOnMatch: stopOnMatch,
                order: order,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RulesTable,
      RuleRow,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RuleRow, BaseReferences<_$AppDatabase, $RulesTable, RuleRow>),
      RuleRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkItemsTableTableManager get workItems =>
      $$WorkItemsTableTableManager(_db, _db.workItems);
  $$WorkItemEventsTableTableManager get workItemEvents =>
      $$WorkItemEventsTableTableManager(_db, _db.workItemEvents);
  $$EnrichmentsTableTableManager get enrichments =>
      $$EnrichmentsTableTableManager(_db, _db.enrichments);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
}
