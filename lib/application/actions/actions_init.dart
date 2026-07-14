import '../action_registry.dart';
import '../event_bus.dart';
import '../snooze_use_case.dart';
import '../../domain/repositories/work_item_repository.dart';
import 'add_tag_action.dart';
import 'archive_action.dart';
import 'complete_action.dart';
import 'copy_link_action.dart';
import 'share_action.dart';
import 'snooze_action.dart';
import 'toggle_star_action.dart';

/// Inicializa e registra todas as ações disponíveis no [ActionRegistry].
/// Deve ser chamada exatamente uma vez durante o boot da aplicação (em `main()`),
/// após a inicialização do repositório.
///
/// Registra as 7 ações:
/// - `complete`: marca como concluído
/// - `archive`: arquiva
/// - `snooze`: adia
/// - `toggleStar`: alterna estrela
/// - `share`: compartilha via sistema nativo
/// - `copyLink`: copia URL para área de transferência
/// - `addTag`: adiciona uma tag
void initializeActions(WorkItemRepository workItemRepository) {
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
}
