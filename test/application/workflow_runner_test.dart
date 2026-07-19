import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/workflow_runner.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

class _NoopAction implements ArticleAction {
  _NoopAction(this.id);

  @override
  final String id;

  @override
  String get label => id;

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {}
}

class _FailingAction implements ArticleAction {
  @override
  String get id => 'failing';

  @override
  String get label => 'Failing';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    throw Exception('boom');
  }
}

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift baseRepo;
  late EventEmittingWorkItemRepository repo;
  late EventBus eventBus;
  late ActionExecutor actionExecutor;
  late WorkflowRunner runner;
  late List<DomainEvent> publishedEvents;

  final item = WorkItem(
    id: 'test-item-1',
    providerId: 'test-provider',
    articleId: 'article-1',
    feedId: 'feed-1',
    title: 'Test Article',
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    eventBus = EventBus();
    repo = EventEmittingWorkItemRepository(baseRepo, eventBus);
    actionExecutor = ActionExecutor(eventBus: eventBus);
    runner = WorkflowRunner(
      workItemRepository: repo,
      actionExecutor: actionExecutor,
      eventBus: eventBus,
    );

    publishedEvents = [];
    eventBus.subscribe(publishedEvents.add);

    ActionRegistry.clear();
    ActionRegistry.register('stepA', () => _NoopAction('stepA'));
    ActionRegistry.register('stepB', () => _NoopAction('stepB'));
    ActionRegistry.register('failing', () => _FailingAction());

    await repo.save(item);
  });

  tearDown(() async {
    ActionRegistry.clear();
    await db.close();
  });

  group('WorkflowRunner', () {
    test('executes steps in order and returns one result per step', () async {
      final results = await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        const ActionInvocation(actionId: 'stepB', params: {}),
      ]);

      expect(results, hasLength(2));
      expect(results[0].actionId, 'stepA');
      expect(results[0].success, isTrue);
      expect(results[1].actionId, 'stepB');
      expect(results[1].success, isTrue);
    });

    test('a failing step does not interrupt the following steps', () async {
      final results = await runner.run(item, [
        const ActionInvocation(actionId: 'failing', params: {}),
        const ActionInvocation(actionId: 'stepB', params: {}),
      ]);

      expect(results, hasLength(2));
      expect(results[0].success, isFalse);
      expect(results[1].success, isTrue);
    });

    test('publishes WorkflowStepExecuted for each step and WorkflowCompleted at the end',
        () async {
      await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
        const ActionInvocation(actionId: 'failing', params: {}),
      ]);

      final stepEvents = publishedEvents.whereType<WorkflowStepExecuted>().toList();
      expect(stepEvents, hasLength(2));
      expect(stepEvents[0].actionId, 'stepA');
      expect(stepEvents[0].success, isTrue);
      expect(stepEvents[0].stepIndex, 0);
      expect(stepEvents[1].actionId, 'failing');
      expect(stepEvents[1].success, isFalse);
      expect(stepEvents[1].stepIndex, 1);

      final completedEvents = publishedEvents.whereType<WorkflowCompleted>().toList();
      expect(completedEvents, hasLength(1));
      expect(completedEvents.single.totalSteps, 2);
      expect(completedEvents.single.succeededSteps, 1);
    });

    test('persists a workflowCompleted row in WorkItemEvents', () async {
      await runner.run(item, [
        const ActionInvocation(actionId: 'stepA', params: {}),
      ]);

      final rows = await (db.select(db.workItemEvents)
            ..where((t) => t.workItemId.equals(item.id) & t.type.equals('workflowCompleted')))
          .get();

      expect(rows, hasLength(1));
      final payload = jsonDecode(rows.single.payloadJson) as Map<String, dynamic>;
      expect(payload['totalSteps'], 1);
      expect(payload['succeededSteps'], 1);
      expect(payload['actionIds'], ['stepA']);
    });

    test('returns an empty result list for an empty workflow', () async {
      final results = await runner.run(item, []);
      expect(results, isEmpty);

      final completedEvents = publishedEvents.whereType<WorkflowCompleted>().toList();
      expect(completedEvents.single.totalSteps, 0);
      expect(completedEvents.single.succeededSteps, 0);
    });
  });
}
