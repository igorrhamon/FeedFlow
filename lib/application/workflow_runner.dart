import '../domain/events/domain_event.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
import 'action_executor.dart';
import 'event_bus.dart';

/// Orquestra a execução de uma sequência de [ActionInvocation]s (um
/// "workflow") sobre um [WorkItem], reaproveitando o [ActionExecutor] já
/// usado por [RuleEngine]/UI para resolver e executar cada ação.
///
/// Semantics (mesma política tolerante a erro do [ActionExecutor]):
/// - Passos executam em sequência, na ordem fornecida.
/// - Falha em um passo **não** interrompe os seguintes.
/// - Progresso é publicado por passo ([WorkflowStepExecuted]) e ao final
///   ([WorkflowCompleted]) no [EventBus]; a conclusão também é gravada como
///   auditoria em `WorkItemEvents` via [WorkItemRepository.logEvent]
///   (nenhuma tabela nova — reaproveita o schema existente).
class WorkflowRunner {
  WorkflowRunner({
    required WorkItemRepository workItemRepository,
    required ActionExecutor actionExecutor,
    required EventBus eventBus,
  })  : _workItemRepository = workItemRepository,
        _actionExecutor = actionExecutor,
        _eventBus = eventBus;

  final WorkItemRepository _workItemRepository;
  final ActionExecutor _actionExecutor;
  final EventBus _eventBus;

  /// Executa [steps] em sequência sobre [item]. Retorna os resultados de
  /// cada passo, na mesma ordem de [steps].
  Future<List<ActionExecutionResult>> run(
    WorkItem item,
    List<ActionInvocation> steps,
  ) async {
    final results = <ActionExecutionResult>[];
    final total = steps.length;

    for (var i = 0; i < total; i++) {
      final result = await _actionExecutor.execute(item, steps[i]);
      results.add(result);

      _eventBus.publish(
        WorkflowStepExecuted(
          workItemId: item.id,
          actionId: steps[i].actionId,
          stepIndex: i,
          totalSteps: total,
          success: result.success,
          timestamp: DateTime.now(),
        ),
      );
    }

    final succeeded = results.where((r) => r.success).length;

    _eventBus.publish(
      WorkflowCompleted(
        workItemId: item.id,
        totalSteps: total,
        succeededSteps: succeeded,
        timestamp: DateTime.now(),
      ),
    );

    await _workItemRepository.logEvent(
      item.id,
      type: 'workflowCompleted',
      actor: 'rule',
      payload: {
        'totalSteps': total,
        'succeededSteps': succeeded,
        'actionIds': steps.map((s) => s.actionId).toList(),
      },
    );

    return results;
  }
}
