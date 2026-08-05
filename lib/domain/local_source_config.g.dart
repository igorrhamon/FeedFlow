// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_source_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalSourceConfigImpl _$$LocalSourceConfigImplFromJson(
  Map<String, dynamic> json,
) => _$LocalSourceConfigImpl(
  id: json['id'] as String,
  type: $enumDecode(_$LocalSourceTypeEnumMap, json['type']),
  path: json['path'] as String,
  label: json['label'] as String,
  enabled: json['enabled'] as bool? ?? true,
  lastSyncAt:
      json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$LocalSourceConfigImplToJson(
  _$LocalSourceConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$LocalSourceTypeEnumMap[instance.type]!,
  'path': instance.path,
  'label': instance.label,
  'enabled': instance.enabled,
  'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$LocalSourceTypeEnumMap = {
  LocalSourceType.folder: 'folder',
  LocalSourceType.markdownVault: 'markdownVault',
  LocalSourceType.pdf: 'pdf',
  LocalSourceType.office: 'office',
};
