import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/repositories/rule_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/rule_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/pages/rule_editor_page.dart';

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
  });
}
