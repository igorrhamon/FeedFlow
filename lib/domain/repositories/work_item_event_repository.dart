/// Leitura da trilha de auditoria (`WorkItemEvents`) — a tabela é escrita via
/// `WorkItemRepository.logEvent`, mas nada a lia até esta interface (WS-16,
/// base do undo de regras). Implementações vivem em
/// `lib/infrastructure/repositories/`; nada em `lib/domain` ou
/// `lib/application` deve depender de drift/SQL diretamente.
abstract class WorkItemEventRepository {
  /// Eventos com `timestamp >= since`, opcionalmente filtrados por [type]
  /// (ex.: `'ruleMatched'`), ordenados por timestamp ascendente (ordem de
  /// ocorrência).
  Future<List<WorkItemEventLog>> findSince(DateTime since, {String? type});
}

/// Uma linha lida de `WorkItemEvents`, já com `payloadJson` decodificado.
///
/// Nomeada `WorkItemEventLog` (não `WorkItemEvent`) para não colidir com a
/// row class que o drift gera para a tabela `WorkItemEvents`
/// (`lib/infrastructure/db/database.g.dart`).
class WorkItemEventLog {
  const WorkItemEventLog({
    required this.id,
    required this.workItemId,
    required this.timestamp,
    required this.type,
    required this.actor,
    required this.payload,
  });

  final int id;
  final String workItemId;
  final DateTime timestamp;
  final String type;
  final String actor;
  final Map<String, dynamic> payload;
}
