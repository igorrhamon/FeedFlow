import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/infrastructure/repositories/enrichment_repository_drift.dart';
import 'package:feedflow/infrastructure/db/database.dart';

void main() {
  group('EnrichmentRepositoryDrift', () {
    late AppDatabase database;
    late EnrichmentRepositoryDrift repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = EnrichmentRepositoryDrift(database);
    });

    tearDown(() async {
      await repository.close();
    });

    test('create inserts enrichment and can be retrieved', () async {
      final enrichment = Enrichment(
        id: 0, // Será auto-increment
        workItemId: 'test:1',
        type: EnrichmentType.summary,
        content: 'This is a summary',
        model: 'gpt-4',
        createdAt: DateTime.now(),
      );

      await repository.create(enrichment);

      final retrieved = await repository.byWorkItemId('test:1');
      expect(retrieved, isNotEmpty);
      expect(retrieved.first.workItemId, 'test:1');
      expect(retrieved.first.type, EnrichmentType.summary);
      expect(retrieved.first.content, 'This is a summary');
      expect(retrieved.first.model, 'gpt-4');
    });

    test('byWorkItemId returns empty list for non-existent item', () async {
      final retrieved = await repository.byWorkItemId('non:existent');
      expect(retrieved, isEmpty);
    });

    test('byWorkItemId returns enrichments ordered by createdAt desc', () async {
      final now = DateTime.now();
      final enrichment1 = Enrichment(
        id: 0,
        workItemId: 'test:1',
        type: EnrichmentType.summary,
        content: 'Summary 1',
        model: 'gpt-4',
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      final enrichment2 = Enrichment(
        id: 0,
        workItemId: 'test:1',
        type: EnrichmentType.translation,
        content: 'Translation',
        model: 'claude-3',
        createdAt: now,
      );

      await repository.create(enrichment1);
      await repository.create(enrichment2);

      final retrieved = await repository.byWorkItemId('test:1');
      expect(retrieved, hasLength(2));
      expect(retrieved.first.type, EnrichmentType.translation);
      expect(retrieved.last.type, EnrichmentType.summary);
    });

    test('delete removes enrichment by id', () async {
      final enrichment = Enrichment(
        id: 0,
        workItemId: 'test:1',
        type: EnrichmentType.summary,
        content: 'To delete',
        model: null,
        createdAt: DateTime.now(),
      );

      await repository.create(enrichment);
      final retrievedBefore = await repository.byWorkItemId('test:1');
      expect(retrievedBefore, hasLength(1));

      final idToDelete = retrievedBefore.first.id;
      await repository.delete(idToDelete);

      final retrievedAfter = await repository.byWorkItemId('test:1');
      expect(retrievedAfter, isEmpty);
    });

    test('clear removes all enrichments', () async {
      final enrichment1 = Enrichment(
        id: 0,
        workItemId: 'test:1',
        type: EnrichmentType.summary,
        content: 'Summary 1',
        model: null,
        createdAt: DateTime.now(),
      );

      final enrichment2 = Enrichment(
        id: 0,
        workItemId: 'test:2',
        type: EnrichmentType.translation,
        content: 'Translation',
        model: null,
        createdAt: DateTime.now(),
      );

      await repository.create(enrichment1);
      await repository.create(enrichment2);

      var allForItem1 = await repository.byWorkItemId('test:1');
      var allForItem2 = await repository.byWorkItemId('test:2');
      expect(allForItem1, hasLength(1));
      expect(allForItem2, hasLength(1));

      await repository.clear();

      allForItem1 = await repository.byWorkItemId('test:1');
      allForItem2 = await repository.byWorkItemId('test:2');
      expect(allForItem1, isEmpty);
      expect(allForItem2, isEmpty);
    });

    test('enrichment with null model is stored and retrieved', () async {
      final enrichment = Enrichment(
        id: 0,
        workItemId: 'test:1',
        type: EnrichmentType.summary,
        content: 'No model specified',
        model: null,
        createdAt: DateTime.now(),
      );

      await repository.create(enrichment);

      final retrieved = await repository.byWorkItemId('test:1');
      expect(retrieved.first.model, isNull);
    });

    test('all enrichment types are correctly stored and retrieved', () async {
      final types = EnrichmentType.values;
      final now = DateTime.now();

      for (int i = 0; i < types.length; i++) {
        final enrichment = Enrichment(
          id: 0,
          workItemId: 'test:types',
          type: types[i],
          content: 'Content for ${types[i].name}',
          model: 'test-model',
          createdAt: now.subtract(Duration(hours: i)),
        );
        await repository.create(enrichment);
      }

      final retrieved = await repository.byWorkItemId('test:types');
      expect(retrieved, hasLength(types.length));

      for (final type in types) {
        expect(
          retrieved.any((e) => e.type == type),
          isTrue,
          reason: 'Type ${type.name} should be in results',
        );
      }
    });
  });
}
