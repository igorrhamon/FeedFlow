import 'local_source_config.dart';

/// Conversão de [LocalSourceType] para o id de registro usado pelo
/// `SourceConnectorRegistry` (Onda 9). Ex.: `LocalSourceType.markdownVault`
/// → `'markdown-vault'`.
extension LocalSourceTypeToShortString on LocalSourceType {
  String toShortString() {
    switch (this) {
      case LocalSourceType.folder:
        return 'folder';
      case LocalSourceType.markdownVault:
        return 'markdown-vault';
      case LocalSourceType.pdf:
        return 'pdf';
      case LocalSourceType.office:
        return 'office';
    }
  }
}
