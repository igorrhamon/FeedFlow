import '../enrichment.dart';

/// Porta de persistência local dos [Enrichment]s (enriquecimentos de IA).
/// Implementações vivem em `lib/infrastructure/repositories/`.
abstract class EnrichmentRepository {
  /// Query reativa: todos os enriquecimentos de um [WorkItem], ordenados
  /// por data de criação (mais recentes primeiro).
  Stream<List<Enrichment>> watchByWorkItemId(String workItemId);

  /// Recupera um enriquecimento específico por ID.
  Future<Enrichment?> byId(int id);

  /// Lista todos os enriquecimentos de um [WorkItem].
  Future<List<Enrichment>> listByWorkItemId(String workItemId);

  /// Persiste um enriquecimento novo no banco local.
  /// Retorna o [Enrichment] com o ID gerado pelo banco.
  Future<Enrichment> insert(Enrichment enrichment);

  /// Remove todos os enriquecimentos de um [WorkItem] (ex.: antes de
  /// regenerar um resumo com modelo mais novo).
  Future<int> deleteByWorkItemId(String workItemId, EnrichmentType? type);

  Future<void> close();
}
