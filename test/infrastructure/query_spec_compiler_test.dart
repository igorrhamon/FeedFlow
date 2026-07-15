import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/domain/query_spec.dart';
import 'package:the_old_reader/domain/rule.dart';
import 'package:the_old_reader/domain/triage_status.dart';
import 'package:the_old_reader/domain/work_item.dart';
import 'package:the_old_reader/infrastructure/db/database.dart';
import 'package:the_old_reader/infrastructure/query_spec_compiler.dart';
import 'package:the_old_reader/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late QuerySpecCompiler compiler;
  late WorkItemRepositoryDrift workItemRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    compiler = QuerySpecCompiler(db);
    workItemRepo = WorkItemRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  WorkItem _createTestItem({
    String id = 'test:1',
    String providerId = 'provider',
    String articleId = 'art1',
    String feedId = 'feed/1',
    String title = 'Test Item',
    TriageStatus status = TriageStatus.novo,
    bool isRead = false,
  }) {
    final now = DateTime.now();
    return WorkItem(
      id: id,
      providerId: providerId,
      articleId: articleId,
      feedId: feedId,
      title: title,
      status: status,
      isRead: isRead,
      ingestedAt: now,
      updatedAt: now,
    );
  }

  group('QuerySpecCompiler', () {
    test('compila e executa filtro equals', () async {
      final item1 = _createTestItem(id: '1:1', title: 'Breaking News', status: TriageStatus.novo);
      final item2 = _createTestItem(id: '1:2', title: 'Old News', status: TriageStatus.novo);
      final item3 =
          _createTestItem(id: '1:3', title: 'Breaking Again', status: TriageStatus.arquivado);

      await workItemRepo.upsertFromArticles([
        item1.copyWith(articleId: 'art1'),
        item2.copyWith(articleId: 'art2'),
        item3.copyWith(articleId: 'art3'),
      ], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
      );

      final result = await compiler.run(spec);
      expect(result.length, 2);
      expect(result.every((i) => i.status == TriageStatus.novo), true);
    });

    test('compila e executa filtro contains', () async {
      final item1 = _createTestItem(id: '1:1', title: 'Breaking News');
      final item2 = _createTestItem(id: '1:2', title: 'Old News');
      final item3 = _createTestItem(id: '1:3', title: 'Breaking Again');

      await workItemRepo.upsertFromArticles([
        item1.copyWith(articleId: 'art1'),
        item2.copyWith(articleId: 'art2'),
        item3.copyWith(articleId: 'art3'),
      ], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'title',
          operator: 'contains',
          value: 'Breaking',
        ),
      );

      final result = await compiler.run(spec);
      expect(result.length, 2);
      expect(result.every((i) => i.title.contains('Breaking')), true);
    });

    test('compila e executa filtro in', () async {
      final item1 = _createTestItem(id: '1:1', status: TriageStatus.novo);
      final item2 = _createTestItem(id: '1:2', status: TriageStatus.arquivado);
      final item3 = _createTestItem(id: '1:3', status: TriageStatus.concluido);

      await workItemRepo.upsertFromArticles([
        item1.copyWith(articleId: 'art1'),
        item2.copyWith(articleId: 'art2'),
        item3.copyWith(articleId: 'art3'),
      ], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'in',
          value: ['novo', 'concluido'],
        ),
      );

      final result = await compiler.run(spec);
      expect(result.length, 2);
      expect(
        result.every((i) => i.status == TriageStatus.novo || i.status == TriageStatus.concluido),
        true,
      );
    });

    test('compila e executa filtro com ordenação ascendente', () async {
      final now = DateTime.now();
      final item1 = WorkItem(
        id: '1:1',
        providerId: 'p',
        articleId: 'art1',
        feedId: 'f1',
        title: 'Item A',
        ingestedAt: now.add(const Duration(hours: 2)),
        updatedAt: now,
      );
      final item2 = WorkItem(
        id: '1:2',
        providerId: 'p',
        articleId: 'art2',
        feedId: 'f1',
        title: 'Item B',
        ingestedAt: now,
        updatedAt: now,
      );
      final item3 = WorkItem(
        id: '1:3',
        providerId: 'p',
        articleId: 'art3',
        feedId: 'f1',
        title: 'Item C',
        ingestedAt: now.add(const Duration(hours: 1)),
        updatedAt: now,
      );

      await workItemRepo.upsertFromArticles([item1, item2, item3], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'exists',
          value: null,
        ),
        sortField: 'ingestedAt',
        sortDescending: false,
      );

      final result = await compiler.run(spec);
      expect(result.length, 3);
      expect(result[0].id, contains('1:2')); // mais cedo
      expect(result[1].id, contains('1:3'));
      expect(result[2].id, contains('1:1')); // mais tarde
    });

    test('compila e executa filtro com ordenação descendente', () async {
      final now = DateTime.now();
      final item1 = WorkItem(
        id: '1:1',
        providerId: 'p',
        articleId: 'art1',
        feedId: 'f1',
        title: 'Item A',
        ingestedAt: now.add(const Duration(hours: 2)),
        updatedAt: now,
      );
      final item2 = WorkItem(
        id: '1:2',
        providerId: 'p',
        articleId: 'art2',
        feedId: 'f1',
        title: 'Item B',
        ingestedAt: now,
        updatedAt: now,
      );
      final item3 = WorkItem(
        id: '1:3',
        providerId: 'p',
        articleId: 'art3',
        feedId: 'f1',
        title: 'Item C',
        ingestedAt: now.add(const Duration(hours: 1)),
        updatedAt: now,
      );

      await workItemRepo.upsertFromArticles([item1, item2, item3], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'exists',
          value: null,
        ),
        sortField: 'ingestedAt',
        sortDescending: true,
      );

      final result = await compiler.run(spec);
      expect(result.length, 3);
      expect(result[0].id, contains('1:1')); // mais tarde primeiro
      expect(result[1].id, contains('1:3'));
      expect(result[2].id, contains('1:2')); // mais cedo
    });

    test('equivalência: memória vs SQL para filtro simples', () async {
      final item1 = _createTestItem(id: '1:1', title: 'Breaking News', status: TriageStatus.novo);
      final item2 = _createTestItem(id: '1:2', title: 'Old News', status: TriageStatus.novo);
      final item3 =
          _createTestItem(id: '1:3', title: 'Breaking Again', status: TriageStatus.arquivado);

      await workItemRepo.upsertFromArticles([
        item1.copyWith(articleId: 'art1'),
        item2.copyWith(articleId: 'art2'),
        item3.copyWith(articleId: 'art3'),
      ], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'novo',
        ),
        sortField: 'title',
        sortDescending: false,
      );

      // Compila via SQL
      final sqlResult = await compiler.run(spec);

      // Filtra em memória
      final allItems = await workItemRepo.watchByStatus(TriageStatus.values).first;
      final memoryResult = [item1, item2, item3];

      // Ambos devem retornar os mesmos IDs
      final sqlIds = sqlResult.map((i) => i.id).toSet();
      final memoryFiltered = memoryResult
          .where((i) => i.status == TriageStatus.novo)
          .map((i) => i.id)
          .toSet();

      expect(sqlIds, memoryFiltered);
    });

    test('compila filtro startsWith', () async {
      final item1 = _createTestItem(id: '1:1', title: 'Breaking News');
      final item2 = _createTestItem(id: '1:2', title: 'Old News');
      final item3 = _createTestItem(id: '1:3', title: 'Breaking Again');

      await workItemRepo.upsertFromArticles([
        item1.copyWith(articleId: 'art1'),
        item2.copyWith(articleId: 'art2'),
        item3.copyWith(articleId: 'art3'),
      ], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'title',
          operator: 'startsWith',
          value: 'Breaking',
        ),
      );

      final result = await compiler.run(spec);
      expect(result.length, 2);
      expect(result.every((i) => i.title.startsWith('Breaking')), true);
    });

    test('retorna lista vazia para nenhuma correspondência', () async {
      final item1 = _createTestItem(id: '1:1', status: TriageStatus.novo);
      await workItemRepo.upsertFromArticles([item1.copyWith(articleId: 'art1')], 'provider');

      final spec = QuerySpec(
        filter: const Condition.simple(
          field: 'status',
          operator: 'equals',
          value: 'arquivado',
        ),
      );

      final result = await compiler.run(spec);
      expect(result.isEmpty, true);
    });
  });
}
