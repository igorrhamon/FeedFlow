# Status das Ondas 5-8 — Execução realizada

> Data de atualização: 2026-08-05
> Branch principal: `main` (commit `07790dc`)
> Branch experimental: `novaVersao` (commit `dfecf7d` com Onda 7 parcial)

## Resumo executivo

As **Ondas 5-8** já foram **totalmente implementadas** e estão funcionais em `main`:

| Onda | Escopo | Status | Commit | Data |
|---|---|---|---|---|
| **5** | Event bus assíncrono, journal persistido, undo de regras | ✅ Concluído | `b40ffd7` | 2026-08-03 |
| **6** | Job queue com DAG, retry, JobRegistry, wiring final | ✅ Concluído | `b4ff505` | 2026-08-03 |
| **7** | `Document`, `SourceConnector`, ingestão universal | ✅ Concluído | `2b8641a` | 2026-08-03 |
| **8** | Knowledge Base, notas versionadas, busca unificada | ✅ Concluído | `498cc1e` + fixes `07790dc` | 2026-08-03 |

---

## Onda 5 — Journal de eventos + higiene

**Commits**: `b40ffd7` (feat), com contexto anterior em WS-16 (commit `fdd1361`)

### Funcionalidades entregues

1. **Event bus assíncrono**: `EventBus.publish()` retorna `Future<void>`, bloqueante até todos os subscribers completarem
2. **Journal persistido**: evento de domínio qualquer é serializado em `WorkItemEvents` via `PersistentJournalListener`
3. **Rule undo**: `RuleUndoUseCase` desinstancia via trilha de eventos (Onda 4 WS-16)
4. **Tipagem de eventos**: `type` enum em `WorkItemEvents` suporta valores anteriormente só publicados no bus

### Componentes novos

- `lib/application/rule_undo_use_case.dart` — undo de regras
- `lib/infrastructure/repositories/work_item_event_repository_drift.dart` — leitura da tabela de eventos
- `lib/application/journal_listener.dart` — persistência de qualquer evento

### Alterações em componentes

- `event_bus.dart`: `publish()` retorna `Future<void>` (breaking change na assinatura)
- `rule_engine.dart`: `async void` → `async` com `await` de `publish()`
- `database_provider.dart`: getters para `workItemEventRepository`/`ruleUndoUseCase`

### Modelo de dados

Nenhuma tabela nova — reaproveitou-se `WorkItemEvents`:
- `type` enum expandido
- `payload` JSON aguarda qualquer evento

### Testes

Suite de Onda 5 passa 100% — `flutter test` verde incluindo undo.

---

## Onda 6 — Job queue + DAG runner persistido

**Commits**: `feb2141` (domain models) → `afdc091` (schema) → `e1a3e0d` (JobRegistry) → `16870d9` (eventos) → `87593a4` (JobRunner) → `87fe9c0` (ActionInvocationJobHandler) → `463275c` (JobRunner wiring) → `b4ff505` (WorkflowRunner integration)

### Funcionalidades entregues

1. **Job queue persistida**: `jobs` table com payload tipado, status, dependências
2. **Retry com backoff exponencial**: `JobRun` registra tentativas, `maxAttempts` configurável
3. **DAG persistido**: `dependsOnJson` permite grafos lineares e fan-out
4. **JobRegistry**: factory pattern (espelho de `ActionRegistry`)
5. **ActionInvocationJobHandler**: cada `ActionInvocation` vira `Job`
6. **WorkflowRunner integrado**: workflows não somem se o app fechar no meio

### Componentes novos

- `lib/domain/job.dart` — `Job`, `JobStatus` enum, `JobRun`
- `lib/domain/repositories/job_repository.dart` — abstract repository
- `lib/infrastructure/repositories/job_repository_drift.dart` — drift impl
- `lib/application/job_runner.dart` — polling + execução em background
- `lib/application/job_registry.dart` — factory
- `lib/application/actions/action_invocation_job_handler.dart` — handler de ação como job
- `lib/application/jobs_init.dart` — inicialização do registry
- Schema: `jobs`, `job_runs` tables (schemaVersion 8 → 9)

