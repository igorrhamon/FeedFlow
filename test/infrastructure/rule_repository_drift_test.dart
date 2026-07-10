import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';

void main() {
  late AppDatabase db;
  late RuleRepositoryDrift repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RuleRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  Rule sampleRule({
    String id = 'r1',
    String name = 'Sample Rule',
    bool enabled = true,
    RuleTrigger trigger = RuleTrigger.onIngested,
    int order = 1,
  }) =>
      Rule(
        id: id,
        name: name,
        enabled: enabled,
        trigger: trigger,
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
        actions: const [
          ActionInvocation(
            actionId: 'setPriority',
            params: {'priority': 'high'},
          ),
        ],
        stopOnMatch: false,
        order: order,
      );

  group('create', () {
    test('cria uma regra nova', () async {
      final rule = sampleRule();
      await repo.create(rule);

      final retrieved = await repo.byId('r1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Sample Rule');
      expect(retrieved.enabled, true);
      expect(retrieved.trigger, RuleTrigger.onIngested);
    });

    test('múltiplas regras podem ser criadas', () async {
      await repo.create(sampleRule(id: 'r1', order: 1));
      await repo.create(sampleRule(id: 'r2', order: 2));

      final all = await repo.list();
      expect(all.length, 2);
      expect(all[0].order, 1);
      expect(all[1].order, 2);
    });
  });

  group('update', () {
    test('atualiza uma regra existente', () async {
      final rule = sampleRule();
      await repo.create(rule);

      final updated = rule.copyWith(name: 'Updated Name', enabled: false);
      await repo.update(updated);

      final retrieved = await repo.byId('r1');
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.enabled, false);
    });

    test('atualiza lança erro se regra não existe', () async {
      final rule = sampleRule(id: 'nonexistent');
      expect(() => repo.update(rule), throwsStateError);
    });
  });

  group('delete', () {
    test('remove uma regra', () async {
      await repo.create(sampleRule());
      await repo.delete('r1');

      final retrieved = await repo.byId('r1');
      expect(retrieved, isNull);
    });

    test('não lança erro se regra não existe', () async {
      expect(() async => repo.delete('nonexistent'), returnsNormally);
    });
  });

  group('list', () {
    test('lista todas as regras em ordem', () async {
      await repo.create(sampleRule(id: 'r2', order: 2));
      await repo.create(sampleRule(id: 'r1', order: 1));
      await repo.create(sampleRule(id: 'r3', order: 3));

      final all = await repo.list();
      expect(all.length, 3);
      expect(all[0].id, 'r1');
      expect(all[1].id, 'r2');
      expect(all[2].id, 'r3');
    });
  });

  group('watchEnabled', () {
    test('stream retorna apenas regras habilitadas', () async {
      await repo.create(sampleRule(id: 'r1', enabled: true, order: 1));
      await repo.create(sampleRule(id: 'r2', enabled: false, order: 2));
      await repo.create(sampleRule(id: 'r3', enabled: true, order: 3));

      final enabled = await repo.watchEnabled().first;
      expect(enabled.length, 2);
      expect(enabled[0].id, 'r1');
      expect(enabled[1].id, 'r3');
      expect(enabled.every((r) => r.enabled), true);
    });

    test('stream reativo — mudança de enabled atualiza stream', () async {
      await repo.create(sampleRule(id: 'r1', enabled: true));

      final stream = repo.watchEnabled();
      var count = 0;

      stream.listen((enabled) {
        count++;
        if (count == 1) {
          expect(enabled.length, 1);
          // Depois desabilita e espera o segundo emit
          repo.update(sampleRule(id: 'r1', enabled: false));
        } else if (count == 2) {
          expect(enabled.length, 0);
        }
      });

      // Aguarda dois emits
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });

  group('clear', () {
    test('remove todas as regras', () async {
      await repo.create(sampleRule(id: 'r1'));
      await repo.create(sampleRule(id: 'r2'));

      await repo.clear();

      final all = await repo.list();
      expect(all, isEmpty);
    });
  });
}
