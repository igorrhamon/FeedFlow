import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../domain/work_item.dart';
import 'external_integration.dart';

/// Integração Webhook: envia um POST com dados do WorkItem para uma URL configurada.
class WebhookIntegration implements ExternalIntegration {
  final http.Client? _client;

  static const _requestTimeout = Duration(seconds: 30);

  WebhookIntegration({http.Client? client}) : _client = client;

  @override
  Future<void> send(WorkItem item, Map<String, dynamic> config) async {
    final url = config['url'] as String?;
    if (url == null || url.isEmpty) {
      throw ArgumentError('Webhook URL is required in config[\'url\']');
    }

    final body = {
      'id': item.id,
      'title': item.title,
      'url': item.url,
      'summary': item.summary,
      'feedId': item.feedId,
      'providerId': item.providerId,
      'status': item.status.toString(),
      'isRead': item.isRead,
      'isStarred': item.isStarred,
    };

    final client = _client ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Webhook failed with status code ${response.statusCode}');
      }
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

}
