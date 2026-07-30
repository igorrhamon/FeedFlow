import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/job_registry.dart';
import 'package:feedflow/application/job_runner.dart';
import 'package:feedflow/application/workflow_runner.dart';
import 'package:feedflow/domain/job.dart';
import 'package:feedflow/domain/job_handler.dart';
import 'package:feedflow/domain/repositories/job_repository.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/work_item.dart';

/// Fake in-memory implementação de [JobRepository] para testes.
class FakeJobRepository implements JobRepository {
  final jobs = <String, Job>{};
  final runs = <JobRun>[];

  @override
  Future<void> enqueue(Job job) async {
    jobs[job.id] = job;
  }

  @override
  Future<Job?> byId(String id) async {
    return jobs[id];
  }

  @override
  Stream<List<Job>> watchByStatus(List<JobStatus> statuses) {
    throw UnimplementedError('watchByStatus not used in tests');
  }

  @override
  Future<List<Job>> claimNextBatch(int limit) async {
    final now = DateTime.now();
    final eligible = jobs.values
        .where((j) =>
            j.status == JobStatus.pending &&
            (j.nextRunAt.isBefore(now) || j.nextRunAt.isAtSameMomentAs(now)))
        .take(limit)
        .toList();

    final claimed = <Job>[];
    for (final job in eligible) {
      final updated = job.copyWith(status: JobStatus.running);
      jobs[job.id] = updated;
      claimed.add(updated);
    }
    return claimed;
  }

  @override
  Future<void> markSucceeded(String id) async {
    final job = jobs[id];
    if (job != null) {
      jobs[id] = job.copyWith(status: JobStatus.done);
    }
  }

  @override
  Future<void> markFailed(
    String id,
    String error, {
    required DateTime nextRunAt,
  }) async {
    final job = jobs[id];
    if (job == null) return;

    final newAttempts = job.attempts + 1;
    final willRetry = newAttempts < job.maxAttempts;

    jobs[id] = job.copyWith(
      status: willRetry ? JobStatus.pending : JobStatus.failed,
      attempts: newAttempts,
      nextRunAt: nextRunAt,
    );
  }

  @override
  Future<void> recordRun(JobRun run) async {
    runs.add(run);
  }

  @override
  Future<void> resetOrphanedRunning() async {
    for (final entry in jobs.entries.toList()) {
      if (entry.value.status == JobStatus.running) {
        jobs[entry.key] = entry.value.copyWith(status: JobStatus.pending);
      }
    }
  }
}

/// Fake job handler para 'actionInvocation' jobs em testes.
class FakeActionInvocationHandler extends JobHandler {
  FakeActionInvocationHandler();

  @override
  String get jobType => 'actionInvocation';

  var callCount = 0;

  @override
  Future<void> run(Job job) async {
    callCount++;
    // Simples: apenas registra que foi chamado.
  }
}

void main() {
  late FakeJobRepository fakeRepo;
  late EventBus eventBus;
  late JobRunner jobRunner;
  late WorkflowRunner runner;

  final item = WorkItem(
    id: 'test-item-1',
    providerId: 'test-provider',
    articleId: 'article-1',
    feedId: 'feed-1',
    title: 'Test Article',
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    fakeRepo = FakeJobRepository();
    eventBus = EventBus();
    jobRunner = JobRunner(jobRepository: fakeRepo, eventBus: eventBus);
    runner = WorkflowRunner(jobRunner: jobRunner);

    JobRegistry.clear();
    JobRegistry.register('actionInvocation', () => FakeActionInvocationHandler());
  });

  tearDown(() {
    JobRegistry.clear();
  });

  group('WorkflowRunner', () {
    test('run() with 3 steps returns 3 job IDs', () async {
      final jobIds = await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        const ActionInvocation(actionId: 'stepB', params: {}),
        const ActionInvocation(actionId: 'stepC', params: {}),
      ]);

      expect(jobIds, hasLength(3));
      expect(jobIds[0], isNotEmpty);
      expect(jobIds[1], isNotEmpty);
      expect(jobIds[2], isNotEmpty);
      expect(jobIds[0], isNot(jobIds[1]));
      expect(jobIds[1], isNot(jobIds[2]));
    });

    test('first job has dependsOn: []', () async {
      final jobIds = await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        const ActionInvocation(actionId: 'stepB', params: {}),
      ]);

      final firstJob = fakeRepo.jobs[jobIds[0]]!;
      expect(firstJob.dependsOn, isEmpty);
    });

    test('second job has dependsOn: [first jobId], third has dependsOn: [second jobId]',
        () async {
      final jobIds = await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        const ActionInvocation(actionId: 'stepB', params: {}),
        const ActionInvocation(actionId: 'stepC', params: {}),
      ]);

      final secondJob = fakeRepo.jobs[jobIds[1]]!;
      expect(secondJob.dependsOn, equals([jobIds[0]]));

      final thirdJob = fakeRepo.jobs[jobIds[2]]!;
      expect(thirdJob.dependsOn, equals([jobIds[1]]));
    });

    test('returns an empty list for an empty workflow', () async {
      final jobIds = await runner.run(item, []);
      expect(jobIds, isEmpty);
    });

    test('payload contains correct workItemId, actionId, and params', () async {
      final params = {'timeout': 5000};
      final jobIds = await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        ActionInvocation(actionId: 'stepB', params: params),
      ]);

      final firstJob = fakeRepo.jobs[jobIds[0]]!;
      expect(firstJob.payload['workItemId'], item.id);
      expect(firstJob.payload['actionId'], 'stepA');
      expect(firstJob.payload['params'], {});

      final secondJob = fakeRepo.jobs[jobIds[1]]!;
      expect(secondJob.payload['workItemId'], item.id);
      expect(secondJob.payload['actionId'], 'stepB');
      expect(secondJob.payload['params'], params);
    });
  });
}
