import '../job.dart';

/// Repositório de jobs persistidos na fila de processamento.
abstract class JobRepository {
  /// Enfileira um novo job.
  Future<void> enqueue(Job job);

  /// Obtém um job por ID.
  Future<Job?> byId(String id);

  /// Observa mudanças na lista de jobs com um dos statuses fornecidos.
  Stream<List<Job>> watchByStatus(List<JobStatus> statuses);

  /// Marca até [limit] jobs elegíveis (status pending, nextRunAt <= now,
  /// todos os dependsOn com status done) como running, atomicamente, e
  /// retorna os jobs reivindicados.
  Future<List<Job>> claimNextBatch(int limit);

  /// Marca um job como bem-sucedido (status done).
  Future<void> markSucceeded(String id);

  /// Marca um job como falhado, com a mensagem de erro e o próximo momento
  /// de execução (se for retry) ou sem (se for falha final).
  Future<void> markFailed(
    String id,
    String error, {
    required DateTime nextRunAt,
  });

  /// Registra uma execução de job.
  Future<void> recordRun(JobRun run);

  /// Reclassifica jobs em status running para pending — usado no boot para
  /// recuperar jobs órfãos de um crash/kill anterior.
  Future<void> resetOrphanedRunning();
}