### Alterações em componentes

- `workflow_runner.dart`: enfileira ações como jobs em vez de rodar inline
- `main.dart`: chamada a `initializeJobHandlers()`
- `database_provider.dart`: getter `jobRepository`/`jobRunner`
- `background_sync.dart`: pode chamar `flushOutbox()` via job queue

### Modelo de dados

```sql
Jobs: id(pk), type, payloadJson, status(pending|running|done|failed),
      dependsOnJson, attempts, maxAttempts, nextRunAt, createdAt

JobRuns: id(pk autoinc), jobId, startedAt, finishedAt, success, error
```

### Testes

Suite de Onda 6 passa — workflow linear de 3 passos sobrevive a restart do app.

---

## Onda 7 — `Document` + `SourceConnector`

**Commits**: `2b8641a` (main), com contexto em `novaVersao` (commit `dfecf7d` anterior)

### Funcionalidades entregues

1. **`Document` abstração**: conteúdo bruto + proveniência (source, author, url, timestamps, media type)
2. **`SourceConnector` interface**: espelho de `FeedProvider`, mas para fontes genéricas
3. **`RssSourceConnector`**: adaptador do `FeedProvider` existente → `Document`
4. **Ingestão universal**: `SyncService.ingest()` agora converte `Document → WorkItem` (não mais direto `Article → WorkItem`)
5. **Compatibilidade total**: 9 providers RSS funcionam sem alteração própria

### Componentes novos

- `lib/domain/document.dart` — `Document` (Freezed)
- `lib/domain/source_connector.dart` — `SourceConnector` interface
- `lib/application/source_connector_registry.dart` — factory
- `lib/infrastructure/connectors/rss_source_connector.dart` — adaptador
- Schema: `documents` table + FK lógica `WorkItems.documentId` nullable

### Alterações em componentes

- `sync_service.dart`: refeito para usar connector genérico
- `tables.dart`/`database.dart`: `WorkItems` ganha `documentId` nullable (migração aditiva)
- `provider_init.dart`: `SourceConnectorRegistry.register()` chamado no boot

### Modelo de dados

```sql
Documents: id(pk), sourceConnectorId, sourceId, contentType, title, author,
           rawContent, url, capturedAt, metadataJson

WorkItems: + documentId (nullable, FK lógica)
```

### Testes

Testes de `sync_service_test.dart` passam com o novo caminho `Document` — 9 providers continuam funcionando sem mudança.

---

## Onda 8 — Knowledge Base

**Commits**: `498cc1e` (feat principal), `07790dc` (merge com fixes), `7a14945` (correções de imports/tipos), `cc735b5` (updatedAt nullable), `ba81c50` (triggers FTS5), `985f42d` (preservar isRead/isStarred)

### Funcionalidades entregues

1. **Notas Markdown**: usuário cria nota vinculada a `Document`/`WorkItem`
2. **Versionamento append-only**: cada edição gera nova versão sem perder a anterior
3. **Busca unificada**: FTS5 indexa `Documents` além de `WorkItems` (títulos, conteúdo, autor, tags)
4. **Biblioteca navegável**: página `knowledge_base_page.dart` lista e busca documentos próprios
5. **Integração com triage**: nota é um tipo de `Document` (sourceConnectorId = `'local-note'`)

### Componentes novos

- `lib/domain/note.dart` — `Note` (Freezed)
- `lib/infrastructure/repositories/document_version_repository_drift.dart` — versionamento
- `lib/pages/note_editor_page.dart` — editor simples de notas
- `lib/pages/knowledge_base_page.dart` — browser de documentos + busca
- `lib/application/actions/note_action.dart` — "criar nota" como ação
- `lib/domain/repositories/document_repository_drift.dart` — queries em `documents`
- Schema: `document_versions` table + triggers FTS5 para `documents` + coluna `updatedAt` em `documents`

### Alterações em componentes

- `search_repository.dart`: passa a indexar `Documents` além de `WorkItems`
- `actions_init.dart`: registra `NoteAction` no `ActionRegistry`
- `pages/settings_page.dart`: link para Knowledge Base
- `tables.dart`/`database.dart`: nova tabela + triggers

