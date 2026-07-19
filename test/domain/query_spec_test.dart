import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/query_spec.dart';
import 'package:feedflow/domain/queue.dart';
import 'package:feedflow/domain/rule.dart';

void main() {
  group('QuerySpec', () {
    test('round-trip fromJson/toJson preserva filtro, sort e limit', () {
      const spec = QuerySpec(
        filter: Condition.compound(
          combinator: 'all',
          conditions: [
            Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
            Condition.simple(field: 'tags', operator: 'contains', value: 'urgente'),
          ],
        ),
        sort: [QuerySort(field: 'title'), QuerySort(field: 'priority', descending: true)],
        limit: 20,
      );

      final json = spec.toJson();
      final decoded = QuerySpec.fromJson(json);

      expect(decoded, spec);
    });

    test('sort e limit são opcionais', () {
      const spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
      );

      final decoded = QuerySpec.fromJson(spec.toJson());
      expect(decoded.sort, isEmpty);
      expect(decoded.limit, isNull);
    });
  });

  group('Queue', () {
    test('round-trip fromJson/toJson preserva todos os campos', () {
      const queue = Queue(
        id: 'q1',
        name: 'Não lidos urgentes',
        spec: QuerySpec(
          filter: Condition.simple(field: 'isRead', operator: 'equals', value: false),
          sort: [QuerySort(field: 'title')],
        ),
        order: 3,
        iconName: 'star',
      );

      final decoded = Queue.fromJson(queue.toJson());
      expect(decoded, queue);
    });

    test('iconName nulo é preservado no round-trip', () {
      const queue = Queue(
        id: 'q1',
        name: 'Fila',
        spec: QuerySpec(filter: Condition.simple(field: 'status', operator: 'equals', value: 'novo')),
        order: 1,
      );

      final decoded = Queue.fromJson(queue.toJson());
      expect(decoded.iconName, isNull);
    });
  });
}
