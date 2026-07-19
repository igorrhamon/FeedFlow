import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/query_spec.dart';
import 'package:feedflow/domain/queue.dart';
import 'package:feedflow/domain/rule.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/queue_repository_drift.dart';

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
    int order = 1,
    String? iconName,
  }) =>
      Queue(
        id: id,
        name: name,
        spec: const QuerySpec(
          filter: Condition.simple(field: 'status', operator: 'equals', value: 'novo'),
          sort: [QuerySort(field: 'title')],
          limit: 50,
        ),
        order: order,
        iconName: iconName,
      );

  group('create', () {
    test('cria uma fila nova', () async {
      final queue = sampleQueue();
      await repo.create(queue);

      final retrieved = await repo.byId('q1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Sample Queue');
      expect(retrieved.spec.filter, const Condition.simple(field: 'status', operator: 'equals', value: 'novo'));
      expect(retrieved.spec.sort, [const QuerySort(field: 'title')]);
      expect(retrieved.spec.limit, 50);
    });

    test('múltiplas filas podem ser criadas', () async {
      await repo.create(sampleQueue(id: 'q1', order: 1));
      await repo.create(sampleQueue(id: 'q2', order: 2));

      final all = await repo.list();
      expect(all.length, 2);
      expect(all[0].order, 1);
      expect(all[1].order, 2);
    });

    test('iconName nulo é preservado', () async {
      await repo.create(sampleQueue());
      final retrieved = await repo.byId('q1');
      expect(retrieved!.iconName, isNull);
    });

    test('iconName não-nulo é preservado', () async {
      await repo.create(sampleQueue(iconName: 'star'));
      final retrieved = await repo.byId('q1');
      expect(retrieved!.iconName, 'star');
    });
  });

  group('update', () {
    test('atualiza uma fila existente', () async {
      final queue = sampleQueue();
      await repo.create(queue);

      final updated = queue.copyWith(name: 'Updated Name');
      await repo.update(updated);

      final retrieved = await repo.byId('q1');
      expect(retrieved!.name, 'Updated Name');
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
    test('stream retorna todas as filas em ordem', () async {
      await repo.create(sampleQueue(id: 'q2', order: 2));
      await repo.create(sampleQueue(id: 'q1', order: 1));

      final all = await repo.watchAll().first;
      expect(all.length, 2);
      expect(all[0].id, 'q1');
      expect(all[1].id, 'q2');
    });

    test('stream reativo — criação de nova fila atualiza stream', () async {
      await repo.create(sampleQueue(id: 'q1'));

      final stream = repo.watchAll();
      var count = 0;

      stream.listen((all) {
        count++;
        if (count == 1) {
          expect(all.length, 1);
          repo.create(sampleQueue(id: 'q2', order: 2));
        } else if (count == 2) {
          expect(all.length, 2);
        }
      });

      await Future.delayed(const Duration(milliseconds: 100));
    });
  });

  group('clear', () {
    test('remove todas as filas', () async {
      await repo.create(sampleQueue(id: 'q1'));
      await repo.create(sampleQueue(id: 'q2'));

      await repo.clear();

      final all = await repo.list();
      expect(all, isEmpty);
    });
  });
}
