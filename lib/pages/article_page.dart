import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../domain/work_item.dart';
import '../providers/feed_provider.dart';
import '../models/article.dart';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _bg = Color(0xFF0F0F0F);
const _surface = Color(0xFF1C1C1E);

class ArticlePage extends StatefulWidget {
  final dynamic article;
  final FeedProvider provider;
  const ArticlePage({super.key, required this.article, required this.provider});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  void initState() {
    super.initState();
    final id = _getArticleId();
    if (id.isNotEmpty) widget.provider.markAsRead(id);
  }

  String _getArticleId() {
    final a = widget.article;
    if (a is Article) return a.id;
    if (a is WorkItem) return a.articleId;
    if (a is Map) return a['id'] as String? ?? '';
    return '';
  }

  String _getTitle() {
    final a = widget.article;
    if (a is Article) return a.title;
    if (a is WorkItem) return a.title;
    if (a is Map) return a['title'] as String? ?? 'Artigo';
    return 'Artigo';
  }

  String _getAuthor() {
    final a = widget.article;
    if (a is Article) return a.author ?? '';
    if (a is WorkItem) return a.author ?? '';
    if (a is Map) return a['author'] as String? ?? '';
    return '';
  }

  DateTime? _getPublished() {
    final a = widget.article;
    if (a is Article) return a.published;
    if (a is WorkItem) return a.published;
    if (a is Map) {
      final published = a['published'];
      if (published is DateTime) return published;
      if (published != null) {
        final ts = int.tryParse(published.toString());
        if (ts != null) return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      }
    }
    return null;
  }

  String _getContent() {
    final a = widget.article;
    if (a is Article) {
      return (a.content?.isNotEmpty == true) ? a.content! : (a.summary ?? '');
    }
    if (a is WorkItem) {
      return (a.content?.isNotEmpty == true) ? a.content! : (a.summary ?? '');
    }
    if (a is Map) {
      final content = a['content'] as String? ?? '';
      final summary = a['summary'] as String? ?? '';
      return content.isNotEmpty ? content : summary;
    }
    return '';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${date.day} ${months[date.month - 1]}. ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final author = _getAuthor();
    final published = _getPublished();
    final htmlContent = _getContent();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Artigo', style: TextStyle(fontSize: 15, color: _textSecondary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'article_title_${_getArticleId()}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (author.isNotEmpty) ...[
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            author[0].toUpperCase(),
                            style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            author,
                            style: const TextStyle(color: _textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (published != null)
                          Text(
                            _formatDate(published),
                            style: const TextStyle(color: _textSecondary, fontSize: 12),
                          ),
                      ] else if (published != null) ...[
                        Text(
                          _formatDate(published),
                          style: const TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: Color(0xFF3A3A3C)),
                  const SizedBox(height: 20),
                  if (htmlContent.isNotEmpty)
                    Html(
                      data: htmlContent,
                      style: {
                        'body': Style(
                          color: _textPrimary,
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.6),
                        ),
                      },
                    )
                  else
                    const Text(
                      'Conteúdo não disponível.',
                      style: TextStyle(color: _textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
