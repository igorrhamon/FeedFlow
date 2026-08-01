import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/article.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Conteúdo bruto ingerido de qualquer fonte, com proveniência explícita.
///
/// A Onda 7 introduz [Document] como a unidade genérica de conteúdo,
/// desacoplando [WorkItem] (triagem local) de [Article] (DTO de provider específico).
/// Qualquer SourceConnector (RSS, email, arquivos, Slack, etc.) produz [Document]s;
/// [WorkItem] passa a referenciar [documentId] opcional, permitindo múltiplas fontes
/// de origem para a mesma triagem local.
@freezed
class Document with _$Document {
  const Document._();

  const factory Document({
    required String id,

    /// Identificador do conector que originou este documento.
    /// Exemplos: 'rss:the-old-reader', 'email:gmail', 'local-note'.
    required String sourceConnectorId,

    /// ID do documento na origem (UID de email, URL de artigo, etc.).
    /// Único por conector, não globalmente.
    required String sourceId,

    /// Tipo MIME do conteúdo (ex.: 'text/markdown', 'text/html', 'application/pdf').
    required String contentType,

    /// Título/assunto do conteúdo.
    required String title,

    /// Autor, remetente ou criador do conteúdo (nullable — PDFs/emails podem não ter).
    String? author,

    /// Conteúdo bruto: HTML, Markdown, texto plano, ou serialização de estrutura
    /// (ex.: JSON extraído de um webhook). Pode ser nulo para anexos.
    String? rawContent,

    /// URL de origem (link do artigo, URL do email, etc.). Nullable.
    String? url,

    /// Quando o conteúdo foi publicado/criado na origem.
    required DateTime capturedAt,

    /// Metadados adicionais específicos do conector, serializados como JSON.
    /// Exemplos: `{ "workItemId": "...", "tags": [...], "attachmentCount": 2 }`.
    String? metadataJson,
  }) = _Document;

  /// Cria um [Document] a partir de um [Article] — adaptador que permite
  /// ao [SyncService] converter `Article → Document → WorkItem` sem
  /// mudança de contrato para chamadores existentes.
  factory Document.fromArticle(Article article, String providerId) {
    return Document(
      id: 'rss:$providerId:${article.id}',
      sourceConnectorId: 'rss:$providerId',
      sourceId: article.id,
      contentType: 'text/html',
      title: article.title,
      author: article.author,
      rawContent: article.content,
      url: article.url,
      capturedAt: article.published ?? DateTime.now(),
      metadataJson: null,
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
