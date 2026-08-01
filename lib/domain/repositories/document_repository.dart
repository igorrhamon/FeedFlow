import '../document.dart';

/// Porta para persistência de [Document]s — usada tanto pelo [SyncService]
/// (ingestão de qualquer conector) quanto pelo [KnowledgeBaseRepository]
/// (Onda 8, para criar notas locais).
abstract class DocumentRepository {
  /// Cria ou atualiza documentos em lote (upsert). Substitui por `sourceId`
  /// + `sourceConnectorId` (chave lógica), não por `id` — permite reingestão
  /// idempotente de um conector sem criar duplicatas.
  Future<void> upsertAll(List<Document> documents);

  /// Retorna um documento pelo seu [id].
  Future<Document?> byId(String id);

  /// Stream contínuo de todos os documentos (ou de um conector específico,
  /// se [sourceConnectorId] for fornecido).
  Stream<List<Document>> watchAll({String? sourceConnectorId});

  /// Remove um documento pelo [id].
  Future<void> delete(String id);

  /// Fecha recursos do repositório.
  Future<void> close();
}
