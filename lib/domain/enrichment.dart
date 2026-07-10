import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrichment.freezed.dart';
part 'enrichment.g.dart';

/// Tipos de enriquecimento suportados (resumo, tradução, classificação, etc.).
enum EnrichmentType {
  summary,
  translation,
  classification,
  entities,
  suggestion,
}

/// Enriquecimento de IA de um [WorkItem] — resumo, tradução, classificação,
/// produzido por um adapter LLM (veja `LlmAdapter` em
/// `lib/infrastructure/llm/llm_adapter.dart`).
@freezed
class Enrichment with _$Enrichment {
  const factory Enrichment({
    /// PK no banco local (auto-increment).
    required int id,

    /// Chave estrangeira para `WorkItems.id`.
    required String workItemId,

    /// Tipo de enriquecimento (summary, translation, etc.).
    required EnrichmentType type,

    /// Conteúdo resultante (texto bruto ou JSON dependendo do tipo).
    required String content,

    /// Modelo LLM usado para gerar este enriquecimento (ex: "gpt-4", "claude-3").
    /// Nulo se não registrado.
    String? model,

    /// Timestamp de criação.
    required DateTime createdAt,
  }) = _Enrichment;

  factory Enrichment.fromJson(Map<String, dynamic> json) =>
      _$EnrichmentFromJson(json);
}
