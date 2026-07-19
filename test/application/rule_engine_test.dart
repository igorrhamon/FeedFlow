import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/rule_engine.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/repositories/rule_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepository workItemRepo;
  late RuleRepository ruleRepo;
  late EventBus bus;
  late ActionExecutor executor;
  late RuleEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bus = EventBus(); // Instância separada para testes, não usa singleton
    // Decorator: publica ArticleIngested/StatusChanged no bus para o
    // RuleEngine reagir — igual à produção (DatabaseProvider.repository).
    workItemRepo = EventEmittingWorkItemRepository(WorkItemRepositoryDrift(db), bus);
    ruleRepo = RuleRepositoryDrift(db);
    executor = ActionExecutor(eventBus: bus);
    engine = RuleEngine(
      workItemRepository: workItemRepo,
      ruleRepository: ruleRepo,
      eventBus: bus,
      actionExecutor: executor,
    );
  });

  tearDown(() async {
    engine.dispose();
    await db.close();
  });

  Article article({
    String id = 'a1',
    String feedId = 'f1',
    String title = 'Título',
  }) =>
      Article(id: id, feedId: feedId, title: title);

  Rule ruleOnIngested({
    String id = 'r1',
    String name = 'Rule',
    required Condition conditions,
    List<ActionInvocation> actions = const [
      ActionInvocation(actionId: 'stub', params: {}),
    ],
  }) =>
      Rule(
        id: id,
        name: name,
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: conditions,
        actions: actions,
        stopOnMatch: false,
        order: 1,
      );

  Rule ruleOnStatusChanged({
    String id = 'r1',
    String name = 'Rule',
    required Condition conditions,
    List<ActionInvocation> actions = const [
      ActionInvocation(actionId: 'stub', params: {}),
    ],
  }) =>
      Rule(
        id: id,
        name: name,
        enabled: true,
        trigger: RuleTrigger.onStatusChanged,
        conditions: conditions,
        actions: actions,
        stopOnMatch: false,
        order: 1,
      );

  group('Condition evaluation', () {
    test('SimpleCondition equals', () async {
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50)); // Aguarda processamento

      expect(matched, isNotNull);
      expect(matched!.ruleId, 'r1');
    });

    test('SimpleCondition notEquals', () async {
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'notEquals',
          value: 'arquivado',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
    });

    test('SimpleCondition contains (string)', () async {
      // 'contains' avaliado no momento da ingestão (trigger onIngested) —
      // save() não publica eventos (ver EventEmittingWorkItemRepository),
      // então o campo testado precisa vir preenchido já no Article.
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'title',
          operator: 'contains',
          value: 'Tít',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
    });

    test('CompoundCondition all (AND)', () async {
      // AND só avalia via evento de ingestão (save() não publica eventos —
      // ver EventEmittingWorkItemRepository), então o segundo ramo usa um
      // segundo item ingerido, não uma mutação in-place do primeiro.
      final rule = ruleOnIngested(
        conditions: Condition.compound(
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
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      // feedId 'f2' — só uma das duas condições casa, AND não fecha
      await workItemRepo.upsertFromArticles([article(id: 'a1', feedId: 'f2')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(matched, isNull);

      // feedId 'f1' — as duas condições casam
      await workItemRepo.upsertFromArticles([article(id: 'a2', feedId: 'f1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
    });

    test('CompoundCondition any (OR)', () async {
      final rule = ruleOnIngested(
        conditions: Condition.compound(
          combinator: 'any',
          conditions: [
            const Condition.simple(
              field: 'priority',
              operator: 'in',
              value: ['high', 'urgent'],
            ),
            const Condition.simple(
              field: 'feedId',
              operator: 'equals',
              value: 'f1',
            ),
          ],
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      // Article com feedId f1 — casa
      await workItemRepo.upsertFromArticles([article(id: 'a1', feedId: 'f1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
    });

    test('CompoundCondition not (negação)', () async {
      final rule = ruleOnIngested(
        conditions: Condition.compound(
          combinator: 'not',
          conditions: [
            const Condition.simple(
              field: 'status',
              operator: 'equals',
              value: 'arquivado',
            ),
          ],
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      // Item novo (não arquivado) — casa
      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
    });
  });

  group('Rule trigger evaluation', () {
    test('gatilho onIngested avalia quando artigo é ingerido', () async {
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
      expect(matched!.ruleId, 'r1');
    });

    test('gatilho onStatusChanged avalia quando status muda', () async {
      final rule = ruleOnStatusChanged(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'triado',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(matched, isNull); // Status é 'novo', não casa

      // Muda status para 'triado'
      await workItemRepo.changeStatus('feedbin:a1', TriageStatus.triado);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
      expect(matched!.workItemId, 'feedbin:a1');
    });

    test('regra desabilitada não avalia', () async {
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      ).copyWith(enabled: false);
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNull);
    });

    test('stopOnMatch interrompe avaliação de outras regras', () async {
      final rule1 = ruleOnIngested(
        id: 'r1',
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      ).copyWith(stopOnMatch: true);

      final rule2 = ruleOnIngested(
        id: 'r2',
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );

      await ruleRepo.create(rule1);
      await ruleRepo.create(rule2);

      final matched = <String>[];
      bus.subscribe((event) {
        if (event is RuleMatched) matched.add(event.ruleId);
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, ['r1']); // Apenas r1, r2 não foi avaliada
    });
  });

  group('RuleMatched event', () {
    test('evento contém payload para auditoria', () async {
      final rule = ruleOnIngested(
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );
      await ruleRepo.create(rule);

      RuleMatched? matched;
      bus.subscribe((event) {
        if (event is RuleMatched) matched = event;
      });

      await workItemRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(matched, isNotNull);
      expect(matched!.payload['status'], 'novo');
      expect(matched!.payload['triggerType'], 'onIngested');
    });
  });
}
