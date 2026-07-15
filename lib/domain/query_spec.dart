import 'package:freezed_annotation/freezed_annotation.dart';

import 'rule.dart';

part 'query_spec.freezed.dart';
part 'query_spec.g.dart';

/// Especificação de consulta sobre [WorkItem]s: filtro + ordenação.
/// Reaproveitando o mesmo vocabulário field/operator/value de [Condition].
@Freezed(fromJson: true, toJson: true)
class QuerySpec with _$QuerySpec {
  const factory QuerySpec({
    required Condition filter, // reusa Condition de lib/domain/rule.dart
    String? sortField, // ex: 'ingestedAt', 'updatedAt', 'title' — nullable = sem ordenação explícita
    @Default(false) bool sortDescending,
  }) = _QuerySpec;

  factory QuerySpec.fromJson(Map<String, dynamic> json) => _$QuerySpecFromJson(json);
}
