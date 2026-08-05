import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_source_config.freezed.dart';
part 'local_source_config.g.dart';

/// Tipo de fonte local: pasta, Obsidian vault, PDF isolado, ou arquivo Office.
enum LocalSourceType { folder, markdownVault, pdf, office }

/// Configuração de uma fonte local de documentos (Onda 9).
/// Representa a seleção do usuário de um caminho a ser ingerido e seus metadados.
@freezed
class LocalSourceConfig with _$LocalSourceConfig {
  const factory LocalSourceConfig({
    /// ID único da configuração de fonte.
    required String id,

    /// Tipo da fonte: pasta, Obsidian vault, PDF, ou Office.
    required LocalSourceType type,

    /// Caminho absoluto no disco da pasta/arquivo raiz.
    required String path,

    /// Rótulo humanizado para exibição na UI (ex.: "Minhas notas", "PDFs de pesquisa").
    required String label,

    /// Se esta fonte está habilitada para sincronização.
    @Default(true) bool enabled,

    /// Última vez que esta fonte foi sincronizada com sucesso.
    DateTime? lastSyncAt,

    /// Quando a configuração foi criada.
    required DateTime createdAt,
  }) = _LocalSourceConfig;

  factory LocalSourceConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalSourceConfigFromJson(json);
}
