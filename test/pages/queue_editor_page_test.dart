import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/query_spec.dart';
import 'package:feedflow/domain/queue.dart';
import 'package:feedflow/domain/repositories/queue_repository.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
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

  // O formulário + lista de filas excede a altura padrão do viewport de
  // teste (600px) — ListView virtualiza mesmo com `children:` fixo, então
  // widgets abaixo da dobra não existem na árvore sem uma superfície maior.
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
      await tester.pumpAndSettle();

      expect(find.text('Filas'), findsOneWidget);
      expect(find.text('Nova Fila'), findsOneWidget);
      expect(find.text('Filas Salvas'), findsOneWidget);
    });

    testWidgets('page displays existing queues', (WidgetTester tester) async {
      await setLargeSurface(tester);
      final testQueue = Queue(
        id: 'q1',
        name: 'Test Queue',
        icon: 'inbox',
        order: 1,
        querySpec: QuerySpec(
          filter: const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
          sortField: 'ingestedAt',
          sortDescending: false,
        ),
      );
      await queueRepo.create(testQueue);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Test Queue'), findsOneWidget);
    });

    testWidgets('form validation works', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Nome e campo de filtro ficam vazios por padrão → disparam mensagens de validação
      expect(find.textContaining('é obrigatório'), findsWidgets);
      // Nenhuma fila deve ter sido criada com o formulário inválido.
      expect(await queueRepo.list(), isEmpty);
    });

    testWidgets('creates a new queue', (WidgetTester tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Preenche o formulário
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Fila'), 'My Queue');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ícone (ex: inbox, star, check)'), 'star');

      // Preenche o filtro
      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Campo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('status').last);
      await tester.pumpAndSettle();

      // Preenche o operador
      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Operador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('equals').last);
      await tester.pumpAndSettle();

      // Preenche o valor
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      // Salva
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      // Verifica que a fila foi criada
      final queues = await queueRepo.list();
      expect(queues.length, 1);
      expect(queues[0].name, 'My Queue');
      expect(queues[0].icon, 'star');
    });

    testWidgets('dry-run button exists and works', (WidgetTester tester) async {
      await setLargeSurface(tester);

      // Cria um WorkItem de teste
      final now = DateTime.now();
      final testItem = WorkItem(
        id: 'test:1',
        providerId: 'provider',
        articleId: 'art1',
        feedId: 'feed/1',
        title: 'Test Article',
        status: TriageStatus.novo,
        ingestedAt: now,
        updatedAt: now,
      );
      await workItemRepo.save(testItem);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Preenche um filtro simples
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Fila'), 'Test');
      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Campo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('status').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      // Clica no botão de preview
      await tester.tap(find.widgetWithText(ElevatedButton, 'Preview'));

      // Stream real do drift precisa de runAsync
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // Verifica que o preview foi mostrado
      expect(find.textContaining('Preview'), findsWidgets);
      expect(find.text('Test Article'), findsOneWidget);
    });

    testWidgets('dry-run does not persist anything', (WidgetTester tester) async {
      await setLargeSurface(tester);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Preenche um filtro simples
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome da Fila'), 'Test');
      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Campo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('status').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), 'novo');

      // Clica no botão de preview
      await tester.tap(find.widgetWithText(ElevatedButton, 'Preview'));

      // Stream real do drift precisa de runAsync
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // Dry-run é preview puro: nenhuma fila é criada
      expect(await queueRepo.list(), isEmpty);
    });

    testWidgets('edits an existing queue', (WidgetTester tester) async {
      await setLargeSurface(tester);

      // Cria uma fila inicial
      final testQueue = Queue(
        id: 'q1',
        name: 'Original Queue',
        icon: 'inbox',
        order: 1,
        querySpec: QuerySpec(
          filter: const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
        ),
      );
      await queueRepo.create(testQueue);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Clica no botão de editar
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verifica que o formulário foi preenchido
      expect(find.widgetWithText(TextFormField, 'Original Queue'), findsOneWidget);
      expect(find.text('Editar Fila'), findsOneWidget);

      // Altera o nome
      await tester.enterText(find.widgetWithText(TextFormField, 'Original Queue'), 'Updated Queue');

      // Salva
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      // Verifica que a fila foi atualizada
      final queues = await queueRepo.list();
      expect(queues[0].name, 'Updated Queue');
    });

    testWidgets('deletes a queue', (WidgetTester tester) async {
      await setLargeSurface(tester);

      // Cria uma fila
      final testQueue = Queue(
        id: 'q1',
        name: 'Queue to Delete',
        icon: 'inbox',
        order: 1,
        querySpec: QuerySpec(
          filter: const Condition.simple(
            field: 'status',
            operator: 'equals',
            value: 'novo',
          ),
        ),
      );
      await queueRepo.create(testQueue);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Verifica que a fila existe
      expect(find.text('Queue to Delete'), findsOneWidget);

      // Clica no botão de deletar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verifica que a fila foi deletada
      expect(await queueRepo.list(), isEmpty);
      expect(find.text('Queue to Delete'), findsNothing);
    });
  });
}
