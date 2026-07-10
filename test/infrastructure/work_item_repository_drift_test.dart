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

  group('watchUnreadCountByFeed', () {
    test('conta itens não lidos por feed', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', isRead: false),
        article(id: 'a2', feedId: 'f1', isRead: true),
        article(id: 'a3', feedId: 'f1', isRead: false),
        article(id: 'a4', feedId: 'f2', isRead: false),
      ], 'feedbin');

      final count = await repo.watchUnreadCountByFeed('f1').first;
      expect(count, 2, reason: 'f1 deve ter 2 itens não lidos');

      final count2 = await repo.watchUnreadCountByFeed('f2').first;
      expect(count2, 1, reason: 'f2 deve ter 1 item não lido');
    });

    test('retorna 0 para feed sem itens não lidos', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', isRead: true),
      ], 'feedbin');

      final count = await repo.watchUnreadCountByFeed('f1').first;
      expect(count, 0);
    });

    test('retorna 0 para feed inexistente', () async {
      final count = await repo.watchUnreadCountByFeed('f-inexistente').first;
      expect(count, 0);
    });

    test('reage a mudanças de isRead via save', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', isRead: false),
      ], 'feedbin');

      final countBefore = await repo.watchUnreadCountByFeed('f1').first;
      expect(countBefore, 1);

      // Marca como lido
      final item = (await repo.byId('feedbin:a1'))!;
      await repo.save(item.copyWith(isRead: true));

      final countAfter = await repo.watchUnreadCountByFeed('f1').first;
      expect(countAfter, 0);
    });

    test('reage a mudanças de isRead via changeStatus (que não muda isRead)', () async {
      // changeStatus NÃO muda isRead, só status. Então contagem não deve mudar.
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', isRead: false),
      ], 'feedbin');

      final countBefore = await repo.watchUnreadCountByFeed('f1').first;
      expect(countBefore, 1);

      await repo.changeStatus('feedbin:a1', TriageStatus.triado);

      final countAfter = await repo.watchUnreadCountByFeed('f1').first;
      expect(countAfter, 1, reason: 'changeStatus não deve afetar isRead');
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
    test('filtra artigos por feedId', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', title: 'Artigo F1-1'),
        article(id: 'a2', feedId: 'f1', title: 'Artigo F1-2'),
        article(id: 'a3', feedId: 'f2', title: 'Artigo F2-1'),
      ], 'feedbin');

      final itemsF1 = await repo.watchByFeedId('f1').first;
      expect(itemsF1.length, 2);
      expect(itemsF1.map((i) => i.articleId).toSet(), {'a1', 'a2'});

      final itemsF2 = await repo.watchByFeedId('f2').first;
      expect(itemsF2.length, 1);
      expect(itemsF2.single.articleId, 'a3');
    });

    test('retorna lista vazia para feed sem artigos', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1'),
      ], 'feedbin');

      final items = await repo.watchByFeedId('f-inexistente').first;
      expect(items, isEmpty);
    });

    test('retorna artigos em uma ordem (teste de reatividade)', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1', title: 'Artigo 1'),
        article(id: 'a2', feedId: 'f1', title: 'Artigo 2'),
      ], 'feedbin');

      final items = await repo.watchByFeedId('f1').first;
      expect(items.length, 2);
      // Ambos os artigos devem estar presentes
      final articleIds = items.map((i) => i.articleId).toSet();
      expect(articleIds, {'a1', 'a2'});
    });

    test('reage a mudanças no banco (novo item adicionado)', () async {
      await repo.upsertFromArticles([
        article(id: 'a1', feedId: 'f1'),
      ], 'feedbin');

      final stream = repo.watchByFeedId('f1');
      final first = await stream.first;
      expect(first.length, 1);

      // Adiciona novo item
      await repo.upsertFromArticles([
        article(id: 'a2', feedId: 'f1'),
      ], 'feedbin');

      // O stream deve emitir novamente
      final second = await stream.first;
      expect(second.length, 2);
    });
  });
}
