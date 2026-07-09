# FeedFlow → Plataforma de Processamento de Informação
## Plano Técnico de Evolução Arquitetural

> **Contexto**: O FeedFlow é hoje um leitor RSS multi-provider (9 providers via interface `FeedProvider`). O objetivo é evoluí-lo para uma *fila inteligente de processamento de informação* — inspirada em triagem de SOC/gestão de incidentes — com estados próprios por artigo, ações extensíveis, regras de automação, filas de trabalho e enriquecimento por IA. Restrição central: **migração incremental, sem reescrita**, com o app compilando e os testes verdes a cada etapa.
>
> Este documento é o registro do plano original. O acompanhamento de execução (o que já foi feito, fase a fase) e o plano de paralelização entre workstreams estão em `docs/PARALLEL-EXECUTION-PLAN.md`.

---

## 1. Avaliação da arquitetura atual

### 1.1 Pontos fortes

| Ponto | Evidência |
|---|---|
| **Abstração de provider madura e provada** | `FeedProvider` (`lib/providers/feed_provider.dart`, ~30 métodos) com 9 implementações; nenhuma página conhece APIs concretas. |
| **Registry extensível** | `ProviderRegistry` (factory + `ProviderInfo`) — padrão que pode ser replicado para Actions, Rules e Enrichers. |
| **Modelos de domínio imutáveis** | Freezed em `Feed`, `Article`, `Category`, `AuthConfig` — serialização JSON pronta, `copyWith` grátis. `Article.metadata: Map<String,dynamic>` já existe como ponto de extensão (hoje nunca populado). |
| **Auth bem resolvida** | 5 tipos de auth config, persistência criptografada (`flutter_secure_storage` via `ProviderSettings`), login UI dinâmica por `ProviderInfo`. |
| **CI funcional** | `.github/workflows/ci.yml`: analyze + test + build web/android. Base para gates de qualidade da migração. |
| **Degradação graciosa como convenção** | Providers read-only (Feedly, Local OPML) retornam vazio/no-op — precedente para features não suportadas por provider. |

### 1.2 Pontos fracos

| Ponto | Evidência | Impacto na nova visão |
|---|---|---|
| **Sem persistência local de artigos** | Nenhum sqflite/drift/hive/isar; tudo é rede sob demanda | **Bloqueador nº 1.** Estados próprios ("Em análise", "Adiado"…) não têm onde viver. É a mudança fundacional. |
| **Sem sincronização em segundo plano** | Nenhum workmanager/service; única exceção é o fire-and-forget do widget | A premissa do pedido ("já possui sync em background") **não se confirma no código** — precisa ser construída. |
| **Lógica de negócio dentro de widgets** | Batching de mark-read-on-scroll em `_FeedArticlesPageState`; auth completa em `main.dart`; agrupamento por pasta em `home_page.dart` | Regras/ações precisarão dessa lógica fora da UI. |
| **Estado 100% `setState` local, sem camada compartilhada** | 105 ocorrências em 13 arquivos; package `provider` declarado mas com **zero usos** | Filas/contadores/estados precisam de estado reativo compartilhado entre telas. |
| **Duplicação massiva entre providers** | 9 providers × ~500 linhas, cada um com `http.get/post` inline, `_headers`, `_parseArticle` próprios; sem classe base | Qualquer mudança transversal (ex.: telemetria de sync) custa ×9. |
| **Tratamento de erro inconsistente** | Mistura de result-objects, retorno vazio silencioso, e `throw UnsupportedError` | Motor de regras/sync precisa distinguir "vazio de verdade" de "falhou". |
| **Testes sem cobertura de comportamento** | ~107 testes, mas nenhum mock HTTP; testes de provider são smoke tests de contrato | Refatorar sync/parsing sem rede mockada é arriscado. |

### 1.3 Débito técnico (inventário)

