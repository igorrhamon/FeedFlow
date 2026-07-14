import 'package:drift/native.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/enrichment_repository_drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnrichmentRepositoryDrift', () {
    late AppDatabase database;
    late EnrichmentRepositoryDrift repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = EnrichmentRepositoryDrift(database);

      // Insert a test WorkItem to reference in enrichments
      await database.into(database.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test:article1',
              providerId: 'test',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Test Article',
              ingestedAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
    });

    tearDown(() async {
      await database.close();
    });

    test('insert creates an enrichment and returns it with ID', () async {
      final enrichment = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'This is a summary.',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      final inserted = await repository.insert(enrichment);

      expect(inserted.id, isNotNull);
      expect(inserted.workItemId, 'test:article1');
      expect(inserted.type, EnrichmentType.summary);
      expect(inserted.content, 'This is a summary.');
      expect(inserted.model, 'claude-3-5-sonnet-20241022');
    });

    test('byId retrieves an enrichment by ID', () async {
      final enrichment = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'This is a summary.',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      final inserted = await repository.insert(enrichment);
      final retrieved = await repository.byId(inserted.id!);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, inserted.id);
      expect(retrieved.content, 'This is a summary.');
    });

    test('byId returns null for non-existent ID', () async {
      final retrieved = await repository.byId(999);
      expect(retrieved, isNull);
    });

    test('listByWorkItemId returns all enrichments for a work item', () async {
      final now = DateTime.now();

      final enrichment1 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'Summary 1',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: now.subtract(Duration(seconds: 1)),
      );

      final enrichment2 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.classification,
        content: 'Tech',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: now,
      );

      await repository.insert(enrichment1);
      await repository.insert(enrichment2);

      final list = await repository.listByWorkItemId('test:article1');

      expect(list, hasLength(2));
      // Should be ordered by createdAt descending
      expect(list[0].type, EnrichmentType.classification);
      expect(list[1].type, EnrichmentType.summary);
    });

    test('watchByWorkItemId emits enrichments as a stream', () async {
      final enrichment = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'This is a summary.',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      final stream = repository.watchByWorkItemId('test:article1');

      final future = stream.take(2).toList();

      // Initially empty
      await Future.delayed(Duration(milliseconds: 100));

      // Insert an enrichment
      await repository.insert(enrichment);

      final emissions = await future;

      expect(emissions[0], isEmpty);
      expect(emissions[1], hasLength(1));
      expect(emissions[1][0].content, 'This is a summary.');
    });

    test('deleteByWorkItemId removes enrichments by work item ID', () async {
      final enrichment1 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'Summary 1',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      final enrichment2 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.classification,
        content: 'Tech',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      await repository.insert(enrichment1);
      await repository.insert(enrichment2);

      final deleted = await repository.deleteByWorkItemId('test:article1');

      expect(deleted, 2);

      final remaining = await repository.listByWorkItemId('test:article1');
      expect(remaining, isEmpty);
    });

    test('deleteByWorkItemId with type filter removes only specified type',
        () async {
      final enrichment1 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.summary,
        content: 'Summary 1',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      final enrichment2 = Enrichment(
        workItemId: 'test:article1',
        type: EnrichmentType.classification,
        content: 'Tech',
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );

      await repository.insert(enrichment1);
      await repository.insert(enrichment2);

      final deleted =
          await repository.deleteByWorkItemId('test:article1', EnrichmentType.summary);

      expect(deleted, 1);

      final remaining = await repository.listByWorkItemId('test:article1');
      expect(remaining, hasLength(1));
      expect(remaining[0].type, EnrichmentType.classification);
    });
  });
}
