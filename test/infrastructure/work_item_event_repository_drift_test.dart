import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_event_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift workItemRepo;
  late WorkItemEventRepositoryDrift eventRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workItemRepo = WorkItemRepositoryDrift(db);
    eventRepo = WorkItemEventRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('WorkItemEventRepositoryDrift.findSince', () {
    test('retorna vazio quando não há eventos', () async {
      final result = await eventRepo.findSince(DateTime(2000));
      expect(result, isEmpty);
    });

    test('exclui eventos anteriores a since', () async {
      final old = DateTime.now().subtract(const Duration(days: 2));
      await workItemRepo.logEvent('item-1', type: 'ruleMatched', actor: 'rule', payload: {'x': 1});
      // Insere diretamente um evento "antigo" para simular timestamp passado.
      await db.into(db.workItemEvents).insert(
            WorkItemEventsCompanion.insert(
              workItemId: 'item-old',
              timestamp: old,
              type: 'ruleMatched',
              actor: 'rule',
              payloadJson: const Value('{}'),
            ),
          );

      final result = await eventRepo.findSince(DateTime.now().subtract(const Duration(hours: 1)));

      expect(result, hasLength(1));
      expect(result.single.workItemId, 'item-1');
    });

    test('filtra por type', () async {
      await workItemRepo.logEvent('item-1', type: 'ruleMatched', actor: 'rule');
      await workItemRepo.logEvent('item-1', type: 'workflowCompleted', actor: 'rule');

      final result = await eventRepo.findSince(DateTime(2000), type: 'ruleMatched');

      expect(result, hasLength(1));
      expect(result.single.type, 'ruleMatched');
    });

    test('decodifica payload com submap aninhado', () async {
      await workItemRepo.logEvent(
        'item-1',
        type: 'ruleMatched',
        actor: 'rule',
        payload: {
          'ruleId': 'r1',
          'before': {'status': 'novo', 'isStarred': false},
          'actionIds': ['toggleStar'],
        },
      );

      final result = await eventRepo.findSince(DateTime(2000));

      expect(result.single.payload['ruleId'], 'r1');
      expect((result.single.payload['before'] as Map)['status'], 'novo');
      expect(result.single.payload['actionIds'], ['toggleStar']);
    });

    test('ordena por timestamp ascendente', () async {
      await workItemRepo.logEvent('item-a', type: 'ruleMatched', actor: 'rule');
      await Future.delayed(const Duration(milliseconds: 5));
      await workItemRepo.logEvent('item-b', type: 'ruleMatched', actor: 'rule');

      final result = await eventRepo.findSince(DateTime(2000));

      expect(result, hasLength(2));
      expect(result[0].workItemId, 'item-a');
      expect(result[1].workItemId, 'item-b');
    });
  });
}
