import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/complete_action.dart';
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
  late CompleteAction action;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    action = CompleteAction(workItemRepository: decoratedRepo);
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

  group('CompleteAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('complete'));
      expect(action.label, isNotEmpty);
    });

    test('changes status to concluido', () async {
      final item = createTestItem(status: TriageStatus.novo);
      await decoratedRepo.save(item);

      await action.execute(item, {});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated, isNotNull);
      expect(updated!.status, equals(TriageStatus.concluido));
    });

    test('ignores params', () async {
      final item = createTestItem(status: TriageStatus.novo);
      await decoratedRepo.save(item);

      await action.execute(item, {'extra': 'value', 'another': 123});

      final updated = await decoratedRepo.byId(item.id);
      expect(updated!.status, equals(TriageStatus.concluido));
    });

    test('works with any status that pode transicionar para concluido', () async {
      // arquivado não transiciona diretamente para concluido (ver
      // kTriageTransitions em lib/domain/triage_status.dart) — não é um bug
      // da ação, é a FSM de triagem sendo respeitada.
      const validStartStatuses = [
        TriageStatus.novo,
        TriageStatus.triado,
        TriageStatus.emAndamento,
      ];
      for (final status in validStartStatuses) {
        final item = createTestItem(
          id: 'test-item-$status',
          status: status,
        );
        await decoratedRepo.save(item);

        await action.execute(item, {});

        final updated = await decoratedRepo.byId(item.id);
        expect(updated!.status, equals(TriageStatus.concluido));
      }
    });
  });
}
