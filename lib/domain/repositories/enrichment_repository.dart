import '../enrichment.dart';

/// Porta de persistência local dos [Enrichment]s. Implementações vivem em
/// `lib/infrastructure/repositories/`; nada em `lib/domain` ou
/// `lib/application` deve depender de drift/SQL diretamente.
abstract class EnrichmentRepository {
  /// Persiste um novo [Enrichment] no banco.
  Future<void> create(Enrichment enrichment);

  /// Retorna todos os enriquecimentos de um [WorkItem].
  Future<List<Enrichment>> byWorkItemId(String workItemId);

  /// Remove um enriquecimento pelo seu ID.
  Future<void> delete(int id);

  /// Limpa todos os enriquecimentos (utilitário para testes/reset).
  Future<void> clear();

  Future<void> close();
}
