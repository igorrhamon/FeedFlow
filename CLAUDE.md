# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FeedFlow** (package name `feedflow`, Android `applicationId io.feedflow.app`; the repo/directory is still named `the_old_reader` from before the rename) started as a Flutter RSS reader client supporting **9 providers** through a common `FeedProvider` interface: The Old Reader, Inoreader, FreshRSS, Miniflux, Tiny Tiny RSS, Feedbin, NewsBlur, Feedly, and Local OPML. It is being evolved (see `docs/EVOLUTION-PLAN.md`) into a **local-first information-processing/triage platform** on top of that provider layer, with a local SQLite (drift) store, article triage states, automation rules, and external-integration actions. Supports web, Android, iOS, Windows, Linux, macOS.

See **ARCHITECTURE.md** for the full multi-provider design (domain models, per-provider quirks, file layout) — note ARCHITECTURE.md predates the local-first triage/automation subsystem described below and does not cover it. See `docs/EVOLUTION-PLAN.md` for the target architecture of that subsystem and `docs/PARALLEL-EXECUTION-PLAN.md` for the phased/workstream (WS-N) execution log and what is and isn't built yet.

Note: AGENTS.md still documents the pre-multi-provider architecture (single `OldReaderApi`, no `FeedProvider`). Treat ARCHITECTURE.md and this file as authoritative for anything related to providers; AGENTS.md's API-quirks section (pagination, feed ID formats, quickadd query-param handling) is still accurate for the underlying Old Reader / Google-Reader-compatible API.

## Architecture

### Layers

- **`lib/models/`**: Freezed domain models — `Feed`, `Article`, `ArticleListResult`, `Category`, `UnreadCount` — shared across all providers. These remain DTOs for the *remote* provider layer.
- **`lib/providers/`**: One directory per provider (`theoldreader/`, `inoreader/`, `freshrss/`, `miniflux/`, `ttrss/`, `feedbin/`, `newsblur/`, `feedly/`, `local_opml/`), each implementing the abstract `FeedProvider` interface (`lib/providers/feed_provider.dart`, 28+ methods). Plus:
  - `provider_registry.dart` — factory/registry (`ProviderRegistry.create(id)`, `getAvailableProviders()`)
  - `provider_init.dart` — registers all 9 providers at startup (`initializeProviders()`, called from `main()`)
  - `auth/auth_config.dart` — Freezed auth config classes per auth type (`GoogleLoginAuthConfig`, `OAuth2AuthConfig`, `ApiKeyAuthConfig`, `BasicAuthConfig`, `LocalOpmlAuthConfig`)
  - Dependency rule: `lib/providers/` (ingestion) never knows about `WorkItem` — only `Article`. The `Article` → `WorkItem` conversion happens in `SyncService`.
