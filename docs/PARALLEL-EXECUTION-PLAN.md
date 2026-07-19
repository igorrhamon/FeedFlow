# Plano de paralelização — fim da Fase 2 e Fases 3-5 do FeedFlow

## Contexto

O plano de evolução arquitetural do FeedFlow (`docs/EVOLUTION-PLAN.md`) está com as Fases 0 e 1 completas e a Fase 2 parcialmente feita: o outbox e o `SyncService` (escrita otimista de read/star com fila de reenvio) já existem e estão testados, mas a *leitura* das páginas (Favoritos, Feed Articles, Home) ainda vem 100% do `FeedProvider` remoto — nenhuma delas consome o `WorkItemRepository` local ainda, e há um gap conhecido (`_markAllAsRead` em `feed_articles_page.dart:236` ainda ignora o outbox).

O objetivo deste documento é dividir o restante (fim da Fase 2 + Fases 3, 4 e 5) em workstreams que agentes diferentes, em worktrees separadas, possam executar em paralelo, respeitando só as dependências que são pré-requisito real — não a ordem numérica das fases do documento original.

**Achado-chave que muda o escopo**: `WorkItem` (`lib/domain/work_item.dart`) já tem `tags`, `priority`, `notes`, `isStarred`, `snoozedUntil`; `TriageStatus`+`kTriageTransitions` (FSM) já existem; `WorkItemRepository`/`WorkItemRepositoryDrift` já expõem streams reativas testadas (`watchByStatus`, `watchCountByStatus`, `changeStatus`). Isso elimina boa parte do trabalho de domínio que a Fase 3 previa do zero. Também: o background sync via `workmanager` **já existe e funciona** (`lib/services/background_sync_scheduler.dart`) — só falta integrá-lo ao `SyncService`/outbox, não criá-lo.

**Adição ao escopo original (não coberta pelo documento-fonte)**: busca full-text local via **FTS5 do SQLite** (título, conteúdo, autor, tags) — recurso de alto valor para um leitor RSS, e o `drift` já usado no projeto suporta tabelas virtuais FTS5. Entra como workstream própria (WS-17, ver Onda 1), pois depende só de `work_items` (Fase 1, já pronta), não de nada das Fases 3-5.

## Hotspots estruturais (valem para todas as ondas)

1. **`lib/infrastructure/db/tables.dart` + `database.dart`** (schema drift, `schemaVersion`). Regra: **uma única workstream "dona do schema" por onda** — quem cria/altera tabela faz o bump de versão; as demais que precisem de schema esperam a próxima onda e fazem rebase sobre a versão final.
2. **`lib/domain/repositories/work_item_repository.dart` + `..._drift.dart`**: várias workstreams vão adicionar métodos novos (`watchStarred`, `watchByFeedId`, `watchByQuerySpec`). São edições aditivas — **sempre acrescentar métodos no fim da classe**, nunca no meio, para não sobrepor diffs.
3. **`lib/main.dart` (`MainScaffold`)**: `IndexedStack` de 3 filhos + `NavigationBar` de 3 destinos casados por índice. Migrar construtores de páginas (Onda 1) e adicionar a aba Inbox (Onda 2) tocam a mesma região — **Onda 2 só entra depois que as edições de `main.dart` da Onda 1 já mergearam**.
4. **`lib/pages/article_page.dart`**: `dynamic article` com branches `is Article`/`is Map` em 5 métodos (`_getArticleId`, `_getTitle`, `_getAuthor`, `_getPublished`, `_getContent`, confirmado por leitura). A primeira workstream que precisar exibir `WorkItem` aqui (Favoritos) adiciona o branch `is WorkItem` de uma vez; as demais só reaproveitam.
5. **`lib/infrastructure/db/database_provider.dart:25`**: `_workItemRepository ??= WorkItemRepositoryDrift(_database!)` — confirmado como diff de **uma linha** para envolver com um Decorator de emissão de eventos, sem tocar `WorkItemRepositoryDrift` (evita conflito com as workstreams de leitura que só consomem `DatabaseProvider.repository`).

## Onda 0 — trivial, qualquer momento

**WS-0**: criar `docs/EVOLUTION-PLAN.md` (referenciado morto em 4 comentários — `app_settings.dart:17`, `sync_service.dart:9`, `feed_articles_page.dart:119,171` — mas o arquivo não existe). **Concluído** — ver `docs/EVOLUTION-PLAN.md`.

## Onda 1 — 7 workstreams paralelas, começam imediatamente

