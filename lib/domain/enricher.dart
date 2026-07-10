import 'enrichment.dart';
import 'work_item.dart';

/// Porta abstrata para enriquecimento de [WorkItem]s por LLM.
///
/// Implementações (ex: `LlmAdapter` em `lib/infrastructure/llm/llm_adapter.dart`)
/// devem chamar uma API LLM configurável e persistir o resultado como um
/// [Enrichment] via `EnrichmentRepository`.
abstract class Enricher {
  /// Enriquece um [WorkItem] com o tipo especificado (summary, translation, etc.).
  ///
  /// Retorna o [Enrichment] criado. Lança em caso de erro de rede, LLM, ou
  /// validação. A implementação pode optar por lançar o erro ou, em alguns
  /// casos, retornar um [Enrichment] com conteúdo de erro — o contrato é
  /// definido por cada implementação.
  Future<Enrichment> enrich(WorkItem item, EnrichmentType type);
}
