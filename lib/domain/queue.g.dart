// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueImpl _$$QueueImplFromJson(Map<String, dynamic> json) => _$QueueImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  spec: QuerySpec.fromJson(json['spec'] as Map<String, dynamic>),
  order: (json['order'] as num).toInt(),
  iconName: json['iconName'] as String?,
);

Map<String, dynamic> _$$QueueImplToJson(_$QueueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'spec': instance.spec.toJson(),
      'order': instance.order,
      'iconName': instance.iconName,
    };
