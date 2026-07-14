import '../work_item.dart';

/// Interface para busca full-text local de [WorkItem]s.
/// Complementa a busca remota via [FeedProvider.search()].
abstract class SearchRepository {
  /// Busca itens por query full-text (título, conteúdo, autor, tags).
  /// Retorna resultados ordenados por relevância BM25.
  Future<List<WorkItem>> search(
    String query, {
    int limit = 50,
  });
}
