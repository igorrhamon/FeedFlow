// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      feeds:
          (json['feeds'] as List<dynamic>?)
              ?.map((e) => Feed.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unreadCount': instance.unreadCount,
      'feeds': instance.feeds.map((e) => e.toJson()).toList(),
    };

_$UnreadCountImpl _$$UnreadCountImplFromJson(Map<String, dynamic> json) =>
    _$UnreadCountImpl(
      id: json['id'] as String,
      count: (json['count'] as num).toInt(),
      updated:
          json['updated'] == null
              ? null
              : DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$$UnreadCountImplToJson(_$UnreadCountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'updated': instance.updated?.toIso8601String(),
    };
