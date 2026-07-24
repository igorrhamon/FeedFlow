# Changelog

All notable changes to FeedFlow will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Onda 4 (WS-16, undo de regras de automação) implementada e testada no branch
  `worktree-ws16-rule-undo`, pendente de merge em `novaVersao`.
- Planejamento da evolução para plataforma de inteligência pessoal em
  `docs/PLATFORM-ROADMAP.md` (Ondas 5-34).

## [1.1.3]

- CI: versionamento automático (bump de patch) a cada push em `main`.

## [1.1.2]

- Fix: base-href do build web ajustado para `/FeedFlow/` (GitHub Pages de projeto).

## [1.1.1]

- CI: criação automática de GitHub Release em push de tag `v*`.

## [1.1.0]

### Added

- **Local-first triage/automation subsystem** (`lib/domain/`, `lib/application/`,
  `lib/infrastructure/`), construído incrementalmente via workstreams WS-1 a WS-17:
  - Persistência local com **drift/SQLite** (`WorkItem`, FSM de triagem
    `novo → triado → emAndamento → concluído/arquivado`).
  - **Inbox** (`inbox_page.dart`) com fila de triagem, ações via bottom-sheet/swipe.
  - **Rule Engine** (`rule_engine.dart`) e **Action Registry/Executor** com 13 ações
    registradas (concluir, arquivar, adiar, favoritar, compartilhar, copiar link, tag,
    webhook, export Notion/Obsidian, resumir/traduzir/classificar).
  - **Editor de regras** (`rule_editor_page.dart`) com dry-run.
  - **Queue/QuerySpec** (`queue_editor_page.dart`) — filas customizadas de itens.
  - **Busca full-text local (FTS5)** sobre título/conteúdo/autor/tags, sincronizada por
    triggers SQL (`lib/infrastructure/db/fts5_helpers.dart`).
  - **Enriquecimento por IA**: adapters Anthropic, OpenRouter e Google AI Studio via
    `LlmEnricherRouter`, configurável em Ajustes → "Provedor de IA".
  - **Workflows**: `WorkflowRunner` executa sequências de ações com trilha de eventos.
  - **Integrações externas**: Notion, Obsidian e webhooks genéricos.
  - **Outbox pattern**: mutações de read/star aplicadas otimisticamente e
    reenviadas ao provider remoto via fila (`SyncService.flushOutbox`).
  - **Background sync** via `workmanager` (Android), integrado ao `SyncService`.
- Security hardening: CORS, prevenção de vazamento de token de auth, sanitização de
  erro, timeouts, prevenção de injeção JSON.
- Isolamento de drift/sqlite3 (`dart:ffi`) do build web via import condicional —
  `DatabaseProvider` retorna `null` sob `kIsWeb` (sem sqlite3/WASM ainda).

### Fixed

- 28 issues de `flutter analyze` resolvidas.
- Página em branco no build web (`Platform.isAndroid` não suportado em web).
- Ícones customizados do Android (mipmap `ic_launcher_round`) versionados.

## [1.0.0] — Fase 1: fundação multi-provider

### Added

- **Multi-provider RSS architecture**: interface abstrata `FeedProvider`,
  `ProviderRegistry` (factory), 9 providers implementados (The Old Reader, Inoreader,
  FreshRSS, Miniflux, Tiny Tiny RSS, Feedbin, NewsBlur, Feedly, Local OPML).
- Modelos de domínio com Freezed: `Feed`, `Article`, `Category`, `UnreadCount`,
  `ArticleListResult`.
- Autenticação por tipo (`GoogleLogin`, `OAuth2`, `ApiKey`, `BasicAuth`, `LocalFile`)
  com persistência criptografada via `ProviderSettings`/`flutter_secure_storage`.
- Gerenciamento de pastas nas assinaturas (`FolderFeedsPage`, `FoldersPage`).

### Changed

- Estrutura reorganizada: `lib/models/`, `lib/providers/`.

## Development Notes

Ver `CLAUDE.md` para comandos de build/teste completos por plataforma e a
arquitetura atual de camadas (`lib/providers` → `lib/domain`/`application`/
`infrastructure` → `lib/pages`).

## Cross-references

- `docs/EVOLUTION-PLAN.md` — arquitetura alvo do subsistema local-first.
- `docs/PARALLEL-EXECUTION-PLAN.md` — histórico de workstreams (WS-N) e status real.
- `docs/PLATFORM-ROADMAP.md` — roadmap de evolução para plataforma de inteligência
  pessoal (Ondas 5-34).