| WS | Escopo | Cria/edita | Dependência real |
|---|---|---|---|
| **WS-1** Favoritos local | `favorites_page.dart` lê via stream do `WorkItemRepository`; adiciona suporte `is WorkItem` em `article_page.dart` | + método aditivo `watchStarred`/filtro em `work_item_repository(_drift).dart`; `main.dart` (construtor) | nenhuma |
| **WS-2** Feed Articles local + fix `_markAllAsRead` | Troca fonte de artigos por stream filtrado por `feedId`; corrige `_markAllAsRead` para passar pelo `SyncService`/outbox | + `watchByFeedId` aditivo | nenhuma (coordenar com WS-1 quem edita `article_page.dart` primeiro — evitar tocar os mesmos 5 getters em paralelo) |
| **WS-3** Home local (contagens) | Badge de não lidos por feed vira local; lista de feeds/categorias continua remota | + `watchUnreadCountsByFeed` aditivo; `main.dart` (construtor) | nenhuma |
| **WS-4** Background sync real | `background_sync.dart` passa a chamar `DatabaseProvider.syncService?.ingest(...)` e `flushOutbox(...)` dentro do job já existente | só edita `background_sync.dart` | nenhuma — é extensão do workmanager já funcional, não criação |
| **WS-5** Event bus + domínio de regras (skeleton) | `domain/events/domain_event.dart`, `application/event_bus.dart` (bus síncrono simples), `domain/rule.dart` (Rule/Condition/ActionInvocation/RuleTrigger), `RuleRepository` + `rule_repository_drift.dart` + tabela nova `Rules` (**dona do schema desta onda**), `application/rule_engine.dart` com execução de ações **stubada** (sem `ActionRegistry` ainda) | Decorator de 1 linha em `database_provider.dart` (item 5 acima) — **mergeia por último na onda** | nenhuma |
| **WS-6** Enricher + LLM adapter | `domain/enrichment.dart`, `domain/enricher.dart`, `EnrichmentRepository`+drift (usa o schema `Enrichments` **já existente**, sem alterar tabela), `infrastructure/llm/llm_adapter.dart` (usa `http`+`flutter_secure_storage`, já no pubspec) | nada em `tables.dart` (adia colunas extra de custo/tokens para quando for a única dona do schema) | nenhuma |
| **WS-17** Full Text Search (FTS5) | Tabela virtual `work_items_fts` (FTS5) indexando título/conteúdo/autor/tags, sincronizada por **triggers SQL** (AFTER INSERT/UPDATE/DELETE em `work_items`) — não por código Dart em `work_item_repository_drift.dart`, evitando tocar esse arquivo; `domain/repositories/search_repository.dart` + `search_repository_drift.dart` (query `MATCH`/`bm25()`); integra como fonte adicional em `pages/search_page.dart` (hoje só busca remota via `FeedProvider.search()`) | tabela nova + triggers em `tables.dart`/`database.dart` (**segunda dona de schema desta onda** — mergeia em sequência com WS-5, cada uma toma o próximo número de `schemaVersion`) | nenhuma — só precisa de `work_items` (Fase 1) |

**Ordem de merge**: WS-4 e WS-6 a qualquer momento (zero superfície compartilhada) → WS-1 → WS-2 → WS-3 (por causa de `article_page.dart` e dos métodos aditivos) → WS-5 e WS-17 por último, nessa ordem entre si (ambas mexem em `tables.dart`/`schemaVersion`, então mergeiam sequencialmente, cada uma pegando o próximo número de versão — não há conflito de conteúdo, só do número de versão e da lista de passos em `MigrationStrategy.onUpgrade`).

**Notas de implementação da FTS5** (para quem pegar WS-17): (a) o campo `content` de `WorkItem`/`WorkItemSnapshot` pode ser HTML — stripar tags antes de indexar, senão o FTS casa com lixo de marcação; (b) `tags` hoje é serializado como `tagsJson` — manter uma coluna auxiliar de texto plano (tags separadas por espaço) só para fins de indexação FTS, atualizada pelo mesmo trigger; (c) confirmar que `sqlite3_flutter_libs` foi compilado com FTS5 habilitado (testar `CREATE VIRTUAL TABLE ... USING fts5(...)` cedo, antes de construir o resto) — é o único risco técnico real desta workstream.

## Onda 2 — depende de partes específicas da Onda 1 (não da onda inteira)

| WS | Escopo | Dependência real |
|---|---|---|
| **WS-7** Inbox + FSM | `pages/inbox_page.dart` (chips de fila, ações via `changeStatus`/snooze direto), `application/snooze_use_case.dart`; 4ª aba em `main.dart` | só `WorkItemRepository.changeStatus` (já existe) — **espera as edições de `main.dart` da Onda 1 mergearem** |
| **WS-8** ActionRegistry + ações iniciais | `domain/article_action.dart`, `application/action_registry.dart` (espelha `provider_registry.dart`), ações: concluir/adiar/arquivar/favoritar/compartilhar (`share_plus` já no pubspec)/copiar link/tag; chamada de `initializeActions()` em `main()` (edição isolada, longe do `IndexedStack`) | assinatura combinada de `SnoozeItem`/`WakeSnoozedItems` com WS-7 (acordar a assinatura antes, não o código pronto) |
| **WS-9** Queue/QuerySpec | `domain/queue.dart`, `domain/query_spec.dart`, `QueueRepository`+drift + tabela nova `Queues` (**dona do schema desta onda**), `query_spec_compiler.dart`, `pages/queue_editor_page.dart` (acessível via link a partir do Inbox, sem nova aba) | `WorkItemRepository` (existe); ponto de entrada de UI depende de WS-7 |
| **WS-10** Editor de regras (dry-run) | `pages/rule_editor_page.dart`, pendurado em `settings_page.dart` (sem nova aba) | só WS-5 (Onda 1) — **não** depende de WS-8, por isso entra já aqui |

