import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import '../models/article.dart';
import '../services/app_settings.dart';
import 'article_page.dart';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _cardBg = Color(0xFF1C1C1E);

enum ArticleFilter { all, unreadOnly, readOnly }

class FeedArticlesPage extends StatefulWidget {
  final FeedProvider provider;
  final Feed feed;
  const FeedArticlesPage({super.key, required this.provider, required this.feed});

  @override
  State<FeedArticlesPage> createState() => _FeedArticlesPageState();
}

class _FeedArticlesPageState extends State<FeedArticlesPage>
    with TickerProviderStateMixin {
  final List<Article> articles = [];
  final ScrollController _scrollController = ScrollController();
  String? _continuation;
  bool _loadingMore = false;
  String? error;
  bool loading = true;
  Set<String> favoriteIds = {};
  late final AnimationController _staggerCtrl;
  late final Animation<double> _staggerAnim;
  bool _markReadOnScroll = false;
  ArticleFilter _filter = ArticleFilter.all;
  final Map<String, GlobalKey> _itemKeys = {};
  final Set<String> _seenArticleIds = {};
  final Set<String> _pendingMarkRead = {};
  double _lastScrollPixels = 0;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _staggerAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _loadArticles();
    _loadFavorites();
    _loadSettings();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadSettings() async {
    final markReadOnScroll = await AppSettings.getMarkReadOnScroll();
    if (mounted) {
      setState(() => _markReadOnScroll = markReadOnScroll);
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _scrollController.dispose();
    _itemKeys.clear();
    _seenArticleIds.clear();
    _pendingMarkRead.clear();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _continuation != null) {
      _loadMore();
    }

    if (_markReadOnScroll) {
      _updateSeenArticles();
      final currentPixels = _scrollController.position.pixels;
      if (currentPixels > _lastScrollPixels) {
        _markScrolledPastArticles();
      }
      _lastScrollPixels = currentPixels;
    }
  }

  void _updateSeenArticles() {
    for (final entry in _itemKeys.entries) {
      if (entry.value.currentContext != null) {
        _seenArticleIds.add(entry.key);
      }
    }
  }

  void _markScrolledPastArticles() {
    for (final articleId in _seenArticleIds) {
      final key = _itemKeys[articleId];
      if (key?.currentContext == null && !_pendingMarkRead.contains(articleId)) {
        final index = articles.indexWhere((a) => a.id == articleId);
        if (index != -1 && !articles[index].isRead) {
          _pendingMarkRead.add(articleId);
          setState(() {
            articles[index] = articles[index].copyWith(isRead: true);
          });
          _markAsReadWithRollback(articleId);
        }
      }
    }
  }

  Future<void> _markAsReadWithRollback(String articleId) async {
    try {
      await widget.provider.markAsRead(articleId);
    } catch (_) {
      if (!mounted) return;
      final idx = articles.indexWhere((a) => a.id == articleId);
      setState(() {
        if (idx != -1) articles[idx] = articles[idx].copyWith(isRead: false);
        _pendingMarkRead.remove(articleId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao marcar artigo como lido.')),
      );
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.provider.getArticles(
        streamId: widget.feed.id,
        limit: 20,
        excludeRead: _filter == ArticleFilter.unreadOnly,
        includeOnlyRead: _filter == ArticleFilter.readOnly,
      );
      setState(() {
        articles..clear()..addAll(result.articles);
        _continuation = result.continuation;
        loading = false;
      });
      _staggerCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _continuation == null) return;
    setState(() => _loadingMore = true);
    try {
      final result = await widget.provider.getArticles(
        streamId: widget.feed.id,
        limit: 20,
        continuation: _continuation,
        excludeRead: _filter == ArticleFilter.unreadOnly,
        includeOnlyRead: _filter == ArticleFilter.readOnly,
      );
      setState(() {
        articles.addAll(result.articles);
        _continuation = result.continuation;
      });
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final result = await widget.provider.getStarredArticles();
      setState(() => favoriteIds = result.articles.map((a) => a.id).toSet());
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String articleId) async {
    final isFav = favoriteIds.contains(articleId);
    if (isFav) {
      await widget.provider.unstarArticle(articleId);
      setState(() => favoriteIds.remove(articleId));
    } else {
      await widget.provider.starArticle(articleId);
      setState(() => favoriteIds.add(articleId));
    }
  }

  Future<void> _markAllAsRead() async {
    await widget.provider.markAllAsRead(widget.feed.id);
    setState(() {
      for (final article in articles) {
        if (!article.isRead) {
          final idx = articles.indexOf(article);
          articles[idx] = article.copyWith(isRead: true);
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os artigos marcados como lidos.')),
      );
    }
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticlePage(article: article, provider: widget.provider),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _setFilter(ArticleFilter filter) {
    setState(() {
      _filter = filter;
      articles.clear();
      _continuation = null;
    });
    _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Center(child: CircularProgressIndicator(color: _accent));
    } else if (error != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _accent, size: 48),
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadArticles,
              child: const Text('Tentar novamente', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
    } else if (articles.isEmpty) {
      content = const Center(
        child: Text('Nenhum artigo encontrado.', style: TextStyle(color: _textSecondary)),
      );
    } else {
      content = ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _accent),
              ),
            );
          }
          final article = articles[index];
          final isFav = favoriteIds.contains(article.id);
          final isRead = article.isRead;

          final delay = (index * 0.05).clamp(0.0, 0.7);
          final itemKey = _itemKeys.putIfAbsent(article.id, () => GlobalKey());

          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _staggerAnim,
                curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _staggerAnim,
                  curve: Interval(delay, delay + 0.3, curve: Curves.easeOutCubic),
                ),
              ),
              child: InkWell(
                onTap: () => _openArticle(context, article),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  key: itemKey,
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isRead ? 0 : 1,
                        child: Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'article_title_${article.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  article.title.isNotEmpty ? article.title : 'Sem título',
                                  style: TextStyle(
                                    color: isRead ? _textSecondary : _textPrimary,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (article.author?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                article.author!,
                                style: const TextStyle(color: _textSecondary, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _AnimatedFavoriteButton(
                        isFav: isFav,
                        onPressed: () => _toggleFavorite(article.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: Text(
          widget.feed.title,
          style: const TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filter == ArticleFilter.unreadOnly
                  ? Icons.mark_email_unread
                  : _filter == ArticleFilter.readOnly
                      ? Icons.mark_email_read
                      : Icons.filter_list,
              color: _filter == ArticleFilter.unreadOnly
                  ? Theme.of(context).colorScheme.primary
                  : _filter == ArticleFilter.readOnly
                      ? Theme.of(context).colorScheme.secondary
                      : _textPrimary,
            ),
            tooltip: _filter == ArticleFilter.unreadOnly
                ? 'Apenas não lidos'
                : _filter == ArticleFilter.readOnly
                    ? 'Apenas lidos'
                    : 'Filtrar artigos',
            onPressed: () {
              final next = _filter == ArticleFilter.all
                  ? ArticleFilter.unreadOnly
                  : _filter == ArticleFilter.unreadOnly
                      ? ArticleFilter.readOnly
                      : ArticleFilter.all;
              _setFilter(next);
            },
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todos como lidos',
            color: _textPrimary,
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filter != ArticleFilter.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: FilterChip(
                label: Text(
                  _filter == ArticleFilter.unreadOnly ? 'Não lidos' : 'Lidos',
                ),
                onSelected: (_) => _setFilter(ArticleFilter.all),
                onDeleted: () => _setFilter(ArticleFilter.all),
                selected: true,
              ),
            ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _AnimatedFavoriteButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onPressed;
  const _AnimatedFavoriteButton({required this.isFav, required this.onPressed});

  @override
  State<_AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedFavoriteButton old) {
    super.didUpdateWidget(old);
    if (widget.isFav != old.isFav) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: IconButton(
        icon: Icon(
          widget.isFav ? Icons.star : Icons.star_border,
          color: widget.isFav ? const Color(0xFFFF6B2C) : const Color(0xFF8E8E93),
          size: 20,
        ),
        onPressed: widget.onPressed,
        visualDensity: VisualDensity.compact,
        tooltip: widget.isFav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      ),
    );
  }
}
