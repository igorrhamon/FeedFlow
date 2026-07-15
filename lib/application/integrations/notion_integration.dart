import 'package:http/http.dart' as http;
import '../../domain/work_item.dart';
import 'external_integration.dart';

/// Integração Notion: cria uma página no Notion via REST API.
/// Requer [token] (Bearer token) e [databaseId] no config.
class NotionIntegration implements ExternalIntegration {
  static const String _notionApiUrl = 'https://api.notion.com/v1/pages';
  static const String _notionVersion = '2022-06-28';

  final http.Client? _client;

  NotionIntegration({http.Client? client}) : _client = client;

  @override
  Future<void> send(WorkItem item, Map<String, dynamic> config) async {
    final token = config['token'] as String?;
    final databaseId = config['databaseId'] as String?;

    if (token == null || token.isEmpty) {
      throw ArgumentError('Notion token is required in config[\'token\']');
    }
    if (databaseId == null || databaseId.isEmpty) {
      throw ArgumentError('Notion database ID is required in config[\'databaseId\']');
    }

    final body = _buildNotionPageBody(item, databaseId);

    final client = _client ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse(_notionApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Notion-Version': _notionVersion,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Notion API failed with status code ${response.statusCode}: ${response.body}',
        );
      }
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  String _buildNotionPageBody(WorkItem item, String databaseId) {
    // Minimal Notion API page creation body with title property
    final title = item.title.replaceAll('"', '\\"');
    return '''{
  "parent": {
    "database_id": "$databaseId"
  },
  "properties": {
    "Name": {
      "title": [
        {
          "text": {
            "content": "$title"
          }
        }
      ]
    }
  }
}''';
  }
}
