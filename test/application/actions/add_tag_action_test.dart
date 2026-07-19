import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/add_tag_action.dart';
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
  late AddTagAction action;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    action = AddTagAction(workItemRepository: decoratedRepo);
  });

  tearDown(() async {
    await db.close();
  });

  WorkItem createTestItem({
    String id = 'test-item-1',
    List<String> tags = const [],
  }) =>
      WorkItem(
        id: id,
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        tags: tags,
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('AddTagAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('addTag'));
      expect(action.label, isNotEmpty);
    });

    test('adds tag to item with no tags', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);

      await action.execute(item, {'tag': 'urgent'});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.tags, equals(['urgent']));
    });

    test('adds tag to item with existing tags', () async {
      final item = createTestItem(tags: ['important', 'work']);
      await decoratedRepo.save(item);

      await action.execute(item, {'tag': 'urgent'});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.tags, equals(['important', 'work', 'urgent']));
    });

    test('is idempotent: does not add duplicate tags', () async {
      final item = createTestItem(tags: ['important']);
      await decoratedRepo.save(item);

      await action.execute(item, {'tag': 'important'});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.tags, equals(['important']));
    });

    test('throws ArgumentError when tag param is missing', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);

      expect(
        () => action.execute(item, {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when tag param is empty string', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);

      expect(
        () => action.execute(item, {'tag': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when tag param is null', () async {
      final item = createTestItem();
      await decoratedRepo.save(item);

      expect(
        () => action.execute(item, {'tag': null}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
