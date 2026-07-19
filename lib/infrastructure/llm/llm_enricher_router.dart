import 'dart:developer' as developer;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/llm_provider_id.dart';
import '../../domain/work_item.dart';
import '../../services/llm_settings.dart';
import 'google_ai_studio_adapter.dart';
import 'llm_adapter.dart';
import 'openrouter_adapter.dart';

/// [Enricher] que delega ao provedor de LLM ativo (`LlmSettings`), resolvido
/// a cada chamada de [enrich] — não no momento da construção. Isso permite
/// trocar de provedor na tela de configurações
/// (`lib/pages/llm_settings_page.dart`) sem reiniciar o app, já que
/// `DatabaseProvider.enricher` é um getter síncrono cacheado, mas [enrich]
/// já é assíncrono e pode ler o provedor ativo a cada execução.
///
/// Delegates injetáveis via construtor para testes (evita mockar HTTP/secure
/// storage dos 3 adapters reais ao mesmo tempo).
class LlmEnricherRouter implements Enricher {
  LlmEnricherRouter({
    Enricher? anthropic,
    Enricher? openRouter,
    Enricher? googleAiStudio,
  })  : _anthropic = anthropic ?? LlmAdapter(),
        _openRouter = openRouter ?? OpenRouterAdapter(),
        _googleAiStudio = googleAiStudio ?? GoogleAiStudioAdapter();

  final Enricher _anthropic;
  final Enricher _openRouter;
  final Enricher _googleAiStudio;

  @override
  String get id => 'llm-router';

  @override
  Set<EnrichmentType> get capabilities => {
        EnrichmentType.summary,
        EnrichmentType.translation,
        EnrichmentType.classification,
      };

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req) async {
    final active = await LlmSettings.getActiveProvider();
    developer.log(
      'routing enrich(type=${req.type.name}) to provider=${active.id} workItem=${item.id}',
      name: 'FeedFlow.LLM.Router',
    );
    try {
      final result = await _resolve(active).enrich(item, req);
      developer.log(
        'enrich succeeded via provider=${active.id} workItem=${item.id}',
        name: 'FeedFlow.LLM.Router',
      );
      return result;
    } catch (e) {
      developer.log(
        'enrich failed via provider=${active.id} workItem=${item.id}: $e',
        name: 'FeedFlow.LLM.Router',
        error: e,
      );
      rethrow;
    }
  }

  Enricher _resolve(LlmProviderId provider) {
    switch (provider) {
      case LlmProviderId.openRouter:
        return _openRouter;
      case LlmProviderId.googleAiStudio:
        return _googleAiStudio;
      case LlmProviderId.anthropic:
        return _anthropic;
    }
  }
}
