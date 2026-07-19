import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/toggle_star_action.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift baseRepo;
  late EventEmittingWorkItemRepository decoratedRepo;
  late EventBus eventBus;
  late ToggleStarAction action;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    action = ToggleStarAction(workItemRepository: decoratedRepo);
  });

  tearDown(() async {
    await db.close();
  });

  WorkItem createTestItem({
    String id = 'test-item-1',
    bool isStarred = false,
  }) =>
      WorkItem(
        id: id,
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        isStarred: isStarred,
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('ToggleStarAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('toggleStar'));
      expect(action.label, isNotEmpty);
    });

    test('toggles star from false to true', () async {
      final item = createTestItem(isStarred: false);
      await decoratedRepo.save(item);

      await action.execute(item, {});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.isStarred, isTrue);
    });

    test('toggles star from true to false', () async {
      final item = createTestItem(isStarred: true);
      await decoratedRepo.save(item);

      await action.execute(item, {});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.isStarred, isFalse);
    });

    test('ignores params', () async {
      final item = createTestItem(isStarred: false);
      await decoratedRepo.save(item);

      await action.execute(item, {'unused': 'param'});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.isStarred, isTrue);
    });
  });
}
