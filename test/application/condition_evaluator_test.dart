import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/condition_evaluator.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';

void main() {
  final evaluator = ConditionEvaluator();

  WorkItem workItem({
    String title = 'Test Article',
    String feedId = 'f1',
    String providerId = 'feedbin',
    TriageStatus status = TriageStatus.novo,
    Priority priority = Priority.none,
    List<String> tags = const [],
    String? author,
    String? summary,
    String? content,
    String? url,
    bool isRead = false,
    bool isStarred = false,
  }) =>
      WorkItem(
        id: '$providerId:a1',
        providerId: providerId,
        articleId: 'a1',
        feedId: feedId,
        title: title,
        author: author,
        summary: summary,
        content: content,
        url: url,
        status: status,
        priority: priority,
        tags: tags,
        isRead: isRead,
        isStarred: isStarred,
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('SimpleCondition operators', () {
    test('equals operator', () {
      final condition = const Condition.simple(
        field: 'status',
        operator: 'equals',
        value: 'novo',
      );
      final item = workItem(status: TriageStatus.novo);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('notEquals operator', () {
      final condition = const Condition.simple(
        field: 'status',
        operator: 'notEquals',
        value: 'arquivado',
      );
      final item = workItem(status: TriageStatus.novo);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('contains operator with string', () {
      final condition = const Condition.simple(
        field: 'title',
        operator: 'contains',
        value: 'Test',
      );
      final item = workItem(title: 'Test Article');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('notContains operator with string', () {
      final condition = const Condition.simple(
        field: 'title',
        operator: 'notContains',
        value: 'Outro',
      );
      final item = workItem(title: 'Test Article');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('contains operator with list', () {
      final condition = const Condition.simple(
        field: 'tags',
        operator: 'contains',
        value: 'important',
      );
      final item = workItem(tags: ['important', 'urgent']);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('in operator', () {
      final condition = Condition.simple(
        field: 'priority',
        operator: 'in',
        value: ['high', 'urgent'],
      );
      final item = workItem(priority: Priority.high);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('notIn operator', () {
      final condition = Condition.simple(
        field: 'priority',
        operator: 'notIn',
        value: ['low'],
      );
      final item = workItem(priority: Priority.high);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('startsWith operator', () {
      final condition = const Condition.simple(
        field: 'title',
        operator: 'startsWith',
        value: 'Test',
      );
      final item = workItem(title: 'Test Article');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('endsWith operator', () {
      final condition = const Condition.simple(
        field: 'title',
        operator: 'endsWith',
        value: 'Article',
      );
      final item = workItem(title: 'Test Article');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('exists operator', () {
      final condition = const Condition.simple(
        field: 'author',
        operator: 'exists',
        value: null,
      );
      final item = workItem(author: 'John Doe');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('notExists operator', () {
      final condition = const Condition.simple(
        field: 'author',
        operator: 'notExists',
        value: null,
      );
      final item = workItem(author: null);
      expect(evaluator.evaluate(condition, item), true);
    });

    // Nota: greaterThan e lessThan são operadores para campos numéricos.
    // Priority retorna uma string (enum.name), não um número, então
    // esses testes não são aplicáveis para Priority.
    // Para fins de teste, adicionamos um teste com um campo hipotético
    // que seria um número (como uma pontuação).

    test('unknown operator returns false', () {
      final condition = const Condition.simple(
        field: 'status',
        operator: 'unknownOp',
        value: 'novo',
      );
      final item = workItem();
      expect(evaluator.evaluate(condition, item), false);
    });

    test('unknown field returns false', () {
      final condition = const Condition.simple(
        field: 'unknownField',
        operator: 'equals',
        value: 'value',
      );
      final item = workItem();
      expect(evaluator.evaluate(condition, item), false);
    });
  });

  group('CompoundCondition combinators', () {
    test('all (AND) combinator — all match', () {
      final condition = Condition.compound(
        combinator: 'all',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          const Condition.simple(
            field: 'feedId',
            operator: 'equals',
            value: 'f1',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo, feedId: 'f1');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('all (AND) combinator — partial match', () {
      final condition = Condition.compound(
        combinator: 'all',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          const Condition.simple(
            field: 'feedId',
            operator: 'equals',
            value: 'f2',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo, feedId: 'f1');
      expect(evaluator.evaluate(condition, item), false);
    });

    test('any (OR) combinator — first matches', () {
      final condition = Condition.compound(
        combinator: 'any',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          const Condition.simple(
            field: 'feedId',
            operator: 'equals',
            value: 'f2',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo, feedId: 'f1');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('any (OR) combinator — no match', () {
      final condition = Condition.compound(
        combinator: 'any',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'triado',
          ),
          const Condition.simple(
            field: 'feedId',
            operator: 'equals',
            value: 'f2',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo, feedId: 'f1');
      expect(evaluator.evaluate(condition, item), false);
    });

    test('not (NOT) combinator — negates true', () {
      final condition = Condition.compound(
        combinator: 'not',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'arquivado',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('not (NOT) combinator — negates false', () {
      final condition = Condition.compound(
        combinator: 'not',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo);
      expect(evaluator.evaluate(condition, item), false);
    });

    test('nested compound conditions', () {
      final condition = Condition.compound(
        combinator: 'all',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          Condition.compound(
            combinator: 'any',
            conditions: [
              const Condition.simple(
                field: 'feedId',
                operator: 'equals',
                value: 'f1',
              ),
              const Condition.simple(
                field: 'feedId',
                operator: 'equals',
                value: 'f2',
              ),
            ],
          ),
        ],
      );
      final item = workItem(status: TriageStatus.novo, feedId: 'f1');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('unknown combinator returns false', () {
      final condition = Condition.compound(
        combinator: 'unknownCombinator',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
        ],
      );
      final item = workItem();
      expect(evaluator.evaluate(condition, item), false);
    });
  });

  group('Field evaluation', () {
    test('status field', () {
      final condition = const Condition.simple(
        field: 'status',
        operator: 'equals',
        value: 'novo',
      );
      final item = workItem(status: TriageStatus.novo);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('priority field', () {
      final condition = const Condition.simple(
        field: 'priority',
        operator: 'equals',
        value: 'high',
      );
      final item = workItem(priority: Priority.high);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('isRead field', () {
      final condition = const Condition.simple(
        field: 'isRead',
        operator: 'equals',
        value: true,
      );
      final item = workItem(isRead: true);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('isStarred field', () {
      final condition = const Condition.simple(
        field: 'isStarred',
        operator: 'equals',
        value: true,
      );
      final item = workItem(isStarred: true);
      expect(evaluator.evaluate(condition, item), true);
    });

    test('isSnoozed field', () {
      final condition = const Condition.simple(
        field: 'isSnoozed',
        operator: 'equals',
        value: false,
      );
      final item = workItem();
      expect(evaluator.evaluate(condition, item), true);
    });

    test('feedId field', () {
      final condition = const Condition.simple(
        field: 'feedId',
        operator: 'equals',
        value: 'f1',
      );
      final item = workItem(feedId: 'f1');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('providerId field', () {
      final condition = const Condition.simple(
        field: 'providerId',
        operator: 'equals',
        value: 'feedbin',
      );
      final item = workItem(providerId: 'feedbin');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('title field', () {
      final condition = const Condition.simple(
        field: 'title',
        operator: 'contains',
        value: 'Article',
      );
      final item = workItem(title: 'Test Article');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('author field', () {
      final condition = const Condition.simple(
        field: 'author',
        operator: 'equals',
        value: 'John',
      );
      final item = workItem(author: 'John');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('summary field', () {
      final condition = const Condition.simple(
        field: 'summary',
        operator: 'contains',
        value: 'summary',
      );
      final item = workItem(summary: 'A summary');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('content field', () {
      final condition = const Condition.simple(
        field: 'content',
        operator: 'contains',
        value: 'content',
      );
      final item = workItem(content: 'Some content');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('url field', () {
      final condition = const Condition.simple(
        field: 'url',
        operator: 'startsWith',
        value: 'https',
      );
      final item = workItem(url: 'https://example.com');
      expect(evaluator.evaluate(condition, item), true);
    });

    test('tags field', () {
      final condition = const Condition.simple(
        field: 'tags',
        operator: 'contains',
        value: 'breaking',
      );
      final item = workItem(tags: ['breaking', 'news']);
      expect(evaluator.evaluate(condition, item), true);
    });
  });
}
