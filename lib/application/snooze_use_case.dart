import '../domain/events/domain_event.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/work_item.dart';
import 'event_bus.dart';

/// Encapsula a lógica de adiamento (snooze) de um [WorkItem]: define/limpa
/// `snoozedUntil` e publica o evento de domínio correspondente
/// ([ItemSnoozed]/[SnoozeExpired]) para que outros componentes (ex.:
/// [RuleEngine]) possam reagir.
class SnoozeUseCase {
  SnoozeUseCase({
    required WorkItemRepository workItemRepository,
    required EventBus eventBus,
  })  : _workItemRepository = workItemRepository,
        _eventBus = eventBus;

  final WorkItemRepository _workItemRepository;
  final EventBus _eventBus;

  /// Adia [item] até [until]. Não valida se [until] está no futuro — a
  /// UI decide o intervalo permitido.
  Future<void> snooze(WorkItem item, DateTime until, {String actor = 'user'}) async {
    await _workItemRepository.save(item.copyWith(snoozedUntil: until));
    _eventBus.publish(
      ItemSnoozed(
        workItemId: item.id,
        snoozedUntil: until,
        actor: actor,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Acorda [item] antes do prazo (ou após expirar), limpando `snoozedUntil`.
  Future<void> wake(WorkItem item) async {
    await _workItemRepository.save(item.copyWith(snoozedUntil: null));
    _eventBus.publish(
      SnoozeExpired(
        workItemId: item.id,
        timestamp: DateTime.now(),
      ),
    );
  }
}
