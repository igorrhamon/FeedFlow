import '../note.dart';

/// Porta para o Knowledge Base (Onda 8). CRUD de [Note] e
/// gestão do histórico de versões + anexos de arquivo.
abstract class KnowledgeBaseRepository {
  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(String noteId);
  Future<Note?> byId(String noteId);
  Stream<List<Note>> watchAll();
  Stream<List<Note>> watchByWorkItem(String workItemId);
  Stream<List<Note>> search(String query);
  Future<List<Note>> history(String documentId);
  Future<void> attachFile(String documentId, String filePath, String fileName);
  Future<void> close();
}