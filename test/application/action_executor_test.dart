import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  group('ActionExecutor', () {
    late EventBus eventBus;
    late ActionExecutor executor;
    late WorkItem testItem;

    setUp(() {
      eventBus = EventBus();
      executor = ActionExecutor(eventBus: eventBus);
      testItem = WorkItem(
        id: 'test-item-1',
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Register test actions
      ActionRegistry.clear();
      ActionRegistry.register('test-action', () => _SuccessfulTestAction());
      ActionRegistry.register('failing-action', () => _FailingTestAction());
      ActionRegistry.register('success', () => _SuccessfulTestAction());
      ActionRegistry.register('fail', () => _FailingTestAction());
      ActionRegistry.register('success-2', () => _SuccessfulTestAction());
    });

    tearDown(() {
      eventBus.clear();
      ActionRegistry.clear();
    });

    group('execute', () {
      test('publishes ActionExecuted event on success', () async {
        final invocation = ActionInvocation(
          actionId: 'test-action',
          params: {'key': 'value'},
        );

        ActionExecutedEvent? capturedEvent;
        eventBus.subscribe((event) {
          if (event is ActionExecuted) {
            capturedEvent = ActionExecutedEvent(
              workItemId: event.workItemId,
              actionId: event.actionId,
              params: event.params,
            );
          }
        });

        final result = await executor.execute(testItem, invocation);

        expect(result.success, isTrue);
        expect(result.actionId, equals('test-action'));
        expect(result.error, isNull);
        expect(capturedEvent, isNotNull);
        expect(capturedEvent!.workItemId, equals(testItem.id));
      });

      test('does NOT publish ActionExecuted event on failure', () async {
        final invocation = ActionInvocation(
          actionId: 'failing-action',
          params: {},
        );

        int eventCount = 0;
        eventBus.subscribe((event) {
          if (event is ActionExecuted) {
            eventCount++;
          }
        });

        final result = await executor.execute(testItem, invocation);

        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        expect(eventCount, equals(0));
      });

      test('returns success false and error when action not found', () async {
        final invocation = ActionInvocation(
          actionId: 'nonexistent-action',
          params: {},
        );

        final result = await executor.execute(testItem, invocation);

        expect(result.success, isFalse);
        expect(result.actionId, equals('nonexistent-action'));
        expect(result.error, isNotNull);
        expect(result.error.toString(), contains('Action not found'));
      });
    });

    group('executeAll', () {
      test('executes all actions in sequence', () async {
        final invocations = [
          ActionInvocation(actionId: 'success-1', params: {}),
          ActionInvocation(actionId: 'success-2', params: {}),
        ];

        final results = await executor.executeAll(testItem, invocations);

        expect(results, hasLength(2));
        expect(results[0].success, isTrue);
        expect(results[1].success, isTrue);
      });

      test('isolates failures: failing action does not prevent next actions', () async {
        final invocations = [
          ActionInvocation(actionId: 'success', params: {}),
          ActionInvocation(actionId: 'fail', params: {}),
          ActionInvocation(actionId: 'success-2', params: {}),
        ];

        final results = await executor.executeAll(testItem, invocations);

        expect(results, hasLength(3));
        expect(results[0].success, isTrue);
        expect(results[1].success, isFalse);
        expect(results[2].success, isTrue);
      });

      test('publishes ActionExecuted only for successful actions', () async {
        final invocations = [
          ActionInvocation(actionId: 'success', params: {'a': 1}),
          ActionInvocation(actionId: 'fail', params: {'b': 2}),
          ActionInvocation(actionId: 'success-2', params: {'c': 3}),
        ];

        final events = <ActionExecutedEvent>[];
        eventBus.subscribe((event) {
          if (event is ActionExecuted) {
            events.add(
              ActionExecutedEvent(
                workItemId: event.workItemId,
                actionId: event.actionId,
                params: event.params,
              ),
            );
          }
        });

        final results = await executor.executeAll(testItem, invocations);

        expect(results, hasLength(3));
        expect(events, hasLength(2)); // Only 2 successes
        expect(events[0].actionId, equals('success'));
        expect(events[1].actionId, equals('success-2'));
      });

      test('returns correct error for each failed action', () async {
        final invocations = [
          ActionInvocation(actionId: 'success', params: {}),
          ActionInvocation(actionId: 'fail', params: {}),
        ];

        final results = await executor.executeAll(testItem, invocations);

        expect(results[0].success, isTrue);
        expect(results[0].error, isNull);
        expect(results[1].success, isFalse);
        expect(results[1].error, isNotNull);
      });
    });
  });
}

// Test helpers
class _SuccessfulTestAction implements ArticleAction {
  @override
  String get id => 'test-action';

  @override
  String get label => 'Test Action';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    // Success: do nothing
  }
}

class _FailingTestAction implements ArticleAction {
  @override
  String get id => 'failing-action';

  @override
  String get label => 'Failing Action';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    throw Exception('Test failure');
  }
}

class ActionExecutedEvent {
  final String workItemId;
  final String actionId;
  final Map<String, dynamic> params;

  ActionExecutedEvent({
    required this.workItemId,
    required this.actionId,
    required this.params,
  });
}
