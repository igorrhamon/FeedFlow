import '../../domain/article_action.dart';
import '../../domain/work_item.dart';
import '../integrations/webhook_integration.dart';

/// Ação que envia um WorkItem para um webhook.
/// Requer que [params] contenha ['url'] com a URL do webhook.
class WebhookAction implements ArticleAction {
  final WebhookIntegration integration;

  WebhookAction({WebhookIntegration? integration})
      : integration = integration ?? WebhookIntegration();

  @override
  String get id => 'webhook';

  @override
  String get label => 'Send to Webhook';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await integration.send(item, params);
  }
}
