import '../../domain/article_action.dart';
import '../../domain/work_item.dart';
import '../snooze_use_case.dart';

/// Ação que adia (snooze) um item por um número de dias.
/// Parâmetro `params['days']` (int, padrão 1) define o número de dias
/// a partir de agora.
class SnoozeAction implements ArticleAction {
  SnoozeAction({required SnoozeUseCase snoozeUseCase})
      : _snoozeUseCase = snoozeUseCase;

  final SnoozeUseCase _snoozeUseCase;

  @override
  String get id => 'snooze';

  @override
  String get label => 'Adiar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final days = params['days'] as int? ?? 1;
    final until = DateTime.now().add(Duration(days: days));
    await _snoozeUseCase.snooze(item, until, actor: 'rule');
  }
}
