import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class TtrssProvider implements FeedProvider {
  String? _sessionId;
  String? _baseUrl;
  BasicAuthConfig? _config;

  TtrssProvider();

  String get _baseUrlResolved => _baseUrl ?? 'https://tt-rss.example.com';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  String get providerId => 'ttrss';

  @override
  String get displayName => 'Tiny Tiny RSS';

  @override
  String get defaultBaseUrl => 'https://tt-rss.example.com';

  @override
  bool get supportsWebProxy => true;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.basicAuth];

  Map<String, dynamic> _apiBody(String op, [Map<String, dynamic>? params]) {
    final body = <String, dynamic>{
      'op': op,
      'sid': _sessionId,
    };
    if (params != null) body.addAll(params);
    return body;
  }

  Future<Map<String, dynamic>?> _apiCall(String op, [Map<String, dynamic>? params]) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlResolved/api/'),
        headers: _headers,
        body: jsonEncode(_apiBody(op, params)),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 0 && data['content'] != null) {
          return data;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final basicConfig = config as BasicAuthConfig;
      final baseUrl = basicConfig.baseUrl ?? defaultBaseUrl;

      final response = await http.post(
        Uri.parse('$baseUrl/api/'),
        headers: _headers,
        body: jsonEncode({
          'op': 'login',
          'user': basicConfig.username,
          'password': basicConfig.password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 0 && data['content'] != null) {
          final content = data['content'] as Map<String, dynamic>;
          final sid = content['session_id'] as String?;
          if (sid != null && sid.isNotEmpty) {
            _sessionId = sid;
            _baseUrl = baseUrl;
            _config = BasicAuthConfig(
              providerId: providerId,
              username: basicConfig.username,
              password: basicConfig.password,
              baseUrl: baseUrl,
            );
            return AuthResult(
              success: true,
              config: _config,
              userId: basicConfig.username,
            );
          }
        }
      }
      return AuthResult(success: false, error: 'Credenciais inválidas ou URL incorreta');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    if (_sessionId != null) {
      await _apiCall('logout');
    }
    _sessionId = null;
    _baseUrl = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_sessionId == null) return false;
    try {
      final result = await _apiCall('getVersion');
      return result != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Object? getStoredAuth() => _config;

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      final result = await _apiCall('getFeeds', {
        'cat_id': -1,
        'unread_only': false,
        'limit': 0,
        'view_mode': 'all_feeds',
      });
      if (result == null) return [];

      final content = result['content'];
      if (content is List) {
        return content.map((feed) {
          final m = feed as Map<String, dynamic>;
          return Feed(
            id: m['id']?.toString() ?? '',
            title: m['title'] as String? ?? 'Sem título',
            url: m['feed_url'] as String?,
            siteUrl: m['link'] as String?,
            categories: [
              if (m['cat_id'] != null) m['cat_id'].toString(),
            ],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) async {
    try {
      final params = <String, dynamic>{
        'feed_url': feedUrl,
      };
      if (category != null) {
        params['cat_id'] = int.tryParse(category) ?? 0;
      }

      final result = await _apiCall('subscribeToFeed', params);
      if (result != null) {
        final content = result['content'];
        if (content is Map<String, dynamic> && content['feed_id'] != null) {
          return FeedResult(
            success: true,
            feedId: content['feed_id'].toString(),
          );
        }
      }
      return FeedResult(success: false, error: 'Erro ao adicionar feed');
    } catch (e) {
      return FeedResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> removeFeed(String feedId) async {
    await _apiCall('unsubscribeFeed', {
      'feed_id': int.tryParse(feedId) ?? 0,
    });
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await _apiCall('renameFeed', {
      'feed_id': int.tryParse(feedId) ?? 0,
      'title': newTitle,
    });
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await _apiCall('moveFeed', {
        'feed_id': int.tryParse(feedId) ?? 0,
        'cat_id': int.tryParse(categoryId) ?? 0,
      });
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final result = await _apiCall('getCategories', {
        'unread_only': false,
      });
      if (result == null) return [];

      final content = result['content'];
      if (content is List) {
        return content.map((cat) {
          final m = cat as Map<String, dynamic>;
          return Category(
            id: m['id']?.toString() ?? '',
            name: m['title'] as String? ?? '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    try {
      final result = await _apiCall('createCategory', {
        'caption': name,
      });
      if (result != null) {
        final content = result['content'];
        if (content is Map<String, dynamic> && content['id'] != null) {
          return CategoryResult(
            success: true,
            categoryId: content['id'].toString(),
            category: Category(id: content['id'].toString(), name: name),
          );
        }
      }
      return CategoryResult(success: false, error: 'Erro ao criar categoria');
    } catch (e) {
      return CategoryResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {
    await _apiCall('renameCategory', {
      'cat_id': int.tryParse(categoryId) ?? 0,
      'caption': newName,
    });
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _apiCall('removeCategory', {
      'cat_id': int.tryParse(categoryId) ?? 0,
    });
  }

  @override
  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
    bool includeOnlyRead = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'feed_id': int.tryParse(streamId) ?? 0,
        'limit': limit,
        'skip': 0,
        'show_content': true,
        'view_mode': excludeRead ? 'unread' : 'all_articles',
      };

      final result = await _apiCall('getHeadlines', params);
      if (result == null) return ArticleListResult(articles: []);

      final content = result['content'];
      if (content is List) {
        final articles = content.map((item) => _parseArticle(item, streamId)).toList();
        return ArticleListResult(articles: articles);
      }
      return ArticleListResult(articles: []);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    try {
      final result = await _apiCall('getArticle', {
        'article_id': int.tryParse(articleId) ?? 0,
      });
      if (result == null) return null;

      final content = result['content'];
      if (content is List && content.isNotEmpty) {
        return _parseArticle(content.first, '');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) async {
    try {
      final articles = <Article>[];
      for (final id in ids) {
        final article = await getArticle(id);
        if (article != null) articles.add(article);
      }
      return articles;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    await _apiCall('updateArticle', {
      'article_ids': [int.tryParse(articleId) ?? 0],
      'field': 2,
      'mode': 0,
    });
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await _apiCall('updateArticle', {
      'article_ids': [int.tryParse(articleId) ?? 0],
      'field': 2,
      'mode': 1,
    });
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    await _apiCall('catchupFeed', {
      'feed_id': int.tryParse(streamId) ?? 0,
      'is_cat': false,
    });
  }

  @override
  Future<void> starArticle(String articleId) async {
    await _apiCall('updateArticle', {
      'article_ids': [int.tryParse(articleId) ?? 0],
      'field': 0,
      'mode': 1,
    });
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await _apiCall('updateArticle', {
      'article_ids': [int.tryParse(articleId) ?? 0],
      'field': 0,
      'mode': 0,
    });
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final result = await _apiCall('getFeeds', {
        'cat_id': -1,
        'unread_only': true,
        'limit': 0,
      });
      if (result == null) return {};

      final content = result['content'];
      if (content is List) {
        return {
          for (final feed in content)
            if (feed is Map<String, dynamic> && feed['id'] != null && feed['unread'] != null)
              feed['id'].toString(): (feed['unread'] as num).toInt(),
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation}) async {
    try {
      final result = await _apiCall('getHeadlines', {
        'feed_id': 0,
        'limit': limit,
        'skip': 0,
        'search': query,
        'show_content': true,
      });
      if (result == null) return ArticleListResult(articles: []);

      final content = result['content'];
      if (content is List) {
        final articles = content.map((item) => _parseArticle(item, '')).toList();
        return ArticleListResult(articles: articles);
      }
      return ArticleListResult(articles: []);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) async {
    try {
      final result = await _apiCall('getHeadlines', {
        'feed_id': 0,
        'limit': limit,
        'skip': 0,
        'view_mode': 'starred',
        'show_content': true,
      });
      if (result == null) return ArticleListResult(articles: []);

      final content = result['content'];
      if (content is List) {
        final articles = content.map((item) => _parseArticle(item, '')).toList();
        return ArticleListResult(articles: articles);
      }
      return ArticleListResult(articles: []);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<String> exportOpml() async {
    try {
      final result = await _apiCall('exportOpml');
      if (result != null && result['content'] is String) {
        return result['content'] as String;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    return OpmlImportResult(success: false, errors: ['Import não suportado via API']);
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final result = await _apiCall('getPref', {
        'pref_name': 'theme',
      });
      if (result != null && result['content'] != null) {
        return {'theme': result['content']};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await _apiCall('setPref', {
      'pref_name': key,
      'value': value,
    });
  }

  Article _parseArticle(dynamic item, String feedId) {
    final m = item as Map<String, dynamic>;
    return Article(
      id: m['id']?.toString() ?? '',
      feedId: feedId.isNotEmpty ? feedId : m['feed_id']?.toString() ?? '',
      title: m['title'] as String? ?? '',
      author: m['author'] as String? ?? '',
      summary: m['content'] as String? ?? '',
      content: m['content'] as String? ?? '',
      url: m['link'] as String? ?? '',
      published: m['updated'] != null ? DateTime.tryParse(m['updated'].toString()) : null,
      categories: [],
      isRead: m['unread'] == false,
      isStarred: m['marked'] == true,
    );
  }
}
