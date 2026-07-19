import '../../domain/article_action.dart';
import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../../domain/work_item.dart';

/// Ação que gera um resumo do item via [Enricher] e persiste o resultado
/// como um [Enrichment] no [EnrichmentRepository].
class SummarizeAction implements ArticleAction {
  SummarizeAction({
    required Enricher enricher,
    required EnrichmentRepository enrichmentRepository,
  })  : _enricher = enricher,
        _enrichmentRepository = enrichmentRepository;

  final Enricher _enricher;
  final EnrichmentRepository _enrichmentRepository;

  @override
  String get id => 'summarize';

  @override
  String get label => 'Resumir';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final enrichment = await _enricher.enrich(
      item,
      EnrichmentRequest(type: EnrichmentType.summary),
    );
    await _enrichmentRepository.insert(enrichment);
  }
}
