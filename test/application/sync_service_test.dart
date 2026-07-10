import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/sync_service.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/outbox_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

import 'fake_feed_provider.dart';

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

  group('ingest', () {
    test('grava artigos como WorkItems novos', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1')], 'fake');
      final item = await workItems.byId('fake:a1');
      expect(item, isNotNull);
      expect(item!.status, TriageStatus.novo);
    });
  });

  group('markAsRead', () {
    test('push bem-sucedido: atualiza local e remove do outbox', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1')], 'fake');
      final provider = FakeFeedProvider();

      await sync.markAsRead(provider, 'fake', 'a1');

      final item = await workItems.byId('fake:a1');
      expect(item!.isRead, true);
      expect(provider.markAsReadCalls, ['a1']);
      expect(await outbox.pending(), isEmpty);
    });

    test('push falha por rede: atualiza local mesmo assim e MANTÉM entrada no outbox', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1')], 'fake');
      final provider = FakeFeedProvider(markAsReadThrows: true);

      await sync.markAsRead(provider, 'fake', 'a1');

      final item = await workItems.byId('fake:a1');
      expect(item!.isRead, true, reason: 'local-first: o estado local não é desfeito por falha de rede');

      final pending = await outbox.pending();
      expect(pending.length, 1);
      expect(pending.single.articleId, 'a1');
      expect(pending.single.attempts, 1);
      expect(pending.single.lastError, isNotNull);
    });

    test('WorkItem inexistente: ainda enfileira e tenta push, sem lançar', () async {
      final provider = FakeFeedProvider();
      await sync.markAsRead(provider, 'fake', 'inexistente');
      expect(provider.markAsReadCalls, ['inexistente']);
      expect(await outbox.pending(), isEmpty);
    });
  });

  group('markAsUnread', () {
    test('atualiza local e chama o provider certo', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1', isRead: true)], 'fake');
      final provider = FakeFeedProvider();

      await sync.markAsUnread(provider, 'fake', 'a1');

      final item = await workItems.byId('fake:a1');
      expect(item!.isRead, false);
      expect(provider.markAsUnreadCalls, ['a1']);
    });
  });

  group('star / unstar', () {
    test('star: atualiza local e chama starArticle', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1')], 'fake');
      final provider = FakeFeedProvider();

      await sync.star(provider, 'fake', 'a1');

      final item = await workItems.byId('fake:a1');
      expect(item!.isStarred, true);
      expect(provider.starCalls, ['a1']);
    });

    test('unstar com falha de rede: mantém local e enfileira', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1', isStarred: true)], 'fake');
      final provider = FakeFeedProvider(unstarThrows: true);

      await sync.unstar(provider, 'fake', 'a1');

      final item = await workItems.byId('fake:a1');
      expect(item!.isStarred, false);
      expect((await outbox.pending()).single.action.name, 'unstar');
    });
  });

  group('flushOutbox', () {
    test('reenvia entradas pendentes e as remove em caso de sucesso', () async {
      await sync.ingest([Article(id: 'a1', feedId: 'f1', title: 'T1')], 'fake');
      final failingProvider = FakeFeedProvider(markAsReadThrows: true);
      await sync.markAsRead(failingProvider, 'fake', 'a1');
      expect(await outbox.pending(), hasLength(1));

      final recoveredProvider = FakeFeedProvider();
      await sync.flushOutbox(recoveredProvider);

      expect(await outbox.pending(), isEmpty);
      expect(recoveredProvider.markAsReadCalls, ['a1']);
    });

    test('sem entradas pendentes não chama o provider', () async {
      final provider = FakeFeedProvider();
      await sync.flushOutbox(provider);
      expect(provider.markAsReadCalls, isEmpty);
    });
  });
}
