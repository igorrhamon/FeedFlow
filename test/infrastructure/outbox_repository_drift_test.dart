import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/outbox_entry.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/outbox_repository_drift.dart';

void main() {
  late AppDatabase db;
  late OutboxRepositoryDrift repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = OutboxRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('enqueue / pending', () {
    test('enfileira e lista em ordem de criação', () async {
      final id1 = await repo.enqueue(workItemId: 'p:a1', articleId: 'a1', action: OutboxAction.markRead);
      final id2 = await repo.enqueue(workItemId: 'p:a2', articleId: 'a2', action: OutboxAction.star);

      final pending = await repo.pending();

      expect(pending.length, 2);
      expect(pending[0].id, id1);
      expect(pending[0].action, OutboxAction.markRead);
      expect(pending[0].attempts, 0);
      expect(pending[1].id, id2);
      expect(pending[1].action, OutboxAction.star);
    });

    test('lista vazia quando não há entradas', () async {
      expect(await repo.pending(), isEmpty);
    });
  });

  group('remove', () {
    test('remove uma entrada existente', () async {
      final id = await repo.enqueue(workItemId: 'p:a1', articleId: 'a1', action: OutboxAction.unstar);
      await repo.remove(id);
      expect(await repo.pending(), isEmpty);
    });
  });

  group('recordFailure', () {
    test('incrementa attempts e grava lastError sem remover a entrada', () async {
      final id = await repo.enqueue(workItemId: 'p:a1', articleId: 'a1', action: OutboxAction.markUnread);

      await repo.recordFailure(id, 'timeout');
      await repo.recordFailure(id, 'timeout de novo');

      final pending = await repo.pending();
      expect(pending.single.attempts, 2);
      expect(pending.single.lastError, 'timeout de novo');
    });

    test('id inexistente não lança erro', () async {
      await repo.recordFailure(999, 'erro');
      expect(await repo.pending(), isEmpty);
    });
  });
}
