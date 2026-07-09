import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkItemRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  Article article({
    String id = 'a1',
    String feedId = 'f1',
    String title = 'Título',
    bool isRead = false,
    bool isStarred = false,
  }) =>
      Article(id: id, feedId: feedId, title: title, isRead: isRead, isStarred: isStarred);

  group('upsertFromArticles', () {
    test('cria WorkItems novos com status novo', () async {
      await repo.upsertFromArticles([article(id: 'a1'), article(id: 'a2')], 'feedbin');

      final item = await repo.byId('feedbin:a1');
      expect(item, isNotNull);
      expect(item!.status, TriageStatus.novo);
      expect(item.providerId, 'feedbin');
      expect(item.articleId, 'a1');

      final all = await repo.watchByStatus(TriageStatus.values).first;
      expect(all.length, 2);
    });

    test('upsert de item existente atualiza snapshot mas preserva status/tags locais', () async {
      await repo.upsertFromArticles([article(id: 'a1', title: 'Original')], 'feedbin');
      await repo.changeStatus('feedbin:a1', TriageStatus.triado);
      await repo.save((await repo.byId('feedbin:a1'))!.copyWith(tags: ['importante']));

      await repo.upsertFromArticles(
        [article(id: 'a1', title: 'Atualizado', isRead: true)],
        'feedbin',
      );

      final item = await repo.byId('feedbin:a1');
      expect(item!.title, 'Atualizado');
      expect(item.isRead, true);
      expect(item.status, TriageStatus.triado, reason: 'status local não deve ser sobrescrito pelo re-sync');
      expect(item.tags, ['importante'], reason: 'tags locais não devem ser sobrescritas pelo re-sync');
    });

    test('lista vazia não faz nada', () async {
      await repo.upsertFromArticles([], 'feedbin');
      final all = await repo.watchByStatus(TriageStatus.values).first;
      expect(all, isEmpty);
    });
  });

  group('changeStatus', () {
    test('transição válida atualiza status e completedAt em estado terminal', () async {
      await repo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await repo.changeStatus('feedbin:a1', TriageStatus.concluido);

      final item = await repo.byId('feedbin:a1');
      expect(item!.status, TriageStatus.concluido);
      expect(item.completedAt, isNotNull);
    });

    test('transição inválida lança StateError', () async {
      await repo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await repo.changeStatus('feedbin:a1', TriageStatus.concluido);

      expect(
        () => repo.changeStatus('feedbin:a1', TriageStatus.triado),
        throwsA(isA<StateError>()),
      );
    });

    test('item inexistente lança StateError', () {
      expect(
        () => repo.changeStatus('feedbin:inexistente', TriageStatus.triado),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('watchByStatus / watchCountByStatus', () {
    test('filtra por status e reage a mudanças', () async {
      await repo.upsertFromArticles(
        [article(id: 'a1'), article(id: 'a2'), article(id: 'a3')],
        'feedbin',
      );
      await repo.changeStatus('feedbin:a1', TriageStatus.arquivado);

      final ativos = await repo.watchByStatus([TriageStatus.novo]).first;
      expect(ativos.length, 2);

      final arquivados = await repo.watchByStatus([TriageStatus.arquivado]).first;
      expect(arquivados.length, 1);
      expect(arquivados.single.articleId, 'a1');
    });

    test('watchCountByStatus retorna contagem correta', () async {
      await repo.upsertFromArticles([article(id: 'a1'), article(id: 'a2')], 'feedbin');
      final count = await repo.watchCountByStatus(TriageStatus.novo).first;
      expect(count, 2);
    });
  });

  group('purgeOlderThan', () {
    test('remove apenas itens terminais mais antigos que o corte', () async {
      await repo.upsertFromArticles([article(id: 'a1'), article(id: 'a2')], 'feedbin');
      await repo.changeStatus('feedbin:a1', TriageStatus.arquivado);
      // a2 continua "novo" — não deve ser removido mesmo sendo "antigo".

      final removed = await repo.purgeOlderThan(DateTime.now().add(const Duration(days: 1)));

      expect(removed, 1);
      expect(await repo.byId('feedbin:a1'), isNull);
      expect(await repo.byId('feedbin:a2'), isNotNull);
    });
  });

  group('save', () {
    test('persiste um WorkItem construído manualmente', () async {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'feedbin:manual',
        providerId: 'feedbin',
        articleId: 'manual',
        feedId: 'f1',
        title: 'Manual',
        priority: Priority.high,
        tags: const ['urgente'],
        ingestedAt: now,
        updatedAt: now,
      );

      await repo.save(item);

      final loaded = await repo.byId('feedbin:manual');
      expect(loaded, isNotNull);
      expect(loaded!.priority, Priority.high);
      expect(loaded.tags, ['urgente']);
    });
  });

  group('watchByFeedId', () {
    test('retorna apenas WorkItems do feedId especificado', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', feedId: 'f1'),
          article(id: 'a2', feedId: 'f1'),
          article(id: 'a3', feedId: 'f2'),
        ],
        'feedbin',
      );

      final f1Items = await repo.watchByFeedId('f1').first;
      expect(f1Items.length, 2);
      expect(f1Items.map((i) => i.articleId).toSet(), {'a1', 'a2'});

      final f2Items = await repo.watchByFeedId('f2').first;
      expect(f2Items.length, 1);
      expect(f2Items.single.articleId, 'a3');
    });

    test('filtra por status quando especificado', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', feedId: 'f1'),
          article(id: 'a2', feedId: 'f1'),
        ],
        'feedbin',
      );
      await repo.changeStatus('feedbin:a1', TriageStatus.arquivado);

      final ativos = await repo.watchByFeedId('f1', statuses: [TriageStatus.novo]).first;
      expect(ativos.length, 1);
      expect(ativos.single.articleId, 'a2');

      final arquivados =
          await repo.watchByFeedId('f1', statuses: [TriageStatus.arquivado]).first;
      expect(arquivados.length, 1);
      expect(arquivados.single.articleId, 'a1');
    });

    test('retorna lista vazia quando feedId não existe', () async {
      await repo.upsertFromArticles([article(id: 'a1', feedId: 'f1')], 'feedbin');

      final result = await repo.watchByFeedId('f999').first;
      expect(result, isEmpty);
    });

    test('reage a mudanças via stream', () async {
      await repo.upsertFromArticles([article(id: 'a1', feedId: 'f1')], 'feedbin');

      final stream = repo.watchByFeedId('f1');
      final first = await stream.first;
      expect(first.length, 1);

      // Adiciona outro artigo
      await repo.upsertFromArticles([article(id: 'a2', feedId: 'f1')], 'feedbin');

      final second = await stream.first;
      expect(second.length, 2);
    });
  });
}
