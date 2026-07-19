// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuerySortImpl _$$QuerySortImplFromJson(Map<String, dynamic> json) =>
    _$QuerySortImpl(
      field: json['field'] as String,
      descending: json['descending'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuerySortImplToJson(_$QuerySortImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'descending': instance.descending,
    };

_$QuerySpecImpl _$$QuerySpecImplFromJson(Map<String, dynamic> json) =>
    _$QuerySpecImpl(
      filter: Condition.fromJson(json['filter'] as Map<String, dynamic>),
      sort:
          (json['sort'] as List<dynamic>?)
              ?.map((e) => QuerySort.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuerySort>[],
      limit: (json['limit'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$QuerySpecImplToJson(_$QuerySpecImpl instance) =>
    <String, dynamic>{
      'filter': instance.filter.toJson(),
      'sort': instance.sort.map((e) => e.toJson()).toList(),
      'limit': instance.limit,
    };
