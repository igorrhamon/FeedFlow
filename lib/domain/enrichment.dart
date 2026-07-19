import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrichment.freezed.dart';

/// Tipo de enriquecimento aplicado a um [WorkItem] via [Enricher].
enum EnrichmentType {
  summary,
  translation,
  classification,
  entities,
  suggestion;

  static EnrichmentType fromName(String name) =>
      EnrichmentType.values.firstWhere((t) => t.name == name);
}

/// Um enriquecimento de IA (resumo, tradução, classificação, etc.)
/// associado a um [WorkItem]. Criado sob demanda por um [Enricher]
/// e persistido no banco local.
///
/// Schema: `Enrichments` table em `lib/infrastructure/db/tables.dart`
/// (schemaVersion 7 — `language`/`tokensUsed`/`costEstimate` adicionados
/// na WS-13, ver `docs/PARALLEL-EXECUTION-PLAN.md`).
@freezed
class Enrichment with _$Enrichment {
  const factory Enrichment({
    int? id,
    required String workItemId,
    required EnrichmentType type,
    required String content,
    String? model,
    required DateTime createdAt,
    String? language,
    int? tokensUsed,
    double? costEstimate,
  }) = _Enrichment;
}
