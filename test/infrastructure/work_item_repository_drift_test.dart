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

  group('watchUnreadCountsByFeed', () {
    test('agrupa não lidos por feedId', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', feedId: 'f1', isRead: false),
          article(id: 'a2', feedId: 'f1', isRead: false),
          article(id: 'a3', feedId: 'f2', isRead: false),
          article(id: 'a4', feedId: 'f2', isRead: true), // lido — não conta
        ],
        'feedbin',
      );

      final counts = await repo.watchUnreadCountsByFeed().first;

      expect(counts['f1'], 2);
      expect(counts['f2'], 1);
      expect(counts['f3'], isNull);
    });

    test('reage a mudanças de isRead', () async {
      await repo.upsertFromArticles([article(id: 'a1', feedId: 'f1', isRead: false)], 'feedbin');

      // Primeiro snapshot: 1 não lido
      var counts = await repo.watchUnreadCountsByFeed().first;
      expect(counts['f1'], 1);

      // Marca como lido via upsert
      await repo.upsertFromArticles([article(id: 'a1', feedId: 'f1', isRead: true)], 'feedbin');

      // Segundo snapshot: 0 não lidos
      counts = await repo.watchUnreadCountsByFeed().first;
      expect(counts['f1'], isNull); // feed desaparece do mapa se não tem não lidos
    });

    test('múltiplos feeds misturados', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', feedId: 'feed-tech', isRead: false),
          article(id: 'a2', feedId: 'feed-tech', isRead: false),
          article(id: 'a3', feedId: 'feed-tech', isRead: true),
          article(id: 'a4', feedId: 'feed-news', isRead: false),
          article(id: 'a5', feedId: 'feed-news', isRead: false),
          article(id: 'a6', feedId: 'feed-news', isRead: false),
          article(id: 'a7', feedId: 'feed-sport', isRead: true),
        ],
        'feedbin',
      );

      final counts = await repo.watchUnreadCountsByFeed().first;

      expect(counts['feed-tech'], 2);
      expect(counts['feed-news'], 3);
      expect(counts['feed-sport'], isNull); // todos lidos
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

  group('watchStarred', () {
    test('retorna apenas itens com isStarred == true', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', isStarred: true),
          article(id: 'a2', isStarred: false),
          article(id: 'a3', isStarred: true),
        ],
        'feedbin',
      );

      final starred = await repo.watchStarred().first;
      expect(starred.length, 2);
      expect(starred.map((s) => s.articleId), containsAll(['a1', 'a3']));
    });

    test('reage a mudanças de isStarred', () async {
      await repo.upsertFromArticles([article(id: 'a1', isStarred: false)], 'feedbin');
      var starred = await repo.watchStarred().first;
      expect(starred, isEmpty);

      // Marcar como favorito
      final item = (await repo.byId('feedbin:a1'))!;
      await repo.save(item.copyWith(isStarred: true));
      starred = await repo.watchStarred().first;
      expect(starred.length, 1);
      expect(starred.single.articleId, 'a1');

      // Desmarcar como favorito
      await repo.save(item.copyWith(isStarred: false));
      starred = await repo.watchStarred().first;
      expect(starred, isEmpty);
    });

    test('ordena por data de ingestão (mais recentes primeiro)', () async {
      final now = DateTime.now();
      final item1 = WorkItem(
        id: 'feedbin:old',
        providerId: 'feedbin',
        articleId: 'old',
        feedId: 'f1',
        title: 'Antigo',
        isStarred: true,
        ingestedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      );
      final item2 = WorkItem(
        id: 'feedbin:new',
        providerId: 'feedbin',
        articleId: 'new',
        feedId: 'f1',
        title: 'Recente',
        isStarred: true,
        ingestedAt: now,
        updatedAt: now,
      );

      await repo.save(item1);
      await repo.save(item2);

      final starred = await repo.watchStarred().first;
      expect(starred.length, 2);
      expect(starred[0].articleId, 'new', reason: 'item mais recente deve vir primeiro');
      expect(starred[1].articleId, 'old');
    });

    test('lista vazia se nenhum item marcado como favorito', () async {
      await repo.upsertFromArticles(
        [article(id: 'a1', isStarred: false), article(id: 'a2', isStarred: false)],
        'feedbin',
      );

      final starred = await repo.watchStarred().first;
      expect(starred, isEmpty);
    });
  });
}
