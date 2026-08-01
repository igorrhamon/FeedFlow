import '../../domain/job.dart';
import '../../domain/job_handler.dart';
import '../../domain/rule.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../action_executor.dart';

/// Handler que executa uma ação sobre um WorkItem a partir de um job
/// da fila de jobs persistida.
///
/// Fluxo:
/// 1. Extrai [workItemId], [actionId] e [params] do job.payload
/// 2. Carrega o WorkItem via [WorkItemRepository.byId()]
/// 3. Constrói um [ActionInvocation] com actionId + params
/// 4. Executa via [ActionExecutor.execute()]
/// 5. Se falha, lança [StateError] (o runner retentará)
///
/// Uso: registrado em [initializeJobHandlers] durante boot do app.
class ActionInvocationJobHandler implements JobHandler {
  ActionInvocationJobHandler({
    required WorkItemRepository workItemRepository,
    required ActionExecutor actionExecutor,
  })  : _workItemRepository = workItemRepository,
        _actionExecutor = actionExecutor;

  final WorkItemRepository _workItemRepository;
  final ActionExecutor _actionExecutor;

  @override
  String get jobType => 'actionInvocation';

  @override
  Future<void> run(Job job) async {
    final workItemId = job.payload['workItemId'] as String;
    final actionId = job.payload['actionId'] as String;
    final params = (job.payload['params'] as Map?)?.cast<String, dynamic>() ?? {};

    final item = await _workItemRepository.byId(workItemId);
    if (item == null) {
      throw StateError('WorkItem not found: $workItemId');
    }

    final result = await _actionExecutor.execute(
      item,
      ActionInvocation(actionId: actionId, params: params),
    );

    if (!result.success) {
      throw StateError('Action failed: ${result.error}');
    }
  }
}
