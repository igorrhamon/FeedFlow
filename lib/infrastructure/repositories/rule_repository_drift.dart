import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/repositories/rule_repository.dart';
import '../../domain/rule.dart';
import '../db/database.dart';

class RuleRepositoryDrift implements RuleRepository {
  RuleRepositoryDrift(this._db);

  final AppDatabase _db;

  @override
  Future<Rule?> byId(String id) async {
    final row = await (_db.select(_db.rules)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> create(Rule rule) async {
    await _db.into(_db.rules).insert(_toCompanion(rule));
  }

  @override
  Future<void> update(Rule rule) async {
    final success = await _db.update(_db.rules).replace(_toCompanion(rule));
    if (!success) {
      throw StateError('Rule não encontrada para atualização: ${rule.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.rules)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Rule>> list() async {
    final rows = await (_db.select(_db.rules)..orderBy([(t) => OrderingTerm.asc(t.order)])).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<Rule>> watchEnabled() {
    final query = _db.select(_db.rules)
      ..where((t) => t.enabled.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.order)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.rules).go();
  }

  @override
  Future<void> close() async {
    await _db.close();
  }

  Rule _toDomain(RuleRow row) {
    return Rule(
      id: row.id,
      name: row.name,
      enabled: row.enabled,
      trigger: RuleTrigger.values.firstWhere(
        (t) => t.name == row.triggerType,
        orElse: () => RuleTrigger.manual,
      ),
      conditions: Condition.fromJson(jsonDecode(row.conditionsJson) as Map<String, dynamic>),
      actions: (jsonDecode(row.actionsJson) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ActionInvocation.fromJson)
          .toList(),
      stopOnMatch: row.stopOnMatch,
      order: row.order,
      intervalMinutes: row.intervalMinutes,
      lastRunAt: row.lastRunAt,
    );
  }

  RulesCompanion _toCompanion(Rule rule) {
    return RulesCompanion(
      id: Value(rule.id),
      name: Value(rule.name),
      enabled: Value(rule.enabled),
      triggerType: Value(rule.trigger.name),
      conditionsJson: Value(jsonEncode(rule.conditions.toJson())),
      actionsJson: Value(jsonEncode(rule.actions.map((a) => a.toJson()).toList())),
      stopOnMatch: Value(rule.stopOnMatch),
      order: Value(rule.order),
      intervalMinutes: Value(rule.intervalMinutes),
      lastRunAt: Value(rule.lastRunAt),
    );
  }
}
