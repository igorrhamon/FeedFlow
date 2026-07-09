import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class FeedbinProvider implements FeedProvider {
  String? _username;
  String? _password;
  BasicAuthConfig? _config;
  final http.Client _client;

  FeedbinProvider({http.Client? client}) : _client = client ?? http.Client();

  static const _defaultBaseUrl = 'https://api.feedbin.com/v2';

  Map<String, String> get _headers {
    final credentials = base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': 'Basic $credentials',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  @override
  String get providerId => 'feedbin';

  @override
  String get displayName => 'Feedbin';

  @override
  String get defaultBaseUrl => _defaultBaseUrl;

  @override
  bool get supportsWebProxy => true;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.basicAuth];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final basicConfig = config as BasicAuthConfig;
      final credentials = base64Encode(utf8.encode('${basicConfig.username}:${basicConfig.password}'));
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/authentication/api_token.json'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _username = basicConfig.username;
        _password = basicConfig.password;
        _config = BasicAuthConfig(
          providerId: providerId,
          username: basicConfig.username,
          password: basicConfig.password,
        );
        return AuthResult(
          success: true,
          config: _config,
          userId: basicConfig.username,
        );
      }
      return AuthResult(success: false, error: 'Credenciais inválidas');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _username = null;
    _password = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_username == null) return false;
    try {
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/authentication/api_token.json'),
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
        Uri.parse('$_defaultBaseUrl/subscriptions.json'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((sub) {
          final m = sub as Map<String, dynamic>;
          return Feed(
            id: m['feed_id']?.toString() ?? '',
            title: m['title'] as String? ?? 'Sem título',
            url: m['feed_url'] as String?,
            siteUrl: m['site_url'] as String?,
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
      final response = await _client.post(
        Uri.parse('$_defaultBaseUrl/subscriptions.json'),
        headers: _headers,
        body: jsonEncode({'feed_url': feedUrl}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return FeedResult(
          success: true,
          feedId: data['feed_id']?.toString(),
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
      Uri.parse('$_defaultBaseUrl/subscriptions/$feedId.json'),
      headers: _headers,
    );
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await _client.post(
      Uri.parse('$_defaultBaseUrl/taggings.json'),
      headers: _headers,
      body: jsonEncode({
        'feed_id': int.tryParse(feedId) ?? 0,
        'name': newTitle,
      }),
    );
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await _client.post(
        Uri.parse('$_defaultBaseUrl/taggings.json'),
        headers: _headers,
        body: jsonEncode({
          'feed_id': int.tryParse(feedId) ?? 0,
          'name': categoryId,
        }),
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/taggings.json'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data is List) {
        final names = <String>{};
        for (final tag in data) {
          if (tag is Map<String, dynamic> && tag['name'] != null) {
            names.add(tag['name'] as String);
          }
        }
        return names.map((name) => Category(
          id: name,
          name: name,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    return CategoryResult(
      success: true,
      categoryId: name,
      category: Category(id: name, name: name),
    );
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {
    // Feedbin doesn't support renaming taggings directly
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Feedbin doesn't support deleting taggings directly
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
      var url = '$_defaultBaseUrl/entries.json?feed_id=$streamId&per_page=$limit';
      if (excludeRead) url += '&unread=true';

      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body);
      if (data is List) {
        final articles = data.map((item) => _parseArticle(item, streamId)).toList();
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
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/entries/$articleId.json'),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseArticle(data, '');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) async {
    try {
      final idsParam = ids.join(',');
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/entries.json?ids=$idsParam'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => _parseArticle(item, '')).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    await _client.post(
      Uri.parse('$_defaultBaseUrl/unread_entries.json'),
      headers: _headers,
      body: jsonEncode({'unread_entries': [int.tryParse(articleId) ?? 0]}),
    );
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await _client.post(
      Uri.parse('$_defaultBaseUrl/unread_entries.json'),
      headers: _headers,
      body: jsonEncode({'unread_entries': [int.tryParse(articleId) ?? 0]}),
    );
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/entries.json?feed_id=$streamId&unread=true'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final ids = data.map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
          await _client.post(
            Uri.parse('$_defaultBaseUrl/unread_entries.json'),
            headers: _headers,
            body: jsonEncode({'unread_entries': ids}),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> starArticle(String articleId) async {
    await _client.post(
      Uri.parse('$_defaultBaseUrl/starred_entries.json'),
      headers: _headers,
      body: jsonEncode({'starred_entries': [int.tryParse(articleId) ?? 0]}),
    );
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await _client.delete(
      Uri.parse('$_defaultBaseUrl/starred_entries.json'),
      headers: _headers,
      body: jsonEncode({'starred_entries': [int.tryParse(articleId) ?? 0]}),
    );
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await _client.get(
        Uri.parse('$_defaultBaseUrl/unread_count.json'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};

      final data = jsonDecode(response.body);
      if (data is List) {
        return {
          for (final item in data)
            if (item is Map<String, dynamic> && item['feed_id'] != null && item['count'] != null)
              item['feed_id'].toString(): (item['count'] as num).toInt(),
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
        Uri.parse('$_defaultBaseUrl/search.json?query=${Uri.encodeComponent(query)}&per_page=$limit'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['entries'] is List) {
        final entries = data['entries'] as List;
        final articles = entries.map((item) => _parseArticle(item, '')).toList();
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
        Uri.parse('$_defaultBaseUrl/starred_entries.json?per_page=$limit'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body);
      if (data is List) {
        final ids = data.map((e) => e.toString()).toList();
        return await getArticlesByIds(ids).then(
          (articles) => ArticleListResult(articles: articles),
        );
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
        Uri.parse('$_defaultBaseUrl/v1/export'),
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
        Uri.parse('$_defaultBaseUrl/import.json'),
      );
      final credentials = base64Encode(utf8.encode('$_username:$_password'));
      request.headers['Authorization'] = 'Basic $credentials';
      request.files.add(
        http.MultipartFile.fromString(
          'opml',
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
    return {};
  }

  @override
  Future<void> setPreference(String key, String value) async {}

  Article _parseArticle(dynamic item, String feedId) {
    final m = item as Map<String, dynamic>;
    return Article(
      id: m['id']?.toString() ?? '',
      feedId: feedId.isNotEmpty ? feedId : m['feed_id']?.toString() ?? '',
      title: m['title'] as String? ?? '',
      author: m['author'] as String? ?? '',
      summary: m['summary'] as String? ?? '',
      content: m['content'] as String? ?? '',
      url: m['url'] as String? ?? '',
      published: m['published'] != null ? DateTime.tryParse(m['published'].toString()) : null,
      categories: [],
      isRead: m['unread'] == false,
      isStarred: false,
    );
  }
}
