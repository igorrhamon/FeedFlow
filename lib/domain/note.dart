import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

/// Nota Markdown vinculada a um [Document] e/ou a um [WorkItem].
/// Fonte de verdade da Knowledge Base (Onda 8).
///
/// Quando vinculada a um WorkItem, [workItemId] referencia o id
/// composto interno ({providerId}:{articleId}).  Quando standalone,
/// [workItemId] é nulo.
@freezed
class Note with _$Note {
  const Note._();

  const factory Note({
    required String id,
    required String documentId,
    required String title,
    required String content,
    String? author,
    String? workItemId,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}