import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/article_action.dart';
import '../../domain/work_item.dart';
import '../integrations/obsidian_integration.dart';

/// Ação que exporta um WorkItem para Obsidian.
/// Lê o vault name do flutter_secure_storage se não estiver em [params].
class ObsidianExportAction implements ArticleAction {
  static const String _vaultKey = 'obsidian_vault';
  static const _storage = FlutterSecureStorage();

  final ObsidianIntegration integration;

  ObsidianExportAction({ObsidianIntegration? integration})
      : integration = integration ?? ObsidianIntegration();

  @override
  String get id => 'obsidianExport';

  @override
  String get label => 'Export to Obsidian';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    var vault = params['vault'] as String?;

    // Se não vier nos params, tenta ler do secure storage
    if (vault == null || vault.isEmpty) {
      vault = await _storage.read(key: _vaultKey);
    }

    await integration.send(item, {
      'vault': vault,
    });
  }
}
