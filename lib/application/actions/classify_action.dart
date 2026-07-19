import 'dart:developer' as developer;

import '../../domain/article_action.dart';
import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../../domain/work_item.dart';

/// Ação que classifica o item via [Enricher] e persiste o resultado como um
/// [Enrichment].
class ClassifyAction implements ArticleAction {
  ClassifyAction({
    required Enricher enricher,
    required EnrichmentRepository enrichmentRepository,
  })  : _enricher = enricher,
        _enrichmentRepository = enrichmentRepository;

  final Enricher _enricher;
  final EnrichmentRepository _enrichmentRepository;

  @override
  String get id => 'classify';

  @override
  String get label => 'Classificar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final enrichment = await _enricher.enrich(
      item,
      EnrichmentRequest(type: EnrichmentType.classification),
    );
    final saved = await _enrichmentRepository.insert(enrichment);
    developer.log(
      'classify saved: id=${saved.id} workItem=${item.id}',
      name: 'FeedFlow.Actions.Classify',
    );
  }
}
