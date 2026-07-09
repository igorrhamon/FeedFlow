# FeedFlow Architecture

## Overview

Multi-provider RSS architecture for the FeedFlow Flutter app, supporting 9 RSS providers through a common `FeedProvider` interface.

## Providers Supported

| Provider | Auth Type | Self-hosted | Base URL | Status |
|----------|-----------|-------------|----------|--------|
| **The Old Reader** | GoogleLogin | No | Fixed | ✅ Implemented |
| **Inoreader** | API Key | No | Fixed | ✅ Implemented |
| **FreshRSS** | Basic Auth | Yes | Configurable | ✅ Implemented |
| **Miniflux** | API Key | Yes | Configurable | ✅ Implemented |
| **Tiny Tiny RSS** | Session/Basic | Yes | Configurable | ✅ Implemented |
| **Feedbin** | Basic Auth | No | Fixed | ✅ Implemented |
| **NewsBlur** | Basic Auth | Yes | Configurable | ✅ Implemented |
| **Feedly** | OAuth2 | No | Fixed | ✅ Implemented |
| **Local OPML** | File | N/A | N/A | ✅ Implemented |

---

## Implementation Status

### Phase 1: Foundation ✅
- [x] Domain models (Feed, Article, Category, AuthConfig) with Freezed
- [x] FeedProvider abstract interface (28+ methods)
- [x] ProviderRegistry (factory pattern)
- [x] ProviderSettings (credential storage via flutter_secure_storage)
- [x] TheOldReaderProvider (wraps existing OldReaderApi)
- [x] 59 unit tests

### Phase 2: Migration ✅
- [x] All 12 page files migrated from OldReaderApi to FeedProvider
- [x] main.dart: FeedProvider + initializeProviders() + ProviderSettings
- [x] Login flow uses ProviderSettings for persistence
- [x] 76/76 tests passing

### Phase 3: Additional Providers ✅
- [x] InoreaderProvider (Google Reader API compatible, API key auth)
- [x] FreshRssProvider (Google Reader API compatible, Basic Auth, self-hosted)
- [x] MinifluxProvider (REST API, API key, self-hosted)
- [x] TtrssProvider (Session-based auth, self-hosted)
- [x] FeedbinProvider (REST API, Basic Auth)
- [x] NewsBlurProvider (Custom API, Basic Auth, self-hosted)
- [x] LocalOpmlProvider (File-based, no auth)
- [x] Provider selection UI in LoginPage (dropdown + dynamic form)
- [x] Base URL field for self-hosted providers
- [x] Auth config persistence for all types
- [x] 96/96 tests passing

### Phase 4: Production Readiness ✅
- [x] FeedlyProvider (OAuth2, read-only — graceful returns for unimplemented methods)
- [x] FeedlyAuth (OAuth2 authorization + token refresh)
- [x] ApplicationId renamed to `io.feedflow.app`
- [x] Release signing config with keystore.properties fallback
- [x] ProGuard/R8 enabled for release builds
- [x] `android:allowBackup="false"` with data extraction rules
- [x] HTML rendering with `flutter_html` in article page
- [x] OPML export with `share_plus` file sharing
- [x] Package renamed from `the_old_reader` to `feedflow`
- [x] 111 tests passing

---

## Core Domain Models

### Feed (lib/models/feed.dart)
```dart
@freezed
class Feed with _$Feed {
  const factory Feed({
    required String id,
    required String title,
    String? url,
    String? siteUrl,
    String? iconUrl,
    @Default(0) int unreadCount,
    @Default([]) List<String> categories,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Feed;

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}
```

### Article (lib/models/article.dart)
```dart
@freezed
class Article with _$Article {
  const factory Article({
    required String id,
    required String feedId,
    required String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    @Default([]) List<String> categories,
    @Default(false) bool isRead,
    @Default(false) bool isStarred,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}

@freezed
class ArticleListResult with _$ArticleListResult {
  const factory ArticleListResult({
    required List<Article> articles,
    String? continuation,
    int? totalCount,
  }) = _ArticleListResult;

  factory ArticleListResult.fromJson(Map<String, dynamic> json) => _$ArticleListResultFromJson(json);
}
```

