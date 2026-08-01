import '../document.dart';
import '../work_item.dart';

/// Interface para busca full-text local de [WorkItem]s e [Document]s.
/// Complementa a busca remota via [FeedProvider.search()].
abstract class SearchRepository {
  /// Busca itens por query full-text (título, conteúdo, autor, tags).
  /// Retorna resultados ordenados por relevância BM25.
  Future<List<WorkItem>> search(
    String query, {
    int limit = 50,
  });

  /// Busca documentos (notas, etc.) por query full-text (título, conteúdo, autor).
  /// Retorna resultados ordenados por relevância BM25. (Onda 8+)
  Future<List<Document>> searchDocuments(
    String query, {
    int limit = 50,
  });
}
