import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class MinifluxProvider implements FeedProvider {
  String? _apiKey;
  String? _baseUrl;
  ApiKeyAuthConfig? _config;
  final http.Client _client;

  MinifluxProvider({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrlResolved => _baseUrl ?? 'https://miniflux.example.com';

  Map<String, String> get _headers => {
    'X-Auth-Token': _apiKey ?? '',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  String get providerId => 'miniflux';

  @override
  String get displayName => 'Miniflux';

  @override
  String get defaultBaseUrl => 'https://miniflux.example.com';

  @override
  bool get supportsWebProxy => true;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.apiKey];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final apiKeyConfig = config as ApiKeyAuthConfig;
      final baseUrl = apiKeyConfig.baseUrl ?? defaultBaseUrl;
      final testUrl = Uri.parse('$baseUrl/v1/me');
      final response = await _client.get(
        testUrl,
        headers: {
          'X-Auth-Token': apiKeyConfig.apiKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _apiKey = apiKeyConfig.apiKey;
        _baseUrl = baseUrl;
        _config = ApiKeyAuthConfig(
          providerId: providerId,
          apiKey: apiKeyConfig.apiKey,
          baseUrl: baseUrl,
        );
        return AuthResult(
          success: true,
          config: _config,
          userId: data['id']?.toString() ?? apiKeyConfig.apiKey,
          userName: data['username'] as String?,
        );
      }
      return AuthResult(success: false, error: 'API key inválida ou URL incorreta');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _apiKey = null;
    _baseUrl = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_apiKey == null) return false;
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/me'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Object? getStoredAuth() => _config;

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/feeds'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((feed) {
          final m = feed as Map<String, dynamic>;
          return Feed(
            id: m['id']?.toString() ?? '',
            title: m['title'] as String? ?? 'Sem título',
            url: m['feed_url'] as String?,
            siteUrl: m['site_url'] as String?,
            categories: [
              if (m['category'] != null)
                (m['category'] as Map<String, dynamic>)['title'] as String? ?? '',
            ].where((n) => n.isNotEmpty).toList(),
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
      final body = <String, dynamic>{
        'feed_url': feedUrl,
      };
      if (category != null) {
        body['category_id'] = int.tryParse(category) ?? 0;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrlResolved/v1/feeds'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return FeedResult(
          success: true,
          feedId: data['id']?.toString(),
        );
      }
      return FeedResult(success: false, error: 'Erro ao adicionar feed');
    } catch (e) {
      return FeedResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> removeFeed(String feedId) async {
    await _client.delete(
      Uri.parse('$_baseUrlResolved/v1/feeds/$feedId'),
      headers: _headers,
    );
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/feeds/$feedId'),
      headers: _headers,
      body: jsonEncode({'title': newTitle}),
    );
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await _client.put(
        Uri.parse('$_baseUrlResolved/v1/feeds/$feedId'),
        headers: _headers,
        body: jsonEncode({'category_id': int.tryParse(categoryId) ?? 0}),
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/categories'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((cat) {
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
      final response = await _client.post(
        Uri.parse('$_baseUrlResolved/v1/categories'),
        headers: _headers,
        body: jsonEncode({'title': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CategoryResult(
          success: true,
          categoryId: data['id']?.toString(),
          category: Category(id: data['id']?.toString() ?? '', name: name),
        );
      }
      return CategoryResult(success: false, error: 'Erro ao criar categoria');
    } catch (e) {
      return CategoryResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/categories/$categoryId'),
      headers: _headers,
      body: jsonEncode({'title': newName}),
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _client.delete(
      Uri.parse('$_baseUrlResolved/v1/categories/$categoryId'),
      headers: _headers,
    );
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
      var url = '$_baseUrlResolved/v1/feeds/$streamId/entries?limit=$limit&order=published_at&direction=desc';
      if (excludeRead) url += '&status=unread';

      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) {
        return ArticleListResult(articles: []);
      }

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['entries'] is List) {
        final rawItems = data['entries'] as List<dynamic>;
        final articles = rawItems.map((item) => _parseArticle(item, streamId)).toList();
        final total = data['total'] as int? ?? 0;
        return ArticleListResult(
          articles: articles,
          totalCount: total,
        );
      }
      return ArticleListResult(articles: []);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/entries/$articleId'),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseArticle(data, data['feed_id']?.toString() ?? '');
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
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/entries/$articleId'),
      headers: _headers,
      body: jsonEncode({'status': 'read'}),
    );
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/entries/$articleId'),
      headers: _headers,
      body: jsonEncode({'status': 'unread'}),
    );
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    final body = <String, dynamic>{
      'feed_id': int.tryParse(streamId) ?? 0,
      'status': 'read',
    };
    if (before != null) {
      body['before'] = before.toUtc().toIso8601String();
    }
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/feeds/$streamId/mark-all-as-read'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  @override
  Future<void> starArticle(String articleId) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/entries/$articleId/bookmark'),
      headers: _headers,
    );
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/entries/$articleId/bookmark'),
      headers: _headers,
    );
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/feeds'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};

      final data = jsonDecode(response.body);
      if (data is List) {
        return {
          for (final feed in data)
            if (feed is Map<String, dynamic> && feed['id'] != null && feed['unread_count'] != null)
              feed['id'].toString(): (feed['unread_count'] as num).toInt(),
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
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/search?query=${Uri.encodeComponent(query)}&limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body);
      if (data is List) {
        final articles = data.map((item) => _parseArticle(item, '')).toList();
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
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/entries?starred=true&limit=$limit&order=published_at&direction=desc'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['entries'] is List) {
        final rawItems = data['entries'] as List<dynamic>;
        final articles = rawItems.map((item) => _parseArticle(item, '')).toList();
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
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/export'),
        headers: _headers,
      );
      return response.statusCode == 200 ? response.body : '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrlResolved/v1/import'),
      );
      request.headers['X-Auth-Token'] = _apiKey ?? '';
      request.files.add(
        http.MultipartFile.fromString(
          'file',
          opmlContent,
          filename: 'subscriptions.opml',
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        return OpmlImportResult(success: true);
      }
      return OpmlImportResult(success: false, errors: ['Erro ao importar OPML']);
    } catch (e) {
      return OpmlImportResult(success: false, errors: [e.toString()]);
    }
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrlResolved/v1/me'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};
      return jsonDecode(response.body) as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await _client.put(
      Uri.parse('$_baseUrlResolved/v1/me'),
      headers: _headers,
      body: jsonEncode({key: value}),
    );
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
      url: m['url'] as String? ?? '',
      published: m['published_at'] != null ? DateTime.tryParse(m['published_at'].toString()) : null,
      categories: [
        if (m['feed'] != null)
          (m['feed'] as Map<String, dynamic>)['title'] as String? ?? '',
      ],
      isRead: m['status'] == 'read',
      isStarred: m['starred'] == true,
    );
  }
}
