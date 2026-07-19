import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/repositories/rule_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';
import 'package:feedflow/pages/rule_editor_page.dart';

class _TrackingAction implements ArticleAction {
  @override
  String get id => 'track';

  @override
  String get label => 'Track';

  final List<String> executedItemIds = [];

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    executedItemIds.add(item.id);
  }
}

void main() {
  late AppDatabase db;
  late RuleRepository ruleRepo;
  late WorkItemRepository workItemRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    ruleRepo = RuleRepositoryDrift(db);
    workItemRepo = WorkItemRepositoryDrift(db);
  });

  tearDown(() async {
    ActionRegistry.clear();
    await db.close();
  });

  // O formulário + lista de regras excede a altura padrão do viewport de
  // teste (600px) — ListView virtualiza mesmo com `children:` fixo (Sliver
  // só monta o que está dentro do viewport + cacheExtent), então os widgets
  // abaixo da dobra (ex.: "Regras (N)") não existem na árvore sem uma
  // superfície maior.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> setLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget buildPage() => MaterialApp(
        home: RuleEditorPage(ruleRepository: ruleRepo, workItemRepository: workItemRepo),
      );

  group('RuleEditorPage', () {
    testWidgets('page loads and shows empty rule list', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Automações'), findsOneWidget);
      expect(find.text('Nova Regra'), findsOneWidget);
      expect(find.text('Regras (0)'), findsOneWidget);
    });

    testWidgets('page displays existing rules', (WidgetTester tester) async {
      await setLargeSurface(tester);
      final testRule = Rule(
        id: 'r1',
        name: 'Test Rule',
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
        actions: const [ActionInvocation(actionId: 'test', params: {})],
        stopOnMatch: false,
        order: 1,
      );
      await ruleRepo.create(testRule);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Test Rule'), findsOneWidget);
      expect(find.text('Regras (1)'), findsOneWidget);
    });

    testWidgets('dry-run button exists', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.preview), findsOneWidget);
      expect(find.text('Testar Condição'), findsOneWidget);
    });

    testWidgets('dry-run does not mutate rules or work items', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // O dry-run valida o formulário inteiro (mesmo _formKey do salvar), então
      // o nome também precisa estar preenchido para o validate() passar.
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Regra'), 'Regra de teste');
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');
      await tester.tap(find.text('Testar Condição'));
      // watchByStatus(...).first é um Stream real do drift — dentro da zona
      // fake-async do testWidgets, pump()/pumpAndSettle() sozinhos não o
      // resolvem; runAsync sai da zona fake por um instante para deixar o
      // Future completar de verdade.
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // Dry-run é preview puro: nenhuma regra é criada, nenhum WorkItem muda.
      expect(await ruleRepo.list(), isEmpty);
      expect(find.textContaining('itens casariam'), findsOneWidget);
    });

    testWidgets('form validation works', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Salvar Regra');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Nome e Valor ficam vazios por padrão -> ambos disparam a mensagem.
      expect(find.text('Campo obrigatório'), findsWidgets);
      // Nenhuma regra deve ter sido criada com o formulário inválido.
      expect(await ruleRepo.list(), isEmpty);
    });

    testWidgets('selecionar addTag mostra campo Tag; complete não mostra campo extra',
        (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Tag'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Adiar por (dias)'), findsNothing);

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Nenhuma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('addTag').last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Tag'), findsOneWidget);

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'addTag'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('complete').last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Tag'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Adiar por (dias)'), findsNothing);
    });

    testWidgets('salvar regra com addTag grava params[tag]', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Regra'), 'Marcar importante');
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Nenhuma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('addTag').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Tag'), 'importante');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Regra'));
      await tester.pumpAndSettle();

      final rules = await ruleRepo.list();
      expect(rules, hasLength(1));
      expect(rules.first.actions.single.actionId, 'addTag');
      expect(rules.first.actions.single.params, {'tag': 'importante'});
    });

    testWidgets('salvar regra com addTag e tag vazia falha a validação',
        (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Regra'), 'Regra sem tag');
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Nenhuma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('addTag').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Regra'));
      await tester.pumpAndSettle();

      expect(find.text('Obrigatório para addTag'), findsOneWidget);
      expect(await ruleRepo.list(), isEmpty);
    });

    testWidgets('salvar regra com snooze grava params[days]', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Regra'), 'Adiar antigos');
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Nenhuma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('snooze').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Adiar por (dias)'), '3');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Regra'));
      await tester.pumpAndSettle();

      final rules = await ruleRepo.list();
      expect(rules, hasLength(1));
      expect(rules.first.actions.single.actionId, 'snooze');
      expect(rules.first.actions.single.params, {'days': 3});
    });

    testWidgets('editar regra com addTag repopula o campo Tag', (WidgetTester tester) async {
      await setLargeSurface(tester);
      final testRule = Rule(
        id: 'r1',
        name: 'Regra existente',
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: const Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
        actions: const [
          ActionInvocation(actionId: 'addTag', params: {'tag': 'ja-lido'}),
        ],
        stopOnMatch: false,
        order: 1,
      );
      await ruleRepo.create(testRule);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Tag'), findsOneWidget);
      final tagField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Tag'));
      expect(tagField.controller!.text, 'ja-lido');
    });

    testWidgets('botão Executar agora só aparece para trigger manual e executa de verdade',
        (WidgetTester tester) async {
      await setLargeSurface(tester);

      final trackingAction = _TrackingAction();
      ActionRegistry.register('track', () => trackingAction);

      await workItemRepo.upsertFromArticles(
        [const Article(id: 'a1', feedId: 'f1', title: 'Artigo')],
        'feedbin',
      );

      final manualRule = Rule(
        id: 'r-manual',
        name: 'Regra manual',
        enabled: true,
        trigger: RuleTrigger.manual,
        conditions: const Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
        actions: const [ActionInvocation(actionId: 'track', params: {})],
        order: 1,
      );
      final autoRule = Rule(
        id: 'r-auto',
        name: 'Regra onIngested',
        enabled: true,
        trigger: RuleTrigger.onIngested,
        conditions: const Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
        actions: const [],
        order: 2,
      );
      await ruleRepo.create(manualRule);
      await ruleRepo.create(autoRule);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Regra onIngested não tem a opção "Executar agora".
      final autoRuleMenu = find.byType(PopupMenuButton).at(1);
      await tester.tap(autoRuleMenu);
      await tester.pumpAndSettle();
      expect(find.text('Executar agora'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Regra manual tem a opção e executa de verdade contra o WorkItem seedado.
      final manualRuleMenu = find.byType(PopupMenuButton).first;
      await tester.tap(manualRuleMenu);
      await tester.pumpAndSettle();
      expect(find.text('Executar agora'), findsOneWidget);

      await tester.tap(find.text('Executar agora'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(trackingAction.executedItemIds, ['feedbin:a1']);
      expect(find.textContaining('1/1 itens processados com sucesso'), findsOneWidget);
    });
  });
}
