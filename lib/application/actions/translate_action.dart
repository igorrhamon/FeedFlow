import '../../domain/article_action.dart';
import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../../domain/work_item.dart';

/// Ação que traduz o item via [Enricher] e persiste o resultado como um
/// [Enrichment]. Parâmetro `params['targetLanguage']` (String, obrigatório)
/// é o código do idioma alvo (ex.: 'pt', 'en', 'es').
class TranslateAction implements ArticleAction {
  TranslateAction({
    required Enricher enricher,
    required EnrichmentRepository enrichmentRepository,
  })  : _enricher = enricher,
        _enrichmentRepository = enrichmentRepository;

  final Enricher _enricher;
  final EnrichmentRepository _enrichmentRepository;

  @override
  String get id => 'translate';

  @override
  String get label => 'Traduzir';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final targetLanguage = params['targetLanguage'] as String?;
    if (targetLanguage == null || targetLanguage.isEmpty) {
      throw ArgumentError(
          'translate requires params[\'targetLanguage\'] (non-empty String)');
    }

    final enrichment = await _enricher.enrich(
      item,
      EnrichmentRequest(
        type: EnrichmentType.translation,
        targetLanguage: targetLanguage,
      ),
    );
    await _enrichmentRepository.insert(enrichment);
  }
}
