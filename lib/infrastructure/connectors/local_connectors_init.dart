import '../../application/source_connector_registry.dart';
import 'folder_source_connector.dart';
import 'markdown_vault_connector.dart';
import 'office_source_connector.dart';
import 'pdf_source_connector.dart';

/// Registra os conectores de fontes locais (Onda 9) no [SourceConnectorRegistry],
/// um por [LocalSourceType] suportado. Deve ser chamada exatamente uma vez
/// durante o boot da aplicação (em `main()`), junto de `initializeActions()`
/// e `initializeProviders()`.
///
/// Registrado por tipo (`'folder'`, `'markdown-vault'`, `'pdf'`, `'office'`),
/// não por instância — cada factory recebe o `LocalSourceConfig` escolhido
/// pelo usuário (caminho, label, etc.) e constrói o conector correspondente.
void initializeLocalConnectors() {
  SourceConnectorRegistry.register('folder', (config) => FolderSourceConnector(config));
  SourceConnectorRegistry.register('markdown-vault', (config) => MarkdownVaultConnector(config));
  SourceConnectorRegistry.register('pdf', (config) => PdfSourceConnector(config));
  SourceConnectorRegistry.register('office', (config) => OfficeSourceConnector(config));
}
