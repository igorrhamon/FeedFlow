import 'package:freezed_annotation/freezed_annotation.dart';

import 'rule.dart';

part 'query_spec.freezed.dart';
part 'query_spec.g.dart';

/// Um critério de ordenação para os resultados de uma [QuerySpec].
@freezed
class QuerySort with _$QuerySort {
  const factory QuerySort({
    required String field, // mesmos nomes de campo aceitos por Condition (ver rule.dart)
    @Default(false) bool descending,
  }) = _QuerySort;

  factory QuerySort.fromJson(Map<String, dynamic> json) => _$QuerySortFromJson(json);
}

/// Especificação declarativa de uma consulta sobre [WorkItem]s: filtro
/// (reaproveitando a mesma árvore de [Condition] usada pelo motor de regras),
/// ordenação e limite opcional de resultados. Compilada em tempo de execução
/// por `QuerySpecCompiler` — não é persistida como query SQL, filtra em
/// memória sobre o stream de itens ativos.
@freezed
class QuerySpec with _$QuerySpec {
  const factory QuerySpec({
    required Condition filter,
    @Default(<QuerySort>[]) List<QuerySort> sort,
    int? limit,
  }) = _QuerySpec;

  factory QuerySpec.fromJson(Map<String, dynamic> json) => _$QuerySpecFromJson(json);
}
