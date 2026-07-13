import 'package:flutter/material.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/feed_provider.dart';
import 'article_page.dart';

class FavoritesPage extends StatefulWidget {
  final FeedProvider provider;
  const FavoritesPage({super.key, required this.provider});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> _favoriteItems = [];
  bool _loadingRemote = true;
  String? _remoteError;

  @override
  void initState() {
    super.initState();
    // Se não temos repositório local (web), carregamos do provider remoto
    if (DatabaseProvider.repository == null) {
      _loadRemoteFavorites();
    }
  }

  Future<void> _loadRemoteFavorites() async {
    setState(() {
      _loadingRemote = true;
      _remoteError = null;
    });
    try {
      final result = await widget.provider.getStarredArticles();
      setState(() {
        _favoriteItems = result.articles;
        _loadingRemote = false;
      });
    } catch (e) {
      setState(() {
        _remoteError = 'Erro: $e';
        _loadingRemote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = DatabaseProvider.repository;

    // Se temos repositório local, usar stream reativo
    if (repository != null) {
      return StreamBuilder<List<WorkItem>>(
        stream: repository.watchStarred(),
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

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum favorito.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
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

    // Fallback para web: usar dados remotos
    if (_loadingRemote) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_remoteError != null) {
      return Center(child: Text(_remoteError!, style: const TextStyle(color: Colors.red)));
    }
    if (_favoriteItems.isEmpty) {
      return const Center(child: Text('Nenhum favorito.'));
    }
    return ListView.builder(
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final article = _favoriteItems[index];
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
}
