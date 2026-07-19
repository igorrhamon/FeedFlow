import '../action_registry.dart';
import '../event_bus.dart';
import '../snooze_use_case.dart';
import '../../domain/enricher.dart';
import '../../domain/repositories/enrichment_repository.dart';
import '../../domain/repositories/work_item_repository.dart';
import 'add_tag_action.dart';
import 'archive_action.dart';
import 'classify_action.dart';
import 'complete_action.dart';
import 'copy_link_action.dart';
import 'share_action.dart';
import 'snooze_action.dart';
import 'summarize_action.dart';
import 'toggle_star_action.dart';
import 'translate_action.dart';
import 'webhook_action.dart';
import 'notion_export_action.dart';
import 'obsidian_export_action.dart';

/// Inicializa e registra todas as ações disponíveis no [ActionRegistry].
/// Deve ser chamada exatamente uma vez durante o boot da aplicação (em `main()`),
/// após a inicialização do repositório.
///
/// Registra as 10 ações sempre disponíveis:
/// - `complete`: marca como concluído
/// - `archive`: arquiva
/// - `snooze`: adia
/// - `toggleStar`: alterna estrela
/// - `share`: compartilha via sistema nativo
/// - `copyLink`: copia URL para área de transferência
/// - `addTag`: adiciona uma tag
/// - `webhook`: envia para um webhook
/// - `notionExport`: exporta para Notion
/// - `obsidianExport`: exporta para Obsidian
///
/// Se [enricher] e [enrichmentRepository] forem fornecidos (WS-13; `null`
/// em plataformas sem persistência local, ex. web), registra também:
/// - `summarize`: gera um resumo via IA
/// - `translate`: traduz via IA (requer `params['targetLanguage']`)
/// - `classify`: classifica via IA
void initializeActions(
  WorkItemRepository workItemRepository, {
  Enricher? enricher,
  EnrichmentRepository? enrichmentRepository,
}) {
  final snoozeUseCase = SnoozeUseCase(
    workItemRepository: workItemRepository,
    eventBus: eventBus,
  );

  ActionRegistry.register(
    'complete',
    () => CompleteAction(workItemRepository: workItemRepository),
  );

  ActionRegistry.register(
    'archive',
    () => ArchiveAction(workItemRepository: workItemRepository),
  );

  ActionRegistry.register(
    'snooze',
    () => SnoozeAction(snoozeUseCase: snoozeUseCase),
  );

  ActionRegistry.register(
    'toggleStar',
    () => ToggleStarAction(workItemRepository: workItemRepository),
  );

  ActionRegistry.register(
    'share',
    () => ShareAction(),
  );

  ActionRegistry.register(
    'copyLink',
    () => CopyLinkAction(),
  );

  ActionRegistry.register(
    'addTag',
    () => AddTagAction(workItemRepository: workItemRepository),
  );

  ActionRegistry.register(
    'webhook',
    () => WebhookAction(),
  );

  ActionRegistry.register(
    'notionExport',
    () => NotionExportAction(),
  );

  ActionRegistry.register(
    'obsidianExport',
    () => ObsidianExportAction(),
  );

  if (enricher != null && enrichmentRepository != null) {
    ActionRegistry.register(
      'summarize',
      () => SummarizeAction(
        enricher: enricher,
        enrichmentRepository: enrichmentRepository,
      ),
    );

    ActionRegistry.register(
      'translate',
      () => TranslateAction(
        enricher: enricher,
        enrichmentRepository: enrichmentRepository,
      ),
    );

    ActionRegistry.register(
      'classify',
      () => ClassifyAction(
        enricher: enricher,
        enrichmentRepository: enrichmentRepository,
      ),
    );
  }
}
