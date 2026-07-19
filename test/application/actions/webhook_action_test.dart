import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:feedflow/application/actions/webhook_action.dart';
import 'package:feedflow/application/integrations/webhook_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  group('WebhookAction', () {
    test('has correct id and label', () {
      final action = WebhookAction();
      expect(action.id, 'webhook');
      expect(action.label, 'Send to Webhook');
    });

    test('execute() delegates to WebhookIntegration.send()', () async {
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
        return http.Response('{"success":true}', 200);
      });

      final integration = WebhookIntegration(client: mockClient);
      final action = WebhookAction(integration: integration);

      await action.execute(item, {'url': 'https://webhook.example.com'});
    });

    test('execute() propagates exception from integration', () async {
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

      final integration = WebhookIntegration();
      final action = WebhookAction(integration: integration);

      expect(
        () => action.execute(item, {}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
