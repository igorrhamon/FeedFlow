import 'package:feedflow/domain/job.dart';

/// Interface para executadores de jobs.
///
/// Cada tipo de job (ex: 'sync', 'enrich', 'export') tem um handler
/// que implementa essa interface. O handler é registrado em um registry
/// (tarefa futura) e invocado pela runner (tarefa futura) quando um job
/// do seu tipo está pronto.
abstract class JobHandler {
  /// Tipo de job que este handler executa (ex: 'sync', 'enrich').
  String get jobType;

  /// Executa o job.
  ///
  /// Deve lançar exceção se falhar (o runner vai capturar e retentar).
  /// Pode ser async, já que a runner é async.
  Future<void> run(Job job);
}
