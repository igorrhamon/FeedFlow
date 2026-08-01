// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Job _$JobFromJson(Map<String, dynamic> json) {
  return _Job.fromJson(json);
}

/// @nodoc
mixin _$Job {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  List<String> get dependsOn => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get maxAttempts => throw _privateConstructorUsedError;
  DateTime get nextRunAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCopyWith<Job> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) then) =
      _$JobCopyWithImpl<$Res, Job>;
  @useResult
  $Res call({
    String id,
    String type,
    Map<String, dynamic> payload,
    JobStatus status,
    List<String> dependsOn,
    int attempts,
    int maxAttempts,
    DateTime nextRunAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$JobCopyWithImpl<$Res, $Val extends Job> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? payload = null,
    Object? status = null,
    Object? dependsOn = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? nextRunAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            payload:
                null == payload
                    ? _value.payload
                    : payload // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as JobStatus,
            dependsOn:
                null == dependsOn
                    ? _value.dependsOn
                    : dependsOn // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            attempts:
                null == attempts
                    ? _value.attempts
                    : attempts // ignore: cast_nullable_to_non_nullable
                        as int,
            maxAttempts:
                null == maxAttempts
                    ? _value.maxAttempts
                    : maxAttempts // ignore: cast_nullable_to_non_nullable
                        as int,
            nextRunAt:
                null == nextRunAt
                    ? _value.nextRunAt
                    : nextRunAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobImplCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$$JobImplCopyWith(_$JobImpl value, $Res Function(_$JobImpl) then) =
      __$$JobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    Map<String, dynamic> payload,
    JobStatus status,
    List<String> dependsOn,
    int attempts,
    int maxAttempts,
    DateTime nextRunAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$JobImplCopyWithImpl<$Res> extends _$JobCopyWithImpl<$Res, _$JobImpl>
    implements _$$JobImplCopyWith<$Res> {
  __$$JobImplCopyWithImpl(_$JobImpl _value, $Res Function(_$JobImpl) _then)
    : super(_value, _then);

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? payload = null,
    Object? status = null,
    Object? dependsOn = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? nextRunAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$JobImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        payload:
            null == payload
                ? _value._payload
                : payload // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as JobStatus,
        dependsOn:
            null == dependsOn
                ? _value._dependsOn
                : dependsOn // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        attempts:
            null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                    as int,
        maxAttempts:
            null == maxAttempts
                ? _value.maxAttempts
                : maxAttempts // ignore: cast_nullable_to_non_nullable
                    as int,
        nextRunAt:
            null == nextRunAt
                ? _value.nextRunAt
                : nextRunAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobImpl implements _Job {
  const _$JobImpl({
    required this.id,
    required this.type,
    final Map<String, dynamic> payload = const {},
    this.status = JobStatus.pending,
    final List<String> dependsOn = const [],
    this.attempts = 0,
    this.maxAttempts = 3,
    required this.nextRunAt,
    required this.createdAt,
  }) : _payload = payload,
       _dependsOn = dependsOn;

  factory _$JobImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  @JsonKey()
  final JobStatus status;
  final List<String> _dependsOn;
  @override
  @JsonKey()
  List<String> get dependsOn {
    if (_dependsOn is EqualUnmodifiableListView) return _dependsOn;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dependsOn);
  }

  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final int maxAttempts;
  @override
  final DateTime nextRunAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Job(id: $id, type: $type, payload: $payload, status: $status, dependsOn: $dependsOn, attempts: $attempts, maxAttempts: $maxAttempts, nextRunAt: $nextRunAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._dependsOn,
              _dependsOn,
            ) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.nextRunAt, nextRunAt) ||
                other.nextRunAt == nextRunAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    const DeepCollectionEquality().hash(_payload),
    status,
    const DeepCollectionEquality().hash(_dependsOn),
    attempts,
    maxAttempts,
    nextRunAt,
    createdAt,
  );

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      __$$JobImplCopyWithImpl<_$JobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobImplToJson(this);
  }
}

