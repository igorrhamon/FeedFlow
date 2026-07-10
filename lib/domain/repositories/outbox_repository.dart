import '../outbox_entry.dart';

/// Porta de persistência da fila de push (outbox). Implementações vivem em
/// `lib/infrastructure/repositories/`.
abstract class OutboxRepository {
  /// Enfileira uma mutação pendente e retorna o id da entrada criada.
  Future<int> enqueue({
    required String workItemId,
    required String articleId,
    required OutboxAction action,
  });

  Future<List<OutboxEntry>> pending();

  /// Remove a entrada — chamado após confirmação de sucesso no provider.
  Future<void> remove(int id);

  /// Registra uma tentativa falha (incrementa `attempts`, grava `lastError`)
  /// sem remover a entrada — ela continua pendente para o próximo flush.
  Future<void> recordFailure(int id, String error);
}
