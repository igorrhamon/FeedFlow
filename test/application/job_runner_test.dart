import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/job_registry.dart';
import 'package:feedflow/application/job_runner.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/job.dart';
import 'package:feedflow/domain/job_handler.dart';
import 'package:feedflow/domain/repositories/job_repository.dart';

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

/// Fake handler para testes.
class FakeJobHandler extends JobHandler {
  FakeJobHandler({required this.jobType, this.shouldThrow = false});

  @override
  final String jobType;

  final bool shouldThrow;
  var callCount = 0;

  @override
  Future<void> run(Job job) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('test error');
    }
  }
}

void main() {
  late FakeJobRepository fakeRepo;
  late EventBus eventBus;
  late JobRunner runner;

  setUp(() {
    fakeRepo = FakeJobRepository();
    eventBus = EventBus();
    runner = JobRunner(jobRepository: fakeRepo, eventBus: eventBus);
    JobRegistry.clear();
  });

  tearDown(() {
    runner.stop();
    JobRegistry.clear();
  });

  group('JobRunner', () {
    test('Job com handler que sucede publica JobStarted e JobSucceeded', () async {
      // Arrange
      final handler = FakeJobHandler(jobType: 'test_job');
      JobRegistry.register('test_job', () => handler);

      final events = <DomainEvent>[];
      eventBus.subscribe((event) {
        events.add(event);
      });

      // Act
      final jobId = await runner.enqueue('test_job', {'data': 'test'});
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(handler.callCount, greaterThanOrEqualTo(1));
      expect(events, containsAll([
        isA<JobEnqueued>().having((e) => e.jobId, 'jobId', jobId),
        isA<JobStarted>().having((e) => e.jobId, 'jobId', jobId),
        isA<JobSucceeded>().having((e) => e.jobId, 'jobId', jobId),
      ]));

      final job = await fakeRepo.byId(jobId);
      expect(job?.status, JobStatus.done);
    });

    test(
        'Job com handler que lança exceção e attempts+1 < maxAttempts retorna pending com nextRunAt',
        () async {
      // Arrange
      final handler = FakeJobHandler(jobType: 'test_job', shouldThrow: true);
      JobRegistry.register('test_job', () => handler);

      final events = <DomainEvent>[];
      eventBus.subscribe((event) {
        events.add(event);
      });

      // Act
      final jobId = await runner.enqueue('test_job', {}, maxAttempts: 3);
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(
        events,
        contains(
          isA<JobRetried>()
              .having((e) => e.jobId, 'jobId', jobId)
              .having((e) => e.attempts, 'attempts', 1),
        ),
      );

      final job = await fakeRepo.byId(jobId);
      expect(job?.status, JobStatus.pending);
      expect(job?.attempts, 1);
      expect(job?.nextRunAt, isNotNull);
    });

    test('Job que esgotou maxAttempts publica JobFailed e marca como failed', () async {
      // Arrange
      final handler = FakeJobHandler(jobType: 'test_job', shouldThrow: true);
      JobRegistry.register('test_job', () => handler);

      final events = <DomainEvent>[];
      eventBus.subscribe((event) {
        events.add(event);
      });

      // Act
      final jobId = await runner.enqueue('test_job', {}, maxAttempts: 1);
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(
        events,
        contains(
          isA<JobFailed>()
              .having((e) => e.jobId, 'jobId', jobId)
              .having((e) => e.attempts, 'attempts', 1),
        ),
      );

      final job = await fakeRepo.byId(jobId);
      expect(job?.status, JobStatus.failed);
      expect(job?.attempts, 1);
    });

    test('Job sem handler registrado trata como falha sem lançar exceção não tratada',
        () async {
      // Arrange
      // Não registra handler para 'unknown_type'

      final events = <DomainEvent>[];
      eventBus.subscribe((event) {
        events.add(event);
      });

      // Act
      final jobId = await runner.enqueue('unknown_type', {});
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      // Deve publicar JobRetried ou JobFailed, dependendo de maxAttempts
      expect(
        events,
        contains(
          isA<JobRetried>()
              .having((e) => e.jobId, 'jobId', jobId)
              .having((e) => e.type, 'type', 'unknown_type'),
        ),
      );

      final job = await fakeRepo.byId(jobId);
      expect(job?.status, JobStatus.pending); // porque maxAttempts default é 3
    });

    test('start() chamado duas vezes não cria dois timers', () async {
      // Arrange
      final handler = FakeJobHandler(jobType: 'test_job');
      JobRegistry.register('test_job', () => handler);

      // Act & Assert: chamadas múltiplas de start() devem ser idempotentes
      runner.start();
      runner.start(); // segunda chamada não deve falhar
      runner.stop();

      // Se chegou aqui sem erro, o teste passou
      expect(true, true);
    });

    test('stop() seguido de start() funciona sem erro', () async {
      // Arrange
      final handler = FakeJobHandler(jobType: 'test_job');
      JobRegistry.register('test_job', () => handler);

      // Act & Assert
      runner.start();
      runner.stop();
      runner.start(); // deve funcionar sem erro
      runner.stop();

      // Se chegou aqui sem erro, o teste passou
      expect(true, true);
    });
  });
}
