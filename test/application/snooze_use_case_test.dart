import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/snooze_use_case.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift repository;
  late EventBus bus;
  late SnoozeUseCase useCase;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = WorkItemRepositoryDrift(db);
    bus = EventBus();
    useCase = SnoozeUseCase(workItemRepository: repository, eventBus: bus);
  });

  tearDown(() async {
    await db.close();
  });

  group('SnoozeUseCase', () {
    test('snooze define snoozedUntil e publica ItemSnoozed', () async {
      await repository.upsertFromArticles(
        [Article(id: 'a1', feedId: 'f1', title: 'Título')],
        'feedbin',
      );
      final item = (await repository.byId('feedbin:a1'))!;

      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      final until = DateTime.now().add(const Duration(days: 1));
      await useCase.snooze(item, until);

      final updated = await repository.byId('feedbin:a1');
      // Drift persiste DateTime com precisão de segundos — compara truncado.
      expect(
        updated!.snoozedUntil!.difference(until).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
      expect(updated.isSnoozed, true);

      expect(events.length, 1);
      final event = events.first as ItemSnoozed;
      expect(event.workItemId, 'feedbin:a1');
      expect(event.snoozedUntil, until);
      expect(event.actor, 'user');
    });

    test('wake limpa snoozedUntil e publica SnoozeExpired', () async {
      await repository.upsertFromArticles(
        [Article(id: 'a1', feedId: 'f1', title: 'Título')],
        'feedbin',
      );
      var item = (await repository.byId('feedbin:a1'))!;
      await useCase.snooze(item, DateTime.now().add(const Duration(days: 1)));
      item = (await repository.byId('feedbin:a1'))!;

      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      await useCase.wake(item);

      final updated = await repository.byId('feedbin:a1');
      expect(updated!.snoozedUntil, isNull);
      expect(updated.isSnoozed, false);

      expect(events.length, 1);
      expect(events.first, isA<SnoozeExpired>());
    });
  });
}