### Category & UnreadCount (lib/models/category.dart)
```dart
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @Default(0) int unreadCount,
    @Default([]) List<Feed> feeds,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class UnreadCount with _$UnreadCount {
  const factory UnreadCount({
    required String id,
    required int count,
    DateTime? updated,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) => _$UnreadCountFromJson(json);
}
```

---

## FeedProvider Interface (lib/providers/feed_provider.dart)

```dart
abstract class FeedProvider {
  String get providerId;
  String get displayName;
  String get defaultBaseUrl;
  bool get supportsWebProxy;
  List<AuthType> get supportedAuthTypes;

  Future<AuthResult> authenticate(Object config);
  Future<void> logout();
  Future<bool> validateToken();
  Object? getStoredAuth();

  Future<List<Feed>> getFeeds();
  Future<FeedResult> addFeed(String feedUrl, {String? category});
  Future<void> removeFeed(String feedId);
  Future<void> renameFeed(String feedId, String newTitle);
  Future<void> moveFeed(String feedId, String? categoryId);

  Future<List<Category>> getCategories();
  Future<CategoryResult> createCategory(String name);
  Future<void> renameCategory(String categoryId, String newName);
  Future<void> deleteCategory(String categoryId);

  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
  });

  Future<Article?> getArticle(String articleId);
  Future<List<Article>> getArticlesByIds(List<String> ids);

  Future<void> markAsRead(String articleId);
  Future<void> markAsUnread(String articleId);
  Future<void> markAllAsRead(String streamId, {DateTime? before});
  Future<void> starArticle(String articleId);
  Future<void> unstarArticle(String articleId);

  Future<Map<String, int>> getUnreadCounts();

  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation});

  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation});

  Future<String> exportOpml();
  Future<OpmlImportResult> importOpml(String opmlContent);

  Future<Map<String, dynamic>> getPreferences();
  Future<void> setPreference(String key, String value);
}

enum AuthType { googleLogin, oauth2, apiKey, basicAuth, localFile }
```

---

## Authentication Abstraction (lib/providers/auth/auth_config.dart)

### Provider-Specific Configs (Freezed classes)
- `GoogleLoginAuthConfig` - The Old Reader (email/password → token)
- `OAuth2AuthConfig` - Feedly (client_id, secret, tokens)
- `ApiKeyAuthConfig` - Inoreader, Miniflux (api key + optional base URL)
- `BasicAuthConfig` - FreshRSS, TT-RSS, Feedbin, NewsBlur (username/password + optional base URL)
- `LocalOpmlAuthConfig` - Local OPML (file path)

### Result Classes
```dart
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    required bool success,
    Object? config,  // Accepts any auth config type
    String? error,
    String? userId,
    String? userName,
  }) = _AuthResult;
}

@freezed
class FeedResult with _$FeedResult {
  const factory FeedResult({
    required bool success,
    String? feedId,
    String? error,
    Feed? feed,
  }) = _FeedResult;
}

@freezed
class CategoryResult with _$CategoryResult {
  const factory CategoryResult({
    required bool success,
    String? categoryId,
    String? error,
    Category? category,
  }) = _CategoryResult;
}

@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required bool success,
    @Default([]) List<Feed> feeds,
    @Default([]) List<String> errors,
  }) = _OpmlImportResult;
}
```

---

## Provider Registry (lib/providers/provider_registry.dart)

```dart
class ProviderInfo {
  final String id;
  final String name;
  final bool supportsWebProxy;
  final bool requiresBaseUrl;
  final List<AuthType> authTypes;
}

class ProviderRegistry {
  static void register(String providerId, FeedProvider Function() factory, ProviderInfo info);
  static FeedProvider? create(String providerId);
  static List<ProviderInfo> getAvailableProviders();
  static ProviderInfo? getProviderInfo(String providerId);
  static bool isRegistered(String providerId);
}
```