- **`lib/domain/`, `lib/application/`, `lib/infrastructure/`**: the local-first triage/automation subsystem — see dedicated section below.
- **`lib/services/`**: `provider_settings.dart` (encrypted credential/settings storage via `flutter_secure_storage`, per-provider), `old_reader_api.dart` (legacy raw HTTP client, now wrapped by `TheOldReaderProvider`), and `background_sync.dart` / `background_sync_scheduler.dart` (Android background sync via `workmanager`; each job calls `DatabaseProvider.syncService?.ingest(...)` then `flushOutbox(...)`, degrading gracefully to widget-only updates if the local DB is unavailable, e.g. on web).
- **`lib/pages/`**: Material Design 3 UI. Pages consume `FeedProvider` for remote data and, increasingly, the local repositories (via `DatabaseProvider`) for triage/queue views — see `inbox_page.dart`, `rule_editor_page.dart`. The end-state goal (per `docs/EVOLUTION-PLAN.md`) is that pages stop calling `FeedProvider` directly and talk to use cases/repositories instead; this migration is in progress, not complete.
- **`lib/widget/feed_widget_service.dart`**: Android home-screen widget integration (`home_widget` package, app group `io.feedflow.app`).
- **`proxy/`**: Node.js Express server, web builds only (CORS bypass for providers that don't send CORS headers).

### Key Architectural Patterns

1. **Provider abstraction**: Every provider implements `FeedProvider` (auth, feeds, categories, articles, read/star state, unread counts, search, OPML import/export, preferences). Pages and `main.dart` depend only on this interface, obtained via `ProviderRegistry.create(providerId)`. A provider not supporting a feature (e.g. Feedly's OAuth2, read-mostly API) returns a graceful empty/no-op result rather than throwing — check an existing provider's unimplemented methods for the expected shape before adding a new one. This same "graceful degradation" convention is reused by the local automation layer (e.g. `DatabaseProvider` returns `null` repositories on web instead of throwing).

2. **Auth is per-provider-family, not universal**: `AuthType` enum = `googleLogin | oauth2 | apiKey | basicAuth | localFile`. Google-Reader-API-compatible providers (The Old Reader, Inoreader, FreshRSS) share request shape but differ in base URL and whether it's configurable (FreshRSS is self-hosted → user-supplied base URL; the others are fixed). `ProviderSettings` persists the chosen auth config (as `Object?`) and the active provider ID.

3. **Platform-aware API access (web CORS)**: Native platforms call provider APIs directly; web routes through `http://localhost:3000/proxy` since browsers enforce CORS and most of these APIs don't send permissive headers. Auto-detected via `kIsWeb`. Override with `OldReaderApi.setOverrideBaseUrl(url)` / `--dart-define=PROXY_URL=...`. Feedly's provider (`supportsWebProxy: false`) always calls the API directly regardless of platform. Separately, the local drift database is **entirely disabled on web** (`DatabaseProvider` getters return `null` under `kIsWeb`) — there is no sqlite3/WASM setup for web yet, so triage state, rules, outbox, and search only exist on native builds.

4. **The Old Reader / Google Reader API identifiers**: feed IDs are `feed/<ObjectId>` (e.g. `feed/00157a17b192950b65be3791`), not URLs. Categories/folders are `user/-/label/FolderName` — strip the prefix to get the display name. Other providers (Miniflux, TT-RSS, Feedbin, NewsBlur) use their own native ID schemes (integers, story hashes, etc.) — don't assume the `feed/<id>` format outside the Google-Reader-compatible providers.

5. **Adding a new provider**: create `lib/providers/{name}/{name}_provider.dart` implementing `FeedProvider`; add an auth config class in `auth_config.dart` if none of the existing 5 fit; register it in `provider_init.dart` with a `ProviderInfo` (set `requiresBaseUrl: true` if self-hosted); add tests under `test/providers/{name}/`. Login UI (`login_screen.dart`) adapts its form fields automatically based on `ProviderInfo.authTypes` / `requiresBaseUrl` — no separate UI wiring needed for the common auth types.

### Local-first triage/automation subsystem (`lib/domain/`, `lib/application/`, `lib/infrastructure/`)

A local-first layer sitting on top of the provider layer that gives every article a **local triage state** independent of any single provider's read/unread flag, plus rules-based automation and external export. Built incrementally as workstreams WS-1 through WS-14 (see `docs/PARALLEL-EXECUTION-PLAN.md` for exact status per workstream — as of the latest commit, WS-1 through WS-10 and WS-14 are done; WS-9 (Queue/QuerySpec), WS-11 (real bottom-sheet wiring), WS-12 (`RuleEngine` ↔ `ActionRegistry` wiring), WS-13 (enrichment actions), WS-15 (workflows) and WS-16 (undo) are not yet implemented). Follows a strict Clean Architecture dependency rule: `domain` imports nothing Flutter-specific; `application` imports `domain`; `infrastructure` implements `domain` repository interfaces.

- **`lib/domain/`** — pure models and abstract repository interfaces, no Flutter/DB imports:
  - `work_item.dart` — `WorkItem`, the aggregate root of local triage. Stable id `workItemIdFor(providerId, articleId)` = `"{providerId}:{articleId}"`; carries `TriageStatus`, `Priority`, `tags`, `snoozedUntil`, `isRead`/`isStarred`, independent of the remote provider's read/unread state. `WorkItem.fromArticle()` builds one from an ingested `Article`.
  - `triage_status.dart` — `TriageStatus` enum (`novo → triado → emAndamento → concluido/arquivado`) plus `kTriageTransitions`/`isValidTriageTransition`, the triage FSM.
  - `rule.dart` — `Rule`: a trigger (`onIngested`/`onStatusChanged`/`manual`/`schedule`) + a `Condition` tree (AND/OR/NOT) + a list of `ActionInvocation`s.
  - `enrichment.dart` / `enricher.dart` — AI enrichment result (summary/translation/classification/entities/suggestion) and the `Enricher` interface implemented by the LLM adapter.
  - `outbox_entry.dart` — a pending read/star mutation waiting to be pushed back to the remote provider (outbox pattern).
  - `article_action.dart` — the `ArticleAction` interface (`id`/`label`/`execute(item, params)`) implemented by every action in `application/actions/`.
  - `events/domain_event.dart` — `ArticleIngested`, `StatusChanged`, `ItemSnoozed`, `SnoozeExpired`, `ActionExecuted`, `RuleMatched`, `EnrichmentCompleted`/`Failed`, `SyncCompleted`/`Failed`.
  - `repositories/` — abstract `WorkItemRepository`, `RuleRepository`, `OutboxRepository`, `EnrichmentRepository`, `SearchRepository`.

- **`lib/application/`** — use cases/orchestration, imports `domain` only:
  - `event_bus.dart` — a simple synchronous `EventBus`; publishers/subscribers for `DomainEvent`s.
  - `rule_engine.dart` — subscribes to the event bus; on `ArticleIngested`/`StatusChanged`, loads enabled rules matching the trigger, evaluates the `Condition` tree via `ConditionEvaluator`, and on a match publishes `RuleMatched` for audit. **Action execution here is currently stubbed (logs only)** — real wiring to `ActionRegistry` is WS-12, not yet merged, even though `ActionExecutor`/`ActionRegistry` themselves are fully built and tested.
  - `condition_evaluator.dart` — operators: `equals`/`notEquals`/`contains`/`notContains`/`in`/`notIn`/`startsWith`/`endsWith`/`greaterThan`/`lessThan`/`exists`/`notExists`, combined via `all`/`any`/`not`, over fields like status/priority/tags/feedId/title/isRead/isSnoozed.
  - `action_registry.dart` / `action_executor.dart` — mirrors `provider_registry.dart`'s pattern for actions. `actions/actions_init.dart` registers the 10 built-in actions: `add_tag_action.dart`, `archive_action.dart`, `complete_action.dart`, `copy_link_action.dart`, `share_action.dart`, `snooze_action.dart`, `toggle_star_action.dart`, `webhook_action.dart`, `notion_export_action.dart`, `obsidian_export_action.dart`.
  - `integrations/` — `ExternalIntegration` implementations backing the export actions: `webhook_integration.dart`, `notion_integration.dart`, `obsidian_integration.dart`.
  - `sync_service.dart` — pulls articles from a `FeedProvider` and ingests them as `WorkItem`s (`Article` → `WorkItem` boundary lives here); applies read/star mutations locally-optimistic and enqueues them in the outbox (`OutboxRepository`) rather than rolling back on network failure — `flushOutbox()` reprocesses pending entries later. This replaces manual rollback logic that used to live in `feed_articles_page.dart`.
  - `snooze_use_case.dart` — snooze/wake-on-schedule logic for `WorkItem`s.

- **`lib/infrastructure/`** — concrete implementations of `domain` interfaces:
  - `db/database.dart`, `db/tables.dart` — drift/SQLite schema. Tables: `WorkItems`, `WorkItemEvents` (audit trail, write-only today — nothing reads it back yet, that's WS-16), `Enrichments`, `OutboxEntries`, `Rules`. Convention: every table uses `@DataClassName('XxxRow')` to avoid colliding with the same-named Freezed domain class (e.g. table `Rules` → `RuleRow`, domain class `Rule`).
  - `db/fts5_helpers.dart` — `stripHtmlTags()` / `tagsJsonToPlaintext()` helpers preparing plain text for the FTS5 full-text-search virtual table (WS-17; search over title/content/author/tags, kept in sync via SQL triggers rather than Dart code, per `docs/PARALLEL-EXECUTION-PLAN.md` §WS-17).
  - `db/database_provider.dart` — lazy singleton access point: `DatabaseProvider.repository` / `.outboxRepository` / `.searchRepository` / `.ruleRepository` / `.syncService`. **Every getter returns `null` under `kIsWeb`** — callers must handle the null/no-op case (see `background_sync.dart`'s `_ingestArticlesWithFallback` for the expected pattern).
  - `repositories/*_drift.dart` — drift-backed implementations of each `domain/repositories/` interface. `event_emitting_work_item_repository.dart` is a decorator around `WorkItemRepositoryDrift` that publishes `ArticleIngested`/`StatusChanged` on every mutation — this decorator (not the raw drift repo) is what `DatabaseProvider.repository` actually returns.
  - `llm/llm_adapter.dart` / `llm/openrouter_adapter.dart` / `llm/google_ai_studio_adapter.dart` — three `Enricher` implementations (Anthropic Claude, OpenRouter, Google AI Studio/Gemini), all supporting `summary`/`translation`/`classification`. Each has its own API key in `flutter_secure_storage` (`LlmProviderId.*.credentialKey`, e.g. `llm_anthropic_api_key`). `llm/llm_enricher_router.dart` (`LlmEnricherRouter`) is what `DatabaseProvider.enricher` actually returns — it re-resolves the active provider (`lib/services/llm_settings.dart`) on every `enrich()` call, so switching provider in `lib/pages/llm_settings_page.dart` (Settings → "Provedor de IA") takes effect without restarting the app. `llm/llm_prompts.dart` holds the shared prompt templates.

- **UI entry points**: `lib/pages/inbox_page.dart` (4th bottom-nav tab; triage queue, status/snooze actions) and `lib/pages/rule_editor_page.dart` (linked from Settings, not its own tab; CRUD for rules plus a dry-run preview that evaluates a rule's condition against real sampled `WorkItem`s before saving — MVP only supports simple, non-composite conditions via the form).

- **Testing convention**: mirrors production structure — `test/application/actions/*_test.dart` (one per action), `test/application/{action_executor,action_registry,rule_engine}_test.dart`, `test/domain/work_item_test.dart`, `test/infrastructure/*_drift_test.dart` (drift repositories, run against an in-memory drift DB), `test/pages/rule_editor_page_test.dart`. `test/fts5_validation_test.dart` at the top level specifically validates FTS5 trigger behavior (accented/HTML content indexing, delete/update trigger correctness).

## Common Commands

### Setup & Dependencies

```bash
flutter pub get                          # Dart/Flutter deps
npm install                               # proxy deps (web only)
flutter pub run build_runner build       # regenerate Freezed/json_serializable/drift code after touching lib/models, auth_config, or lib/domain|infrastructure/db
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
flutter test --reporter expanded          # all unit/widget tests (test/models, test/providers/*, test/domain, test/application, test/infrastructure, test/pages, widget_test.dart, etc.)
flutter test test/providers/feedly/feedly_provider_test.dart   # single test file
flutter test test/application/rule_engine_test.dart            # single test file, rule engine subsystem
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
├── domain/                          # Pure models + abstract repos: work_item, triage_status, rule,
│   │                                 # enrichment/enricher, outbox_entry, article_action, events/, repositories/
│   ├── events/                      # domain_event.dart (ArticleIngested, StatusChanged, RuleMatched, ...)
│   └── repositories/                # WorkItemRepository, RuleRepository, OutboxRepository, ...
├── application/                     # Use cases: rule_engine, condition_evaluator, event_bus, sync_service,
│   │                                 # action_registry, action_executor, snooze_use_case
│   ├── actions/                     # ArticleAction impls: add_tag, archive, complete, copy_link, share,
│   │                                 # snooze, toggle_star, webhook, notion_export, obsidian_export,
│   │                                 # summarize, translate, classify
│   └── integrations/                # webhook_integration, notion_integration, obsidian_integration
├── infrastructure/
│   ├── db/                          # database.dart, tables.dart (drift schema), database_provider.dart,
│   │                                 # fts5_helpers.dart
│   ├── repositories/                # *_drift.dart impls + event_emitting_work_item_repository.dart (decorator)
│   └── llm/                         # llm_adapter (Anthropic), openrouter_adapter, google_ai_studio_adapter,
│                                     # llm_enricher_router (delegates to active provider), llm_prompts
├── services/
│   ├── provider_settings.dart       # Encrypted per-provider credential/settings storage
│   ├── llm_settings.dart            # Active LLM provider (LlmProviderId) persistence
│   ├── old_reader_api.dart          # Legacy API (TheOldReaderProvider)
│   ├── background_sync.dart         # Android background sync (calls SyncService.ingest/flushOutbox)
│   └── background_sync_scheduler.dart
├── widget/feed_widget_service.dart  # Android home-screen widget
└── pages/                           # login_page, splash_screen, login_screen, home_page,
                                      # inbox_page (triage queue), feed_articles_page, article_page,
                                      # favorites_page, folders_page, folder_feeds_page, add_feed_page,
                                      # subscriptions_page, search_page, settings_page, rule_editor_page,
                                      # llm_settings_page

proxy/           # proxy.js, proxy-debug.js, config.json, test-quickadd.js — web CORS only
test/            # models/, providers/{feedly,inoreader}/, domain/, application/{,actions}/, infrastructure/,
                 # repositories/, llm/, pages/, provider_registry_test.dart, widget_test.dart, ...
tests/           # login.spec.ts (Playwright E2E, web only)
docs/            # EVOLUTION-PLAN.md (target architecture), PARALLEL-EXECUTION-PLAN.md (WS-N execution log)
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

- 4 bottom tabs (Feeds, Inbox, Favoritos, Ajustes) via `_selectedIndex` (0-3) in `main.dart`, added to an `IndexedStack`.
- "Pastas" (drawer) opens via `Navigator.push`, not `IndexedStack` — adding it to the `IndexedStack` breaks the `NavigationBar` assertion.
- `AddFeedPage` opens via FAB on the Feeds tab; returns `true` when a feed was added.
- `rule_editor_page.dart` is reached from Settings, not a bottom tab.

## Dependencies of note

- **freezed** / **json_serializable**: all domain models and auth configs — run `build_runner` after editing any `@freezed` class.
- **drift** / **drift_dev**: local SQLite ORM backing `lib/infrastructure/db/`; run `build_runner` after touching `tables.dart` or `database.dart`. Web is unsupported (`DatabaseProvider` returns `null` under `kIsWeb`) — there is no sqlite3/WASM setup yet.
- **workmanager**: Android background sync scheduling (`background_sync_scheduler.dart`).
- **uuid**: generates ids for local domain entities (rules, outbox entries, etc.).
- **flutter_secure_storage**: encrypted credential storage for every provider's auth config, and for the LLM adapter's API key.
- **flutter_web_auth_2**: OAuth2 flow for Feedly.
- **flutter_html**: article HTML rendering.
- **share_plus** / **path_provider**: OPML export, share action.
- **url_launcher**: opening external links (e.g. copy_link/webhook-adjacent actions).
- **home_widget**: Android home-screen widget.
- **provider** (^6.1.2): declared but not deeply integrated — most state is still local `setState`; planned for shared app state in a later phase (see `docs/EVOLUTION-PLAN.md` §2.4).
- **Android JDK 17** required for Windows Android builds; set `$env:JAVA_HOME` first (see Building above).

## Cross-References

- **ARCHITECTURE.md** — full multi-provider design: domain model definitions, `FeedProvider` interface, per-provider implementation notes, "Adding a New Provider" checklist. Does not cover `lib/domain|application|infrastructure`.
- **AGENTS.md** — API quirks reference for the Google-Reader-compatible API; its architecture section predates the multi-provider refactor and describes the old single-`OldReaderApi` design.
- **docs/EVOLUTION-PLAN.md** — target architecture and rationale for the local-first triage/automation subsystem (bounded contexts, `WorkItem` model, dependency rules).
- **docs/PARALLEL-EXECUTION-PLAN.md** — workstream (WS-N) breakdown, merge order, schema-ownership conflicts, and current build/verification status for that subsystem; check here before assuming a WS-N feature is finished.
