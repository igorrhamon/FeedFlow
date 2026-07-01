import 'package:drift/drift.dart';

/// Um `WorkItem` de domínio por linha. `id` é `{providerId}:{articleId}`
/// (ver `workItemIdFor` em `lib/domain/work_item.dart`).
///
/// `@DataClassName('WorkItemRow')` evita colisão com a classe de domínio
/// `WorkItem` (Freezed) — o drift nomearia a row class `WorkItem` por
/// padrão (singular de `WorkItems`).
@DataClassName('WorkItemRow')
class WorkItems extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get articleId => text()();
  TextColumn get feedId => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get url => text().nullable()();
  DateTimeColumn get published => dateTime().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('novo'))();
  TextColumn get priority => text().withDefault(const Constant('none'))();
  /// Lista de tags serializada como JSON (`["a","b"]`).
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get ingestedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Trilha de auditoria de mudanças de um [WorkItem] — quem/o que moveu o
/// item e quando. Base para "desfazer últimas N horas de uma regra" em
/// fases futuras (motor de regras).
class WorkItemEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workItemId => text()();
  DateTimeColumn get timestamp => dateTime()();
  /// statusChanged | snoozed | snoozeExpired | actionExecuted | ruleMatched | ingested
  TextColumn get type => text()();
  /// user | rule | sync
  TextColumn get actor => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
}

/// Enriquecimentos de IA (resumo, tradução, classificação, ...) associados a
/// um [WorkItem]. Schema criado nesta fase; nada ainda o popula — ver Fase 5
/// do plano de evolução (Enricher/LLM adapters).
class Enrichments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workItemId => text()();
  /// summary | translation | classification | entities | suggestion
  TextColumn get type => text()();
  TextColumn get content => text()();
  TextColumn get model => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Fila de push de mutações read/star (Fase 2 — outbox pattern). A UI
/// aplica a mudança localmente de forma otimista; uma entrada aqui garante
/// que ela chegue ao provider remoto mesmo que a primeira tentativa falhe.
///
/// `@DataClassName('OutboxEntryRow')` evita colisão com a classe de domínio
/// `OutboxEntry` (Freezed) — mesmo motivo do `WorkItemRow` em `WorkItems`.
@DataClassName('OutboxEntryRow')
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workItemId => text()();
  TextColumn get articleId => text()();
  /// markRead | markUnread | star | unstar
  TextColumn get action => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}
