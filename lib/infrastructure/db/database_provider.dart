import 'package:flutter/foundation.dart';

import '../../application/event_bus.dart';
import '../../application/sync_service.dart';
import '../../domain/repositories/outbox_repository.dart';
import '../../domain/repositories/rule_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../repositories/event_emitting_work_item_repository.dart';
import '../repositories/outbox_repository_drift.dart';
import '../repositories/rule_repository_drift.dart';
import '../repositories/search_repository_drift.dart';
import '../repositories/work_item_repository_drift.dart';
import 'database.dart';

/// Acesso lazy ao banco local / repositórios / [SyncService]. Sem web/WASM
/// nesta fase (ver `AppDatabase`) — em `kIsWeb`, todos os getters retornam
/// `null` e chamadas de sync/shadow-write viram no-op, sem quebrar a build
/// web.
class DatabaseProvider {
  DatabaseProvider._();

  static AppDatabase? _database;
  static WorkItemRepository? _workItemRepository;
  static OutboxRepository? _outboxRepository;
  static SearchRepository? _searchRepository;
  static RuleRepository? _ruleRepository;
  static SyncService? _syncService;

  static WorkItemRepository? get repository {
    if (kIsWeb) return null;
    _database ??= AppDatabase();
    return _workItemRepository ??= EventEmittingWorkItemRepository(
      WorkItemRepositoryDrift(_database!),
      eventBus,
    );
  }

  static OutboxRepository? get outboxRepository {
    if (kIsWeb) return null;
    _database ??= AppDatabase();
    return _outboxRepository ??= OutboxRepositoryDrift(_database!);
  }

  static SearchRepository? get searchRepository {
    if (kIsWeb) return null;
    _database ??= AppDatabase();
    return _searchRepository ??= SearchRepositoryDrift(_database!);
  }

  static RuleRepository? get ruleRepository {
    if (kIsWeb) return null;
    _database ??= AppDatabase();
    return _ruleRepository ??= RuleRepositoryDrift(_database!);
  }

  static SyncService? get syncService {
    final workItems = repository;
    final outbox = outboxRepository;
    if (workItems == null || outbox == null) return null;
    return _syncService ??= SyncService(workItemRepository: workItems, outboxRepository: outbox);
  }
}
