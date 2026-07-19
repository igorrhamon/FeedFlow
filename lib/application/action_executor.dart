import '../domain/events/domain_event.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
import 'action_registry.dart';
import 'event_bus.dart';

/// Resultado da execução de uma única ação.
class ActionExecutionResult {
  /// ID da ação que foi executada.
  final String actionId;

  /// Sucesso ou falha.
  final bool success;

  /// Erro capturado, se [success] for false.
  final Object? error;

  const ActionExecutionResult({
    required this.actionId,
    required this.success,
    this.error,
  });

  @override
  String toString() => 'ActionExecutionResult(id: $actionId, success: $success, error: $error)';
}

/// Executor de ações: camada centralizada que resolve, valida e executa
/// [ActionInvocation]s sobre [WorkItem]s, com captura robusta de erros
/// e publicação de eventos.
///
/// Usado por:
/// - [RuleEngine] (quando regras casam): `await executor.executeAll(...)`
/// - Futuro [WorkflowRunner] (orquestrador de passos): `await executor.execute(...)`
/// - UI (botões de ação rápida na página de artigo): `await executor.execute(...)`
class ActionExecutor {
  ActionExecutor({required EventBus eventBus}) : _eventBus = eventBus;

  final EventBus _eventBus;

  /// Executa uma única [ActionInvocation] sobre um [WorkItem].
  /// **Nunca lança** — qualquer exceção é capturada e retornada no resultado.
  ///
  /// Semantics:
  /// 1. Resolve a ação via [ActionRegistry.get(invocation.actionId)]
  /// 2. Se não encontrada, retorna `success: false, error: 'Action not found'`
  /// 3. Chama [action.execute(item, invocation.params)]
  /// 4. Se sucesso: publica [ActionExecuted] no [EventBus]
  /// 5. Se falha: captura a exceção e retorna sem publicar
  Future<ActionExecutionResult> execute(
    WorkItem item,
    ActionInvocation invocation,
  ) async {
    try {
      final action = ActionRegistry.get(invocation.actionId);
      if (action == null) {
        return ActionExecutionResult(
          actionId: invocation.actionId,
          success: false,
          error: 'Action not found: ${invocation.actionId}',
        );
      }

      await action.execute(item, invocation.params);

      // Sucesso: publica evento de auditoria
      _eventBus.publish(
        ActionExecuted(
          workItemId: item.id,
          actionId: invocation.actionId,
          params: invocation.params,
          timestamp: DateTime.now(),
        ),
      );

      return ActionExecutionResult(
        actionId: invocation.actionId,
        success: true,
      );
    } catch (e) {
      return ActionExecutionResult(
        actionId: invocation.actionId,
        success: false,
        error: e,
      );
    }
  }

  /// Executa uma lista de [ActionInvocation]s em sequência, isolando falhas
  /// por passo: se uma ação falha, as demais ainda são executadas.
  ///
  /// Retorna a lista de [ActionExecutionResult], um por ação, mantendo a
  /// mesma ordem da entrada.
  ///
  /// **Semantics**:
  /// - Executa ações em ordem (sequencial, não paralela)
  /// - Falha em uma ação NÃO impede as próximas
  /// - Cada resultado reporta `success: true/false` independentemente
  /// - Eventos [ActionExecuted] são publicados apenas para ações bem-sucedidas
  ///
  /// **Caso de uso**: RuleEngine quando uma regra casa executa sua lista de
  /// ações e precisa saber qual(ais) falhou(falharam) para auditoria/retry.
  Future<List<ActionExecutionResult>> executeAll(
    WorkItem item,
    List<ActionInvocation> invocations,
  ) async {
    final results = <ActionExecutionResult>[];

    for (final invocation in invocations) {
      final result = await execute(item, invocation);
      results.add(result);
    }

    return results;
  }
}
