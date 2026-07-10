import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class NewsBlurProvider implements FeedProvider {
  String? _username;
  String? _baseUrl;
  BasicAuthConfig? _config;

  NewsBlurProvider();

  String get _baseUrlResolved => _baseUrl ?? 'https://newsblur.com';

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  @override
  String get providerId => 'newsblur';

  @override
  String get displayName => 'NewsBlur';

  @override
  String get defaultBaseUrl => 'https://newsblur.com';

  @override
  bool get supportsWebProxy => true;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.basicAuth];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final basicConfig = config as BasicAuthConfig;
      final baseUrl = basicConfig.baseUrl ?? defaultBaseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: _headers,
        body: {
          'username': basicConfig.username,
          'password': basicConfig.password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['authenticated'] == true) {
          _username = basicConfig.username;
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
      return AuthResult(success: false, error: 'Credenciais inválidas');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _username = null;
    _baseUrl = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_username == null) return false;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/login'),
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
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/feeds'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final feedsMap = data['feeds'] as Map<String, dynamic>? ?? {};
      final folders = data['folders'] as Map<String, dynamic>? ?? {};

      final feeds = <Feed>[];
      for (final entry in feedsMap.entries) {
        final m = entry.value as Map<String, dynamic>;
        final feedId = entry.key;
        final folderId = m['folder_id']?.toString();
        final folder = folderId != null ? folders[folderId] : null;
        final folderName = folder is Map<String, dynamic> ? folder['title'] as String? : null;

        feeds.add(Feed(
          id: feedId,
          title: m['title'] as String? ?? 'Sem título',
          url: m['feed_link'] as String?,
          siteUrl: m['feed_address'] as String?,
          categories: folderName != null ? [folderName] : [],
        ));
      }
      return feeds;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlResolved/api/reader/add_url'),
        headers: _headers,
        body: {'url': feedUrl},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'ok') {
          return FeedResult(success: true);
        }
      }
      return FeedResult(success: false, error: 'Erro ao adicionar feed');
    } catch (e) {
      return FeedResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> removeFeed(String feedId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/delete_feed'),
      headers: _headers,
      body: {'feed_id': feedId},
    );
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/rename_feed'),
      headers: _headers,
      body: {'feed_id': feedId, 'title': newTitle},
    );
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await http.post(
        Uri.parse('$_baseUrlResolved/api/reader/move_feed_to_folder'),
        headers: _headers,
        body: {'feed_id': feedId, 'folder_id': categoryId},
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/folders'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final folders = data['folders'] as Map<String, dynamic>? ?? {};

      return folders.entries.map((entry) {
        final m = entry.value as Map<String, dynamic>;
        return Category(
          id: entry.key,
          name: m['title'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlResolved/api/reader/add_folder'),
        headers: _headers,
        body: {'folder_name': name},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'ok') {
          return CategoryResult(
            success: true,
            categoryId: data['folder_id']?.toString(),
            category: Category(id: data['folder_id']?.toString() ?? '', name: name),
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
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/rename_folder'),
      headers: _headers,
      body: {'folder_id': categoryId, 'folder_name': newName},
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/delete_folder'),
      headers: _headers,
      body: {'folder_id': categoryId},
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
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/stories?feed_id=$streamId&page=0'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final stories = data['stories'] as List<dynamic>? ?? [];
      final articles = stories.map((item) => _parseArticle(item, streamId)).toList();
      return ArticleListResult(articles: articles);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/story?story_id=$articleId'),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final story = data['story'] as Map<String, dynamic>?;
      if (story != null) return _parseArticle(story, '');
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
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/mark_story_hashes_as_read'),
      headers: _headers,
      body: {'story_hash': articleId},
    );
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/mark_story_hashes_as_unread'),
      headers: _headers,
      body: {'story_hash': articleId},
    );
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/mark_feed_as_read'),
      headers: _headers,
      body: {'feed_id': streamId},
    );
  }

  @override
  Future<void> starArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/mark_story_hash_as_starred'),
      headers: _headers,
      body: {'story_hash': articleId},
    );
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/api/reader/mark_story_hash_as_unstarred'),
      headers: _headers,
      body: {'story_hash': articleId},
    );
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/feeds?count=true'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final feedsMap = data['feeds'] as Map<String, dynamic>? ?? {};

      return {
        for (final entry in feedsMap.entries)
          if (entry.value is Map<String, dynamic>)
            entry.key: (entry.value['num_stories_unread'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/search_stories?q=${Uri.encodeComponent(query)}&page=0'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final stories = data['stories'] as List<dynamic>? ?? [];
      final articles = stories.map((item) => _parseArticle(item, '')).toList();
      return ArticleListResult(articles: articles);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/starred_stories?page=0'),
        headers: _headers,
      );
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final stories = data['stories'] as List<dynamic>? ?? [];
      final articles = stories.map((item) => _parseArticle(item, '')).toList();
      return ArticleListResult(articles: articles);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<String> exportOpml() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/api/reader/export_opml'),
        headers: _headers,
      );
      return response.statusCode == 200 ? response.body : '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    return OpmlImportResult(success: false, errors: ['Import não suportado']);
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
      id: m['story_hash'] as String? ?? m['id']?.toString() ?? '',
      feedId: feedId.isNotEmpty ? feedId : m['feed_id']?.toString() ?? '',
      title: m['title'] as String? ?? '',
      author: m['author'] as String? ?? '',
      summary: m['short_content'] as String? ?? '',
      content: m['content'] as String? ?? '',
      url: m['permalink'] as String? ?? '',
      published: m['published'] != null ? DateTime.tryParse(m['published'].toString()) : null,
      categories: [],
      isRead: m['read_status'] == 'unread' ? false : true,
      isStarred: m['starred'] == true,
    );
  }
}
