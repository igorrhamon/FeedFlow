import 'package:flutter/services.dart';

import '../../domain/article_action.dart';
import '../../domain/work_item.dart';

/// Ação que copia a URL de um item para a área de transferência.
/// Se o item não tiver URL, copia uma string vazia (não falha).
class CopyLinkAction implements ArticleAction {
  @override
  String get id => 'copyLink';

  @override
  String get label => 'Copiar link';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final text = item.url ?? '';
    await Clipboard.setData(ClipboardData(text: text));
  }
}
