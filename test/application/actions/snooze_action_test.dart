import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/snooze_action.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/snooze_use_case.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift baseRepo;
  late EventEmittingWorkItemRepository decoratedRepo;
  late EventBus eventBus;
  late SnoozeUseCase snoozeUseCase;
  late SnoozeAction action;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    snoozeUseCase = SnoozeUseCase(
      workItemRepository: decoratedRepo,
      eventBus: eventBus,
    );
    action = SnoozeAction(snoozeUseCase: snoozeUseCase);
  });

  tearDown(() async {
    await db.close();
  });

  WorkItem createTestItem({String id = 'test-item-1'}) => WorkItem(
        id: id,
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('SnoozeAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('snooze'));
      expect(action.label, isNotEmpty);
    });

    test('snoozes item for default 1 day', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);
      final now = DateTime.now();

      await action.execute(item, {});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.snoozedUntil, isNotNull);
      expect(updated.snoozedUntil!.isAfter(now), isTrue);
      // Drift persiste DateTime com precisão de segundos — compara com
      // tolerância em vez de inDays (que trunca e é sensível a perda de
      // sub-segundo perto da fronteira do dia).
      final diff = updated.snoozedUntil!.difference(now);
      expect(diff.inSeconds, closeTo(const Duration(days: 1).inSeconds, 2));
    });

    test('snoozes item for custom days from params', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);
      final now = DateTime.now();

      await action.execute(item, {'days': 3});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.snoozedUntil, isNotNull);
      final diff = updated.snoozedUntil!.difference(now);
      expect(diff.inSeconds, closeTo(const Duration(days: 3).inSeconds, 2));
    });

    test('snoozes item for 0 days (immediate wake)', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);
      final now = DateTime.now();

      await action.execute(item, {'days': 0});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      // snoozedUntil should be roughly now (or just past)
      expect(updated!.snoozedUntil!.isAfter(now.subtract(Duration(seconds: 1))), isTrue);
    });
  });
}
