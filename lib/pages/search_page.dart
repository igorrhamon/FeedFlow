import 'dart:convert';

import 'package:flutter/material.dart';
import '../domain/document.dart';
import '../domain/note.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/feed_provider.dart';
import '../models/article.dart';
import 'article_page.dart';
import 'note_editor_page.dart';

class SearchPage extends StatefulWidget {
  final FeedProvider provider;
  const SearchPage({super.key, required this.provider});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<Article> _remoteResults = [];
  List<WorkItem> _localResults = [];
  List<Document> _documentResults = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
    });

    try {
      // Busca local no FTS5 (WorkItems)
      final localRepo = DatabaseProvider.searchRepository;
      final localFuture = localRepo != null
          ? localRepo.search(q, limit: 50)
          : Future.value(<WorkItem>[]);

      // Busca local de Documents (notas/Onda 8)
      final documentsFuture = localRepo != null
          ? localRepo.searchDocuments(q, limit: 50)
          : Future.value(<Document>[]);

      // Busca remota no provider
      final remoteFuture = widget.provider.search(q);

      // Aguarda todas em paralelo
      final results = await Future.wait([localFuture, documentsFuture, remoteFuture]);
      final local = results[0] as List<WorkItem>;
      final documents = results[1] as List<Document>;
      final remote = results[2] as ArticleListResult;

      setState(() {
        _localResults = local;
        _documentResults = documents;
        _remoteResults = remote.articles;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na busca: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_searched && _localResults.isEmpty && _documentResults.isEmpty && _remoteResults.isEmpty) {
      body = const Center(child: Text('Nenhum resultado encontrado.'));
    } else {
      final items = <_SearchResultItem>[];

      // Adiciona seção de resultados locais (artigos)
      if (_localResults.isNotEmpty) {
        items.add(_SearchResultItem.header('Artigos Locais (${_localResults.length})'));
        items.addAll(_localResults.map((item) => _SearchResultItem.localWorkItem(item)));
      }

      // Adiciona seção de notas (Onda 8)
      if (_documentResults.isNotEmpty) {
        items.add(_SearchResultItem.header('Notas (${_documentResults.length})'));
        items.addAll(_documentResults.map((doc) => _SearchResultItem.document(doc)));
      }

      // Adiciona seção de resultados remotos
      if (_remoteResults.isNotEmpty) {
        items.add(_SearchResultItem.header('Resultados Remotos (${_remoteResults.length})'));
        items.addAll(_remoteResults.map((article) => _SearchResultItem.remoteArticle(article)));
      }

      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          if (item.isHeader) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                item.headerText!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }

          if (item.localWorkItem != null) {
            final work = item.localWorkItem!;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  work.title.isNotEmpty ? work.title : 'Sem título',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: work.author != null
                    ? Text(work.author!)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticlePage(article: _workItemToArticle(work), provider: widget.provider),
                  ),
                ),
              ),
            );
          }

          if (item.document != null) {
            final doc = item.document!;
            // Converter Document para Note para exibir em NoteEditorPage
            final note = _documentToNote(doc);
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  doc.title.isNotEmpty ? doc.title : 'Sem título',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: doc.author != null
                    ? Text(doc.author!)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteEditorPage(note: note),
                  ),
                ),
              ),
            );
          }

          // remoteArticle
          final article = item.remoteArticle!;
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                article.title.isNotEmpty ? article.title : 'Sem título',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: (article.author?.isNotEmpty == true) ? Text(article.author!) : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article, provider: widget.provider),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar artigos...',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: body,
    );
  }
}

/// Converte um [WorkItem] em um [Article] para renderização em [ArticlePage].
Article _workItemToArticle(WorkItem item) {
  return Article(
    id: item.articleId,
    feedId: item.feedId,
    title: item.title,
    author: item.author,
    summary: item.summary,
    content: item.content,
    url: item.url,
    published: item.published,
    updated: item.updated,
    categories: item.tags,
    isRead: item.isRead,
    isStarred: item.isStarred,
  );
}

/// Converte um [Document] (resultado de busca de notas) em um [Note] para [NoteEditorPage].
Note _documentToNote(Document doc) {
  final metadata = doc.metadataJson != null
      ? (jsonDecode(doc.metadataJson!) as Map<String, dynamic>)
      : <String, dynamic>{};
  return Note(
    id: doc.id,
    documentId: doc.id,
    title: doc.title,
    content: doc.rawContent ?? '',
    author: doc.author,
    workItemId: metadata['workItemId'] as String?,
    tags: (metadata['tags'] as List?)?.cast<String>() ?? [],
    createdAt: doc.capturedAt,
    updatedAt: doc.capturedAt,
  );
}

/// Classe auxiliar para representar itens de resultado (header, local, documento ou remoto)
class _SearchResultItem {
  final String? headerText;
  final WorkItem? localWorkItem;
  final Document? document;
  final Article? remoteArticle;

  _SearchResultItem({
    this.headerText,
    this.localWorkItem,
    this.document,
    this.remoteArticle,
  });

  factory _SearchResultItem.header(String text) =>
      _SearchResultItem(headerText: text);

  factory _SearchResultItem.localWorkItem(WorkItem item) =>
      _SearchResultItem(localWorkItem: item);

  factory _SearchResultItem.document(Document doc) =>
      _SearchResultItem(document: doc);

  factory _SearchResultItem.remoteArticle(Article article) =>
      _SearchResultItem(remoteArticle: article);

  bool get isHeader => headerText != null;
}
