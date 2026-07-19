import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/integrations/obsidian_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  group('workItemToMarkdown', () {
    test('generates Markdown with title, author, and content', () {
      final now = DateTime.now();
      final published = DateTime(2024, 7, 14);
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article Title',
        author: 'John Doe',
        summary: 'This is a summary',
        content: 'This is the main content of the article',
        url: 'https://example.com/article',
        published: published,
        status: TriageStatus.novo,
        tags: ['tag1', 'tag2'],
        ingestedAt: now,
        updatedAt: now,
      );

      final markdown = workItemToMarkdown(item);

      expect(markdown, contains('# Test Article Title'));
      expect(markdown, contains('**Author:** John Doe'));
      expect(markdown, contains('**Published:**'));
      expect(markdown, contains('**Tags:** tag1, tag2'));
      expect(markdown, contains('**URL:**'));
      expect(markdown, contains('https://example.com/article'));
      expect(markdown, contains('## Content'));
      expect(markdown, contains('This is the main content of the article'));
      expect(markdown, contains('## Summary'));
      expect(markdown, contains('This is a summary'));
    });

    test('generates Markdown with minimal data (title only)', () {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Minimal Article',
        status: TriageStatus.novo,
        ingestedAt: now,
        updatedAt: now,
      );

      final markdown = workItemToMarkdown(item);

      expect(markdown, contains('# Minimal Article'));
      expect(markdown, isNotEmpty);
    });

    test('generates Markdown without empty optional fields', () {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Article without extras',
        author: '',
        url: '',
        status: TriageStatus.novo,
        tags: [],
        ingestedAt: now,
        updatedAt: now,
      );

      final markdown = workItemToMarkdown(item);

      expect(markdown, contains('# Article without extras'));
      expect(markdown, isNot(contains('**Author:**')));
      expect(markdown, isNot(contains('**URL:**')));
      expect(markdown, isNot(contains('**Tags:**')));
    });
  });

  group('ObsidianIntegration', () {
    test('send() throws ArgumentError if vault is missing', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        status: TriageStatus.novo,
        ingestedAt: now,
        updatedAt: now,
      );

      final integration = ObsidianIntegration();
      expect(
        () => integration.send(item, {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('send() throws ArgumentError if vault is empty', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        status: TriageStatus.novo,
        ingestedAt: now,
        updatedAt: now,
      );

      final integration = ObsidianIntegration();
      expect(
        () => integration.send(item, {'vault': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
