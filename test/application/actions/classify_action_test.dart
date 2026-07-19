import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/classify_action.dart';
import 'package:feedflow/domain/enricher.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/domain/repositories/enrichment_repository.dart';
import 'package:feedflow/domain/work_item.dart';

class _FakeEnricher implements Enricher {
  EnrichmentRequest? lastRequest;

  @override
  String get id => 'fake-enricher';

  @override
  Set<EnrichmentType> get capabilities => EnrichmentType.values.toSet();

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req) async {
    lastRequest = req;
    return Enrichment(
      workItemId: item.id,
      type: req.type,
      content: 'tecnologia, testes',
      createdAt: DateTime.now(),
    );
  }
}

class _FakeEnrichmentRepository implements EnrichmentRepository {
  final List<Enrichment> inserted = [];

  @override
  Future<Enrichment> insert(Enrichment enrichment) async {
    final saved = enrichment.copyWith(id: inserted.length + 1);
    inserted.add(saved);
    return saved;
  }

  @override
  Future<Enrichment?> byId(int id) async {
    final matches = inserted.where((e) => e.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<Enrichment>> listByWorkItemId(String workItemId) async =>
      inserted.where((e) => e.workItemId == workItemId).toList();

  @override
  Stream<List<Enrichment>> watchByWorkItemId(String workItemId) =>
      Stream.value(inserted.where((e) => e.workItemId == workItemId).toList());

  @override
  Future<int> deleteByWorkItemId(String workItemId,
      [EnrichmentType? type]) async {
    final before = inserted.length;
    inserted.removeWhere((e) =>
        e.workItemId == workItemId && (type == null || e.type == type));
    return before - inserted.length;
  }

  @override
  Future<void> close() async {}
}

void main() {
  late _FakeEnricher enricher;
  late _FakeEnrichmentRepository repository;
  late ClassifyAction action;

  final item = WorkItem(
    id: 'test-item-1',
    providerId: 'test-provider',
    articleId: 'article-1',
    feedId: 'feed-1',
    title: 'Test Article',
    content: 'Some content to classify.',
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    enricher = _FakeEnricher();
    repository = _FakeEnrichmentRepository();
    action = ClassifyAction(
      enricher: enricher,
      enrichmentRepository: repository,
    );
  });

  group('ClassifyAction', () {
    test('has correct id and label', () {
      expect(action.id, equals('classify'));
      expect(action.label, isNotEmpty);
    });

    test('calls enricher with EnrichmentType.classification and persists',
        () async {
      await action.execute(item, {});

      expect(enricher.lastRequest?.type, EnrichmentType.classification);
      expect(repository.inserted, hasLength(1));
      expect(repository.inserted.first.content, 'tecnologia, testes');
    });
  });
}