1. **Docs desatualizadas**: citavam `lib/managers/favorites_manager.dart` e duplicatas na raiz de `lib/` — nenhum dos dois existe (já corrigido).
2. **Dead code**: `lib/pages/feed_articles_page_xml.dart` (já removido).
3. **`print()` de debug** (já removido).
4. **Dependência órfã**: `provider: ^6.1.2` declarada e não usada (uso planejado na Fase 2).
5. **`main.dart` monolítico**: `MyApp` + `MainScaffold` + `LoginPage` + `_SplashScreen` no mesmo arquivo (já refatorado — LoginPage/SplashScreen extraídos).
6. **`ProviderSettings.getConnectedProviders()`** com lista hard-coded (já corrigido — deriva do registry).
7. **Favoritos efêmeros**: `Set<String> favoriteIds` reconstruído por página; sem fonte única.
8. **IDs de stream Google-Reader vazados na UI**: `home_page.dart` usa `user/-/state/com.google/reading-list` literalmente.

---

## 2. Arquitetura proposta

### 2.1 Princípio diretor: **local-first**

- **Hoje**: provider remoto é a fonte de verdade; a UI é um espelho sob demanda.
- **Proposto**: um **banco local** é a fonte de verdade do *trabalho* (estados, filas, tags, enriquecimentos); os providers viram **fontes de ingestão** e alvos de sincronização parcial (read/star). Tudo o mais (regras, filas, IA, workflows) é construído sobre o repositório local.

### 2.2 Diagrama de alto nível

```
┌────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION (lib/pages, lib/ui)           │
│   Inbox/Filas • Detalhe+Ações • Editor de Regras • Configuração    │
│   (StreamBuilder sobre queries reativas do repositório local)      │
└───────────────▲────────────────────────────────▲───────────────────┘
                │ streams / commands              │
┌───────────────┴───────────────┐  ┌─────────────┴───────────────────┐
│      APPLICATION (use cases)  │  │        AUTOMATION               │
│  TriageArticle, SnoozeItem,   │  │  RuleEngine (trigger/cond/ação) │
│  ExecuteAction, RunEnrichment │  │  ActionRegistry (commands)      │
│  SyncNow, ApplyRules          │  │  WorkflowRunner (pipeline)      │
└───────▲──────────▲────────────┘  └───────▲─────────────▲───────────┘
        │          │        domain events   │             │
┌───────┴──────────┴────────────────────────┴─────┐ ┌─────┴──────────┐
│                DOMAIN (lib/domain)               │ │  ENRICHMENT    │
│  WorkItem (aggregate) • TriageStatus (FSM)       │ │  Enricher API  │
│  Rule • Queue(QuerySpec) • Enrichment • eventos  │ │  LLM adapters  │
└───────▲──────────────────────────▲───────────────┘ └─────▲──────────┘
        │ repositories             │                        │
┌───────┴───────────────┐  ┌───────┴────────────────────────┴────────┐
│  INFRASTRUCTURE       │  │              INGESTION / SYNC            │
│  drift (SQLite/WASM)  │  │  SyncService (pull incremental)          │
│  WorkItemRepository   │  │  Outbox (push read/star p/ provider)     │
│  RuleRepository       │  │  FeedProvider × 9  (INALTERADOS)         │
│  QueueRepository      │  │  ProviderRegistry (existente)            │
└───────────────────────┘  └──────────────────────────────────────────┘
```

### 2.3 Bounded Contexts

| Contexto | Responsabilidade | O que reaproveita |
|---|---|---|
| **Ingestion/Sync** | Puxar artigos dos providers para o store local; empurrar read/star de volta (outbox); reconciliar estado | Todo `lib/providers/` como está — a interface `FeedProvider` já é o "driver" de ingestão |
| **Triage/Workflow** (novo núcleo) | `WorkItem` com máquina de estados, prioridade, tags, snooze; filas virtuais | Modelos Freezed como padrão; `Article` vira DTO de entrada |
| **Automation** | Regras (trigger→condições→ações), registro de ações, pipelines | Padrão `ProviderRegistry` replicado como `ActionRegistry` |
| **Enrichment (IA)** | Interface `Enricher` (resumo, tradução, classificação, entidades); adapters de LLM | Padrão de degradação graciosa dos providers |
| **Presentation** | Telas orientadas a filas; ações contextuais | Pages e navegação existentes, migradas gradualmente |

**Regras de dependência**:
- `domain` não importa nada de fora (nem Flutter).
- `application` importa `domain`; `infrastructure` implementa interfaces do `domain`.
- `providers/` (ingestão) **nunca** conhece `WorkItem` — só `Article`. A conversão Article→WorkItem acontece no SyncService.
- `pages/` não chama `FeedProvider` diretamente após a migração (Fase 2+); fala com use cases/repositórios.

