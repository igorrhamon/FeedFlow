import '../domain/query_spec.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import 'condition_evaluator.dart';

/// Compila uma [QuerySpec] declarativa em um stream reativo de [WorkItem]s.
///
/// Não é uma query SQL: parte do stream de todos os itens ativos
/// (`watchByStatus(TriageStatus.values)`, o mesmo ponto de entrada usado por
/// `RuleDryRunner` e `InboxPage`) e filtra em memória via [ConditionEvaluator]
/// — mesma decisão de design usada no restante da Onda 2 para evitar duas
/// implementações paralelas de avaliação de condição.
class QuerySpecCompiler {
  QuerySpecCompiler({ConditionEvaluator? evaluator}) : _evaluator = evaluator ?? ConditionEvaluator();

  final ConditionEvaluator _evaluator;

  Stream<List<WorkItem>> compile(QuerySpec spec, WorkItemRepository repository) {
    return repository.watchByStatus(TriageStatus.values).map((items) {
      var result = items.where((item) => _evaluator.evaluate(spec.filter, item)).toList();

      if (spec.sort.isNotEmpty) {
        result.sort((a, b) {
          for (final sort in spec.sort) {
            final aValue = _evaluator.getFieldValue(sort.field, a);
            final bValue = _evaluator.getFieldValue(sort.field, b);
            final comparison = _compare(aValue, bValue);
            if (comparison != 0) {
              return sort.descending ? -comparison : comparison;
            }
          }
          return 0;
        });
      }

      if (spec.limit != null && result.length > spec.limit!) {
        result = result.sublist(0, spec.limit!);
      }

      return result;
    });
  }

  int _compare(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is Comparable && b is Comparable) {
      return Comparable.compare(a, b);
    }
    return a.toString().compareTo(b.toString());
  }
}
