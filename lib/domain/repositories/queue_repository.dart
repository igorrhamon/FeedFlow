import '../queue.dart';

/// Porta de persistência local das [Queue]s. Implementações vivem em
/// `lib/infrastructure/repositories/`; nada em `lib/domain` ou
/// `lib/application` deve depender de drift/SQL diretamente.
abstract class QueueRepository {
  /// Obtém uma fila pelo ID.
  Future<Queue?> byId(String id);

  /// Cria uma fila nova.
  Future<void> create(Queue queue);

  /// Atualiza uma fila existente.
  Future<void> update(Queue queue);

  /// Remove uma fila.
  Future<void> delete(String id);

  /// Lista todas as filas, ordenadas por [Queue.order].
  Future<List<Queue>> list();

  /// Stream reativo de todas as filas, ordenadas por [Queue.order].
  Stream<List<Queue>> watchAll();

  /// Remove todas as filas. Útil em testes.
  Future<void> clear();

  Future<void> close();
}
