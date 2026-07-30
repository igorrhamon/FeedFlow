import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feedflow/domain/job.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/job_repository_drift.dart';

void main() {
  group('JobRepositoryDrift', () {
    late AppDatabase db;
    late JobRepositoryDrift repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepositoryDrift(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueue + byId retorna o job salvo', () async {
      final job = Job(
        id: 'job-1',
        type: 'test',
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await repository.enqueue(job);
      final retrieved = await repository.byId('job-1');

      expect(retrieved != null, isTrue);
      expect(retrieved!.id, equals('job-1'));
      expect(retrieved.type, equals('test'));
      expect(retrieved.status, equals(JobStatus.pending));
    });

    test('claimNextBatch NÃO retorna job com nextRunAt no futuro', () async {
      final futureTime = DateTime.now().add(Duration(hours: 1));
      final job = Job(
        id: 'job-future',
        type: 'test',
        nextRunAt: futureTime,
        createdAt: DateTime.now(),
      );

      await repository.enqueue(job);
      final claimed = await repository.claimNextBatch(10);

      expect(claimed, isEmpty);
    });

    test('claimNextBatch NÃO retorna job cujo dependsOn referencia um job não done',
        () async {
      final now = DateTime.now();
      final depJob = Job(
        id: 'dep-job',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );
      final dependentJob = Job(
        id: 'dependent-job',
        type: 'test',
        dependsOn: ['dep-job'],
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(depJob);
      await repository.enqueue(dependentJob);

      // Primeiro claim - só deve retornar dep-job (sem dependências)
      final firstClaim = await repository.claimNextBatch(10);
      expect(firstClaim.any((j) => j.id == 'dep-job'), isTrue);
      expect(firstClaim.any((j) => j.id == 'dependent-job'), isFalse);

      // Tentando claim novamente com dependent-job ainda com dep-job não done
      final secondClaim = await repository.claimNextBatch(10);
      expect(secondClaim, isEmpty);
    });

    test('claimNextBatch RETORNA job com dependsOn: [] imediatamente', () async {
      final now = DateTime.now();
      final job = Job(
        id: 'job-no-deps',
        type: 'test',
        dependsOn: [],
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);
      final claimed = await repository.claimNextBatch(10);

      expect(claimed, hasLength(1));
      expect(claimed[0].id, equals('job-no-deps'));
      expect(claimed[0].status, equals(JobStatus.running));
    });

    test('claimNextBatch RETORNA job cujo único dependsOn já está done', () async {
      final now = DateTime.now();
      final depJob = Job(
        id: 'dep-job-done',
        type: 'test',
        status: JobStatus.done,
        nextRunAt: now,
        createdAt: now,
      );
      final dependentJob = Job(
        id: 'dependent-on-done',
        type: 'test',
        dependsOn: ['dep-job-done'],
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(depJob);
      await repository.enqueue(dependentJob);
      final claimed = await repository.claimNextBatch(10);

      expect(claimed, hasLength(1));
      expect(claimed[0].id, equals('dependent-on-done'));
      expect(claimed[0].status, equals(JobStatus.running));
    });

    test('chamar claimNextBatch duas vezes não retorna o mesmo job duas vezes',
        () async {
      final now = DateTime.now();
      final job = Job(
        id: 'job-unique',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);

      final firstClaim = await repository.claimNextBatch(10);
      expect(firstClaim, hasLength(1));
      expect(firstClaim[0].status, equals(JobStatus.running));

      final secondClaim = await repository.claimNextBatch(10);
      expect(secondClaim, isEmpty);
    });

    test('markSucceeded muda status para done', () async {
      final now = DateTime.now();
      final job = Job(
        id: 'job-succeed',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);
      await repository.markSucceeded('job-succeed');

      final updated = await repository.byId('job-succeed');
      expect(updated!.status, equals(JobStatus.done));
    });

    test('resetOrphanedRunning muda todos os jobs running para pending', () async {
      final now = DateTime.now();
      final job1 = Job(
        id: 'job-1-orphan',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );
      final job2 = Job(
        id: 'job-2-orphan',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job1);
      await repository.enqueue(job2);

      // Claim ambos para marcá-los como running
      await repository.claimNextBatch(10);

      // Verifica que estão running
      var retrieved1 = await repository.byId('job-1-orphan');
      var retrieved2 = await repository.byId('job-2-orphan');
      expect(retrieved1!.status, equals(JobStatus.running));
      expect(retrieved2!.status, equals(JobStatus.running));

      // Reset
      await repository.resetOrphanedRunning();

      // Verifica que voltaram a pending
      retrieved1 = await repository.byId('job-1-orphan');
      retrieved2 = await repository.byId('job-2-orphan');
      expect(retrieved1!.status, equals(JobStatus.pending));
      expect(retrieved2!.status, equals(JobStatus.pending));
    });

    test('recordRun persiste um JobRun consultável', () async {
      final now = DateTime.now();
      final jobRun = JobRun(
        jobId: 'test-job-id',
        startedAt: now,
        finishedAt: now.add(Duration(seconds: 5)),
        success: true,
      );

      await repository.recordRun(jobRun);

      // Lê diretamente via query para verificar persistência
      final savedRuns = await (db.select(db.jobRuns)
            ..where((t) => t.jobId.equals('test-job-id')))
          .get();

      expect(savedRuns, hasLength(1));
      expect(savedRuns[0].jobId, equals('test-job-id'));
      expect(savedRuns[0].success, isTrue);
    });

    test('markFailed com retry atualiza status para pending e incrementa attempts',
        () async {
      // Use DateTime with only millisecond precision to avoid SQLite precision issues
      final nowMs = (DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000;
      final now = DateTime.fromMillisecondsSinceEpoch(nowMs);
      final job = Job(
        id: 'job-retry',
        type: 'test',
        maxAttempts: 3,
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);
      final nextRetry = DateTime.fromMillisecondsSinceEpoch(nowMs + 300000); // +5 minutes
      await repository.markFailed('job-retry', 'Error message', nextRunAt: nextRetry);

      final updated = await repository.byId('job-retry');
      expect(updated!.status, equals(JobStatus.pending));
      expect(updated.attempts, equals(1));
      expect(updated.nextRunAt, equals(nextRetry));
    });

    test('markFailed sem retry (attempts >= maxAttempts) muda status para failed',
        () async {
      final now = DateTime.now();
      final job = Job(
        id: 'job-final-fail',
        type: 'test',
        maxAttempts: 2,
        attempts: 1,
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);
      final nextRetry = now.add(Duration(minutes: 5));
      await repository.markFailed(
        'job-final-fail',
        'Final error',
        nextRunAt: nextRetry,
      );

      final updated = await repository.byId('job-final-fail');
      expect(updated!.status, equals(JobStatus.failed));
      expect(updated.attempts, equals(2));
    });

    test('watchByStatus observa mudanças de status', () async {
      final now = DateTime.now();
      final job = Job(
        id: 'job-watch',
        type: 'test',
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(job);

      final completer = Completer<List<Job>>();
      final subscription = repository
          .watchByStatus([JobStatus.pending])
          .listen((jobs) {
        if (!completer.isCompleted) {
          completer.complete(jobs);
        }
      });

      final jobs = await completer.future.timeout(Duration(seconds: 5));
      expect(jobs.length, greaterThan(0));
      expect(jobs.any((j) => j.id == 'job-watch'), isTrue);

      await subscription.cancel();
    });

    test('claimNextBatch respeita o limit', () async {
      final now = DateTime.now();
      for (int i = 0; i < 10; i++) {
        final job = Job(
          id: 'job-$i',
          type: 'test',
          nextRunAt: now,
          createdAt: now,
        );
        await repository.enqueue(job);
      }

      final claimed = await repository.claimNextBatch(3);
      expect(claimed, hasLength(3));
    });

    test('claimNextBatch filtra múltiplas dependências corretamente', () async {
      final now = DateTime.now();
      final dep1 = Job(
        id: 'dep-1',
        type: 'test',
        status: JobStatus.done,
        nextRunAt: now,
        createdAt: now,
      );
      final dep2 = Job(
        id: 'dep-2',
        type: 'test',
        status: JobStatus.pending,
        nextRunAt: now,
        createdAt: now,
      );
      final jobWithMultipleDeps = Job(
        id: 'job-multi-deps',
        type: 'test',
        dependsOn: ['dep-1', 'dep-2'],
        nextRunAt: now,
        createdAt: now,
      );

      await repository.enqueue(dep1);
      await repository.enqueue(dep2);
      await repository.enqueue(jobWithMultipleDeps);

      final claimed = await repository.claimNextBatch(10);

      // Não deve incluir job-multi-deps pois dep-2 ainda está pending
      expect(claimed.any((j) => j.id == 'job-multi-deps'), isFalse);

      // Agora marca dep-2 como done
      await repository.markSucceeded('dep-2');

      final claimedAgain = await repository.claimNextBatch(10);

      // Agora deve incluir job-multi-deps
      expect(claimedAgain.any((j) => j.id == 'job-multi-deps'), isTrue);
    });
  });
}

// Importar DateTime para Completer (já presente via flutter_test)
