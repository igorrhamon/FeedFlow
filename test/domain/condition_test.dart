import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/models/article.dart';

void main() {
  group('Condition serialization', () {
    test('SimpleCondition serializa e desserializa', () {
      final cond = const Condition.simple(
        field: 'status',
        operator: 'equals',
        value: 'novo',
      );

      final json = cond.toJson();
      final restored = Condition.fromJson(json);

      expect(restored, cond);
    });

    test('CompoundCondition serializa e desserializa', () {
      final cond = Condition.compound(
        combinator: 'all',
        conditions: [
          const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          const Condition.simple(
            field: 'priority',
            operator: 'in',
            value: ['high', 'urgent'],
          ),
        ],
      );

      final json = cond.toJson();
      final restored = Condition.fromJson(json);

      expect(restored, cond);
    });

    test('Condition aninhada complex serializa e desserializa', () {
      final cond = Condition.compound(
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
                field: 'priority',
                operator: 'in',
                value: ['high', 'urgent'],
              ),
              const Condition.simple(
                field: 'tags',
                operator: 'contains',
                value: 'breaking',
              ),
            ],
          ),
        ],
      );

      final json = cond.toJson();
      final restored = Condition.fromJson(json);

      expect(restored, cond);
    });
  });

  group('Rule serialization', () {
    test('Rule completa serializa e desserializa', () {
      final rule = Rule(
        id: 'r1',
        name: 'Marcar breaking como urgente',
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: const Condition.simple(
          field: 'tags',
          operator: 'contains',
          value: 'breaking',
        ),
        actions: [
          const ActionInvocation(
            actionId: 'setPriority',
            params: {'priority': 'urgent'},
          ),
        ],
        stopOnMatch: true,
        order: 1,
      );

      final json = rule.toJson();
      final restored = Rule.fromJson(json);

      expect(restored.id, rule.id);
      expect(restored.name, rule.name);
      expect(restored.enabled, rule.enabled);
      expect(restored.trigger, rule.trigger);
      expect(restored.stopOnMatch, rule.stopOnMatch);
      expect(restored.order, rule.order);
      expect(restored.actions.length, 1);
      expect(restored.actions.first.actionId, 'setPriority');
    });
  });
}
