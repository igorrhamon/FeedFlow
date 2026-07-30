import '../domain/rule.dart';
import '../domain/work_item.dart';
import 'job_runner.dart';

/// Orquestra a enfileiramento de uma sequência de [ActionInvocation]s (um
/// "workflow") sobre um [WorkItem] através da fila de jobs persistida (Onda 6).
///
/// **Mudança de responsabilidade (WS-14 → Task 8):**
/// Este runner não mais executa passos diretamente nem publica eventos de
/// progresso ([WorkflowStepExecuted] / [WorkflowCompleted]). Em vez disso:
/// - Enfileira cada passo como um job 'actionInvocation' via [JobRunner.enqueue()]
/// - Encadeia dependências lineares (segundo job depende do primeiro, etc.)
/// - Retorna os job IDs enfileirados
///
/// Eventos de progresso agora vêm do pipeline de jobs (via [JobSucceeded] /
/// [JobFailed] do [ActionInvocationJobHandler]) em vez de serem publicados
/// por este runner. Auditoria de conclusão também deixa de ser responsabilidade
/// deste runner.
class WorkflowRunner {
  WorkflowRunner({
    required JobRunner jobRunner,
  }) : _jobRunner = jobRunner;

  final JobRunner _jobRunner;

  /// Enfileira [steps] em sequência linear sobre [item], com cada passo
  /// dependendo do anterior. Retorna os IDs dos jobs enfileirados, na mesma
  /// ordem de [steps].
  Future<List<String>> run(
    WorkItem item,
    List<ActionInvocation> steps,
  ) async {
    final jobIds = <String>[];

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final dependsOn = i == 0 ? <String>[] : [jobIds[i - 1]];

      final jobId = await _jobRunner.enqueue(
        'actionInvocation',
        {
          'workItemId': item.id,
          'actionId': step.actionId,
          'params': step.params,
        },
        dependsOn: dependsOn,
      );

      jobIds.add(jobId);
    }

    return jobIds;
  }
}
