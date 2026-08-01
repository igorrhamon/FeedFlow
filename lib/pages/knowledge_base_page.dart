import 'package:flutter/material.dart';

import '../domain/note.dart';
import '../infrastructure/db/database_provider.dart';
import 'note_editor_page.dart';

/// Página da Knowledge Base — biblioteca de notas locais e documentos ingeridos.
/// Onda 8: MVVM básico, sem refinamento de UI. Apenas exibe lista de notas.
class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({Key? key}) : super(key: key);

  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
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
        title: const Text('Knowledge Base'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: kbRepo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('Nenhuma nota criada'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content.length > 50
                    ? '${note.content.substring(0, 50)}...'
                    : note.content),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorPage(note: note),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