### 2.4 Estado de UI

Decisão: **queries reativas do drift + `StreamBuilder`** para listas/contadores, e `ChangeNotifier` com o package `provider` para estado de app. Riverpod fica como alternativa consciente (ver §7.6).

---

## 3. Novo modelo de domínio

### 3.1 Aggregate root: `WorkItem`

```dart
// lib/domain/work_item.dart (Freezed)
class WorkItem {
  WorkItemId id;              // VO: "{providerId}:{articleId}" — estável e único
  ArticleRef source;          // VO: providerId, articleId, feedId, url
  ArticleSnapshot snapshot;   // VO: title, author, summary, content, published (cópia local)
  TriageStatus status;        // enum da FSM (§3.5)
  Priority priority;          // VO: none | low | medium | high | urgent
  Set<Tag> tags;              // VO: etiquetas locais
  DateTime? snoozedUntil;     // adiamento é atributo temporal, não estado (§7.2)
  bool isStarred;             // espelho sincronizado do provider
  ReadSyncState readSync;     // VO: sincronização read local↔provider (outbox)
  List<Enrichment> enrichments; // resumos, traduções, classificações (IA)
  String? notes;              // anotação do usuário
  DateTime ingestedAt; DateTime? completedAt;
}
```

### 3.2 Demais entidades e Value Objects

| Tipo | Nome | Conteúdo |
|---|---|---|
| Entidade | `Rule` | id, name, enabled, `RuleTrigger` (onIngested, onStatusChanged, manual, schedule), `List<Condition>`, `List<ActionInvocation>`, stopOnMatch, ordem |
| VO | `Condition` | árvore serializável (JSON): campo + operador + valor; combinadores `all`/`any`/`not` |
| VO | `ActionInvocation` | actionId + parâmetros (`Map<String, dynamic>`) — referencia o `ActionRegistry` |
| Entidade | `Queue` | id, name, icon, ordem, `QuerySpec` — fila = filtro salvo (virtual) |
| VO | `QuerySpec` | filtro + ordenação serializáveis, compilados para SQL do drift |
| VO | `Enrichment` | type (summary, translation, classification, entities, suggestion), content, model, language?, createdAt, custo/tokens? |
| VO | `WorkItemEvent` | trilha de auditoria: (timestamp, tipo, ator: user\|rule\|sync, payload) |

### 3.3 Interfaces (ports) novas

```dart
abstract class WorkItemRepository {
  Stream<List<WorkItem>> watch(QuerySpec spec);
  Stream<Map<String, int>> watchCounts(List<QuerySpec> specs);
  Future<WorkItem?> byId(WorkItemId id);
  Future<void> upsertFromIngestion(List<Article> articles, String providerId);
  Future<void> save(WorkItem item);
  Future<int> purge(RetentionPolicy policy);
}

abstract class RuleRepository    { CRUD + Stream<List<Rule>> watchEnabled(); }
abstract class QueueRepository   { CRUD + reordenação; }

abstract class ArticleAction {
  String get id; String get label; IconData get icon;
  bool canApply(WorkItem item);
  Future<ActionResult> execute(WorkItem item, ActionContext ctx, Map<String,dynamic> params);
}
class ActionRegistry { register/byId/all; }

abstract class Enricher {
  String get id;
  Set<EnrichmentType> get capabilities;
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req);
}
```

### 3.4 Use cases (application layer)

`IngestArticles`, `SyncNow`, `FlushOutbox`, `ChangeStatus`, `SnoozeItem`/`WakeSnoozedItems`, `ExecuteAction`, `ApplyRules(trigger, item)`, `RunEnrichment`, `SaveRule` (com dry-run/preview), `PurgeOldItems`.

### 3.5 Máquina de estados (`TriageStatus`)

```
                    ┌──────────── (regra/ação: arquivar direto) ───────────┐
                    │                                                      ▼
  novo ──► triado ──► emAndamento ──► concluído ──────────────────► arquivado
   │          ▲            │              ▲                             ▲
   │          └────────────┘ (voltar)     │                             │
   └────────────── (concluir/arquivar direto de qualquer estado) ───────┘

  overlay temporal:  snoozedUntil != null  ⇒ item oculto das filas ativas
```

