// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  payload: json['payload'] as Map<String, dynamic>? ?? const {},
  status:
      $enumDecodeNullable(_$JobStatusEnumMap, json['status']) ??
      JobStatus.pending,
  dependsOn:
      (json['dependsOn'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 3,
  nextRunAt: DateTime.parse(json['nextRunAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'payload': instance.payload,
  'status': _$JobStatusEnumMap[instance.status]!,
  'dependsOn': instance.dependsOn,
  'attempts': instance.attempts,
  'maxAttempts': instance.maxAttempts,
  'nextRunAt': instance.nextRunAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$JobStatusEnumMap = {
  JobStatus.pending: 'pending',
  JobStatus.running: 'running',
  JobStatus.done: 'done',
  JobStatus.failed: 'failed',
};

_$JobRunImpl _$$JobRunImplFromJson(Map<String, dynamic> json) => _$JobRunImpl(
  id: (json['id'] as num?)?.toInt(),
  jobId: json['jobId'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  finishedAt:
      json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
  success: json['success'] as bool? ?? false,
  error: json['error'] as String?,
);

Map<String, dynamic> _$$JobRunImplToJson(_$JobRunImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'startedAt': instance.startedAt.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
      'success': instance.success,
      'error': instance.error,
    };
