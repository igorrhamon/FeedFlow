import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/action_registry.dart';
import 'package:feedflow/domain/article_action.dart';
import 'package:feedflow/domain/repositories/work_item_repository.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

void main() {
  late AppDatabase db;
  late WorkItemRepository workItemRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workItemRepository = WorkItemRepositoryDrift(db);

    // Clear and register test actions
    ActionRegistry.clear();
    ActionRegistry.register(
      'complete',
      () => _TestCompleteAction(workItemRepository: workItemRepository),
    );
    ActionRegistry.register(
      'archive',
      () => _TestArchiveAction(workItemRepository: workItemRepository),
    );
    ActionRegistry.register(
      'snooze',
      () => _TestSnoozeAction(workItemRepository: workItemRepository),
    );
    ActionRegistry.register(
      'toggleStar',
      () => _TestToggleStarAction(workItemRepository: workItemRepository),
    );
    ActionRegistry.register(
      'share',
      () => _TestShareAction(),
    );
    ActionRegistry.register(
      'copyLink',
      () => _TestCopyLinkAction(),
    );
    ActionRegistry.register(
      'addTag',
      () => _TestAddTagAction(workItemRepository: workItemRepository),
    );
  });

  tearDown(() async {
    ActionRegistry.clear();
    await db.close();
  });

  group('InboxPage - Dynamic Actions', () {
    test('ActionRegistry returns all 7 registered actions', () {
      final actions = ActionRegistry.getAvailable();
      expect(actions, hasLength(7));
      expect(
        actions.map((a) => a.id).toList(),
        containsAll(['complete', 'archive', 'snooze', 'toggleStar', 'share', 'copyLink', 'addTag']),
      );
    });

    test('Each action has a label', () {
      final actions = ActionRegistry.getAvailable();
      for (final action in actions) {
        expect(action.label, isNotEmpty);
        expect(action.id, isNotEmpty);
      }
    });

    test('complete action changes status to concluido', () async {
      final item = WorkItem(
        id: 'test-item-1',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: TriageStatus.novo,
      );
      await workItemRepository.save(item);

      final completeAction = ActionRegistry.get('complete')!;
      await completeAction.execute(item, {});

      final updated = await workItemRepository.byId('test-item-1');
      expect(updated?.status, equals(TriageStatus.concluido));
    });

    test('archive action changes status to arquivado', () async {
      final item = WorkItem(
        id: 'test-item-2',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: TriageStatus.novo,
      );
      await workItemRepository.save(item);

      final archiveAction = ActionRegistry.get('archive')!;
      await archiveAction.execute(item, {});

      final updated = await workItemRepository.byId('test-item-2');
      expect(updated?.status, equals(TriageStatus.arquivado));
    });

    test('snooze action with days parameter sets snoozedUntil', () async {
      final item = WorkItem(
        id: 'test-item-3',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await workItemRepository.save(item);

      final snoozeAction = ActionRegistry.get('snooze')!;
      final beforeSnooze = DateTime.now();
      await snoozeAction.execute(item, {'days': 3});
      final afterSnooze = DateTime.now();

      final updated = await workItemRepository.byId('test-item-3');
      expect(updated?.snoozedUntil, isNotNull);
      expect(updated!.snoozedUntil!.isAfter(beforeSnooze.add(const Duration(days: 2))), true);
      expect(updated.snoozedUntil!.isBefore(afterSnooze.add(const Duration(days: 4))), true);
    });

    test('snooze action with default days=1', () async {
      final item = WorkItem(
        id: 'test-item-4',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await workItemRepository.save(item);

      final snoozeAction = ActionRegistry.get('snooze')!;
      await snoozeAction.execute(item, {});

      final updated = await workItemRepository.byId('test-item-4');
      expect(updated?.snoozedUntil, isNotNull);
    });

    test('toggleStar action toggles isStarred', () async {
      final item = WorkItem(
        id: 'test-item-5',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isStarred: false,
      );
      await workItemRepository.save(item);

      final toggleStarAction = ActionRegistry.get('toggleStar')!;
      await toggleStarAction.execute(item, {});

      var updated = await workItemRepository.byId('test-item-5');
      expect(updated?.isStarred, isTrue);

      await toggleStarAction.execute(updated!, {});
      updated = await workItemRepository.byId('test-item-5');
      expect(updated?.isStarred, isFalse);
    });

    test('addTag action adds tag to item', () async {
      final item = WorkItem(
        id: 'test-item-6',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['existing'],
      );
      await workItemRepository.save(item);

      final addTagAction = ActionRegistry.get('addTag')!;
      await addTagAction.execute(item, {'tag': 'important'});

      final updated = await workItemRepository.byId('test-item-6');
      expect(updated?.tags, containsAll(['existing', 'important']));
      expect(updated?.tags.length, equals(2));
    });

    test('addTag action is idempotent', () async {
      final item = WorkItem(
        id: 'test-item-7',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['urgent'],
      );
      await workItemRepository.save(item);

      final addTagAction = ActionRegistry.get('addTag')!;
      await addTagAction.execute(item, {'tag': 'urgent'});

      final updated = await workItemRepository.byId('test-item-7');
      expect(updated?.tags, equals(['urgent']));
      expect(updated?.tags.length, equals(1));
    });

    test('addTag action throws on empty tag', () async {
      final item = WorkItem(
        id: 'test-item-8',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await workItemRepository.save(item);

      final addTagAction = ActionRegistry.get('addTag')!;
      expect(
        () => addTagAction.execute(item, {'tag': ''}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('share action executes without error', () async {
      final item = WorkItem(
        id: 'test-item-9',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final shareAction = ActionRegistry.get('share')!;
      await shareAction.execute(item, {});
      // No-op action, just verify it doesn't crash
      expect(true, isTrue);
    });

    test('copyLink action executes without error', () async {
      final item = WorkItem(
        id: 'test-item-10',
        providerId: 'test',
        articleId: 'article',
        feedId: 'feed',
        title: 'Test Article',
        ingestedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final copyLinkAction = ActionRegistry.get('copyLink')!;
      await copyLinkAction.execute(item, {});
      // No-op action, just verify it doesn't crash
      expect(true, isTrue);
    });
  });
}

// Test action implementations
class _TestCompleteAction implements ArticleAction {
  _TestCompleteAction({required this.workItemRepository});

  final WorkItemRepository workItemRepository;

  @override
  String get id => 'complete';

  @override
  String get label => 'Concluir';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await workItemRepository.changeStatus(item.id, TriageStatus.concluido);
  }
}

class _TestArchiveAction implements ArticleAction {
  _TestArchiveAction({required this.workItemRepository});

  final WorkItemRepository workItemRepository;

  @override
  String get id => 'archive';

  @override
  String get label => 'Arquivar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await workItemRepository.changeStatus(item.id, TriageStatus.arquivado);
  }
}

class _TestSnoozeAction implements ArticleAction {
  _TestSnoozeAction({required this.workItemRepository});

  final WorkItemRepository workItemRepository;

  @override
  String get id => 'snooze';

  @override
  String get label => 'Adiar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final days = params['days'] as int? ?? 1;
    final until = DateTime.now().add(Duration(days: days));
    await workItemRepository.save(item.copyWith(snoozedUntil: until));
  }
}

class _TestToggleStarAction implements ArticleAction {
  _TestToggleStarAction({required this.workItemRepository});

  final WorkItemRepository workItemRepository;

  @override
  String get id => 'toggleStar';

  @override
  String get label => 'Estrela';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await workItemRepository.save(item.copyWith(isStarred: !item.isStarred));
  }
}

class _TestShareAction implements ArticleAction {
  @override
  String get id => 'share';

  @override
  String get label => 'Compartilhar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {}
}

class _TestCopyLinkAction implements ArticleAction {
  @override
  String get id => 'copyLink';

  @override
  String get label => 'Copiar link';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {}
}

class _TestAddTagAction implements ArticleAction {
  _TestAddTagAction({required this.workItemRepository});

  final WorkItemRepository workItemRepository;

  @override
  String get id => 'addTag';

  @override
  String get label => 'Adicionar tag';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final tag = params['tag'] as String?;
    if (tag == null || tag.isEmpty) {
      throw ArgumentError('addTag requires params[\'tag\']');
    }

    final tags = item.tags;
    if (!tags.contains(tag)) {
      final updatedTags = [...tags, tag];
      await workItemRepository.save(item.copyWith(tags: updatedTags));
    }
  }
}
