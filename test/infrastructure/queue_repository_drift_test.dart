import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/domain/queue.dart';
import 'package:the_old_reader/domain/query_spec.dart';
import 'package:the_old_reader/domain/rule.dart';
import 'package:the_old_reader/infrastructure/db/database.dart';
import 'package:the_old_reader/infrastructure/repositories/queue_repository_drift.dart';

void main() {
  late AppDatabase db;
  late QueueRepositoryDrift repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = QueueRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  Queue sampleQueue({
    String id = 'q1',
    String name = 'Sample Queue',
    String icon = 'inbox',
    int order = 1,
  }) =>
      Queue(
        id: id,
        name: name,
        icon: icon,
        order: order,
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

  group('create', () {
    test('cria uma fila nova', () async {
      final queue = sampleQueue();
      await repo.create(queue);

      final retrieved = await repo.byId('q1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Sample Queue');
      expect(retrieved.icon, 'inbox');
      expect(retrieved.order, 1);
    });

    test('múltiplas filas podem ser criadas', () async {
      await repo.create(sampleQueue(id: 'q1', order: 1));
      await repo.create(sampleQueue(id: 'q2', order: 2));

      final all = await repo.list();
      expect(all.length, 2);
      expect(all[0].order, 1);
      expect(all[1].order, 2);
    });
  });

  group('update', () {
    test('atualiza uma fila existente', () async {
      final queue = sampleQueue();
      await repo.create(queue);

      final updated = queue.copyWith(name: 'Updated Queue', icon: 'star');
      await repo.update(updated);

      final retrieved = await repo.byId('q1');
      expect(retrieved!.name, 'Updated Queue');
      expect(retrieved.icon, 'star');
    });

    test('atualiza lança erro se fila não existe', () async {
      final queue = sampleQueue(id: 'nonexistent');
      expect(() => repo.update(queue), throwsStateError);
    });
  });

  group('delete', () {
    test('remove uma fila', () async {
      await repo.create(sampleQueue());
      await repo.delete('q1');

      final retrieved = await repo.byId('q1');
      expect(retrieved, isNull);
    });

    test('não lança erro se fila não existe', () async {
      expect(() async => repo.delete('nonexistent'), returnsNormally);
    });
  });

  group('list', () {
    test('lista todas as filas em ordem', () async {
      await repo.create(sampleQueue(id: 'q2', order: 2));
      await repo.create(sampleQueue(id: 'q1', order: 1));
      await repo.create(sampleQueue(id: 'q3', order: 3));

      final all = await repo.list();
      expect(all.length, 3);
      expect(all[0].id, 'q1');
      expect(all[1].id, 'q2');
      expect(all[2].id, 'q3');
    });
  });

  group('watchAll', () {
    test('stream retorna todas as filas ordenadas', () async {
      await repo.create(sampleQueue(id: 'q1', order: 1));
      await repo.create(sampleQueue(id: 'q2', order: 2));
      await repo.create(sampleQueue(id: 'q3', order: 3));

      final all = await repo.watchAll().first;
      expect(all.length, 3);
      expect(all[0].id, 'q1');
      expect(all[1].id, 'q2');
      expect(all[2].id, 'q3');
    });

    test('stream reativo — criação de fila atualiza stream', () async {
      final stream = repo.watchAll();
      var count = 0;

      stream.listen((queues) {
        count++;
        if (count == 1) {
          expect(queues.length, 1);
          // Depois cria uma segunda fila
          repo.create(sampleQueue(id: 'q2', order: 2));
        } else if (count == 2) {
          expect(queues.length, 2);
        }
      });

      await repo.create(sampleQueue(id: 'q1', order: 1));

      // Aguarda dois emits
      await Future.delayed(const Duration(milliseconds: 200));
    });
  });

  group('clear', () {
    test('remove todas as filas', () async {
      await repo.create(sampleQueue(id: 'q1'));
      await repo.create(sampleQueue(id: 'q2'));

      final before = await repo.list();
      expect(before.length, 2);

      await repo.clear();

      final after = await repo.list();
      expect(after.isEmpty, true);
    });
  });

  group('querySpec serialization', () {
    test('persiste e recupera QuerySpec corretamente', () async {
      final queue = Queue(
        id: 'q1',
        name: 'Complex Filter',
        icon: 'search',
        order: 1,
        querySpec: QuerySpec(
          filter: const Condition.simple(
            field: 'title',
            operator: 'contains',
            value: 'breaking',
          ),
          sortField: 'updatedAt',
          sortDescending: true,
        ),
      );

      await repo.create(queue);
      final retrieved = await repo.byId('q1');

      expect(retrieved, isNotNull);
      expect(retrieved!.querySpec.sortField, 'updatedAt');
      expect(retrieved.querySpec.sortDescending, true);
      expect(retrieved.querySpec.filter, isA<SimpleCondition>());
      final simple = retrieved.querySpec.filter as SimpleCondition;
      expect(simple.field, 'title');
      expect(simple.operator, 'contains');
      expect(simple.value, 'breaking');
    });
  });
}
