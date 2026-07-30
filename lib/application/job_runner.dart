import 'dart:async';
import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';

import '../domain/events/domain_event.dart';
import '../domain/job.dart';
import '../domain/repositories/job_repository.dart';
import 'event_bus.dart';
import 'job_registry.dart';

/// Motor de processamento da fila persistida de jobs (Onda 6).
/// Faz polling periodicamente via [claimNextBatch], executa jobs via
/// [JobRegistry.get], publica eventos de ciclo de vida, e implementa retry com
/// backoff exponencial.
class JobRunner {
  JobRunner({required JobRepository jobRepository, required EventBus eventBus})
      : _jobRepository = jobRepository,
        _eventBus = eventBus;

  final JobRepository _jobRepository;
  final EventBus _eventBus;
  Timer? _timer;

  static const _pollInterval = Duration(seconds: 4);
  static const _baseBackoff = Duration(seconds: 30);
  static const _maxBackoff = Duration(minutes: 30);
  static const _batchSize = 10;

  /// Enfileira um novo job com o tipo e payload fornecidos, retornando seu id.
  Future<String> enqueue(String type, Map<String, dynamic> payload,
      {List<String> dependsOn = const [], int maxAttempts = 3}) async {
    final id = const Uuid().v4();
    final job = Job(
      id: id,
      type: type,
      payload: payload,
      status: JobStatus.pending,
      dependsOn: dependsOn,
      attempts: 0,
      maxAttempts: maxAttempts,
      nextRunAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _jobRepository.enqueue(job);
    await _eventBus.publish(
      JobEnqueued(
        jobId: id,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
    unawaited(_processBatch());
    return id;
  }

  /// Inicia o polling periódico de jobs. Pode ser chamado múltiplas vezes sem
  /// criar vários timers.
  void start() {
    if (_timer != null) return;
    unawaited(_jobRepository.resetOrphanedRunning());
    unawaited(_processBatch());
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_processBatch()));
  }

  /// Para o polling periódico.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _processBatch() async {
    final jobs = await _jobRepository.claimNextBatch(_batchSize);
    for (final job in jobs) {
      try {
        await _runOne(job);
      } catch (e, stackTrace) {
        developer.log(
          'JobRunner: _runOne falhou para job ${job.id}',
          name: 'feedflow.job_runner',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _runOne(Job job) async {
    await _eventBus.publish(
      JobStarted(
        jobId: job.id,
        type: job.type,
        timestamp: DateTime.now(),
      ),
    );
    final startedAt = DateTime.now();
    final handler = JobRegistry.get(job.type);
    String? error;
    var success = false;
    if (handler == null) {
      error = 'No handler registered for job type: ${job.type}';
    } else {
      try {
        await handler.run(job);
        success = true;
      } catch (e) {
        error = e.toString();
      }
    }
    await _jobRepository.recordRun(
      JobRun(
        jobId: job.id,
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        success: success,
        error: error,
      ),
    );
    if (success) {
      await _jobRepository.markSucceeded(job.id);
      await _eventBus.publish(
        JobSucceeded(
          jobId: job.id,
          type: job.type,
          timestamp: DateTime.now(),
        ),
      );
    } else {
      final nextAttempts = job.attempts + 1;
      if (nextAttempts < job.maxAttempts) {
        final backoff = _baseBackoff * (1 << job.attempts);
        final capped = backoff > _maxBackoff ? _maxBackoff : backoff;
        final nextRunAt = DateTime.now().add(capped);
        await _jobRepository.markFailed(job.id, error ?? 'unknown error',
            nextRunAt: nextRunAt);
        await _eventBus.publish(
          JobRetried(
            jobId: job.id,
            type: job.type,
            attempts: nextAttempts,
            nextRunAt: nextRunAt,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        await _jobRepository.markFailed(job.id, error ?? 'unknown error',
            nextRunAt: DateTime.now());
        await _eventBus.publish(
          JobFailed(
            jobId: job.id,
            type: job.type,
            error: error ?? 'unknown error',
            attempts: nextAttempts,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }
}
