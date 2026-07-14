import '../../domain/article_action.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../../domain/triage_status.dart';
import '../../domain/work_item.dart';

/// Ação que marca um item como concluído (status = [TriageStatus.concluido]).
class CompleteAction implements ArticleAction {
  CompleteAction({required WorkItemRepository workItemRepository})
      : _workItemRepository = workItemRepository;

  final WorkItemRepository _workItemRepository;

  @override
  String get id => 'complete';

  @override
  String get label => 'Marcar como concluído';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await _workItemRepository.changeStatus(item.id, TriageStatus.concluido);
  }
}
