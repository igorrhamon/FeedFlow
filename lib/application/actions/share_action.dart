import 'package:share_plus/share_plus.dart';

import '../../domain/article_action.dart';
import '../../domain/work_item.dart';

/// Ação que compartilha um item usando o sistema nativo de compartilhamento
/// (Share.share). A URL do item é compartilhada; se não houver URL,
/// o título é usado como fallback.
class ShareAction implements ArticleAction {
  @override
  String get id => 'share';

  @override
  String get label => 'Compartilhar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final text = item.url ?? item.title;
    try {
      await Share.share(text);
    } catch (e) {
      // Compartilhamento é um side-effect de UI. Se falhar (ex: sem app de
      // compartilhamento disponível), não deve quebrar a execução da ação.
      // Logs são deixados para debug.
    }
  }
}
