import 'enrichment.dart';
import 'work_item.dart';

/// Contexto e parâmetros de uma operação de enriquecimento sob demanda.
class EnrichmentRequest {
  EnrichmentRequest({
    required this.type,
    this.targetLanguage,
  });

  final EnrichmentType type;

  /// Linguagem alvo (ex.: 'pt', 'en', 'es') para enriquecimentos de tradução.
  /// Ignorado para outros tipos.
  final String? targetLanguage;
}

/// Porta de abstração para provedores de enriquecimento (LLM, APIs externas).
///
/// Implementações (ex.: [LlmAdapter]) registram-se em um registry (futuro)
/// e são invocadas pelo use case [RunEnrichment] (futuro). Degradação
/// graciosa: um [Enricher] que não suporte uma capability retorna um erro
/// apropriado, nunca throws.
abstract class Enricher {
  /// Identificador único do enricher (ex.: 'llm-anthropic', 'llm-openai').
  String get id;

  /// Conjunto de capabilities que este enricher oferece.
  Set<EnrichmentType> get capabilities;

  /// Enriquece um [WorkItem] sob demanda, retornando um [Enrichment].
  ///
  /// Lança [StateError] se [type] não está em [capabilities].
  /// Lança [Exception] em caso de erro de rede/API; o caller decide se
  /// persiste uma falha ou tenta novamente.
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req);
}
