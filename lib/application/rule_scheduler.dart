import 'dart:developer' as developer;

import '../domain/repositories/rule_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';
import 'action_executor.dart';
import 'condition_evaluator.dart';

/// Executa regras de gatilho [RuleTrigger.schedule] cujo intervalo
/// configurado (`Rule.intervalMinutes`) já decorreu desde a última execução
/// (`Rule.lastRunAt`).
///
/// Não depende do `RuleEngine` — este hoje só reage a eventos de domínio
/// (`ArticleIngested`/`StatusChanged`) publicados no event bus e não é
/// instanciado em produção. `RuleScheduler` é chamado diretamente pelo ciclo
/// de background sync já existente (`BackgroundSync.run()`, ~15min via
/// WorkManager no Android), que é o único agendador periódico real do app.
/// Por isso intervalos menores que esse ciclo não são garantidos.
class RuleScheduler {
  RuleScheduler({
    required RuleRepository ruleRepository,
    required WorkItemRepository workItemRepository,
    required ActionExecutor actionExecutor,
  })  : _ruleRepository = ruleRepository,
        _workItemRepository = workItemRepository,
        _actionExecutor = actionExecutor,
        _evaluator = ConditionEvaluator();

  final RuleRepository _ruleRepository;
  final WorkItemRepository _workItemRepository;
  final ActionExecutor _actionExecutor;
  final ConditionEvaluator _evaluator;

  static const _defaultIntervalMinutes = 60;

  /// Roda todas as regras de schedule habilitadas e vencidas, executando as
  /// ações contra os itens que casarem e atualizando `lastRunAt`. Nunca
  /// lança — falha em uma regra não impede as demais.
  Future<void> runDue({DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    final rules = await _ruleRepository.list();
    final dueRules = rules.where(
      (r) => r.enabled && r.trigger == RuleTrigger.schedule && _isDue(r, effectiveNow),
    );

    for (final rule in dueRules) {
      try {
        final items = await _workItemRepository.watchByStatus(TriageStatus.values).first;
        final matched = items.where((item) => _evaluator.evaluate(rule.conditions, item));
        for (final item in matched) {
          await _actionExecutor.executeAll(item, rule.actions);
        }
        await _ruleRepository.update(rule.copyWith(lastRunAt: effectiveNow));
      } catch (e) {
        developer.log(
          'RuleScheduler: falha ao rodar regra ${rule.id}: $e',
          name: 'feedflow.rule_scheduler',
        );
      }
    }
  }

  bool _isDue(Rule rule, DateTime now) {
    final lastRun = rule.lastRunAt;
    if (lastRun == null) return true;
    final intervalMinutes = rule.intervalMinutes ?? _defaultIntervalMinutes;
    return now.difference(lastRun).inMinutes >= intervalMinutes;
  }
}
