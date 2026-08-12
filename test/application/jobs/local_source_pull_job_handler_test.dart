import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/jobs/local_source_pull_job_handler.dart';
import 'package:feedflow/application/source_connector_registry.dart';
import 'package:feedflow/application/sync_service.dart';
import 'package:feedflow/domain/document.dart';
import 'package:feedflow/domain/job.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/domain/repositories/local_source_config_repository.dart';
import 'package:feedflow/domain/source_connector.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/document_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/outbox_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';

class _FakeLocalSourceConfigRepository implements LocalSourceConfigRepository {
  final Map<String, LocalSourceConfig> _store = {};
  final List<MapEntry<String, DateTime>> lastSyncCalls = [];

  void seed(LocalSourceConfig config) => _store[config.id] = config;

  @override
  Future<void> save(LocalSourceConfig config) async => _store[config.id] = config;

  @override
  Future<LocalSourceConfig?> byId(String id) async => _store[id];

  @override
  Stream<List<LocalSourceConfig>> watchAll() => Stream.value(_store.values.toList());

  @override
  Future<void> delete(String id) async => _store.remove(id);

  @override
  Future<void> updateLastSync(String id, DateTime syncedAt) async {
    lastSyncCalls.add(MapEntry(id, syncedAt));
    final existing = _store[id];
    if (existing != null) _store[id] = existing.copyWith(lastSyncAt: syncedAt);
  }

  @override
  Future<void> close() async {}
}

class _FakeSourceConnector implements SourceConnector {
  _FakeSourceConnector({required this.documents});

  final List<Document> documents;
  DateTime? receivedSince;
  bool closed = false;

  @override
  String get id => 'fake:connector';

  @override
  Future<List<Document>> pull({DateTime? since}) async {
    receivedSince = since;
    return documents;
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}

Document _document(String id) => Document(
      id: id,
      sourceConnectorId: 'fake:connector',
      sourceId: id,
      contentType: 'text/plain',
      title: 'Doc $id',
      rawContent: 'conteúdo',
      capturedAt: DateTime(2026, 1, 1),
    );

LocalSourceConfig _config({
  String id = 'src1',
  bool enabled = true,
  DateTime? lastSyncAt,
}) =>
    LocalSourceConfig(
      id: id,
      type: LocalSourceType.folder,
      path: '/tmp/notas',
      label: 'Notas',
      enabled: enabled,
      lastSyncAt: lastSyncAt,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late AppDatabase db;
  late SyncService syncService;
  late _FakeLocalSourceConfigRepository configRepository;
  late LocalSourcePullJobHandler handler;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncService = SyncService(
      workItemRepository: WorkItemRepositoryDrift(db),
      outboxRepository: OutboxRepositoryDrift(db),
      documentRepository: DocumentRepositoryDrift(db),
    );
    configRepository = _FakeLocalSourceConfigRepository();
    handler = LocalSourcePullJobHandler(
      configRepository: configRepository,
      syncService: syncService,
    );
    SourceConnectorRegistry.clear();
  });

  tearDown(() async {
    SourceConnectorRegistry.clear();
    await db.close();
  });

  Job jobFor(String configId) => Job(
        id: 'job1',
        type: 'local_source_pull',
        payload: {'sourceConfigId': configId},
        nextRunAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

  group('LocalSourcePullJobHandler', () {
    test('jobType returns "local_source_pull"', () {
      expect(handler.jobType, equals('local_source_pull'));
    });

    test('run() pulls documents via the registered connector, ingests them, and updates lastSyncAt', () async {
      final connector = _FakeSourceConnector(documents: [_document('d1'), _document('d2')]);
      SourceConnectorRegistry.register('folder', (config) => connector);

      final config = _config();
      configRepository.seed(config);

      await handler.run(jobFor(config.id));

      expect(connector.closed, isTrue);
      expect(configRepository.lastSyncCalls, hasLength(1));
      expect(configRepository.lastSyncCalls.single.key, equals(config.id));

      final stored = await DocumentRepositoryDrift(db).byId('d1');
      expect(stored, isNotNull);
    });

    test('run() passes config.lastSyncAt as since to the connector', () async {
      final since = DateTime(2026, 1, 1);
      final connector = _FakeSourceConnector(documents: []);
      SourceConnectorRegistry.register('folder', (config) => connector);

      final config = _config(lastSyncAt: since);
      configRepository.seed(config);

      await handler.run(jobFor(config.id));

      expect(connector.receivedSince, equals(since));
    });

    test('run() is a no-op when config does not exist', () async {
      await handler.run(jobFor('missing'));
      expect(configRepository.lastSyncCalls, isEmpty);
    });

    test('run() is a no-op when config is disabled', () async {
      final connector = _FakeSourceConnector(documents: []);
      SourceConnectorRegistry.register('folder', (config) => connector);

      final config = _config(enabled: false);
      configRepository.seed(config);

      await handler.run(jobFor(config.id));

      expect(configRepository.lastSyncCalls, isEmpty);
      expect(connector.closed, isFalse);
    });

    test('run() throws when no connector is registered for the type', () async {
      final config = _config();
      configRepository.seed(config);

      expect(() => handler.run(jobFor(config.id)), throwsStateError);
    });
  });
}
