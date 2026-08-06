import '../../domain/job.dart';
import '../../domain/job_handler.dart';
import '../../domain/local_source_type_ext.dart';
import '../../domain/repositories/local_source_config_repository.dart';
import '../source_connector_registry.dart';
import '../sync_service.dart';

/// Handler que sincroniza uma fonte local (pasta, vault Markdown, PDF ou
/// Office) configurada pelo usuário, a partir de um job da fila de jobs
/// persistida (Onda 9).
///
/// Fluxo:
/// 1. Extrai `sourceConfigId` do payload do job.
/// 2. Carrega o [LocalSourceConfig] via [LocalSourceConfigRepository.byId()].
/// 3. Se a config não existe ou está desabilitada, encerra sem erro (no-op).
/// 4. Resolve o [SourceConnector] pelo tipo via [SourceConnectorRegistry].
/// 5. Puxa os documentos novos/alterados desde a última sincronização e
///    ingere via [SyncService.ingestDocuments].
/// 6. Atualiza o timestamp de última sincronização.
///
/// Uso: registrado em `initializeJobHandlers` durante boot do app.
class LocalSourcePullJobHandler implements JobHandler {
  LocalSourcePullJobHandler({
    required LocalSourceConfigRepository configRepository,
    required SyncService syncService,
  })  : _configRepository = configRepository,
        _syncService = syncService;

  final LocalSourceConfigRepository _configRepository;
  final SyncService _syncService;

  @override
  String get jobType => 'local_source_pull';

  @override
  Future<void> run(Job job) async {
    final configId = job.payload['sourceConfigId'] as String;
    final config = await _configRepository.byId(configId);

    if (config == null || !config.enabled) return;

    final connector = SourceConnectorRegistry.create(config.type.toShortString(), config);
    if (connector == null) {
      throw StateError('Unknown connector type: ${config.type}');
    }

    try {
      final documents = await connector.pull(since: config.lastSyncAt);
      await _syncService.ingestDocuments(documents, connector.id);
      await _configRepository.updateLastSync(configId, DateTime.now());
    } finally {
      await connector.close();
    }
  }
}
