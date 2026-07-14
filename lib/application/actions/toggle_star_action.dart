import '../../domain/article_action.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../../domain/work_item.dart';

/// Ação que inverte o estado de estrela de um item (isStarred = !isStarred).
class ToggleStarAction implements ArticleAction {
  ToggleStarAction({required WorkItemRepository workItemRepository})
      : _workItemRepository = workItemRepository;

  final WorkItemRepository _workItemRepository;

  @override
  String get id => 'toggleStar';

  @override
  String get label => 'Alternar favorito';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    await _workItemRepository.save(
      item.copyWith(isStarred: !item.isStarred),
    );
  }
}
