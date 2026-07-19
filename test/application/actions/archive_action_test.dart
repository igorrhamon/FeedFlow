import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/archive_action.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift baseRepo;
  late EventEmittingWorkItemRepository decoratedRepo;
  late EventBus eventBus;
  late ArchiveAction action;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    action = ArchiveAction(workItemRepository: decoratedRepo);
  });

  tearDown(() async {
    await db.close();
  });

  WorkItem createTestItem({
    String id = 'test-item-1',
    TriageStatus status = TriageStatus.novo,
  }) =>
      WorkItem(
        id: id,
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        status: status,
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('ArchiveAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('archive'));
      expect(action.label, isNotEmpty);
    });

    test('changes status to arquivado', () async {
      final item = createTestItem(status: TriageStatus.novo);
      await decoratedRepo.save(item);

      await action.execute(item, {});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.status, equals(TriageStatus.arquivado));
    });

    test('ignores params', () async {
      final item = createTestItem(status: TriageStatus.novo);
      await decoratedRepo.save(item);

      await action.execute(item, {'unused': true});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.status, equals(TriageStatus.arquivado));
    });
  });
}
