# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FeedFlow** (package name `feedflow`, Android `applicationId io.feedflow.app`; the repo/directory is still named `the_old_reader` from before the rename) is a Flutter RSS reader client supporting **9 providers** through a common `FeedProvider` interface: The Old Reader, Inoreader, FreshRSS, Miniflux, Tiny Tiny RSS, Feedbin, NewsBlur, Feedly, and Local OPML. Supports web, Android, iOS, Windows, Linux, macOS.

See **ARCHITECTURE.md** for the full multi-provider design (domain models, per-provider quirks, file layout). This file covers commands and the patterns most likely to trip up an edit.

Note: AGENTS.md still documents the pre-multi-provider architecture (single `OldReaderApi`, no `FeedProvider`). Treat ARCHITECTURE.md and this file as authoritative for anything related to providers; AGENTS.md's API-quirks section (pagination, feed ID formats, quickadd query-param handling) is still accurate for the underlying Old Reader / Google-Reader-compatible API.

## Architecture

### Layers

- **`lib/models/`**: Freezed domain models — `Feed`, `Article`, `ArticleListResult`, `Category`, `UnreadCount` — shared across all providers.
- **`lib/providers/`**: One directory per provider (`theoldreader/`, `inoreader/`, `freshrss/`, `miniflux/`, `ttrss/`, `feedbin/`, `newsblur/`, `feedly/`, `local_opml/`), each implementing the abstract `FeedProvider` interface (`lib/providers/feed_provider.dart`, 28+ methods). Plus:
  - `provider_registry.dart` — factory/registry (`ProviderRegistry.create(id)`, `getAvailableProviders()`)
  - `provider_init.dart` — registers all 9 providers at startup (`initializeProviders()`, called from `main()`)
  - `auth/auth_config.dart` — Freezed auth config classes per auth type (`GoogleLoginAuthConfig`, `OAuth2AuthConfig`, `ApiKeyAuthConfig`, `BasicAuthConfig`, `LocalOpmlAuthConfig`)
