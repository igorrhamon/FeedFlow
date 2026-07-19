import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/rule_scheduler.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

class _CompleteTestAction implements ArticleAction {
  @override
  String get id => 'test-complete';

  @override
  String get label => 'Test complete';

  final List<String> executedItemIds = [];

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    executedItemIds.add(item.id);
  }
}

void main() {
  late AppDatabase db;
  late RuleRepositoryDrift ruleRepo;
  late WorkItemRepositoryDrift workItemRepo;
  late _CompleteTestAction testAction;
  late RuleScheduler scheduler;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ruleRepo = RuleRepositoryDrift(db);
    workItemRepo = WorkItemRepositoryDrift(db);

    testAction = _CompleteTestAction();
    ActionRegistry.clear();
    ActionRegistry.register('test-complete', () => testAction);

    scheduler = RuleScheduler(
      ruleRepository: ruleRepo,
      workItemRepository: workItemRepo,
      actionExecutor: ActionExecutor(eventBus: EventBus()),
    );

    await workItemRepo.upsertFromArticles(
      [const Article(id: 'a1', feedId: 'f1', title: 'Artigo')],
      'feedbin',
    );
  });

  tearDown(() async {
    ActionRegistry.clear();
    await db.close();
  });

  Rule scheduleRule({
    String id = 'r1',
    int? intervalMinutes = 60,
    DateTime? lastRunAt,
  }) =>
      Rule(
        id: id,
        name: 'Regra agendada',
        enabled: true,
        trigger: RuleTrigger.schedule,
        conditions: const Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
        actions: const [ActionInvocation(actionId: 'test-complete', params: {})],
        order: 1,
        intervalMinutes: intervalMinutes,
        lastRunAt: lastRunAt,
      );

  test('regra sem lastRunAt roda na primeira chamada e grava lastRunAt', () async {
    await ruleRepo.create(scheduleRule());
    final now = DateTime(2026, 1, 1, 12);

    await scheduler.runDue(now: now);

    expect(testAction.executedItemIds, ['feedbin:a1']);
    final updated = await ruleRepo.byId('r1');
    expect(updated!.lastRunAt, now);
  });

  test('regra roda de novo só depois do intervalo decorrer', () async {
    final lastRun = DateTime(2026, 1, 1, 12);
    await ruleRepo.create(scheduleRule(intervalMinutes: 60, lastRunAt: lastRun));

    // 30min depois — ainda não venceu o intervalo de 60min.
    await scheduler.runDue(now: lastRun.add(const Duration(minutes: 30)));
    expect(testAction.executedItemIds, isEmpty);

    // 60min depois — venceu.
    await scheduler.runDue(now: lastRun.add(const Duration(minutes: 60)));
    expect(testAction.executedItemIds, ['feedbin:a1']);
  });

  test('regra desabilitada nunca roda', () async {
    final rule = scheduleRule().copyWith(enabled: false);
    await ruleRepo.create(rule);

    await scheduler.runDue(now: DateTime(2026, 1, 1, 12));

    expect(testAction.executedItemIds, isEmpty);
  });

  test('regra de trigger onIngested (não schedule) nunca roda via scheduler', () async {
    final rule = scheduleRule().copyWith(trigger: RuleTrigger.onIngested);
    await ruleRepo.create(rule);

    await scheduler.runDue(now: DateTime(2026, 1, 1, 12));

    expect(testAction.executedItemIds, isEmpty);
  });

  test('intervalMinutes nulo usa default de 60 minutos', () async {
    final lastRun = DateTime(2026, 1, 1, 12);
    await ruleRepo.create(scheduleRule(intervalMinutes: null, lastRunAt: lastRun));

    await scheduler.runDue(now: lastRun.add(const Duration(minutes: 59)));
    expect(testAction.executedItemIds, isEmpty);

    await scheduler.runDue(now: lastRun.add(const Duration(minutes: 60)));
    expect(testAction.executedItemIds, ['feedbin:a1']);
  });

  test('falha em uma regra não impede a execução das demais', () async {
    ActionRegistry.register('boom', () => _ThrowingAction());
    final broken = scheduleRule(id: 'r-broken').copyWith(
      actions: const [ActionInvocation(actionId: 'boom', params: {})],
    );
    final healthy = scheduleRule(id: 'r-healthy');

    await ruleRepo.create(broken);
    await ruleRepo.create(healthy);

    await scheduler.runDue(now: DateTime(2026, 1, 1, 12));

    expect(testAction.executedItemIds, ['feedbin:a1']);
  });
}

class _ThrowingAction implements ArticleAction {
  @override
  String get id => 'boom';

  @override
  String get label => 'Boom';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    throw Exception('Falha simulada');
  }
}
