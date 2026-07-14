import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/domain/events/domain_event.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/event_emitting_work_item_repository.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepositoryDrift baseRepo;
  late EventEmittingWorkItemRepository decoratedRepo;
  late EventBus bus;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    baseRepo = WorkItemRepositoryDrift(db);
    bus = EventBus();
    decoratedRepo = EventEmittingWorkItemRepository(baseRepo, bus);
  });

  tearDown(() async {
    await db.close();
  });

  Article article({
    String id = 'a1',
    String feedId = 'f1',
    String title = 'Título',
  }) =>
      Article(id: id, feedId: feedId, title: title);

  group('EventEmittingWorkItemRepository', () {
    test('upsertFromArticles publica ArticleIngested', () async {
      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      expect(events.length, 1);
      expect(events.first, isA<ArticleIngested>());

      final ingestedEvent = events.first as ArticleIngested;
      expect(ingestedEvent.workItemId, 'feedbin:a1');
      expect(ingestedEvent.providerId, 'feedbin');
      expect(ingestedEvent.articleId, 'a1');
      expect(ingestedEvent.title, 'Título');
    });

    test('upsertFromArticles múltiplos artigos publica múltiplos eventos', () async {
      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      await decoratedRepo.upsertFromArticles(
        [article(id: 'a1'), article(id: 'a2'), article(id: 'a3')],
        'feedbin',
      );

      expect(events.length, 3);
      expect(events.every((e) => e is ArticleIngested), true);
    });

    test('changeStatus publica StatusChanged com ator user', () async {
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      await decoratedRepo.changeStatus('feedbin:a1', TriageStatus.triado);

      // Primeiro evento é ArticleIngested (antes de limpar events), depois StatusChanged
      final statusChangedEvents =
          events.whereType<StatusChanged>().toList();
      expect(statusChangedEvents.length, 1);

      final statusChanged = statusChangedEvents.first;
      expect(statusChanged.workItemId, 'feedbin:a1');
      expect(statusChanged.fromStatus, 'novo');
      expect(statusChanged.toStatus, 'triado');
      expect(statusChanged.actor, 'user');
    });

    test('changeStatus com transição inválida lança erro', () async {
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      // concluido só permite ir para arquivado/emAndamento (kTriageTransitions);
      // triado é destino inválido a partir daí.
      await decoratedRepo.changeStatus('feedbin:a1', TriageStatus.concluido);

      expect(
        () => decoratedRepo.changeStatus('feedbin:a1', TriageStatus.triado),
        throwsStateError,
      );
    });

    test('watchByStatus é passado através do decorator', () async {
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      final items = await decoratedRepo.watchByStatus([TriageStatus.novo]).first;
      expect(items.length, 1);
      expect(items.first.id, 'feedbin:a1');
    });

    test('byId é passado através do decorator', () async {
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      final item = await decoratedRepo.byId('feedbin:a1');
      expect(item, isNotNull);
      expect(item!.title, 'Título');
    });

    test('save não publica eventos', () async {
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');

      final events = <DomainEvent>[];
      bus.subscribe((e) => events.add(e));

      var item = await decoratedRepo.byId('feedbin:a1');
      await decoratedRepo.save(item!.copyWith(notes: 'nova nota'));

      // save não publica eventos (apenas upsertFromArticles e changeStatus fazem)
      expect(events.isEmpty, true);
    });

    test('decorator não alterar comportamento do repositório subjacente', () async {
      // Insere via decorator
      await decoratedRepo.upsertFromArticles([article(id: 'a1')], 'feedbin');
      await decoratedRepo.changeStatus('feedbin:a1', TriageStatus.triado);

      // Lê via base — dados devem estar lá
      final itemFromBase = await baseRepo.byId('feedbin:a1');
      expect(itemFromBase, isNotNull);
      expect(itemFromBase!.status, TriageStatus.triado);

      // Lê via decorator — mesmos dados
      final itemFromDecorated = await decoratedRepo.byId('feedbin:a1');
      expect(itemFromDecorated, isNotNull);
      expect(itemFromDecorated!.status, TriageStatus.triado);

      expect(itemFromBase, itemFromDecorated);
    });
  });
}
