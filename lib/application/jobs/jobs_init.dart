import '../../domain/repositories/work_item_repository.dart';
import '../action_executor.dart';
import '../job_registry.dart';
import 'action_invocation_job_handler.dart';

/// Inicializa e registra todos os handlers de jobs disponíveis no [JobRegistry].
/// Deve ser chamada exatamente uma vez durante o boot da aplicação (em `main()`),
/// após a inicialização dos repositórios e do [ActionExecutor].
///
/// Registra os handlers de jobs:
/// - `actionInvocation`: executa uma ação sobre um WorkItem
void initializeJobHandlers({
  required WorkItemRepository workItemRepository,
  required ActionExecutor actionExecutor,
}) {
  JobRegistry.clear();
  JobRegistry.register(
    'actionInvocation',
    () => ActionInvocationJobHandler(
      workItemRepository: workItemRepository,
      actionExecutor: actionExecutor,
    ),
  );
}