- Transições válidas explicitadas numa tabela `Map<TriageStatus, Set<TriageStatus>>`.
- **"Adiado" não é estado da FSM** — é `snoozedUntil`. "Em análise"/"Em andamento" colapsam em `triado`/`emAndamento`.
- **Independência do provider**: `TriageStatus` nunca é escrito no provider; ponte via política configurável (ex.: "concluído/arquivado ⇒ marcar read no provider").

### 3.6 Eventos de domínio

`ArticleIngested`, `StatusChanged`, `ItemSnoozed`/`SnoozeExpired`, `ActionExecuted`, `RuleMatched`, `EnrichmentCompleted`/`EnrichmentFailed`, `SyncCompleted`/`SyncFailed`. Event bus síncrono simples no application layer (sem package novo) — o RuleEngine é o principal assinante.

---

## 4. Estratégia de migração

Cada fase termina com: app compilando, `flutter analyze` limpo, todos os testes verdes, e comportamento atual preservado.

### Fase 0 — Higiene e fundações de teste ✅ concluída

### Fase 1 — Persistência local (fundação) ✅ concluída

### Fase 2 — Leitura local + SyncService + outbox 🟡 parcial (outbox/SyncService prontos; migração de leitura das páginas em andamento — ver `docs/PARALLEL-EXECUTION-PLAN.md`)

### Fase 3 — Triagem + Filas + Ações ⬜ planejada

### Fase 4 — Motor de regras ⬜ planejada

### Fase 5 — IA, workflows e background sync ⬜ planejada

(Detalhes de escopo de cada fase e como o trabalho está dividido entre workstreams paralelas: ver `docs/PARALLEL-EXECUTION-PLAN.md`.)

---

## 5. Refatorações

### O que **não** muda
- `lib/providers/**` (os 9 providers e o registry) — intocados até a Fase 5.
- `lib/models/**` — `Article` permanece como DTO dos providers.
- `old_reader_api.dart`, proxy web, login/auth, widget Android.

### Dependências novas
| Package | Uso | Fase |
|---|---|---|
| `drift` + `sqlite3_flutter_libs` | banco local reativo | 1 (feito) |
| `workmanager` | background sync Android | 5 (já existia antes do plano — reaproveitado) |
| `flutter_local_notifications` | notificação de regra/enriquecimento | 5 |

---

## 6. Roadmap

Ver `docs/PARALLEL-EXECUTION-PLAN.md` para o desenho de execução paralela (ondas de workstreams) que substitui o roadmap sequencial original de sprints.

---

## 7. Avaliação crítica (questionando a proposta original)

**7.1** O risco nº 1 não é técnico, é "falência de inbox" — mitigado por auto-arquivamento por idade, triagem em massa e regras.
**7.2** Seis estados são estados demais — FSM enxuta (4 estados + overlay de snooze).
**7.3** Não construir dois motores (regras E workflows) — workflows = pipelines lineares de `ActionInvocation`.
**7.4** IA automática em ingestão é armadilha de custo — enriquecimento on-demand por padrão, orçamento por regra.
**7.5** A premissa "já temos sync em background" era falsa quando este plano foi escrito — motivou investir Fases 1-2 em fundação local-first primeiro.
**7.6** Alternativas consideradas e rejeitadas: guardar estado em `Article.metadata` (sem identidade estável), Hive/Isar em vez de drift (sem queries/manutenção instável), Riverpod em vez de provider (paradigma novo demais no meio da migração), sincronizar `TriageStatus` via tags do provider (matriz de compatibilidade 9×6 inviável).
**7.7** Naming/UX: vocabulário de produto sugerido — Inbox, "Para ler", "Lendo", "Feito", "Arquivo", "Soneca".

**Adição pós-plano original**: busca full-text local via FTS5 do SQLite (título, conteúdo, autor, tags) — não coberta aqui, incorporada como workstream própria no plano de execução paralela.

---

## Verificação

- Por fase/workstream: `flutter analyze` limpo + `flutter test --reporter expanded` + build Android debug e web no CI.
- Fase 1-2: abrir o app com flag ligada/desligada e comparar comportamento; inspecionar tabela `work_items` populada; modo avião após sync → artigos legíveis offline; derrubar rede durante mark-read → outbox reenvia.
- Fase 3+: fluxo completo novo→concluído→arquivado com trilha de eventos; regra de exemplo (categoria → tag+fila) validada por dry-run.
