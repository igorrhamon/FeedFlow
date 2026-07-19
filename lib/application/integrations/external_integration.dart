import '../../domain/work_item.dart';

/// Interface abstrata para integrações externas.
/// Define o contrato para enviar/exportar um [WorkItem] para sistemas externos
/// (webhook, Notion, Obsidian, etc).
abstract class ExternalIntegration {
  /// Envia/exporta o item conforme a configuração fornecida.
  /// Lança exceção em falha — a ação que chama esta integração decide
  /// como tratar/reportar o erro.
  ///
  /// Parâmetros:
  /// - [item]: o [WorkItem] a ser exportado.
  /// - [config]: mapa de configuração específico da integração
  ///   (ex: {'url': 'https://...'} para webhook, {'token': '...', 'databaseId': '...'}
  ///   para Notion). Pode estar vazio dependendo da integração.
  Future<void> send(WorkItem item, Map<String, dynamic> config);
}
