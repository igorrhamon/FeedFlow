// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentImpl _$$DocumentImplFromJson(Map<String, dynamic> json) =>
    _$DocumentImpl(
      id: json['id'] as String,
      sourceConnectorId: json['sourceConnectorId'] as String,
      sourceId: json['sourceId'] as String,
      contentType: json['contentType'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      rawContent: json['rawContent'] as String?,
      url: json['url'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      metadataJson: json['metadataJson'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
    );

Map<String, dynamic> _$$DocumentImplToJson(_$DocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceConnectorId': instance.sourceConnectorId,
      'sourceId': instance.sourceId,
      'contentType': instance.contentType,
      'title': instance.title,
      'author': instance.author,
      'rawContent': instance.rawContent,
      'url': instance.url,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'metadataJson': instance.metadataJson,
      'isRead': instance.isRead,
      'isStarred': instance.isStarred,
    };
