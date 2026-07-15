import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:feedflow/application/integrations/webhook_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  group('WebhookIntegration', () {
    test('send() successfully posts to webhook URL with 200 response', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        author: 'Test Author',
        summary: 'Test Summary',
        content: 'Test Content',
        url: 'https://example.com/article',
        status: TriageStatus.novo,
        ingestedAt: now,
        updatedAt: now,
      );

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://webhook.example.com/notify');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.body, contains('Test Article'));
        return http.Response('{"success":true}', 200);
      });

      final integration = WebhookIntegration(client: mockClient);
      await integration.send(item, {'url': 'https://webhook.example.com/notify'});
    });

    test('send() throws exception on non-2xx response', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        ingestedAt: now,
        updatedAt: now,
      );

      final mockClient = MockClient((request) async {
        return http.Response('{"error":"Webhook failed"}', 500);
      });

      final integration = WebhookIntegration(client: mockClient);
      expect(
        () => integration.send(item, {'url': 'https://webhook.example.com/notify'}),
        throwsA(isA<Exception>()),
      );
    });

    test('send() throws ArgumentError if URL is missing', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        ingestedAt: now,
        updatedAt: now,
      );

      final integration = WebhookIntegration();
      expect(
        () => integration.send(item, {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('send() throws ArgumentError if URL is empty', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'test:123',
        providerId: 'test',
        articleId: '123',
        feedId: 'feed/456',
        title: 'Test Article',
        ingestedAt: now,
        updatedAt: now,
      );

      final integration = WebhookIntegration();
      expect(
        () => integration.send(item, {'url': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
