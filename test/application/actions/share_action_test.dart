import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/share_action.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  group('ShareAction', () {
    final action = ShareAction();

    test('has correct id and label', () {
      expect(action.id, equals('share'));
      expect(action.label, isNotEmpty);
    });

    test('does not throw when url is null', () async {
      final item = WorkItem(
        id: 'test-item-1',
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        url: null,
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should not throw even though share may fail
      await action.execute(item, {});

      // If we get here, test passes (no exception thrown)
      expect(true, isTrue);
    });

    test('does not throw when title is present', () async {
      final item = WorkItem(
        id: 'test-item-1',
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article Title',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await action.execute(item, {});

      expect(true, isTrue);
    });
  });
}