### Initialization (lib/providers/provider_init.dart)
All 9 providers registered:
```dart
void initializeProviders() {
  ProviderRegistry.register('theoldreader', ...);  // GoogleLogin
  ProviderRegistry.register('inoreader', ...);      // API Key
  ProviderRegistry.register('freshrss', ...);       // Basic Auth, self-hosted
  ProviderRegistry.register('miniflux', ...);       // API Key, self-hosted
  ProviderRegistry.register('ttrss', ...);          // Session-based, self-hosted
  ProviderRegistry.register('feedbin', ...);        // Basic Auth
  ProviderRegistry.register('newsblur', ...);       // Basic Auth, self-hosted
  ProviderRegistry.register('local_opml', ...);     // File-based
  ProviderRegistry.register('feedly', ...);         // OAuth2
}
```

---

## Settings Storage (lib/services/provider_settings.dart)

`ProviderSettings` using `flutter_secure_storage`:
- Per-provider credentials (encrypted at rest)
- Active provider tracking
- Provider-specific settings (custom base URLs)

```dart
class ProviderSettings {
  static Future<void> saveAuthConfig(String providerId, Object config);
  static Future<Object?> loadAuthConfig(String providerId);
  static Future<void> clearAuthConfig(String providerId);
  static Future<void> setActiveProvider(String providerId);
  static Future<String?> getActiveProvider();
  static Future<void> saveProviderSetting(String providerId, String key, String value);
  static Future<String?> getProviderSetting(String providerId, String key);
  static Future<Map<String, bool>> getConnectedProviders();
}
```

---

## Provider Implementations

### TheOldReaderProvider (lib/providers/theoldreader/)
- Wraps existing `OldReaderApi` for backward compatibility
- Converts between OldReaderApi responses and domain models
- Handles XML/JSON response parsing
- Maps Google Reader API states (read/starred) to boolean flags

### InoreaderProvider (lib/providers/inoreader/)
- Google Reader API compatible endpoints
- API key authentication via `Authorization: GoogleLogin auth=<key>`
- Base URL: `https://www.inoreader.com/reader/api/0`

### FreshRssProvider (lib/providers/freshrss/)
- Google Reader API compatible (same as The Old Reader/Inoreader)
- Basic Auth with configurable base URL
- Default path: `/api/greader.php`

### MinifluxProvider (lib/providers/miniflux/)
- Custom REST API (`/v1/` endpoints)
- API key via `X-Auth-Token` header
- Different data format (JSON objects, not Google Reader format)

### TtrssProvider (lib/providers/ttrss/)
- Session-based auth (login returns session_id)
- POST-based API at `/api/`
- Integer IDs for feeds/articles

### FeedbinProvider (lib/providers/feedbin/)
- REST API with Basic Auth
- Fixed base URL: `https://api.feedbin.com/v2`
- Taggings for categories

### NewsBlurProvider (lib/providers/newsblur/)
- Custom API with Basic Auth
- Story hashes instead of integer IDs
- Folder-based organization

### FeedlyProvider (lib/providers/feedly/)
- REST API at `https://cloud.feedly.com`
- OAuth2 authentication with token refresh via `FeedlyAuth`
- Implemented: authenticate, logout, validateToken, getFeeds, getCategories, getArticles, getUnreadCounts, markAsRead, markAsUnread, starArticle, unstarArticle, getStarredArticles
- Graceful returns (not crashes) for unimplemented methods: addFeed, removeFeed, renameFeed, moveFeed, createCategory, renameCategory, deleteCategory, getArticle, getArticlesByIds, markAllAsRead, search, exportOpml, importOpml, getPreferences, setPreference
- `supportsWebProxy: false` (direct API calls only)

### LocalOpmlProvider (lib/providers/local_opml/)
- File-based, no network
- Parses OPML files for feed lists
- Limited functionality (read-only feeds)

---

## Login UI

The login screen dynamically adapts based on the selected provider:

