import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  group('ActionRegistry', () {
    setUp(() {
      ActionRegistry.clear();
    });

    test('register and get an action', () {
      final action = _TestAction('test');
      ActionRegistry.register('test', () => action);

      final retrieved = ActionRegistry.get('test');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test'));
    });

    test('get returns null for unregistered action', () {
      final retrieved = ActionRegistry.get('nonexistent');
      expect(retrieved, isNull);
    });

    test('isRegistered returns true for registered actions', () {
      ActionRegistry.register('test', () => _TestAction());

      expect(ActionRegistry.isRegistered('test'), isTrue);
      expect(ActionRegistry.isRegistered('nonexistent'), isFalse);
    });

    test('getAvailable returns all registered actions', () {
      ActionRegistry.register('action-1', () => _TestAction('action-1'));
      ActionRegistry.register('action-2', () => _TestAction('action-2'));
      ActionRegistry.register('action-3', () => _TestAction('action-3'));

      final available = ActionRegistry.getAvailable();

      expect(available, hasLength(3));
      expect(available.map((a) => a.id).toSet(), equals({'action-1', 'action-2', 'action-3'}));
    });

    test('getAvailable returns empty list when no actions registered', () {
      final available = ActionRegistry.getAvailable();
      expect(available, isEmpty);
    });

    test('clear removes all registered actions', () {
      ActionRegistry.register('action-1', () => _TestAction('action-1'));
      ActionRegistry.register('action-2', () => _TestAction('action-2'));

      ActionRegistry.clear();

      expect(ActionRegistry.getAvailable(), isEmpty);
      expect(ActionRegistry.get('action-1'), isNull);
    });

    test('factory is called each time get is called', () {
      int callCount = 0;
      ActionRegistry.register('test', () {
        callCount++;
        return _TestAction('test');
      });

      ActionRegistry.get('test');
      ActionRegistry.get('test');
      ActionRegistry.get('test');

      expect(callCount, equals(3));
    });
  });
}

class _TestAction implements ArticleAction {
  _TestAction([String? customId]) : _customId = customId;

  final String? _customId;

  @override
  String get id => _customId ?? 'test-action';

  @override
  String get label => 'Test Action';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {}
}
