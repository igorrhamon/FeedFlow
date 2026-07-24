import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_executor.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/application/rule_engine.dart';
import 'package:feedflow/application/rule_undo_use_case.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/repositories/rule_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_event_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

class _NoopIrreversibleAction implements ArticleAction {
  @override
  String get id => 'webhook';

  @override
  String get label => 'Webhook (stub de teste)';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {}
}

class _FailingAction implements ArticleAction {
  @override
  String get id => 'boom';

  @override
  String get label => 'Falha proposital';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    throw Exception('boom');
  }
}

void main() {
  late AppDatabase db;
  late WorkItemRepository workItemRepo;
  late WorkItemRepositoryDrift baseRepo;
  late RuleRepository ruleRepo;
  late EventBus bus;
  late ActionExecutor executor;
  late RuleEngine engine;
  late RuleUndoUseCase undoUseCase;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bus = EventBus();
    baseRepo = WorkItemRepositoryDrift(db);
    workItemRepo = EventEmittingWorkItemRepository(baseRepo, bus);
    ruleRepo = RuleRepositoryDrift(db);
    executor = ActionExecutor(eventBus: bus);
    engine = RuleEngine(
      workItemRepository: workItemRepo,
      ruleRepository: ruleRepo,
      eventBus: bus,
      actionExecutor: executor,
    );
    undoUseCase = RuleUndoUseCase(
      workItemRepository: workItemRepo,
      eventRepository: WorkItemEventRepositoryDrift(db),
      ruleRepository: ruleRepo,
    );

    ActionRegistry.clear();
    ActionRegistry.register('archive', () => ArchiveActionForTest(workItemRepo));
    ActionRegistry.register('toggleStar', () => ToggleStarActionForTest(workItemRepo));
    ActionRegistry.register('addTag', () => AddTagActionForTest(workItemRepo));
    ActionRegistry.register('webhook', () => _NoopIrreversibleAction());
    ActionRegistry.register('boom', () => _FailingAction());
  });

  tearDown(() async {
    engine.dispose();
    ActionRegistry.clear();
    await db.close();
  });

  Article article({String id = 'a1', String feedId = 'f1'}) => Article(id: id, feedId: feedId, title: 'T');

  Rule ruleWithActions({
    String id = 'r1',
    List<ActionInvocation> actions = const [],
  }) =>
      Rule(
        id: id,
        name: 'Regra de teste',
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: const Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
        actions: actions,
        stopOnMatch: false,
        order: 1,
      );

  Future<void> waitForRuleEngine() => Future.delayed(const Duration(milliseconds: 50));

  group('RuleUndoUseCase.undoRule', () {
    test('reverte status (archive)', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'archive', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      final beforeUndo = await workItemRepo.byId('feedbin:a1');
      expect(beforeUndo!.status, TriageStatus.arquivado);

      final result = await undoUseCase.undoRule('r1');

      final afterUndo = await workItemRepo.byId('feedbin:a1');
      expect(afterUndo!.status, TriageStatus.novo);
      expect(result.reverted, hasLength(1));
      expect(result.reverted.single.fieldsReverted, contains('status'));
    });

    test('reverte isStarred (toggleStar)', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'toggleStar', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      final beforeUndo = await workItemRepo.byId('feedbin:a1');
      expect(beforeUndo!.isStarred, isTrue);

      final result = await undoUseCase.undoRule('r1');

      final afterUndo = await workItemRepo.byId('feedbin:a1');
      expect(afterUndo!.isStarred, isFalse);
      expect(result.reverted.single.fieldsReverted, contains('isStarred'));
    });

    test('reverte tags (addTag) resolvendo o parâmetro via RuleRepository', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'addTag', params: {'tag': 'urgente'})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      final beforeUndo = await workItemRepo.byId('feedbin:a1');
      expect(beforeUndo!.tags, contains('urgente'));

      final result = await undoUseCase.undoRule('r1');

      final afterUndo = await workItemRepo.byId('feedbin:a1');
      expect(afterUndo!.tags, isNot(contains('urgente')));
      expect(result.reverted.single.fieldsReverted, contains('tags'));
    });

    test('reporta ruleDeletedCannotResolveParams quando a regra foi excluída', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'addTag', params: {'tag': 'urgente'})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      await ruleRepo.delete('r1');

      final result = await undoUseCase.undoRule('r1');

      expect(result.reverted, hasLength(1));
      final skip = result.reverted.single.actionsSkipped.single;
      expect(skip.actionId, 'addTag');
      expect(skip.reason, ActionUndoSkipReason.ruleDeletedCannotResolveParams);

      final afterUndo = await workItemRepo.byId('feedbin:a1');
      expect(afterUndo!.tags, contains('urgente')); // não revertido
    });

    test('não reverte item modificado depois do match (modifiedAfterMatch)', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'archive', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      // Edição manual do usuário bem depois do match da regra — usa um
      // updatedAt explícito no futuro em vez de sleep real, para não
      // depender da precisão de segundo do timestamp persistido pelo drift.
      final edited = await workItemRepo.byId('feedbin:a1');
      await workItemRepo.save(
        edited!.copyWith(status: TriageStatus.triado, updatedAt: DateTime.now().add(const Duration(days: 1))),
      );

      final result = await undoUseCase.undoRule('r1');

      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.skipReason, WorkItemUndoSkipReason.modifiedAfterMatch);

      final afterUndo = await workItemRepo.byId('feedbin:a1');
      expect(afterUndo!.status, TriageStatus.triado); // preservado
    });

    test('não reverte fora da janela de tempo', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'archive', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      // O drift persiste DateTime com precisão de segundo (trunca
      // sub-segundo) — espera mais de 1s real para garantir que o
      // timestamp do evento fique estritamente antes do cutoff (window: 0)
      // mesmo após o round-trip pelo banco.
      await Future.delayed(const Duration(milliseconds: 2100));

      final result = await undoUseCase.undoRule('r1', window: const Duration(milliseconds: 0));

      expect(result.matchesFound, 0);
      expect(result.reverted, isEmpty);
      expect(result.skipped, isEmpty);
    });

    test('reporta ações irreversíveis sem tentar revertê-las', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'webhook', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      final result = await undoUseCase.undoRule('r1');

      expect(result.reverted, hasLength(1));
      final skip = result.reverted.single.actionsSkipped.single;
      expect(skip.actionId, 'webhook');
      expect(skip.reason, ActionUndoSkipReason.irreversibleAction);
    });

    test('não reverte ação que falhou originalmente', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'boom', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article()], 'feedbin');
      await waitForRuleEngine();

      final result = await undoUseCase.undoRule('r1');

      expect(result.reverted, hasLength(1));
      final skip = result.reverted.single.actionsSkipped.single;
      expect(skip.actionId, 'boom');
      expect(skip.reason, ActionUndoSkipReason.actionFailedOriginally);
    });

    test('matchesFound reflete os matches na janela mesmo com itens pulados', () async {
      await ruleRepo.create(ruleWithActions(
        actions: const [ActionInvocation(actionId: 'archive', params: {})],
      ));
      await workItemRepo.upsertFromArticles([article(id: 'a1'), article(id: 'a2')], 'feedbin');
      await waitForRuleEngine();

      final result = await undoUseCase.undoRule('r1');

      expect(result.matchesFound, 2);
      expect(result.reverted, hasLength(2));
    });
  });
}

// Ações reais mínimas (não dependem de ActionRegistry global de produção)
// para exercitar o fluxo completo RuleEngine -> WorkItemEvents -> undo.
class ArchiveActionForTest implements ArticleAction {
  ArchiveActionForTest(this._repo);
  final WorkItemRepository _repo;

  @override
  String get id => 'archive';

  @override
  String get label => 'Arquivar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) =>
      _repo.changeStatus(item.id, TriageStatus.arquivado);
}

class ToggleStarActionForTest implements ArticleAction {
  ToggleStarActionForTest(this._repo);
  final WorkItemRepository _repo;

  @override
  String get id => 'toggleStar';

  @override
  String get label => 'Alternar favorito';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) =>
      _repo.save(item.copyWith(isStarred: !item.isStarred));
}

class AddTagActionForTest implements ArticleAction {
  AddTagActionForTest(this._repo);
  final WorkItemRepository _repo;

  @override
  String get id => 'addTag';

  @override
  String get label => 'Adicionar tag';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final tag = params['tag'] as String;
    if (!item.tags.contains(tag)) {
      await _repo.save(item.copyWith(tags: [...item.tags, tag]));
    }
  }
}