- **`lib/services/`**: `provider_settings.dart` (encrypted credential/settings storage via `flutter_secure_storage`, per-provider), `old_reader_api.dart` (legacy raw HTTP client, now wrapped by `TheOldReaderProvider`), and `background_sync.dart` / `background_sync_scheduler.dart` (Android background sync).
- **`lib/pages/`**: Material Design 3 UI. All pages consume `FeedProvider`, not `OldReaderApi`, directly.
- **`lib/widget/feed_widget_service.dart`**: Android home-screen widget integration (`home_widget` package, app group `io.feedflow.app`).
- **`proxy/`**: Node.js Express server, web builds only (CORS bypass for providers that don't send CORS headers).

### Key Architectural Patterns

1. **Provider abstraction**: Every provider implements `FeedProvider` (auth, feeds, categories, articles, read/star state, unread counts, search, OPML import/export, preferences). Pages and `main.dart` depend only on this interface, obtained via `ProviderRegistry.create(providerId)`. A provider not supporting a feature (e.g. Feedly's OAuth2, read-mostly API) returns a graceful empty/no-op result rather than throwing — check an existing provider's unimplemented methods for the expected shape before adding a new one.

2. **Auth is per-provider-family, not universal**: `AuthType` enum = `googleLogin | oauth2 | apiKey | basicAuth | localFile`. Google-Reader-API-compatible providers (The Old Reader, Inoreader, FreshRSS) share request shape but differ in base URL and whether it's configurable (FreshRSS is self-hosted → user-supplied base URL; the others are fixed). `ProviderSettings` persists the chosen auth config (as `Object?`) and the active provider ID.

3. **Platform-aware API access (web CORS)**: Native platforms call provider APIs directly; web routes through `http://localhost:3000/proxy` since browsers enforce CORS and most of these APIs don't send permissive headers. Auto-detected via `kIsWeb`. Override with `OldReaderApi.setOverrideBaseUrl(url)` / `--dart-define=PROXY_URL=...`. Feedly's provider (`supportsWebProxy: false`) always calls the API directly regardless of platform.

4. **The Old Reader / Google Reader API identifiers**: feed IDs are `feed/<ObjectId>` (e.g. `feed/00157a17b192950b65be3791`), not URLs. Categories/folders are `user/-/label/FolderName` — strip the prefix to get the display name. Other providers (Miniflux, TT-RSS, Feedbin, NewsBlur) use their own native ID schemes (integers, story hashes, etc.) — don't assume the `feed/<id>` format outside the Google-Reader-compatible providers.

5. **Adding a new provider**: create `lib/providers/{name}/{name}_provider.dart` implementing `FeedProvider`; add an auth config class in `auth_config.dart` if none of the existing 5 fit; register it in `provider_init.dart` with a `ProviderInfo` (set `requiresBaseUrl: true` if self-hosted); add tests under `test/providers/{name}/`. Login UI (`login_screen.dart`) adapts its form fields automatically based on `ProviderInfo.authTypes` / `requiresBaseUrl` — no separate UI wiring needed for the common auth types.

## Common Commands

### Setup & Dependencies

```bash
flutter pub get                          # Dart/Flutter deps
npm install                               # proxy deps (web only)
flutter pub run build_runner build       # regenerate Freezed/json_serializable code after touching lib/models or auth_config
flutter pub run build_runner clean       # if codegen gets stuck
```

### Running

```bash
flutter run                               # Android/iOS/desktop

# Web (needs proxy running separately for CORS):
node proxy/proxy.js                       # terminal 1
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1   # terminal 2

# Combined web + proxy launcher:
.\direct-launcher.bat        # Windows
pwsh .\start-web-app.ps1     # PowerShell
./direct-launcher.sh         # macOS/Linux

node proxy/proxy-debug.js    # proxy with verbose logging
```

### Building

```bash
# Windows requires JAVA_HOME set before any Android build:
$env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17-extracted\jdk17"

flutter build apk --debug --split-per-abi     # fast Android debug build
flutter build apk --release --split-per-abi
flutter build ios --release
flutter build web --release
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

### Testing

```bash
flutter test --reporter expanded          # all unit/widget tests (test/models, test/providers/*, widget_test.dart, etc.)
flutter test test/providers/feedly/feedly_provider_test.dart   # single test file
flutter test --verbose

# Playwright E2E (web only; env var names still use the pre-rename prefix, not "feedflow_*"):
export the_old_reader_email="your@email.com"
export the_old_reader_password="your_password"
npx playwright test                       # requires proxy running on :3000
npx playwright test login.spec.ts
npx playwright test --grep "@skip"        # skip if env vars unset
npx playwright test --debug
```

### Code Quality

```bash
flutter analyze          # static analysis, no separate typecheck step
flutter pub outdated
```

## Project Structure

```
lib/
├── main.dart                        # Entry point, initializeProviders(), MyApp/theme
├── models/                          # Feed, Article, ArticleListResult, Category, UnreadCount (Freezed)
├── providers/
│   ├── feed_provider.dart           # Abstract FeedProvider interface
│   ├── provider_registry.dart       # Factory/registry
│   ├── provider_init.dart           # Registers all 9 providers
│   ├── auth/auth_config.dart        # Per-auth-type Freezed config classes
│   ├── theoldreader/  inoreader/  freshrss/  miniflux/  ttrss/
│   ├── feedbin/  newsblur/  local_opml/
│   └── feedly/                      # feedly_provider.dart + feedly_auth.dart (OAuth2 + refresh)
├── services/
│   ├── provider_settings.dart       # Encrypted per-provider credential/settings storage
│   ├── old_reader_api.dart          # Legacy raw HTTP client, wrapped by TheOldReaderProvider
│   ├── background_sync.dart         # Android background sync
│   └── background_sync_scheduler.dart # Android background sync scheduler
├── widget/feed_widget_service.dart  # Android home-screen widget
└── pages/                           # login_screen, home_page, feed_articles_page,
                                      # article_page, favorites_page, folders_page,
                                      # folder_feeds_page, add_feed_page, subscriptions_page,
                                      # search_page, settings_page

proxy/           # proxy.js, proxy-debug.js, config.json, test-quickadd.js — web CORS only
test/            # models/, providers/{feedly,inoreader}/, provider_registry_test.dart, widget_test.dart, ...
tests/           # login.spec.ts (Playwright E2E, web only)
```

## Critical Implementation Details

### The Old Reader / Google Reader API quirks (apply to TheOldReader, Inoreader, FreshRSS providers)

- Auth: `POST /accounts/ClientLogin` (Email/Passwd) → token sent as `Authorization: GoogleLogin auth=<token>` on every request.
- `subscription/quickadd` requires `quickadd` as a **query parameter**, not in the request body — the proxy (`proxy/proxy.js`, ~line 100+) moves it from body to query string for web.
- Pagination: `stream/items/ids` / `stream/contents` support `n` (limit, max 10000/1000), `c` (continuation), `nt`/`ot` (timestamps). `tag/list`, `subscription/list`, `unread-count` return everything at once — no pagination.
- Article content can be JSON or Atom XML; `feed_articles_page.dart` tries JSON first, falls back to XML parsing.
- `getItemsContentsApi` batches item content fetches in groups of 250.

### Other providers

- **Miniflux**: distinct REST API (`/v1/...`), `X-Auth-Token` header, JSON objects rather than Google Reader shape.
- **TT-RSS**: session-based auth (login returns `session_id`), POST-based API at `/api/`, integer IDs.
- **Feedbin**: REST + Basic Auth, fixed base URL `https://api.feedbin.com/v2`, categories via "taggings".
- **NewsBlur**: Basic Auth, story hashes instead of integer IDs, folder-based organization.
- **Feedly**: OAuth2 via `FeedlyAuth` (authorize + token refresh), `https://cloud.feedly.com`; read-mostly — mutation methods (addFeed, createCategory, markAllAsRead, search, OPML, preferences, etc.) return gracefully rather than being implemented.
- **Local OPML**: no network, parses an OPML file for a read-only feed list.

### Navigation

- 3 bottom tabs (Feeds, Favoritos, Config.) via `_selectedIndex` (0-2).
- "Pastas" (drawer) opens via `Navigator.push`, not `IndexedStack` — adding it to the `IndexedStack` breaks the `NavigationBar` assertion.
- `AddFeedPage` opens via FAB on the Feeds tab; returns `true` when a feed was added.

## Dependencies of note

- **freezed** / **json_serializable**: all domain models and auth configs — run `build_runner` after editing any `@freezed` class.
- **flutter_secure_storage**: encrypted credential storage for every provider's auth config.
- **flutter_web_auth_2**: OAuth2 flow for Feedly.
- **flutter_html**: article HTML rendering.
- **share_plus** / **path_provider**: OPML export.
- **home_widget**: Android home-screen widget.
- **provider** (^6.1.2): declared but not deeply integrated — most state is still local `setState`.
- **Android JDK 17** required for Windows Android builds; set `$env:JAVA_HOME` first (see Building above).

## Cross-References

- **ARCHITECTURE.md** — full multi-provider design: domain model definitions, `FeedProvider` interface, per-provider implementation notes, "Adding a New Provider" checklist.
- **AGENTS.md** — API quirks reference for the Google-Reader-compatible API; its architecture section predates the multi-provider refactor and describes the old single-`OldReaderApi` design.
