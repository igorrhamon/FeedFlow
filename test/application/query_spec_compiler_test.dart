import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/query_spec_compiler.dart';
import 'package:feedflow/domain/query_spec.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift repo;
  final compiler = QuerySpecCompiler();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkItemRepositoryDrift(db);

    await repo.upsertFromArticles([
      Article(id: 'a1', feedId: 'f1', title: 'Bravo'),
      Article(id: 'a2', feedId: 'f1', title: 'Alpha'),
      Article(id: 'a3', feedId: 'f2', title: 'Charlie'),
    ], 'feedbin');

    // a2 marcado como triado, a3 marcado como arquivado.
    await repo.changeStatus('feedbin:a2', TriageStatus.triado);
    await repo.changeStatus('feedbin:a3', TriageStatus.arquivado);
  });

  tearDown(() async {
    await db.close();
  });

  test('filtro simples retorna apenas itens que casam', () async {
    const spec = QuerySpec(
      filter: Condition.simple(field: 'feedId', operator: 'equals', value: 'f1'),
    );

    final result = await compiler.compile(spec, repo).first;
    expect(result.map((i) => i.articleId).toSet(), {'a1', 'a2'});
  });

  test('filtro composto (all) combina condições', () async {
    const spec = QuerySpec(
      filter: Condition.compound(
        combinator: 'all',
        conditions: [
          Condition.simple(field: 'feedId', operator: 'equals', value: 'f1'),
          Condition.simple(field: 'status', operator: 'equals', value: 'triado'),
        ],
      ),
    );

    final result = await compiler.compile(spec, repo).first;
    expect(result.map((i) => i.articleId).toList(), ['a2']);
  });

  test('sort ascendente por título', () async {
    const spec = QuerySpec(
      filter: Condition.simple(field: 'feedId', operator: 'equals', value: 'f1'),
      sort: [QuerySort(field: 'title')],
    );

    final result = await compiler.compile(spec, repo).first;
    expect(result.map((i) => i.title).toList(), ['Alpha', 'Bravo']);
  });

  test('sort descendente por título', () async {
    const spec = QuerySpec(
      filter: Condition.simple(field: 'feedId', operator: 'equals', value: 'f1'),
      sort: [QuerySort(field: 'title', descending: true)],
    );

    final result = await compiler.compile(spec, repo).first;
    expect(result.map((i) => i.title).toList(), ['Bravo', 'Alpha']);
  });

  test('limit restringe a quantidade de resultados', () async {
    const spec = QuerySpec(
      filter: Condition.simple(field: 'status', operator: 'exists', value: null),
      sort: [QuerySort(field: 'title')],
      limit: 2,
    );

    final result = await compiler.compile(spec, repo).first;
    expect(result.length, 2);
    expect(result.map((i) => i.title).toList(), ['Alpha', 'Bravo']);
  });
}
