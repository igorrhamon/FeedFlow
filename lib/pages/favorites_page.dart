import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/article.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import 'article_page.dart';

class FavoritesPage extends StatefulWidget {
  final FeedProvider provider;
  const FavoritesPage({super.key, required this.provider});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Article> _remoteArticles = [];
  bool _loadingRemote = false;
  String? _errorRemote;

  @override
  void initState() {
    super.initState();
    _loadRemoteFallback();
  }

  /// Carrega favoritos remotamente (fallback para web/kIsWeb)
  Future<void> _loadRemoteFallback() async {
    setState(() {
      _loadingRemote = true;
      _errorRemote = null;
    });
    try {
      final result = await widget.provider.getStarredArticles();
      setState(() {
        _remoteArticles = result.articles;
        _loadingRemote = false;
      });
    } catch (e) {
      setState(() {
        _errorRemote = 'Erro: $e';
        _loadingRemote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = DatabaseProvider.repository;

    // Se repo é null (web), usa fallback remoto
    if (repo == null) {
      if (_loadingRemote) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_errorRemote != null) {
        return Center(child: Text(_errorRemote!, style: const TextStyle(color: Colors.red)));
      }
      if (_remoteArticles.isEmpty) {
        return const Center(child: Text('Nenhum favorito.'));
      }
      return ListView.builder(
        itemCount: _remoteArticles.length,
        itemBuilder: (context, index) {
          final article = _remoteArticles[index];
          return ListTile(
            title: Text(article.title),
            subtitle: Text(article.author ?? ''),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArticlePage(article: article, provider: widget.provider)),
            ),
          );
        },
      );
    }

    // Caso principal: usa stream do repositório local
    return StreamBuilder<List<WorkItem>>(
      stream: repo.watchStarred(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final starredItems = snapshot.data ?? [];
        if (starredItems.isEmpty) {
          return const Center(child: Text('Nenhum favorito.'));
        }

        return ListView.builder(
          itemCount: starredItems.length,
          itemBuilder: (context, index) {
            final item = starredItems[index];
            return ListTile(
              title: Text(item.title),
              subtitle: Text(item.author ?? ''),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: item, provider: widget.provider),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
