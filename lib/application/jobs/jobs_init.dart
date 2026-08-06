import '../../domain/repositories/local_source_config_repository.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../action_executor.dart';
import '../job_registry.dart';
import '../sync_service.dart';
import 'action_invocation_job_handler.dart';
import 'local_source_pull_job_handler.dart';

/// Inicializa e registra todos os handlers de jobs disponíveis no [JobRegistry].
/// Deve ser chamada exatamente uma vez durante o boot da aplicação (em `main()`),
/// após a inicialização dos repositórios e do [ActionExecutor].
///
/// Registra os handlers de jobs:
/// - `actionInvocation`: executa uma ação sobre um WorkItem
/// - `local_source_pull`: sincroniza uma fonte local (pasta/vault/PDF/Office)
void initializeJobHandlers({
  required WorkItemRepository workItemRepository,
  required ActionExecutor actionExecutor,
  LocalSourceConfigRepository? localSourceConfigRepository,
  SyncService? syncService,
}) {
  JobRegistry.clear();
  JobRegistry.register(
    'actionInvocation',
    () => ActionInvocationJobHandler(
      workItemRepository: workItemRepository,
      actionExecutor: actionExecutor,
    ),
  );
  if (localSourceConfigRepository != null && syncService != null) {
    JobRegistry.register(
      'local_source_pull',
      () => LocalSourcePullJobHandler(
        configRepository: localSourceConfigRepository,
        syncService: syncService,
      ),
    );
  }
}
