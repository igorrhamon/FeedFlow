// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleImpl _$$ArticleImplFromJson(Map<String, dynamic> json) =>
    _$ArticleImpl(
      id: json['id'] as String,
      feedId: json['feedId'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      summary: json['summary'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      published:
          json['published'] == null
              ? null
              : DateTime.parse(json['published'] as String),
      updated:
          json['updated'] == null
              ? null
              : DateTime.parse(json['updated'] as String),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isRead: json['isRead'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ArticleImplToJson(_$ArticleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feedId': instance.feedId,
      'title': instance.title,
      'author': instance.author,
      'summary': instance.summary,
      'content': instance.content,
      'url': instance.url,
      'published': instance.published?.toIso8601String(),
      'updated': instance.updated?.toIso8601String(),
      'categories': instance.categories,
      'isRead': instance.isRead,
      'isStarred': instance.isStarred,
      'metadata': instance.metadata,
    };

_$ArticleListResultImpl _$$ArticleListResultImplFromJson(
  Map<String, dynamic> json,
) => _$ArticleListResultImpl(
  articles:
      (json['articles'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
  continuation: json['continuation'] as String?,
  totalCount: (json['totalCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ArticleListResultImplToJson(
  _$ArticleListResultImpl instance,
) => <String, dynamic>{
  'articles': instance.articles.map((e) => e.toJson()).toList(),
  'continuation': instance.continuation,
  'totalCount': instance.totalCount,
};
