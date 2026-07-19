import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/repositories/queue_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/queue_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/pages/queue_editor_page.dart';

void main() {
  late AppDatabase db;
  late QueueRepository queueRepo;
  late WorkItemRepository workItemRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    queueRepo = QueueRepositoryDrift(db);
    workItemRepo = WorkItemRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> setLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget buildPage() => MaterialApp(
        home: QueueEditorPage(queueRepository: queueRepo, workItemRepository: workItemRepo),
      );

  group('QueueEditorPage', () {
    testWidgets('page loads and shows empty queue list', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.text('Filas'), findsWidgets);
      expect(find.text('Nova Fila'), findsOneWidget);
      expect(find.text('Nenhuma fila criada.'), findsOneWidget);

      // drift agenda um Timer.run() interno para a primeira emissão de cada
      // watch() ativo — fechar o banco aqui (dentro do corpo do teste, e não
      // só no tearDown) drena esses timers antes do Flutter desmontar a
      // árvore e checar "nenhum timer pendente" (ver comentário em
      // drift/src/runtime/executor/stream_queries.dart).
      await db.close();
    });

    testWidgets('cria uma fila e ela aparece na lista', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Fila'), 'Não lidos');
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Fila'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.text('Não lidos'), findsOneWidget);
      expect(await queueRepo.list(), hasLength(1));

      await db.close();
    });

    testWidgets('preview atualiza ao preencher o filtro', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.text('Preencha o filtro para ver o preview.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.textContaining('itens casariam'), findsOneWidget);

      await db.close();
    });

    testWidgets('form validation works', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Fila'));
      await tester.pumpAndSettle();

      expect(find.text('Campo obrigatório'), findsWidgets);
      expect(await queueRepo.list(), isEmpty);

      await db.close();
    });
  });
}