**Ordem de merge**: WS-7 primeiro (dona da 4ª aba) → WS-8 → WS-9/WS-10 (a qualquer momento após WS-7).

## Onda 3 — wiring final

| WS | Escopo | Dependência real |
|---|---|---|
| **WS-11** Bottom-sheet/swipe reais | `inbox_page.dart` passa a listar `ActionRegistry.getAvailableActions(item)` em vez de chamadas diretas | WS-8 |
| **WS-12** RuleEngine ↔ ActionRegistry real | `rule_engine.dart` troca stub por `ActionExecutor.executeAll(...)`; `DatabaseProvider.ruleEngine` instancia o `RuleEngine` (com `ActionExecutor` real) e `main.dart` força a criação no boot, após `initializeActions`. **Concluído** — commit `10b2ee9` / PR #25. Pendente: `RuleMatched` ainda não carrega payload dedicado para undo (ver WS-16) | WS-5 + WS-8 |
| **WS-13** Enricher como ação | `summarize_action.dart`/`translate_action.dart`/`classify_action.dart`; **aqui** faz a migração de schema adiada em WS-6 (`language`/`tokensUsed`/`costEstimate` em `Enrichments`) — dona do schema desta onda | WS-6 + WS-8 |
| **WS-14** Integrações externas | `obsidian_export_action.dart`/`notion_export_action.dart`/`webhook_action.dart` | só WS-8 — paralelo a WS-13, arquivos distintos |
| **WS-15** Workflows | `workflow_runner.dart` executa `ActionInvocation` em sequência; progresso via `WorkItemEvents` existente (evitar tabela nova) | WS-5 + WS-8 (não depende de WS-13) |

**Ordem de merge**: WS-11 e WS-14 primeiro → WS-12 (**concluído**) → WS-13 (dona do schema) → WS-15 (rebase sobre schema final de WS-13).

## Onda 4 — fecha auditoria/undo

**WS-16**: `rule_undo_use_case.dart` + `WorkItemEventRepository` (leitura da tabela `WorkItemEvents`, que só é escrita hoje, nunca lida) para "desfazer últimas 24h de uma regra". Depende de WS-12 (payload de `RuleMatched`). Sem conflito de schema.

## Conflitos de arquivo — resumo

| Arquivo | Risco | Mitigação |
|---|---|---|
| `tables.dart`/`database.dart` | WS-5, WS-17 (mesma onda), WS-9, WS-13 (ondas seguintes) alteram schema | uma dona de schema por vez, merge sequencial, cada uma pega o próximo `schemaVersion` |
| `article_page.dart` (5 getters `_get*`) | WS-1 e WS-2 na mesma onda | WS-1 adiciona suporte `WorkItem`; WS-2 só consome |
| `main.dart` (IndexedStack/NavigationBar) | Onda 1 (troca de construtor) vs Onda 2 (nova aba) | Onda 2 só começa após merge das edições de `main.dart` da Onda 1 |
| `main.dart` (bootstrap `main()`) | WS-8 | edição isolada, baixo risco |
| `database_provider.dart` | WS-1/2/3 (consumo) vs WS-5 (Decorator) | diff de 1 linha; WS-5 mergeia por último na sua onda |
| `work_item_repository(_drift).dart` | vários WS adicionando métodos | sempre no fim da classe |

## Verificação

- Cada workstream, antes do merge: `flutter analyze` limpo + `flutter test --reporter expanded` (171 testes hoje, crescendo por WS) + a suíte de repositório roda `NativeDatabase.memory()` (detecta rápido incompatibilidade de schema entre workstreams que mexeram em `tables.dart` em momentos diferentes).
- WS-17 (FTS5) especificamente: teste de repositório inserindo WorkItems com acentos/HTML no conteúdo e conferindo que a busca por palavra do título/autor/tag retorna o item esperado, e que tags/conteúdo removidos não continuam aparecendo em buscas (trigger de DELETE/UPDATE funcionando).
- Após cada onda: abrir o app e conferir manualmente a região tocada (ex.: 4ª aba Inbox aparece e não quebra a `NavigationBar`; Favoritos/Feed Articles/Home continuam funcionando offline).
- Fase 3+ (Onda 2/3): fluxo novo→triado→concluído→arquivado de ponta a ponta com trilha de eventos; regra de exemplo validada por dry-run antes do wiring real (WS-10 antes de WS-12).
- CI (`ci.yml`) permanece com o gate único (analyze+test-flutter+test-proxy); como há muitas branches paralelas, rodar a suíte completa localmente a cada merge sequencial, não só no PR isolado.