1. **Provider Dropdown**: Shows all 9 registered providers
2. **API Key providers** (Inoreader, Miniflux): Shows API Key field
3. **Basic Auth providers** (FreshRSS, TT-RSS, Feedbin, NewsBlur): Shows Email/Password fields
4. **Self-hosted providers** (FreshRSS, Miniflux, TT-RSS, NewsBlur): Shows base URL field
5. **The Old Reader**: Shows Email/Password fields
6. **Feedly**: Shows OAuth2 authorization button (Client ID + optional Client Secret)

---

## Security Considerations

1. **Credential Storage**: All auth tokens stored via `flutter_secure_storage` (encrypted at rest)
2. **No Hardcoded Secrets**: Client IDs, secrets, API keys are entered by users
3. **Token Validation**: Providers validate tokens before storing
4. **Secure Transmission**: HTTPS for all API calls
5. **Web Proxy**: CORS bypass via local proxy, no credentials sent to third parties

---

## File Structure

```
lib/
├── main.dart                        # Entry point + Login + MainScaffold
├── models/
│   ├── feed.dart                    # Freezed Feed model
│   ├── article.dart                 # Freezed Article + ArticleListResult
│   └── category.dart                # Freezed Category + UnreadCount
├── providers/
│   ├── feed_provider.dart           # Abstract FeedProvider interface
│   ├── provider_registry.dart       # Provider factory/registry
│   ├── provider_init.dart           # Provider registration (all 9)
│   ├── auth/
│   │   └── auth_config.dart         # Freezed auth config classes
│   ├── theoldreader/
│   │   └── theoldreader_provider.dart
│   ├── inoreader/
│   │   └── inoreader_provider.dart
│   ├── freshrss/
│   │   └── freshrss_provider.dart
│   ├── miniflux/
│   │   └── miniflux_provider.dart
│   ├── ttrss/
│   │   └── ttrss_provider.dart
│   ├── feedbin/
│   │   └── feedbin_provider.dart
│   ├── newsblur/
│   │   └── newsblur_provider.dart
│   ├── feedly/
│   │   ├── feedly_provider.dart
│   │   └── feedly_auth.dart
│   └── local_opml/
│       └── local_opml_provider.dart
├── services/
│   ├── provider_settings.dart       # Credential/settings storage
│   ├── old_reader_api.dart          # Legacy API (used by TheOldReaderProvider)
│   ├── background_sync.dart         # Android background sync
│   └── background_sync_scheduler.dart # Android background sync scheduler
├── widget/
│   └── feed_widget_service.dart     # Home screen widget (home_widget)
└── pages/                           # All pages use FeedProvider
    ├── login_screen.dart
    ├── home_page.dart
    ├── feed_articles_page.dart
    ├── article_page.dart            # HTML rendering via flutter_html
    ├── favorites_page.dart
    ├── folders_page.dart
    ├── folder_feeds_page.dart
    ├── add_feed_page.dart
    ├── subscriptions_page.dart
    ├── search_page.dart
    └── settings_page.dart           # OPML export via share_plus

test/
├── models/                          # Model unit tests
├── services/                        # Service unit tests
│   └── background_sync_test.dart
├── providers/                       # Provider unit tests
│   ├── inoreader/
│   └── feedly/
├── widget_test.dart
└── old_reader_api_test.dart
```

---

## Adding a New Provider

1. Create directory `lib/providers/{provider_name}/`
2. Create `{provider_name}_provider.dart` implementing `FeedProvider`
3. Implement all 28+ interface methods
4. Add auth config class in `lib/providers/auth/auth_config.dart` if needed
5. Register in `lib/providers/provider_init.dart` with `ProviderInfo`
6. Set `requiresBaseUrl: true` for self-hosted providers
7. Add unit tests in `test/providers/{provider_name}/`
8. Run `flutter analyze` and `flutter test`

---

## Tests

- **111 unit tests** passing
- Model tests: Feed, Article, Category, AuthConfig, ProviderRegistry
- Provider tests: TheOldReader, Inoreader, Feedly (properties, auth, interface compliance, graceful returns)
- Widget tests: LoginScreen (dynamic form switching)
