import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/article_action.dart';
import '../../domain/work_item.dart';
import '../integrations/notion_integration.dart';

/// Ação que exporta um WorkItem para Notion.
/// Lê o token e database ID do flutter_secure_storage se não estiverem em [params].
class NotionExportAction implements ArticleAction {
  static const String _tokenKey = 'notion_token';
  static const String _databaseIdKey = 'notion_database_id';
  static const _storage = FlutterSecureStorage();

  final NotionIntegration integration;

  NotionExportAction({NotionIntegration? integration})
      : integration = integration ?? NotionIntegration();

  @override
  String get id => 'notionExport';

  @override
  String get label => 'Export to Notion';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    var token = params['token'] as String?;
    var databaseId = params['databaseId'] as String?;

    // Se não vierem nos params, tenta ler do secure storage
    if (token == null || token.isEmpty) {
      token = await _storage.read(key: _tokenKey);
    }
    if (databaseId == null || databaseId.isEmpty) {
      databaseId = await _storage.read(key: _databaseIdKey);
    }

    await integration.send(item, {
      'token': token,
      'databaseId': databaseId,
    });
  }
}
