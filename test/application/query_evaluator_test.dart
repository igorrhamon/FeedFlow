import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/query_evaluator.dart';
import 'package:feedflow/domain/query_spec.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  group('QueryEvaluator', () {
    late QueryEvaluator evaluator;

    setUp(() {
      evaluator = QueryEvaluator();
    });

    // Ajudante: cria um WorkItem de teste
    WorkItem _createItem({
      String title = 'Test Item',
      String feedId = 'feed/123',
      TriageStatus status = TriageStatus.novo,
      bool isRead = false,
      bool isStarred = false,
    }) {
      final now = DateTime.now();
      return WorkItem(
        id: '${feedId}:123',
        providerId: 'theoldreader',
        articleId: '123',
        feedId: feedId,
        title: title,
        ingestedAt: now,
        updatedAt: now,
        status: status,
        isRead: isRead,
        isStarred: isStarred,
      );
    }

    test('aplica filtro equals e retorna itens que casam', () {
      final items = [
        _createItem(title: 'Breaking News', status: TriageStatus.novo),
        _createItem(title: 'Old News', status: TriageStatus.novo),
        _createItem(title: 'Breaking Again', status: TriageStatus.arquivado),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );

      final result = evaluator.apply(spec, items);
      expect(result.length, 2);
      expect(result.every((i) => i.status == TriageStatus.novo), true);
    });

    test('aplica filtro contains em título', () {
      final items = [
        _createItem(title: 'Breaking News'),
        _createItem(title: 'Old News'),
        _createItem(title: 'Breaking Again'),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(
          field: 'title',
          operator: 'contains',
          value: 'Breaking',
        ),
      );

      final result = evaluator.apply(spec, items);
      expect(result.length, 2);
      expect(result.every((i) => i.title.contains('Breaking')), true);
    });

    test('aplica filtro in para valores em lista', () {
      final items = [
        _createItem(status: TriageStatus.novo),
        _createItem(status: TriageStatus.arquivado),
        _createItem(status: TriageStatus.concluido),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(
          field: 'status',
          operator: 'in',
          value: ['novo', 'concluido'],
        ),
      );

      final result = evaluator.apply(spec, items);
      expect(result.length, 2);
      expect(
        result.every((i) => i.status == TriageStatus.novo || i.status == TriageStatus.concluido),
        true,
      );
    });

    test('ordena por ingestedAt ascendente', () {
      final now = DateTime.now();
      final items = [
        WorkItem(
          id: 'a',
          providerId: 'p',
          articleId: 'art1',
          feedId: 'f1',
          title: 'Item A',
          ingestedAt: now.add(const Duration(hours: 2)),
          updatedAt: now,
        ),
        WorkItem(
          id: 'b',
          providerId: 'p',
          articleId: 'art2',
          feedId: 'f1',
          title: 'Item B',
          ingestedAt: now,
          updatedAt: now,
        ),
        WorkItem(
          id: 'c',
          providerId: 'p',
          articleId: 'art3',
          feedId: 'f1',
          title: 'Item C',
          ingestedAt: now.add(const Duration(hours: 1)),
          updatedAt: now,
        ),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'ingestedAt',
        sortDescending: false,
      );

      final result = evaluator.apply(spec, items);
      expect(result[0].id, 'b'); // mais cedo
      expect(result[1].id, 'c');
      expect(result[2].id, 'a'); // mais tarde
    });

    test('ordena por ingestedAt descendente', () {
      final now = DateTime.now();
      final items = [
        WorkItem(
          id: 'a',
          providerId: 'p',
          articleId: 'art1',
          feedId: 'f1',
          title: 'Item A',
          ingestedAt: now.add(const Duration(hours: 2)),
          updatedAt: now,
        ),
        WorkItem(
          id: 'b',
          providerId: 'p',
          articleId: 'art2',
          feedId: 'f1',
          title: 'Item B',
          ingestedAt: now,
          updatedAt: now,
        ),
        WorkItem(
          id: 'c',
          providerId: 'p',
          articleId: 'art3',
          feedId: 'f1',
          title: 'Item C',
          ingestedAt: now.add(const Duration(hours: 1)),
          updatedAt: now,
        ),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'ingestedAt',
        sortDescending: true,
      );

      final result = evaluator.apply(spec, items);
      expect(result[0].id, 'a'); // mais tarde
      expect(result[1].id, 'c');
      expect(result[2].id, 'b'); // mais cedo
    });

    test('ordena por título ascendente', () {
      final items = [
        _createItem(title: 'Zebra'),
        _createItem(title: 'Apple'),
        _createItem(title: 'Mango'),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'title',
        sortDescending: false,
      );

      final result = evaluator.apply(spec, items);
      expect(result[0].title, 'Apple');
      expect(result[1].title, 'Mango');
      expect(result[2].title, 'Zebra');
    });

    test('ordena por título descendente', () {
      final items = [
        _createItem(title: 'Zebra'),
        _createItem(title: 'Apple'),
        _createItem(title: 'Mango'),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'title',
        sortDescending: true,
      );

      final result = evaluator.apply(spec, items);
      expect(result[0].title, 'Zebra');
      expect(result[1].title, 'Mango');
      expect(result[2].title, 'Apple');
    });

    test('ordena por updatedAt ascendente', () {
      final now = DateTime.now();
      final items = [
        WorkItem(
          id: 'a',
          providerId: 'p',
          articleId: 'art1',
          feedId: 'f1',
          title: 'Item A',
          ingestedAt: now,
          updatedAt: now.add(const Duration(hours: 2)),
        ),
        WorkItem(
          id: 'b',
          providerId: 'p',
          articleId: 'art2',
          feedId: 'f1',
          title: 'Item B',
          ingestedAt: now,
          updatedAt: now,
        ),
        WorkItem(
          id: 'c',
          providerId: 'p',
          articleId: 'art3',
          feedId: 'f1',
          title: 'Item C',
          ingestedAt: now,
          updatedAt: now.add(const Duration(hours: 1)),
        ),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'updatedAt',
        sortDescending: false,
      );

      final result = evaluator.apply(spec, items);
      expect(result[0].id, 'b');
      expect(result[1].id, 'c');
      expect(result[2].id, 'a');
    });

    test('combina filtro e ordenação', () {
      final now = DateTime.now();
      final items = [
        WorkItem(
          id: 'a',
          providerId: 'p',
          articleId: 'art1',
          feedId: 'f1',
          title: 'Breaking News',
          ingestedAt: now.add(const Duration(hours: 2)),
          updatedAt: now,
          status: TriageStatus.novo,
        ),
        WorkItem(
          id: 'b',
          providerId: 'p',
          articleId: 'art2',
          feedId: 'f1',
          title: 'Old News',
          ingestedAt: now,
          updatedAt: now,
          status: TriageStatus.arquivado,
        ),
        WorkItem(
          id: 'c',
          providerId: 'p',
          articleId: 'art3',
          feedId: 'f1',
          title: 'Breaking Again',
          ingestedAt: now.add(const Duration(hours: 1)),
          updatedAt: now,
          status: TriageStatus.novo,
        ),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
        sortField: 'ingestedAt',
        sortDescending: true,
      );

      final result = evaluator.apply(spec, items);
      expect(result.length, 2); // apenas status == novo
      expect(result[0].id, 'a'); // mais recente primeiro (descending)
      expect(result[1].id, 'c');
    });

    test('retorna lista vazia se nenhum item casar', () {
      final items = [
        _createItem(status: TriageStatus.novo),
        _createItem(status: TriageStatus.novo),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'arquivado',
        ),
      );

      final result = evaluator.apply(spec, items);
      expect(result.isEmpty, true);
    });

    test('ignora campo de ordenação desconhecido', () {
      final items = [
        _createItem(title: 'B'),
        _createItem(title: 'A'),
      ];

      final spec = QuerySpec(
        filter: Condition.simple(field: 'status', operator: 'exists', value: null),
        sortField: 'unknownField',
      );

      final result = evaluator.apply(spec, items);
      // Deve filtrar sem erro, mas sem ordenação
      expect(result.length, 2);
    });
  });
}
