import 'package:flutter/material.dart';

import '../domain/note.dart';
import '../infrastructure/db/database_provider.dart';

/// Página de edição de nota — básica, sem preview markdown, sem histórico visual.
/// Onda 8: MVVM básico, apenas CRUD de texto plano.
class NoteEditorPage extends StatefulWidget {
  final Note note;

  const NoteEditorPage({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kbRepo = DatabaseProvider.knowledgeBaseRepository;
    if (kbRepo == null) {
      return const Scaffold(
        body: Center(
          child: Text('Knowledge Base não disponível nesta plataforma'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final updatedNote = widget.note.copyWith(
                title: _titleController.text,
                content: _contentController.text,
                updatedAt: DateTime.now(),
              );
              await kbRepo.updateNote(updatedNote);
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título da nota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Conteúdo (Markdown)',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
