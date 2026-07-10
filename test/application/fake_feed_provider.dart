import 'package:feedflow/models/article.dart';
import 'package:feedflow/models/category.dart';
import 'package:feedflow/models/feed.dart';
import 'package:feedflow/providers/auth/auth_config.dart';
import 'package:feedflow/providers/feed_provider.dart';

/// Dublê de teste mínimo de [FeedProvider], usado para testar o
/// [SyncService] sem depender de rede ou de um provider real. Só
/// `markAsRead`/`markAsUnread`/`starArticle`/`unstarArticle` têm
/// comportamento configurável — o resto não é exercitado por esses testes.
class FakeFeedProvider implements FeedProvider {
  FakeFeedProvider({
    this.markAsReadThrows = false,
    this.markAsUnreadThrows = false,
    this.starThrows = false,
    this.unstarThrows = false,
  });

  bool markAsReadThrows;
  bool markAsUnreadThrows;
  bool starThrows;
  bool unstarThrows;

  final List<String> markAsReadCalls = [];
  final List<String> markAsUnreadCalls = [];
  final List<String> starCalls = [];
  final List<String> unstarCalls = [];

  @override
  String get providerId => 'fake';

  @override
  Future<void> markAsRead(String articleId) async {
    markAsReadCalls.add(articleId);
    if (markAsReadThrows) throw Exception('rede indisponível');
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    markAsUnreadCalls.add(articleId);
    if (markAsUnreadThrows) throw Exception('rede indisponível');
  }

  @override
  Future<void> starArticle(String articleId) async {
    starCalls.add(articleId);
    if (starThrows) throw Exception('rede indisponível');
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    unstarCalls.add(articleId);
    if (unstarThrows) throw Exception('rede indisponível');
  }

  @override
  String get displayName => 'Fake';

  @override
  String get defaultBaseUrl => '';

  @override
  bool get supportsWebProxy => false;

  @override
  List<AuthType> get supportedAuthTypes => const [];

  @override
  Future<AuthResult> authenticate(Object config) => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<bool> validateToken() => throw UnimplementedError();

  @override
  Object? getStoredAuth() => throw UnimplementedError();

  @override
  Future<List<Feed>> getFeeds() => throw UnimplementedError();

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) => throw UnimplementedError();

  @override
  Future<void> removeFeed(String feedId) => throw UnimplementedError();

  @override
  Future<void> renameFeed(String feedId, String newTitle) => throw UnimplementedError();

  @override
  Future<void> moveFeed(String feedId, String? categoryId) => throw UnimplementedError();

  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<CategoryResult> createCategory(String name) => throw UnimplementedError();

  @override
  Future<void> renameCategory(String categoryId, String newName) => throw UnimplementedError();

  @override
  Future<void> deleteCategory(String categoryId) => throw UnimplementedError();

  @override
  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
    bool includeOnlyRead = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<Article?> getArticle(String articleId) => throw UnimplementedError();

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) => throw UnimplementedError();

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) => throw UnimplementedError();

  @override
  Future<Map<String, int>> getUnreadCounts() => throw UnimplementedError();

  @override
  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation}) =>
      throw UnimplementedError();

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) =>
      throw UnimplementedError();

  @override
  Future<String> exportOpml() => throw UnimplementedError();

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getPreferences() => throw UnimplementedError();

  @override
  Future<void> setPreference(String key, String value) => throw UnimplementedError();
}
