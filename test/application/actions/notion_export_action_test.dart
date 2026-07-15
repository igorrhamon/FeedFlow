import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:feedflow/application/actions/notion_export_action.dart';
import 'package:feedflow/application/integrations/notion_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('NotionExportAction', () {
    test('has correct id and label', () {
      final action = NotionExportAction();
      expect(action.id, 'notionExport');
      expect(action.label, 'Export to Notion');
    });

    test('execute() delegates to NotionIntegration.send() with config from params', () async {
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
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response('{"id":"page-123"}', 200);
      });

      final integration = NotionIntegration(client: mockClient);
      final action = NotionExportAction(integration: integration);

      await action.execute(item, {
        'token': 'test-token',
        'databaseId': 'test-db-id',
      });
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

      final mockClient = MockClient((request) async {
        return http.Response('{"error":"Invalid token"}', 401);
      });

      final integration = NotionIntegration(client: mockClient);
      final action = NotionExportAction(integration: integration);

      expect(
        () => action.execute(item, {
          'token': 'invalid-token',
          'databaseId': 'test-db-id',
        }),
        throwsA(isA<Exception>()),
      );
    });
  });
}
