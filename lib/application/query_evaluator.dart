import '../domain/query_spec.dart';
import '../domain/work_item.dart';
import 'condition_evaluator.dart';

/// Avaliador de especificações de consulta ([QuerySpec]) contra listas
/// de [WorkItem]s em memória. Reusa [ConditionEvaluator] para o filtro
/// e aplica ordenação conforme o [QuerySpec].
class QueryEvaluator {
  QueryEvaluator({ConditionEvaluator? conditionEvaluator})
      : _conditionEvaluator = conditionEvaluator ?? ConditionEvaluator();

  final ConditionEvaluator _conditionEvaluator;

  /// Aplica o [QuerySpec] a uma lista de [WorkItem]s: filtra via condição
  /// e ordena conforme [sortField]/[sortDescending]. Retorna uma nova lista
  /// sem modificar a original.
  List<WorkItem> apply(QuerySpec spec, List<WorkItem> items) {
    // Filtra usando a condição
    var result = items
        .where((item) => _conditionEvaluator.evaluate(spec.filter, item))
        .toList();

    // Ordena se sortField for especificado
    if (spec.sortField != null) {
      _applySorting(result, spec.sortField!, spec.sortDescending);
    }

    return result;
  }

  void _applySorting(List<WorkItem> items, String sortField, bool descending) {
    final comparator = _getComparator(sortField);
    if (comparator == null) {
      // Campo não reconhecido — não ordena
      return;
    }

    items.sort(comparator);
    if (descending) {
      items.sort((a, b) => comparator(b, a));
    }
  }

  int Function(WorkItem, WorkItem)? _getComparator(String sortField) {
    switch (sortField) {
      case 'ingestedAt':
        return (a, b) => a.ingestedAt.compareTo(b.ingestedAt);
      case 'updatedAt':
        return (a, b) => a.updatedAt.compareTo(b.updatedAt);
      case 'title':
        return (a, b) => a.title.compareTo(b.title);
      case 'published':
        return (a, b) {
          if (a.published == null && b.published == null) return 0;
          if (a.published == null) return 1;
          if (b.published == null) return -1;
          return a.published!.compareTo(b.published!);
        };
      case 'updated':
        return (a, b) {
          if (a.updated == null && b.updated == null) return 0;
          if (a.updated == null) return 1;
          if (b.updated == null) return -1;
          return a.updated!.compareTo(b.updated!);
        };
      default:
        return null;
    }
  }
}
