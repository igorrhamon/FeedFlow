import 'document.dart';

/// Interface abstrata para qualquer fonte de conteúdo que produz [Document]s.
///
/// Espelha [FeedProvider] mas genérica — permite que RSS, email, arquivos,
/// webhooks, etc. sejam tratados uniformemente pela camada de aplicação.
/// Cada implementação (RssSourceConnector, ImapSourceConnector, etc.)
/// fica em `lib/infrastructure/connectors/`.
abstract class SourceConnector {
  /// Identificador único do conector (ex.: 'rss:the-old-reader', 'email:gmail').
  String get id;

  /// Puxa conteúdo novo da origem e retorna como [Document]s.
  ///
  /// [since]: opcional, implementações podem usar para paginação/incremental
  /// (ex.: IMAP UID, data de sincronização anterior). Se nulo, implementação
  /// retorna conteúdo recente por padrão (últimas N horas/itens).
  Future<List<Document>> pull({DateTime? since});

  /// Fecha recursos do conector (conexão HTTP, arquivo aberto, etc.).
  /// Chamada antes de descartar a instância.
  Future<void> close();
}
