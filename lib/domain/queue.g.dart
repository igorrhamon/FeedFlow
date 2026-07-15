// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueImpl _$$QueueImplFromJson(Map<String, dynamic> json) => _$QueueImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  order: (json['order'] as num).toInt(),
  querySpec: QuerySpec.fromJson(json['querySpec'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$QueueImplToJson(_$QueueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'order': instance.order,
      'querySpec': instance.querySpec.toJson(),
    };
