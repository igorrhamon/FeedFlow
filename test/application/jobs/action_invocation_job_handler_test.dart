import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/jobs/action_invocation_job_handler.dart';
import 'package:feedflow/domain/document.dart';
import 'package:feedflow/domain/job.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/models/article.dart';

void main() {
  group('ActionInvocationJobHandler', () {
    late FakeWorkItemRepository fakeWorkItemRepository;
    late FakeActionExecutor fakeActionExecutor;
    late ActionInvocationJobHandler handler;

    setUp(() {
      fakeWorkItemRepository = FakeWorkItemRepository();
      fakeActionExecutor = FakeActionExecutor();
      handler = ActionInvocationJobHandler(
        workItemRepository: fakeWorkItemRepository,
        actionExecutor: fakeActionExecutor,
      );
    });

    test('jobType returns "actionInvocation"', () {
      expect(handler.jobType, equals('actionInvocation'));
    });

    test('run() executes action successfully when item exists', () async {
      // Arrange
      final workItem = _createTestWorkItem(id: 'item1');
      fakeWorkItemRepository.addItem(workItem);
      fakeActionExecutor.setResult(true);

      final job = Job(
        id: 'job1',
        type: 'actionInvocation',
        payload: {
          'workItemId': 'item1',
          'actionId': 'complete',
          'params': {'note': 'Done'},
        },
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act - should not throw
      await handler.run(job);

      // Assert - Verify that ActionExecutor was called
      expect(fakeActionExecutor.lastItem?.id, equals('item1'));
      expect(fakeActionExecutor.lastInvocation?.actionId, equals('complete'));
      expect(fakeActionExecutor.lastInvocation?.params['note'], equals('Done'));
    });

    test('run() throws StateError when WorkItem not found', () async {
      // Arrange
      final job = Job(
        id: 'job2',
        type: 'actionInvocation',
        payload: {
          'workItemId': 'nonexistent',
          'actionId': 'complete',
          'params': {},
        },
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => handler.run(job),
        throwsA(isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('WorkItem not found'),
        )),
      );
    });

    test('run() throws StateError when action fails', () async {
      // Arrange
      final workItem = _createTestWorkItem(id: 'item2');
      fakeWorkItemRepository.addItem(workItem);
      fakeActionExecutor.setResult(false, error: 'Action error');

      final job = Job(
        id: 'job3',
        type: 'actionInvocation',
        payload: {
          'workItemId': 'item2',
          'actionId': 'complete',
          'params': {},
        },
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => handler.run(job),
        throwsA(isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Action failed'),
        )),
      );
    });

    test('run() extracts params correctly from payload', () async {
      // Arrange
      final workItem = _createTestWorkItem(id: 'item3');
      fakeWorkItemRepository.addItem(workItem);
      fakeActionExecutor.setResult(true);

      final params = {'key1': 'value1', 'key2': 42};
      final job = Job(
        id: 'job4',
        type: 'actionInvocation',
        payload: {
          'workItemId': 'item3',
          'actionId': 'customAction',
          'params': params,
        },
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act
      await handler.run(job);

      // Assert
      expect(fakeActionExecutor.lastInvocation?.params, equals(params));
    });

    test('run() handles missing params in payload', () async {
      // Arrange
      final workItem = _createTestWorkItem(id: 'item4');
      fakeWorkItemRepository.addItem(workItem);
      fakeActionExecutor.setResult(true);

      final job = Job(
        id: 'job5',
        type: 'actionInvocation',
        payload: {
          'workItemId': 'item4',
          'actionId': 'complete',
          // No 'params' key
        },
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert - should not throw
      await handler.run(job);

      // Verify params defaults to empty map
      expect(fakeActionExecutor.lastInvocation?.params, equals({}));
    });
  });
}

// ============================================================================
// Fakes for testing
// ============================================================================

class FakeWorkItemRepository implements WorkItemRepository {
  final Map<String, WorkItem> _items = {};

  void addItem(WorkItem item) {
    _items[item.id] = item;
  }

  @override
  Future<WorkItem?> byId(String id) async => _items[id];

  @override
  Future<void> changeStatus(String id, TriageStatus newStatus) async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> logEvent(
    String workItemId, {
    required String type,
    required String actor,
    Map<String, dynamic> payload = const {},
  }) async {}

  @override
  Future<int> purgeOlderThan(
    DateTime cutoff, {
    List<TriageStatus>? statuses,
  }) async =>
      0;

  @override
  Future<void> save(WorkItem item) async {
    _items[item.id] = item;
  }

  @override
  Future<void> upsertFromArticles(
    List<Article> articles,
    String providerId,
  ) async {}

  @override
  Future<void> upsertFromDocuments(
    List<Document> documents,
    String providerId,
  ) async {}

  @override
  Stream<List<WorkItem>> watchByFeedId(
    String feedId, {
    List<TriageStatus>? statuses,
  }) =>
      Stream.value([]);

  @override
  Stream<List<WorkItem>> watchByStatus(List<TriageStatus> statuses) =>
      Stream.value([]);

  @override
  Stream<int> watchCountByStatus(TriageStatus status) => Stream.value(0);

  @override
  Stream<List<WorkItem>> watchStarred() => Stream.value([]);

  @override
  Stream<Map<String, int>> watchUnreadCountsByFeed() => Stream.value({});
}

class FakeActionExecutor implements ActionExecutor {
  WorkItem? lastItem;
  ActionInvocation? lastInvocation;
  bool _shouldSucceed = true;
  Object? _error;

  void setResult(bool success, {Object? error}) {
    _shouldSucceed = success;
    _error = error;
  }

  @override
  Future<ActionExecutionResult> execute(
    WorkItem item,
    ActionInvocation invocation,
  ) async {
    lastItem = item;
    lastInvocation = invocation;

    return ActionExecutionResult(
      actionId: invocation.actionId,
      success: _shouldSucceed,
      error: _error,
    );
  }

  @override
  Future<List<ActionExecutionResult>> executeAll(
    WorkItem item,
    List<ActionInvocation> invocations,
  ) async {
    final results = <ActionExecutionResult>[];
    for (final inv in invocations) {
      results.add(await execute(item, inv));
    }
    return results;
  }
}

// ============================================================================
// Test helpers
// ============================================================================

WorkItem _createTestWorkItem({required String id}) {
  return WorkItem(
    id: id,
    providerId: 'provider1',
    articleId: 'article1',
    title: 'Test Article',
    content: 'Test content',
    url: 'https://example.com',
    author: 'Test Author',
    feedId: 'feed1',
    isRead: false,
    isStarred: false,
    status: TriageStatus.novo,
    tags: const [],
    priority: Priority.none,
    notes: '',
    snoozedUntil: null,
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
