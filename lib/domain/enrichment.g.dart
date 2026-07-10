// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrichment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnrichmentImpl _$$EnrichmentImplFromJson(Map<String, dynamic> json) =>
    _$EnrichmentImpl(
      id: (json['id'] as num).toInt(),
      workItemId: json['workItemId'] as String,
      type: $enumDecode(_$EnrichmentTypeEnumMap, json['type']),
      content: json['content'] as String,
      model: json['model'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EnrichmentImplToJson(_$EnrichmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workItemId': instance.workItemId,
      'type': _$EnrichmentTypeEnumMap[instance.type]!,
      'content': instance.content,
      'model': instance.model,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$EnrichmentTypeEnumMap = {
  EnrichmentType.summary: 'summary',
  EnrichmentType.translation: 'translation',
  EnrichmentType.classification: 'classification',
  EnrichmentType.entities: 'entities',
  EnrichmentType.suggestion: 'suggestion',
};
