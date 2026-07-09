# AGENTS.md

## Commands

```bash
flutter pub get                          # install Dart deps
npm install                              # install proxy deps
flutter analyze                          # lint + static analysis (no typecheck step)
flutter test --reporter expanded         # widget tests
npx playwright test                      # E2E (web only, needs proxy + env vars)
flutter build apk --debug --split-per-abi  # Android debug APK (arm64-v8a, armeabi-v7a, x86_64)
```

## Build quirk (Windows)

`JAVA_HOME` must be set explicitly before any `flutter build`:
```powershell
$env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17-extracted\jdk17"
```

## Platform-aware API access

- Native (Android/iOS/Windows/Linux/macOS): calls `https://theoldreader.com/reader/api/0` directly
- Web: calls `http://localhost:3000/proxy` via a Node.js Express proxy (CORS bypass)
- Detection is automatic via `kIsWeb` in `OldReaderApi.baseUrl`
- Override with `OldReaderApi.setOverrideBaseUrl(url)` or `--dart-define=PROXY_URL=...`

## Auth

Token obtained via `POST /accounts/ClientLogin` with `Email`/`Passwd` params.
Sent as `Authorization: GoogleLogin auth=<token>` on every request.
Stored via `flutter_secure_storage` (`AuthService` in `lib/services/auth_service.dart`).

## Architecture

- No state management framework. `MainScaffold` in `lib/main.dart` holds `OldReaderApi` and passes it down via constructor. Pages use `setState`.
- All API methods live in `lib/services/old_reader_api.dart` (~530 lines, ~40 methods).
- `lib/pages/` contains UI. Starred articles are managed via `FeedProvider.getStarredArticles()` / `starArticle()` / `unstarArticle()`.
- `lib/proxy_config.dart` does not exist; proxy port is configured via `OldReaderApi.setProxyPort(int)`.

## API quirks

- `subscription/quickadd` requires `quickadd` as a **query parameter**, not in body. The proxy handles this by moving the body param to the query string.
- Feed identifiers use `feed/<ObjectId>` format (e.g. `feed/00157a17b192950b65be3791`), not URLs.
- Categories/folders use label IDs like `user/-/label/FolderName`. Extract the name by stripping `user/-/label/` prefix.
- `getItemsContentsApi` batches item content fetches in groups of 250.
- `tag/list`, `subscription/list`, `unread-count` have **no pagination** — return all data at once.
- `stream/items/ids` and `stream/contents` support pagination via `n` (limit, max 10000/1000), `c` (continuation), `nt`/`ot` (timestamps).
- Article content can be JSON or Atom XML. `feed_articles_page.dart` tries JSON first, falls back to XML parsing.
- `extractCategoriesFromTagsResponse` filters tags by `user/-/label/` prefix — only handles JSON.

## Navigation

- 3 bottom tabs (Feeds, Favoritos, Config.) mapped via `_selectedIndex` (0-2).
- "Pastas" in the drawer opens via `Navigator.push` (not IndexedStack) — adding it to IndexedStack will crash the NavigationBar assertion.
- `AddFeedPage` opens via FAB on "Feeds" tab; returns `true` if a feed was added.
