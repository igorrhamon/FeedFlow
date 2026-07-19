import '../../domain/article_action.dart';
import '../../domain/repositories/work_item_repository.dart';
import '../../domain/work_item.dart';

/// Ação que adiciona uma tag a um item.
/// Parâmetro `params['tag']` (String, obrigatório) é a tag a ser adicionada.
/// Se a tag já existir no item, não faz nada (idempotente).
class AddTagAction implements ArticleAction {
  AddTagAction({required WorkItemRepository workItemRepository})
      : _workItemRepository = workItemRepository;

  final WorkItemRepository _workItemRepository;

  @override
  String get id => 'addTag';

  @override
  String get label => 'Adicionar tag';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final tag = params['tag'] as String?;
    if (tag == null || tag.isEmpty) {
      throw ArgumentError('addTag requires params[\'tag\'] (non-empty String)');
    }

    // Idempotência: só adiciona se a tag não existir
    final tags = item.tags;
    if (!tags.contains(tag)) {
      final updatedTags = [...tags, tag];
      await _workItemRepository.save(item.copyWith(tags: updatedTags));
    }
  }
}
