import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/journal_listener.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';

/// Fake simples de [WorkItemRepository] só para capturar chamadas a
/// [logEvent] em memória — os demais métodos não são exercitados por
/// [JournalListener] e lançam [UnimplementedError].
class FakeWorkItemRepository implements WorkItemRepository {
  final List<
      ({
        String workItemId,
        String type,
        String actor,
        Map<String, dynamic> payload
      })> loggedEvents = [];

  @override
  Future<void> logEvent(
    String workItemId, {
    required String type,
    required String actor,
    Map<String, dynamic> payload = const {},
  }) async {
    loggedEvents.add((
      workItemId: workItemId,
      type: type,
      actor: actor,
      payload: payload,
    ));
  }

  @override
  Stream<List<WorkItem>> watchByStatus(List<TriageStatus> statuses) =>
      throw UnimplementedError();

  @override
  Stream<int> watchCountByStatus(TriageStatus status) =>
      throw UnimplementedError();

  @override
  Future<WorkItem?> byId(String id) => throw UnimplementedError();

  @override
  Future<void> upsertFromArticles(articles, String providerId) =>
      throw UnimplementedError();

  @override
  Future<void> save(WorkItem item) => throw UnimplementedError();

  @override
  Future<void> changeStatus(String id, TriageStatus newStatus) =>
      throw UnimplementedError();

  @override
  Future<int> purgeOlderThan(DateTime cutoff, {List<TriageStatus>? statuses}) =>
      throw UnimplementedError();

  @override
  Stream<Map<String, int>> watchUnreadCountsByFeed() =>
      throw UnimplementedError();

  @override
  Stream<List<WorkItem>> watchByFeedId(String feedId,
          {List<TriageStatus>? statuses}) =>
      throw UnimplementedError();

  @override
  Future<void> close() => throw UnimplementedError();

  @override
  Stream<List<WorkItem>> watchStarred() => throw UnimplementedError();
}

