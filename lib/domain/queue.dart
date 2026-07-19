import 'package:freezed_annotation/freezed_annotation.dart';

import 'query_spec.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// Uma fila customizada de itens: nome + [QuerySpec] que a define.
///
/// [iconName] é um `String?` (nome lógico de ícone, ex. `'label'`,
/// `'star'`), não um `IconData` — `IconData` não serializa de forma estável
/// via Freezed/json_serializable, e a resolução para um ícone real do
/// Material fica a cargo da camada de UI (`lib/pages/queue_editor_page.dart`).
@freezed
class Queue with _$Queue {
  const factory Queue({
    required String id,
    required String name,
    required QuerySpec spec,
    required int order,
    String? iconName,
  }) = _Queue;

  factory Queue.fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
}
