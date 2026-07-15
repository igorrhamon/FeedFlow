// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuerySpecImpl _$$QuerySpecImplFromJson(Map<String, dynamic> json) =>
    _$QuerySpecImpl(
      filter: Condition.fromJson(json['filter'] as Map<String, dynamic>),
      sortField: json['sortField'] as String?,
      sortDescending: json['sortDescending'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuerySpecImplToJson(_$QuerySpecImpl instance) =>
    <String, dynamic>{
      'filter': instance.filter.toJson(),
      'sortField': instance.sortField,
      'sortDescending': instance.sortDescending,
    };