abstract class _Job implements Job {
  const factory _Job({
    required final String id,
    required final String type,
    final Map<String, dynamic> payload,
    final JobStatus status,
    final List<String> dependsOn,
    final int attempts,
    final int maxAttempts,
    required final DateTime nextRunAt,
    required final DateTime createdAt,
  }) = _$JobImpl;

  factory _Job.fromJson(Map<String, dynamic> json) = _$JobImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  Map<String, dynamic> get payload;
  @override
  JobStatus get status;
  @override
  List<String> get dependsOn;
  @override
  int get attempts;
  @override
  int get maxAttempts;
  @override
  DateTime get nextRunAt;
  @override
  DateTime get createdAt;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobRun _$JobRunFromJson(Map<String, dynamic> json) {
  return _JobRun.fromJson(json);
}

/// @nodoc
mixin _$JobRun {
  int? get id => throw _privateConstructorUsedError;
  String get jobId => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get finishedAt => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this JobRun to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobRunCopyWith<JobRun> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobRunCopyWith<$Res> {
  factory $JobRunCopyWith(JobRun value, $Res Function(JobRun) then) =
      _$JobRunCopyWithImpl<$Res, JobRun>;
  @useResult
  $Res call({
    int? id,
    String jobId,
    DateTime startedAt,
    DateTime? finishedAt,
    bool success,
    String? error,
  });
}

/// @nodoc
class _$JobRunCopyWithImpl<$Res, $Val extends JobRun>
    implements $JobRunCopyWith<$Res> {
  _$JobRunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? jobId = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            jobId:
                null == jobId
                    ? _value.jobId
                    : jobId // ignore: cast_nullable_to_non_nullable
                        as String,
            startedAt:
                null == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            finishedAt:
                freezed == finishedAt
                    ? _value.finishedAt
                    : finishedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobRunImplCopyWith<$Res> implements $JobRunCopyWith<$Res> {
  factory _$$JobRunImplCopyWith(
    _$JobRunImpl value,
    $Res Function(_$JobRunImpl) then,
  ) = __$$JobRunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String jobId,
    DateTime startedAt,
    DateTime? finishedAt,
    bool success,
    String? error,
  });
}

/// @nodoc
class __$$JobRunImplCopyWithImpl<$Res>
    extends _$JobRunCopyWithImpl<$Res, _$JobRunImpl>
    implements _$$JobRunImplCopyWith<$Res> {
  __$$JobRunImplCopyWithImpl(
    _$JobRunImpl _value,
    $Res Function(_$JobRunImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? jobId = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _$JobRunImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        jobId:
            null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                    as String,
        startedAt:
            null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        finishedAt:
            freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobRunImpl implements _JobRun {
  const _$JobRunImpl({
    this.id,
    required this.jobId,
    required this.startedAt,
    this.finishedAt,
    this.success = false,
    this.error,
  });

  factory _$JobRunImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobRunImplFromJson(json);

  @override
  final int? id;
  @override
  final String jobId;
  @override
  final DateTime startedAt;
  @override
  final DateTime? finishedAt;
  @override
  @JsonKey()
  final bool success;
  @override
  final String? error;

  @override
  String toString() {
    return 'JobRun(id: $id, jobId: $jobId, startedAt: $startedAt, finishedAt: $finishedAt, success: $success, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobRunImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    jobId,
    startedAt,
    finishedAt,
    success,
    error,
  );

  /// Create a copy of JobRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobRunImplCopyWith<_$JobRunImpl> get copyWith =>
      __$$JobRunImplCopyWithImpl<_$JobRunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobRunImplToJson(this);
  }
}

abstract class _JobRun implements JobRun {
  const factory _JobRun({
    final int? id,
    required final String jobId,
    required final DateTime startedAt,
    final DateTime? finishedAt,
    final bool success,
    final String? error,
  }) = _$JobRunImpl;

  factory _JobRun.fromJson(Map<String, dynamic> json) = _$JobRunImpl.fromJson;

  @override
  int? get id;
  @override
  String get jobId;
  @override
  DateTime get startedAt;
  @override
  DateTime? get finishedAt;
  @override
  bool get success;
  @override
  String? get error;

  /// Create a copy of JobRun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobRunImplCopyWith<_$JobRunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
