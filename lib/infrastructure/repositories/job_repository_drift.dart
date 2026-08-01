import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../db/database.dart';

class JobRepositoryDrift implements JobRepository {
  JobRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<void> enqueue(Job job) async {
    await _db.into(_db.jobs).insert(_toCompanion(job));
  }

  @override
  Future<Job?> byId(String id) async {
    final row = await (_db.select(_db.jobs)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<List<Job>> watchByStatus(List<JobStatus> statuses) {
    final statusNames = statuses.map((s) => s.name).toList();
    final query = _db.select(_db.jobs)
      ..where((t) => t.status.isIn(statusNames))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Job>> claimNextBatch(int limit) async {
    return await _db.transaction(() async {
      // Busca generosamente (limit * 5) de jobs elegíveis por data/status
      final now = DateTime.now();
      final rows = await (_db.select(_db.jobs)
            ..where((t) =>
                t.status.equals('pending') & t.nextRunAt.isSmallerOrEqualValue(now))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit * 5))
          .get();

      // Decodifica e filtra em Dart: só inclui jobs cujas dependências estão todas done
      final eligibleJobs = <JobRow>[];
      for (final row in rows) {
        final dependsOnIds = (jsonDecode(row.dependsOnJson) as List<dynamic>)
            .cast<String>()
            .toList();

        if (dependsOnIds.isEmpty) {
          // Sem dependências, é elegível
          eligibleJobs.add(row);
        } else {
          // Verifica se todas as dependências estão done
          final dependencyStatuses = await (_db.select(_db.jobs)
                ..where((t) => t.id.isIn(dependsOnIds)))
              .get();

          final allDone = dependencyStatuses.length == dependsOnIds.length &&
              dependencyStatuses.every((j) => j.status == 'done');
          if (allDone) {
            eligibleJobs.add(row);
          }
        }

        // Para quando atingir o limit
        if (eligibleJobs.length >= limit) break;
      }

      // Tenta marcar atomicamente cada job como running
      final claimed = <Job>[];
      for (final row in eligibleJobs) {
        final updated = await (_db.update(_db.jobs)
              ..where((t) => t.id.equals(row.id) & t.status.equals('pending')))
            .write(JobsCompanion(status: Value('running')));

        if (updated == 1) {
          // Sucesso — retorna com status atualizado
          claimed.add(_toDomain(row.copyWith(status: 'running')));
        }
        // else: outro caller já reivindicou este job, pula
      }

      return claimed;
    });
  }

  @override
  Future<void> markSucceeded(String id) async {
    await (_db.update(_db.jobs)..where((t) => t.id.equals(id)))
        .write(const JobsCompanion(status: Value('done')));
  }

  @override
  Future<void> markFailed(
    String id,
    String error, {
    required DateTime nextRunAt,
  }) async {
    // Obter o job atual para verificar attempts
    final job = await byId(id);
    if (job == null) return;

    final newAttempts = job.attempts + 1;
    final willRetry = newAttempts < job.maxAttempts;

    await (_db.update(_db.jobs)..where((t) => t.id.equals(id))).write(
      JobsCompanion(
        status: Value(willRetry ? 'pending' : 'failed'),
        attempts: Value(newAttempts),
        nextRunAt: Value(nextRunAt),
      ),
    );
  }

  @override
  Future<void> recordRun(JobRun run) async {
    await _db.into(_db.jobRuns).insert(_jobRunToCompanion(run));
  }

  @override
  Future<void> resetOrphanedRunning() async {
    await (_db.update(_db.jobs)..where((t) => t.status.equals('running')))
        .write(const JobsCompanion(status: Value('pending')));
  }

  Job _toDomain(JobRow row) {
    return Job(
      id: row.id,
      type: row.type,
      payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
      status: JobStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => JobStatus.pending,
      ),
      dependsOn: (jsonDecode(row.dependsOnJson) as List<dynamic>)
          .cast<String>()
          .toList(),
      attempts: row.attempts,
      maxAttempts: row.maxAttempts,
      nextRunAt: row.nextRunAt,
      createdAt: row.createdAt,
    );
  }

  JobsCompanion _toCompanion(Job job) {
    return JobsCompanion(
      id: Value(job.id),
      type: Value(job.type),
      payloadJson: Value(jsonEncode(job.payload)),
      status: Value(job.status.name),
      dependsOnJson: Value(jsonEncode(job.dependsOn)),
      attempts: Value(job.attempts),
      maxAttempts: Value(job.maxAttempts),
      nextRunAt: Value(job.nextRunAt),
      createdAt: Value(job.createdAt),
    );
  }

  JobRunsCompanion _jobRunToCompanion(JobRun run) {
    return JobRunsCompanion(
      jobId: Value(run.jobId),
      startedAt: Value(run.startedAt),
      finishedAt: Value(run.finishedAt),
      success: Value(run.success),
      error: Value(run.error),
    );
  }
}
