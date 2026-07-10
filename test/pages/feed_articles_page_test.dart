import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/sync_service.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/outbox_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

import '../application/fake_feed_provider.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift workItems;
  late OutboxRepositoryDrift outbox;
  late SyncService sync;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workItems = WorkItemRepositoryDrift(db);
    outbox = OutboxRepositoryDrift(db);
    sync = SyncService(workItemRepository: workItems, outboxRepository: outbox);
  });

  tearDown(() async {
    await db.close();
  });

  group('markAllAsRead via SyncService', () {
    test('marca todos os artigos não lidos como lidos via SyncService', () async {
      // Ingest alguns artigos, alguns lidos e alguns não
      await sync.ingest([
        Article(id: 'a1', feedId: 'f1', title: 'Artigo 1', isRead: false),
        Article(id: 'a2', feedId: 'f1', title: 'Artigo 2', isRead: true),
        Article(id: 'a3', feedId: 'f1', title: 'Artigo 3', isRead: false),
      ], 'fake');

      final provider = FakeFeedProvider();

      // Simula o comportamento de _markAllAsRead para cada artigo não lido
      final items = await workItems.watchByFeedId('f1').first;
      for (final item in items) {
        if (!item.isRead) {
          await sync.markAsRead(provider, 'fake', item.articleId);
        }
      }

      // Verifica que apenas os artigos não lidos foram marcados
      expect(provider.markAsReadCalls, {'a1', 'a3'});
      expect(provider.markAsReadCalls.length, 2);

      // Verifica que o estado local foi atualizado
      final a1 = await workItems.byId('fake:a1');
      final a2 = await workItems.byId('fake:a2');
      final a3 = await workItems.byId('fake:a3');
      expect(a1!.isRead, true);
      expect(a2!.isRead, true); // Era já lido
      expect(a3!.isRead, true);

      // Verifica que o outbox foi limpo (push bem-sucedido)
      expect(await outbox.pending(), isEmpty);
    });

    test('com falha de rede: estado local é atualizado mesmo assim', () async {
      await sync.ingest([
        Article(id: 'a1', feedId: 'f1', title: 'Artigo 1', isRead: false),
        Article(id: 'a2', feedId: 'f1', title: 'Artigo 2', isRead: false),
      ], 'fake');

      final provider = FakeFeedProvider(markAsReadThrows: true);

      // Simula _markAllAsRead com falha de rede
      final items = await workItems.watchByFeedId('f1').first;
      for (final item in items) {
        if (!item.isRead) {
          await sync.markAsRead(provider, 'fake', item.articleId);
        }
      }

      // Estado local foi atualizado (local-first)
      final a1 = await workItems.byId('fake:a1');
      final a2 = await workItems.byId('fake:a2');
      expect(a1!.isRead, true);
      expect(a2!.isRead, true);

      // Mas o outbox mantém as entradas pendentes
      final pending = await outbox.pending();
      expect(pending.length, 2);
      expect(pending.map((e) => e.articleId).toSet(), {'a1', 'a2'});
    });

    test('watchByFeedId fornece lista de artigos para marcar como lido', () async {
      await sync.ingest([
        Article(id: 'a1', feedId: 'f1', title: 'F1-1', isRead: false),
        Article(id: 'a2', feedId: 'f1', title: 'F1-2', isRead: false),
        Article(id: 'a3', feedId: 'f2', title: 'F2-1', isRead: false),
      ], 'fake');

      // watchByFeedId retorna só artigos do feed específico
      final f1Items = await workItems.watchByFeedId('f1').first;
      final f2Items = await workItems.watchByFeedId('f2').first;

      expect(f1Items.length, 2);
      expect(f2Items.length, 1);

      // Marca f1 como lido
      final provider = FakeFeedProvider();
      for (final item in f1Items) {
        if (!item.isRead) {
          await sync.markAsRead(provider, 'fake', item.articleId);
        }
      }

      // Só f1 foi marcado
      expect(provider.markAsReadCalls, {'a1', 'a2'});

      // Verifica que f2 continua não lido
      final a3 = await workItems.byId('fake:a3');
      expect(a3!.isRead, false);
    });
  });
}
