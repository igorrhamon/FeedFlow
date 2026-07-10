import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import '../models/category.dart';
import '../widget/feed_widget_service.dart';
import 'feed_articles_page.dart';
import 'folder_feeds_page.dart';

const _accent = Color(0xFFFF6B2C);
const _maxWidgetArticles = 5;
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _divider = Color(0xFF3A3A3C);
const _surface = Color(0xFF1C1C1E);

class HomePage extends StatefulWidget {
  final FeedProvider provider;
  const HomePage({super.key, required this.provider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Feed> feeds = [];
  Map<String, int> unreadCounts = {};
  List<Category> categories = [];
  Map<String, List<Feed>> feedsByFolder = {};
  List<Feed> uncategorizedFeeds = [];
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        widget.provider.getFeeds(),
        widget.provider.getUnreadCounts(),
        widget.provider.getCategories(),
      ]);

      feeds = results[0] as List<Feed>;
      unreadCounts = results[1] as Map<String, int>;
      categories = results[2] as List<Category>;

      final byFolder = <String, List<Feed>>{};
      final uncategorized = <Feed>[];
      for (final feed in feeds) {
        if (feed.categories.isNotEmpty) {
          for (final catName in feed.categories) {
            byFolder.putIfAbsent(catName, () => []).add(feed);
          }
        } else {
          uncategorized.add(feed);
        }
      }

      feedsByFolder = byFolder;
      uncategorizedFeeds = uncategorized;

      setState(() => loading = false);

      // Update Android home widget with latest unread articles (fire-and-forget)
      widget.provider
          .getArticles(
            streamId: 'user/-/state/com.google/reading-list',
            limit: _maxWidgetArticles,
            excludeRead: true,
          )
          .then((result) => FeedWidgetService.update(result.articles))
          .catchError((_) {}); // Ignore widget update errors silently
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  void _openFeed(BuildContext context, Feed feed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(provider: widget.provider, feed: feed),
      ),
    );
  }

  void _openSmartStream(BuildContext context, String id, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(
          provider: widget.provider,
          feed: Feed(id: id, title: title),
        ),
      ),
    );
  }

  void _openFolderFeed(BuildContext context, String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderFeedsPage(
          provider: widget.provider,
          folderName: folderName,
        ),
      ),
    );
  }

  String _feedInitial(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  Color _avatarColor(String title) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
    ];
    if (title.isEmpty) return colors[0];
    return colors[title.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: _accent),
      );
    } else if (error != null) {
      body = Center(
        key: ValueKey('error'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadFeeds,
              child: const Text('Tentar novamente', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
    } else {
      final totalUnread = unreadCounts['user/-/state/com.google/reading-list'] ?? 0;
      final categoryNames = categories.map((c) => c.name).toList()..sort();
      body = RefreshIndicator(
        key: const ValueKey('content'),
      color: _accent,
      backgroundColor: _surface,
      onRefresh: _loadFeeds,
      child: ListView(
        children: [
          _sectionHeader('INÍCIO'),
          _smartStreamTile(
            context,
            icon: Icons.all_inbox_rounded,
            title: 'Todos os artigos',
            subtitle: totalUnread > 0 ? '$totalUnread não lidos' : null,
            streamId: 'user/-/state/com.google/reading-list',
            streamTitle: 'Todos os artigos',
            hasUnread: totalUnread > 0,
          ),
          _smartStreamTile(
            context,
            icon: Icons.circle_notifications_rounded,
            title: 'Não lidos',
            subtitle: totalUnread > 0 ? '$totalUnread artigos' : 'Nenhum',
            streamId: 'user/-/state/com.google/reading-list',
            streamTitle: 'Não lidos',
            hasUnread: totalUnread > 0,
          ),
          const Divider(color: _divider, height: 1),
          if (categoryNames.isNotEmpty) ...[
            _sectionHeader('PASTAS'),
            ...categoryNames.map((name) {
              final folderFeeds = feedsByFolder[name] ?? [];
              final folderUnread = unreadCounts['user/-/label/$name'] ?? 0;
              return _FolderSection(
                key: ValueKey('folder_$name'),
                name: name,
                unreadCount: folderUnread,
                feeds: folderFeeds,
                unreadCounts: unreadCounts,
                onFolderTap: () => _openFolderFeed(context, name),
                onFeedTap: (feed) => _openFeed(context, feed),
              );
            }),
            const Divider(color: _divider, height: 1),
          ],
          if (uncategorizedFeeds.isNotEmpty) ...[
            _sectionHeader('SEM CATEGORIA'),
            ...uncategorizedFeeds.map((feed) {
              final count = unreadCounts[feed.id] ?? 0;
              return _feedTile(context, feed: feed, title: feed.title, count: count, isLast: false);
            }),
          ],
          if (feeds.isEmpty && categoryNames.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Text(
                'Nenhum feed. Toque em + para adicionar.',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: body,
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _smartStreamTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String streamId,
    required String streamTitle,
    required bool hasUnread,
  }) {
    return InkWell(
      onTap: () => _openSmartStream(context, streamId, streamTitle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: hasUnread
              ? const Border(left: BorderSide(color: _accent, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasUnread ? const Color(0x1AFF6B2C) : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: hasUnread ? _accent : _textSecondary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _feedTile(
    BuildContext context, {
    required Feed feed,
    required String title,
    required int count,
    required bool isLast,
  }) {
    final hasUnread = count > 0;
    return Column(
      children: [
        InkWell(
          onTap: () => _openFeed(context, feed),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: hasUnread
                  ? const Border(left: BorderSide(color: _accent, width: 3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _avatarColor(title).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _feedInitial(title),
                    style: TextStyle(
                      color: _avatarColor(title),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 999 ? '999+' : count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 18),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(color: _divider, height: 1, indent: 66),
      ],
    );
  }
}

class _FolderSection extends StatefulWidget {
  final String name;
  final int unreadCount;
  final List<Feed> feeds;
  final Map<String, int> unreadCounts;
  final void Function() onFolderTap;
  final void Function(Feed) onFeedTap;

  const _FolderSection({
    super.key,
    required this.name,
    required this.unreadCount,
    required this.feeds,
    required this.unreadCounts,
    required this.onFolderTap,
    required this.onFeedTap,
  });

  @override
  State<_FolderSection> createState() => _FolderSectionState();
}

class _FolderSectionState extends State<_FolderSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasUnread = widget.unreadCount > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.onFolderTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: hasUnread
                  ? const Border(left: BorderSide(color: _accent, width: 3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasUnread ? const Color(0x1AFF6B2C) : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _expanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                    color: hasUnread ? _accent : _textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.unreadCount > 999 ? '999+' : widget.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (widget.feeds.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: _textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _expanded && widget.feeds.isNotEmpty
                ? widget.feeds.map((feed) {
                    final count = widget.unreadCounts[feed.id] ?? 0;
                    final hasFeedUnread = count > 0;
                    return InkWell(
                      onTap: () => widget.onFeedTap(feed),
                      child: Container(
                        padding: const EdgeInsets.only(left: 66, right: 20, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          border: hasFeedUnread
                              ? const Border(left: BorderSide(color: _accent, width: 2))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                feed.title,
                                style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 13,
                                  fontWeight: hasFeedUnread ? FontWeight.w500 : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasFeedUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  count > 999 ? '999+' : count.toString(),
                                  style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        ),
        const Divider(color: _divider, height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
