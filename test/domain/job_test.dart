import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/job.dart';

void main() {
  group('Job', () {
    test('should have correct default values', () {
      final now = DateTime.now();
      final job = Job(
        id: 'job-1',
        type: 'sync',
        nextRunAt: now,
        createdAt: now,
      );

      expect(job.status, JobStatus.pending);
      expect(job.attempts, 0);
      expect(job.maxAttempts, 3);
      expect(job.dependsOn, isEmpty);
      expect(job.payload, isEmpty);
    });

    test('should allow custom values', () {
      final now = DateTime.now();
      final job = Job(
        id: 'job-1',
        type: 'sync',
        payload: {'url': 'https://example.com'},
        status: JobStatus.running,
        dependsOn: ['job-0'],
        attempts: 1,
        maxAttempts: 5,
        nextRunAt: now,
        createdAt: now,
      );

      expect(job.status, JobStatus.running);
      expect(job.attempts, 1);
      expect(job.maxAttempts, 5);
      expect(job.dependsOn, ['job-0']);
      expect(job.payload, {'url': 'https://example.com'});
    });

    test('should serialize to JSON and preserve all fields', () {
      final now = DateTime.now();
      final job = Job(
        id: 'job-1',
        type: 'enrich',
        payload: {'a': {'b': 1}},
        status: JobStatus.done,
        dependsOn: ['job-0', 'job-1'],
        attempts: 2,
        maxAttempts: 4,
        nextRunAt: now,
        createdAt: now,
      );

      final json = job.toJson();

      expect(json['id'], 'job-1');
      expect(json['type'], 'enrich');
      expect(json['payload'], {'a': {'b': 1}});
      expect(json['status'], 'done');
      expect(json['dependsOn'], ['job-0', 'job-1']);
      expect(json['attempts'], 2);
      expect(json['maxAttempts'], 4);
      expect(json['nextRunAt'], now.toIso8601String());
      expect(json['createdAt'], now.toIso8601String());
    });

    test('should round-trip from JSON and preserve all fields', () {
      final now = DateTime.now();
      final original = Job(
        id: 'job-1',
        type: 'export',
        payload: {'nested': {'data': {'value': 42}}},
        status: JobStatus.failed,
        dependsOn: ['job-0'],
        attempts: 3,
        maxAttempts: 3,
        nextRunAt: now,
        createdAt: now,
      );

      final json = original.toJson();
      final restored = Job.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.payload, original.payload);
      expect(restored.status, original.status);
      expect(restored.dependsOn, original.dependsOn);
      expect(restored.attempts, original.attempts);
      expect(restored.maxAttempts, original.maxAttempts);
      expect(restored.nextRunAt, original.nextRunAt);
      expect(restored.createdAt, original.createdAt);
    });

    test('should handle complex nested payload in round-trip', () {
      final now = DateTime.now();
      final complexPayload = {
        'a': {
          'b': 1,
          'c': [1, 2, 3],
          'd': {
            'e': 'nested',
            'f': false,
          },
        },
      };

      final job = Job(
        id: 'job-1',
        type: 'sync',
        payload: complexPayload,
        nextRunAt: now,
        createdAt: now,
      );

      final json = job.toJson();
      final restored = Job.fromJson(json);

      expect(restored.payload, complexPayload);
    });

    test('should have immutable fields', () {
      final now = DateTime.now();
      final job = Job(
        id: 'job-1',
        type: 'sync',
        nextRunAt: now,
        createdAt: now,
      );

      // Freezed generates copyWith method for immutability
      final updatedJob = job.copyWith(status: JobStatus.running);

      expect(job.status, JobStatus.pending);
      expect(updatedJob.status, JobStatus.running);
    });
  });

  group('JobRun', () {
    test('should have correct default values', () {
      final now = DateTime.now();
      final run = JobRun(
        jobId: 'job-1',
        startedAt: now,
      );

      expect(run.id, isNull);
      expect(run.finishedAt, isNull);
      expect(run.success, false);
      expect(run.error, isNull);
    });

    test('should allow custom values', () {
      final startedAt = DateTime.now();
      final finishedAt = startedAt.add(Duration(seconds: 10));
      final run = JobRun(
        id: 1,
        jobId: 'job-1',
        startedAt: startedAt,
        finishedAt: finishedAt,
        success: true,
        error: null,
      );

      expect(run.id, 1);
      expect(run.jobId, 'job-1');
      expect(run.success, true);
      expect(run.error, isNull);
    });

    test('should have error message for failed runs', () {
      final now = DateTime.now();
      final run = JobRun(
        jobId: 'job-1',
        startedAt: now,
        finishedAt: now.add(Duration(seconds: 5)),
        success: false,
        error: 'Connection timeout',
      );

      expect(run.success, false);
      expect(run.error, 'Connection timeout');
    });

    test('should serialize to JSON and preserve all fields', () {
      final startedAt = DateTime.now();
      final finishedAt = startedAt.add(Duration(seconds: 15));
      final run = JobRun(
        id: 42,
        jobId: 'job-1',
        startedAt: startedAt,
        finishedAt: finishedAt,
        success: true,
        error: null,
      );

      final json = run.toJson();

      expect(json['id'], 42);
      expect(json['jobId'], 'job-1');
      expect(json['startedAt'], startedAt.toIso8601String());
      expect(json['finishedAt'], finishedAt.toIso8601String());
      expect(json['success'], true);
      expect(json['error'], isNull);
    });

    test('should round-trip from JSON preserving all fields', () {
      final startedAt = DateTime.now();
      final finishedAt = startedAt.add(Duration(seconds: 20));
      final original = JobRun(
        id: 99,
        jobId: 'job-abc',
        startedAt: startedAt,
        finishedAt: finishedAt,
        success: false,
        error: 'Network error',
      );

      final json = original.toJson();
      final restored = JobRun.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.jobId, original.jobId);
      expect(restored.startedAt, original.startedAt);
      expect(restored.finishedAt, original.finishedAt);
      expect(restored.success, original.success);
      expect(restored.error, original.error);
    });

    test('should have immutable fields', () {
      final now = DateTime.now();
      final run = JobRun(
        jobId: 'job-1',
        startedAt: now,
      );

      final updatedRun = run.copyWith(success: true);

      expect(run.success, false);
      expect(updatedRun.success, true);
    });
  });

  group('JobStatus', () {
    test('should have all expected values', () {
      expect(JobStatus.values, contains(JobStatus.pending));
      expect(JobStatus.values, contains(JobStatus.running));
      expect(JobStatus.values, contains(JobStatus.done));
      expect(JobStatus.values, contains(JobStatus.failed));
    });

    test('enum values should serialize correctly', () {
      final now = DateTime.now();
      final job = Job(
        id: 'job-1',
        type: 'sync',
        status: JobStatus.pending,
        nextRunAt: now,
        createdAt: now,
      );

      final json = job.toJson();
      expect(json['status'], 'pending');

      final restored = Job.fromJson(json);
      expect(restored.status, JobStatus.pending);
    });
  });
}