### Modelo de dados

```sql
Documents: + updatedAt(nullable) para compatibilidade com Onda 7

DocumentVersions: id(pk autoinc), documentId, contentSnapshot, createdAt, changeNote

documents_fts5: tabela virtual indexando Documents title/content/author

Triggers: AFTER INSERT/UPDATE/DELETE em documents atualizando documents_fts5
```

### Testes

Suite completa passa:
- `document_version_repository_drift_test.dart` — versionamento
- `search_repository_drift_test.dart` — FTS5 sobre documents
- Sem regressão em `work_item_repository_drift_test.dart` ou páginas existentes

### Correções de schema pós-implementação

1. `cc735b5`: `updatedAt` em `documents` é nullable para compatibilidade com `DocumentVersion` anterior (não tinha data de update)
2. `ba81c50`: triggers FTS5 usam `rowid` interno do SQLite em vez de `id` TEXT para evitar inconsistências
3. `985f42d`: migração garante que `isRead`/`isStarred` são preservados no caminho `Article → Document → WorkItem`

---

## Estado do repositório (2026-08-05)

### Branch `main`

- Commit: `07790dc` (Merge pull request #40 — Onda 8)
- Testes: verdes
- Build: Android/iOS/web compilam
- Funcionalidades: Todas as Ondas 5-8 funcionales

### Branch `novaVersao`

- Commit: `dfecf7d` (Onda 7 parcial)
- Estado: experimental, a ser descontinuado — Onda 7 já está integrada em `main` via Onda 8

### Worktrees órfãs/históricos

- `worktree-ws16-rule-undo` (fdd1361) — base da Onda 5
- `sdd/onda6-task3-job-registry`, `sdd/onda6-task6-job-events` — partes da Onda 6
- `worktree-onda7-document-sourceconnector`, `worktree-onda8-implementation` — Ondas 7-8
- Muitas outras branches de trabalho paralelo (ver `git branch -vv`)

---

## O que falta para as próximas ondas (9+)

### Onda 9 — Conectores de arquivos

Escopo definido em `PLATFORM-ROADMAP.md` (pasta local, Markdown/Obsidian, PDF, Office).

Pré-requisito: Onda 7 ✅ (Document + SourceConnector abstraction)

### Onda 10 — Email (IMAP)

Escopo em roadmap. Novos componentes: `ImapSourceConnector`, forma de login para IMAP.

Pré-requisitos: Onda 7 ✅, Onda 6 ✅ (para poll via job)

### Continuação: Ondas 11-34

Ver `PLATFORM-ROADMAP.md` para detalhes de Fase A (ingestão), B (inteligência), C (planejamento), D (execução/agentes), E (plataforma).

---

## Observações e débito técnico

1. **Branch `novaVersao`** foi criada com Onda 7 parcial e agora está superada por `main` — considere descontinuar ou fazer rebase
2. **`Document.sourceId`** é string hoje — seria valor object (VO) para maior type-safety nas próximas ondas
3. **Triggers FTS5 manuais** funcionam bem, mas precisarão de migração ao passar de 3 para 4+ tipos de fonte (ordem de triggers importa)
4. **Job queue em `pending` estado**: nenhuma remoção automática de jobs bem-sucedidos antigos — adicionar política de limpeza (Onda 6 v1.1)
5. **`DocumentVersion.contentSnapshot`** é texto bruto — permitir diffs comprimidos (Onda 8 v1.1)

---

## Próximos passos (recomendados)

1. **Limpar branches**: remover `novaVersao`, `sdd/*`, worktrees órfãs (manter lista de nomes para referência histórica)
2. **Começar Onda 9**: arquivo connectors de pasta local como primeira extensão de ingestão
3. **Testar e-2-e**: fluxo completo de criação de nota + busca + regra disparando sobre nota
4. **Atualizar roadmap**: próximas 3 ondas devem estar detalhadas em planning doc (similar a Onda 5.md/Onda 2.md historicamente)
5. **Performance**: em voltas futuras, perfilar job queue (latência de polling) e FTS5 (com 10k+ documentos)
