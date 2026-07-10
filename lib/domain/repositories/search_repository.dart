import '../work_item.dart';

/// Repositório para busca local full-text nos WorkItems já sincronizados.
abstract interface class SearchRepository {
  /// Busca por uma query de texto livre nos campos title, content, author e tags
  /// dos WorkItems locais, usando FTS5 (SQLite).
  ///
  /// Retorna uma lista ordenada por relevância (BM25).
  /// Em plataformas que não suportam banco local (web/WASM), retorna lista vazia.
  Future<List<WorkItem>> search(String query);
}
