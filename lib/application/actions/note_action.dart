import 'package:uuid/uuid.dart';

import '../../domain/article_action.dart';
import '../../domain/note.dart';
import '../../domain/repositories/knowledge_base_repository.dart';
import '../../domain/work_item.dart';

/// Ação que cria ou atualiza uma [Note] vinculada a um [WorkItem] na Knowledge Base.
class NoteAction implements ArticleAction {
  NoteAction({required KnowledgeBaseRepository knowledgeBaseRepository})
      : _kbRepository = knowledgeBaseRepository;

  final KnowledgeBaseRepository _kbRepository;
  static const _uuid = Uuid();

  @override
  String get id => 'createNote';

  @override
  String get label => 'Criar nota';

  @override
  Future<void> execute(WorkItem item, Map<String, dynamic> params) async {
    final title = params['title'] as String? ?? item.title;
    final content = params['content'] as String? ?? '';

    final note = Note(
      id: _uuid.v4(),
      documentId: _uuid.v4(),
      title: title,
      content: content,
      author: 'user',
      workItemId: item.id,
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _kbRepository.createNote(note);
  }
}
