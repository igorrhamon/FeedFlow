import '../../domain/article_action.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../../domain/triage_status.dart';
import '../../domain/work_item.dart';

/// Ação que arquiva um item (status = [TriageStatus.arquivado]).
class ArchiveAction implements ArticleAction {
  ArchiveAction({required WorkItemRepository workItemRepository})
      : _workItemRepository = workItemRepository;

  final WorkItemRepository _workItemRepository;

  @override
  String get id => 'archive';

  @override
  String get label => 'Arquivar';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await _workItemRepository.changeStatus(item.id, TriageStatus.arquivado);
  }
}
