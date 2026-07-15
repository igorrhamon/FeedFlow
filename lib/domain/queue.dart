import 'package:freezed_annotation/freezed_annotation.dart';

import 'query_spec.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// Fila de trabalho: um conjunto persistente de [WorkItem]s definido por um
/// [QuerySpec], exibido via ícone e nome.
@freezed
class Queue with _$Queue {
  const factory Queue({
    required String id,
    required String name,
    required String icon, // nome do ícone Material (ex: 'inbox', 'star') — string simples
    required int order,
    required QuerySpec querySpec,
  }) = _Queue;

  factory Queue.fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
}
