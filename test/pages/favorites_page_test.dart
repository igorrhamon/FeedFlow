import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';
import 'package:drift/native.dart';

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

  group('FavoritesPage - streaming starred items', () {
    test('watchStarred filtra corretamente itens com isStarred true', () async {
      await repo.upsertFromArticles(
        [
          article(id: 'a1', title: 'Item Favorito 1', isStarred: true),
          article(id: 'a2', title: 'Item Normal', isStarred: false),
          article(id: 'a3', title: 'Item Favorito 2', isStarred: true),
        ],
        'testprovider',
      );

      final starred = await repo.watchStarred().first;

      expect(starred.length, 2);
      expect(starred.map((i) => i.title), containsAll(['Item Favorito 1', 'Item Favorito 2']));
      expect(starred.map((i) => i.title), isNot(contains('Item Normal')));
    });

    test('watchStarred reage corretamente a mudanças de state', () async {
      await repo.upsertFromArticles([article(id: 'a1', title: 'Teste', isStarred: false)], 'testprovider');

      // Inicialmente, sem favoritos
      var starred = await repo.watchStarred().first;
      expect(starred, isEmpty);

      // Marcar como favorito
      final item = (await repo.byId('testprovider:a1'))!;
      await repo.save(item.copyWith(isStarred: true));

      starred = await repo.watchStarred().first;
      expect(starred.length, 1);
      expect(starred.single.title, 'Teste');

      // Desmarcar como favorito
      await repo.save(item.copyWith(isStarred: false));

      starred = await repo.watchStarred().first;
      expect(starred, isEmpty);
    });

    test('watchStarred mantém ordem por data de ingestão (recentes primeiro)', () async {
      final now = DateTime.now();
      final oldItem = WorkItem(
        id: 'testprovider:old',
        providerId: 'testprovider',
        articleId: 'old',
        feedId: 'f1',
        title: 'Antigo',
        isStarred: true,
        ingestedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      );
      final newItem = WorkItem(
        id: 'testprovider:new',
        providerId: 'testprovider',
        articleId: 'new',
        feedId: 'f1',
        title: 'Recente',
        isStarred: true,
        ingestedAt: now,
        updatedAt: now,
      );

      await repo.save(oldItem);
      await repo.save(newItem);

      final starred = await repo.watchStarred().first;

      expect(starred.length, 2);
      expect(starred[0].title, 'Recente');
      expect(starred[1].title, 'Antigo');
    });
  });
}
