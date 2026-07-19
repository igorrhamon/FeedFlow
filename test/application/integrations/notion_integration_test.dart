import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:feedflow/application/integrations/notion_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  group('NotionIntegration', () {
    test('send() successfully creates page in Notion with valid config', () async {
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

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://api.notion.com/v1/pages',
        );
        expect(request.headers['Authorization'], 'Bearer test-token-123');
        expect(request.headers['Notion-Version'], '2022-06-28');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.body, contains('Test Article'));
        expect(request.body, contains('test-database-id-456'));
        return http.Response('{"id":"page-123"}', 200);
      });

      final integration = NotionIntegration(client: mockClient);
      await integration.send(
        item,
        {
          'token': 'test-token-123',
          'databaseId': 'test-database-id-456',
        },
      );
    });

    test('send() throws exception on API error', () async {
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

      final mockClient = MockClient((request) async {
        return http.Response('{"error":"Invalid token"}', 401);
      });

      final integration = NotionIntegration(client: mockClient);
      expect(
        () => integration.send(
          item,
          {
            'token': 'invalid-token',
            'databaseId': 'test-database-id',
          },
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('send() throws ArgumentError if token is missing', () async {
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

      final integration = NotionIntegration();
      expect(
        () => integration.send(item, {'databaseId': 'test-db'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('send() throws ArgumentError if databaseId is missing', () async {
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

      final integration = NotionIntegration();
      expect(
        () => integration.send(item, {'token': 'test-token'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('send() throws ArgumentError if token is empty', () async {
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

      final integration = NotionIntegration();
      expect(
        () => integration.send(item, {'token': '', 'databaseId': 'test-db'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('send() throws ArgumentError if databaseId is empty', () async {
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

      final integration = NotionIntegration();
      expect(
        () => integration.send(item, {'token': 'test-token', 'databaseId': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
