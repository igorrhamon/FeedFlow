import '../domain/job_handler.dart';

/// Registro factory-based de todos os handlers de jobs disponíveis no sistema.
/// Inspirado em [ActionRegistry] e [ProviderRegistry], permite que diferentes componentes
/// consultem, criem e litem handlers por tipo de job sem acoplamento direto.
///
/// Uso típico:
/// ```dart
/// // Registrar (feito uma única vez em initializeJobHandlers())
/// JobRegistry.register('sync', () => SyncJobHandler(...));
///
/// // Consultar em tempo de execução (ex: JobRunner)
/// final handler = JobRegistry.get('sync');
/// if (handler != null) await handler.run(job);
///
/// // Listar todos os tipos de jobs disponíveis
/// final all = JobRegistry.getAvailable();
/// ```
class JobRegistry {
  JobRegistry._();

  static final Map<String, JobHandler Function()> _factories = {};

  /// Registra um handler de job com sua factory (construtora).
  /// Chamado por [initializeJobHandlers] durante boot.
  static void register(String jobType, JobHandler Function() factory) {
    _factories[jobType] = factory;
  }

  /// Retorna o handler de job com [jobType], ou `null` se não registrado.
  static JobHandler? get(String jobType) {
    final factory = _factories[jobType];
    return factory?.call();
  }

  /// Lista de todos os tipos de jobs registrados. Útil para consultar
  /// quais handlers estão disponíveis.
  static List<String> getAvailable() => _factories.keys.toList();

  /// Verificação simples: se um handler está registrado.
  static bool isRegistered(String jobType) => _factories.containsKey(jobType);

  /// Limpa todos os registros. Útil em testes.
  static void clear() => _factories.clear();
}
