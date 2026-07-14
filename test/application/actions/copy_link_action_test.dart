import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/copy_link_action.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CopyLinkAction', () {
    final action = CopyLinkAction();

    test('has correct id and label', () {
      expect(action.id, equals('copyLink'));
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

      // Should not throw even though clipboard operation may fail
      await action.execute(item, {});

      expect(true, isTrue);
    });

    test('does not throw when url is present', () async {
      final item = WorkItem(
        id: 'test-item-1',
        providerId: 'test-provider',
        articleId: 'article-1',
        feedId: 'feed-1',
        title: 'Test Article',
        url: 'https://example.com/article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await action.execute(item, {});

      expect(true, isTrue);
    });
  });
}