void main() {
  late FakeWorkItemRepository repo;
  late JournalListener listener;

  setUp(() {
    repo = FakeWorkItemRepository();
    listener = JournalListener(workItemRepository: repo);
  });

  group('JournalListener.call', () {
    test('ArticleIngested grava logEvent com type articleIngested', () async {
      final event = ArticleIngested(
        workItemId: 'feedbin:a1',
        providerId: 'feedbin',
        articleId: 'a1',
        feedId: 'f1',
        title: 'Título',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, 'feedbin:a1');
      expect(logged.type, 'articleIngested');
      expect(logged.actor, 'system');
      expect(logged.payload['providerId'], 'feedbin');
      expect(logged.payload['articleId'], 'a1');
      expect(logged.payload['feedId'], 'f1');
      expect(logged.payload['title'], 'Título');
    });

    test('StatusChanged grava logEvent com type statusChanged', () async {
      final event = StatusChanged(
        workItemId: 'feedbin:a1',
        fromStatus: 'novo',
        toStatus: 'triado',
        actor: 'user',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, 'feedbin:a1');
      expect(logged.type, 'statusChanged');
      expect(logged.actor, 'system');
      expect(logged.payload['fromStatus'], 'novo');
      expect(logged.payload['toStatus'], 'triado');
      expect(logged.payload['actor'], 'user');
    });

    test('SyncFailed grava logEvent com type syncFailed e workItemId vazio',
        () async {
      final event = SyncFailed(
        providerId: 'feedbin',
        error: 'timeout',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'syncFailed');
      expect(logged.payload['providerId'], 'feedbin');
      expect(logged.payload['error'], 'timeout');
    });

    test('SyncCompleted grava logEvent com type syncCompleted e workItemId vazio',
        () async {
      final event = SyncCompleted(
        providerId: 'feedbin',
        itemsIngested: 5,
        itemsUpdated: 2,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'syncCompleted');
      expect(logged.payload['itemsIngested'], 5);
      expect(logged.payload['itemsUpdated'], 2);
    });

    test('ItemSnoozed grava logEvent com type snoozed', () async {
      final now = DateTime.now();
      final event = ItemSnoozed(
        workItemId: 'feedbin:a1',
        snoozedUntil: now,
        actor: 'user',
        timestamp: now,
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.type, 'snoozed');
      expect(logged.payload['snoozedUntil'], now.toIso8601String());
    });

    test('SnoozeExpired grava logEvent com type snoozeExpired', () async {
      final event = SnoozeExpired(
        workItemId: 'feedbin:a1',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      expect(repo.loggedEvents.single.type, 'snoozeExpired');
    });

    test('ActionExecuted grava logEvent com type actionExecuted', () async {
      final event = ActionExecuted(
        workItemId: 'feedbin:a1',
        actionId: 'archive',
        params: const {'foo': 'bar'},
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.type, 'actionExecuted');
      expect(logged.payload['actionId'], 'archive');
      expect(logged.payload['params'], {'foo': 'bar'});
    });

    test('EnrichmentCompleted grava logEvent com type enrichmentCompleted',
        () async {
      final event = EnrichmentCompleted(
        workItemId: 'feedbin:a1',
        enrichmentType: 'summary',
        model: 'claude',
        tokensUsed: 100,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      expect(repo.loggedEvents.single.type, 'enrichmentCompleted');
    });

    test('EnrichmentFailed grava logEvent com type enrichmentFailed', () async {
      final event = EnrichmentFailed(
        workItemId: 'feedbin:a1',
        enrichmentType: 'summary',
        error: 'timeout',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      expect(repo.loggedEvents.single.type, 'enrichmentFailed');
    });

    test('WorkflowStepExecuted grava logEvent com type workflowStepExecuted',
        () async {
      final event = WorkflowStepExecuted(
        workItemId: 'feedbin:a1',
        actionId: 'archive',
        stepIndex: 0,
        totalSteps: 2,
        success: true,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      expect(repo.loggedEvents.single.type, 'workflowStepExecuted');
    });

    test('RuleMatched NÃO dispara logEvent (gravação manual pelo RuleEngine)',
        () async {
      final event = RuleMatched(
        ruleId: 'r1',
        workItemId: 'feedbin:a1',
        ruleName: 'Rule',
        actionId: 'archive',
        payload: const {},
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, isEmpty);
    });

    test(
        'WorkflowCompleted NÃO dispara logEvent (gravação manual pelo WorkflowRunner)',
        () async {
      final event = WorkflowCompleted(
        workItemId: 'feedbin:a1',
        totalSteps: 2,
        succeededSteps: 2,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, isEmpty);
    });

    test('JobEnqueued grava logEvent com type jobEnqueued e workItemId vazio',
        () async {
      final event = JobEnqueued(
        jobId: 'job-123',
        type: 'sync',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'jobEnqueued');
      expect(logged.payload['jobId'], 'job-123');
      expect(logged.payload['type'], 'sync');
    });

    test('JobStarted grava logEvent com type jobStarted e workItemId vazio',
        () async {
      final event = JobStarted(
        jobId: 'job-123',
        type: 'sync',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'jobStarted');
      expect(logged.payload['jobId'], 'job-123');
      expect(logged.payload['type'], 'sync');
    });

    test('JobSucceeded grava logEvent com type jobSucceeded e workItemId vazio',
        () async {
      final event = JobSucceeded(
        jobId: 'job-123',
        type: 'sync',
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'jobSucceeded');
      expect(logged.payload['jobId'], 'job-123');
      expect(logged.payload['type'], 'sync');
    });

    test('JobFailed grava logEvent com type jobFailed e workItemId vazio',
        () async {
      final event = JobFailed(
        jobId: 'job-123',
        type: 'sync',
        error: 'network timeout',
        attempts: 2,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'jobFailed');
      expect(logged.payload['jobId'], 'job-123');
      expect(logged.payload['type'], 'sync');
      expect(logged.payload['error'], 'network timeout');
      expect(logged.payload['attempts'], 2);
    });

    test('JobRetried grava logEvent com type jobRetried e workItemId vazio',
        () async {
      final nextRun = DateTime.now().add(Duration(minutes: 5));
      final event = JobRetried(
        jobId: 'job-123',
        type: 'sync',
        attempts: 1,
        nextRunAt: nextRun,
        timestamp: DateTime.now(),
      );

      await listener.call(event);

      expect(repo.loggedEvents, hasLength(1));
      final logged = repo.loggedEvents.single;
      expect(logged.workItemId, '');
      expect(logged.type, 'jobRetried');
      expect(logged.payload['jobId'], 'job-123');
      expect(logged.payload['type'], 'sync');
      expect(logged.payload['attempts'], 1);
      expect(logged.payload['nextRunAt'], nextRun.toIso8601String());
    });
  });

  group('initializeJournalListener + EventBus real', () {
    test('assina o bus e recebe eventos publicados', () async {
      final bus = EventBus();
      final createdListener = initializeJournalListener(
        bus: bus,
        workItemRepository: repo,
      );

      expect(createdListener, isA<JournalListener>());

      await bus.publish(ArticleIngested(
        workItemId: 'feedbin:a1',
        providerId: 'feedbin',
        articleId: 'a1',
        feedId: 'f1',
        title: 'Título',
        timestamp: DateTime.now(),
      ));

      expect(repo.loggedEvents, hasLength(1));
      expect(repo.loggedEvents.single.type, 'articleIngested');

      await bus.publish(RuleMatched(
        ruleId: 'r1',
        workItemId: 'feedbin:a1',
        ruleName: 'Rule',
        actionId: null,
        payload: const {},
        timestamp: DateTime.now(),
      ));

      // RuleMatched não gera novo logEvent — continua com apenas 1.
      expect(repo.loggedEvents, hasLength(1));
    });
  });
}
