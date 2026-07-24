# Onda 2 — Inbox/FSM, ActionRegistry, Queue/QuerySpec, Editor de Regras (dry-run)

## Contexto

O FeedFlow está em migração incremental para uma "fila inteligente de processamento de informação" local-first (`docs/EVOLUTION-PLAN.md`). O trabalho é dividido em ondas de workstreams paralelas (`docs/PARALLEL-EXECUTION-PLAN.md`). A **Onda 1** (WS-1 a WS-6, WS-17 — persistência local, sync com outbox, event bus, rule engine skeleton, enricher/LLM, FTS5) está **100% mergeada em `main`, estável, 260 testes passando**. O incidente de push indevido que gerou os branches `*-restante`/`rescue`/`revert` já foi contido — esses branches não contêm nada além do que já está em `main` por vias legítimas de PR.

Este plano cobre a **Onda 2**, já esboçada em alto nível em `docs/PARALLEL-EXECUTION-PLAN.md` §"Onda 2": WS-7 (Inbox+FSM), WS-8 (ActionRegistry), WS-9 (Queue/QuerySpec), WS-10 (Editor de regras dry-run). Nenhum arquivo-alvo dessas 4 workstreams existe ainda — parte-se de código limpo. O objetivo deste plano é detalhar exatamente o que cada workstream cria/edita, resolver as decisões de design que o doc-fonte deixou em aberto (assinatura de snooze, serialização de QuerySpec, mecanismo do dry-run) e definir a ordem de merge para permitir execução paralela por agentes em worktrees separadas, como foi feito na Onda 1.

## Decisões de design transversais

**1. Snooze — nova API em `WorkItemRepository` (ponto de sincronização WS-7 ↔ WS-8)**

Adicionar ao **fim** de `lib/domain/repositories/work_item_repository.dart` (regra do hotspot — métodos aditivos sempre no fim):

```dart
/// Adia um item até [until]. Ortogonal ao TriageStatus (não passa por
/// changeStatus) — um item snoozed pode estar em qualquer status ativo.
Future<void> snoozeItem(String id, DateTime until, {String actor = 'user'});

/// Acorda itens cujo snoozedUntil já passou, limpando o campo e retornando
/// os ids acordados. Não requer WorkItemEvents (ver decisão 2).
Future<List<String>> wakeSnoozedItems({DateTime? now});
```

Implementar em `WorkItemRepositoryDrift` (update direto na coluna `snoozedUntil`) e no decorator `EventEmittingWorkItemRepository` (publica `ItemSnoozed`/`SnoozeExpired`, que já existem em `domain/events/domain_event.dart` mas nunca foram publicados). Não é necessário mudar `changeStatus`/`StatusChanged` — snooze é campo próprio, não transição de FSM.

**2. `WorkItemEvents` (tabela de auditoria) — não usar nesta onda.** Ninguém lê essa tabela hoje (fica para WS-16/Onda 4). Snooze usa só o event bus via decorator, sem gravação extra.

**3. `QuerySpec` reaproveita `Condition` de `lib/domain/rule.dart`** em vez de criar uma árvore de filtro paralela — mesmos operadores, mesma semântica de campo, evita duplicação.

**4. `QuerySpecCompiler` filtra em memória** (decisão do usuário) sobre `watchByStatus(TriageStatus.values)`, usando um `ConditionEvaluator` extraído de `RuleEngine` (refactor puro, sem mudar comportamento) e compartilhado entre `RuleEngine`, `QuerySpecCompiler` e o dry-run de WS-10.

**5. Dry-run de regras (WS-10) não reutiliza `RuleEngine` em runtime** (ele é orientado a evento único, não a "avaliar sob demanda contra N itens"). Usa a mesma lógica de avaliação (`ConditionEvaluator`) fora do ciclo de eventos — nunca publica `RuleMatched`, nunca executa ações.

## WS-7 — Inbox + FSM

**Dependência real**: nenhuma (Onda 1/`main.dart` já no estado esperado — 3 abas simples). Dona da 4ª aba.

**Criar:**
- `lib/application/snooze_use_case.dart` — `SnoozeUseCase(WorkItemRepository)`: `snoozeUntil`, `snoozeFor(Duration)`, `wakeExpired()`.
- `lib/pages/inbox_page.dart` — sem `FeedProvider` (100% local via `DatabaseProvider.repository`). Chips por `TriageStatus` (foco em novo/triado/emAndamento; toggle para mostrar concluído/arquivado) usando `StreamBuilder` sobre `watchByStatus`; badges via `watchCountByStatus`; ações rápidas diretas (concluir/adiar/arquivar chamando `changeStatus`/`SnoozeUseCase` — sem `ActionRegistry` ainda, isso é WS-11/Onda 3). Tratar `item.isSnoozed` visualmente.

**Editar:**
- `lib/domain/repositories/work_item_repository.dart` — `snoozeItem`/`wakeSnoozedItems` (fim da classe).
- `lib/infrastructure/repositories/work_item_repository_drift.dart` — implementação.
- `lib/infrastructure/repositories/event_emitting_work_item_repository.dart` — implementação + publicação de eventos.
- `lib/main.dart` `MainScaffold` — 4ª entrada no `IndexedStack` (`const InboxPage()`), 4º `NavigationDestination` (ícone `Icons.inbox_rounded`, label "Inbox"), item correspondente no `Drawer`. Manter FAB restrito a `_selectedIndex == 0`.

**Testes**: casos de `snoozeItem`/`wakeSnoozedItems` em `work_item_repository_drift_test.dart` (adiar, acordar só vencidos, não tocar não vencidos); publicação de `ItemSnoozed`/`SnoozeExpired` no teste do decorator; `snooze_use_case_test.dart` novo; smoke de widget de `inbox_page.dart` (chips renderizam, tap conclui item).

## WS-8 — ActionRegistry + ações iniciais

**Dependência real**: assinatura de snooze já definida acima; mais seguro esperar WS-7 mergear antes de compilar contra a interface definitiva.

**Criar:**
- `lib/domain/article_action.dart` — `abstract class ArticleAction { id, label, icon, isAvailable(WorkItem), execute(WorkItem, Map<String,dynamic> params) }`.
- `lib/application/action_registry.dart` — espelha `lib/providers/provider_registry.dart` (estático, sem DI): `register`, `get`, `getAvailableActions(WorkItem)`, `execute(actionId, item, params)`; função livre `initializeActions()` chamada em `main()`.
- `lib/application/actions/` (uma ação por arquivo): `complete_action.dart`, `snooze_action.dart` (usa `SnoozeUseCase`), `archive_action.dart`, `star_action.dart` (toggle local via `save`, **não** passa pelo outbox/SyncService — documentar essa distinção no docstring para não confundir com o star remoto sincronizado), `share_action.dart` (`share_plus`, já no pubspec), `copy_link_action.dart` (`Clipboard`), `add_tag_action.dart`.

**Editar:**
- `lib/main.dart` `main()` — `initializeActions();` após `initializeProviders();` (linha isolada).

**Testes**: `action_registry_test.dart` (filtro de disponibilidade, erro em id desconhecido); um teste por ação usando `WorkItemRepositoryDrift` em memória; `ShareAction`/`CopyLinkAction` com cobertura mínima (`isAvailable`) se não houver precedente de mock de plugin nativo no repo.

## WS-9 — Queue/QuerySpec

**Dependência real**: `WorkItemRepository` (existe). UI final depende do link a partir do Inbox (WS-7), mas domínio/repositório/compiler são independentes. **Dona do schema desta onda** (`schemaVersion` 4→5).

**Criar:**
- `lib/domain/query_spec.dart` — Freezed `QuerySpec({filter: Condition, sort: List<QuerySort>, limit})` + `QuerySort({field, descending})`, reaproveitando `Condition` de `rule.dart`.
- `lib/domain/queue.dart` — Freezed `Queue({id, name, spec: QuerySpec, order, iconName: String?})`. **Usar `String? iconName`, não `IconData`** (evita atrito de serialização Freezed/json_serializable).
- `lib/domain/repositories/queue_repository.dart` + `lib/infrastructure/repositories/queue_repository_drift.dart` — espelha exatamente `RuleRepository`/`RuleRepositoryDrift` (`byId/create/update/delete/list/watchAll/clear/close`).
- `lib/domain/condition_evaluator.dart` — extração (refactor puro, sem mudar comportamento) de `_evaluateCondition`/`_evaluateSimpleCondition`/`_evaluateCompoundCondition`/`_getFieldValue` de `lib/application/rule_engine.dart` para métodos estáticos reaproveitáveis; `RuleEngine` passa a chamar `ConditionEvaluator.evaluate`. Rodar `rule_engine_test.dart` inalterado antes/depois como regressão.
- `lib/application/query_spec_compiler.dart` — `compile(QuerySpec) → Stream<List<WorkItem>>`, filtra em memória sobre `watchByStatus(TriageStatus.values)` via `ConditionEvaluator`, aplica sort/limit.
- `lib/pages/queue_editor_page.dart` — form (nome + builder de condições simples campo/operador/valor combinadas em all/any) com preview ao vivo via `QuerySpecCompiler` + lista de filas existentes (criar/editar/excluir).

**Editar:**
- `lib/infrastructure/db/tables.dart` — tabela `Queues` (`id, name, specJson, order, iconName`) no fim do arquivo.
- `lib/infrastructure/db/database.dart` — adicionar `Queues` ao `@DriftDatabase`, `schemaVersion => 5`, bloco `if (from < 5) await m.createTable(queues);` em `onUpgrade` (não tocar blocos anteriores).
- `lib/infrastructure/db/database_provider.dart` — getter `queueRepository` (padrão lazy singleton dos demais).

**Testes**: `queue_repository_drift_test.dart` (formato de `rule_repository_drift_test.dart`); `condition_evaluator_test.dart` (portar casos de operador de `rule_engine_test.dart`); `query_spec_compiler_test.dart` (filtros simples/compostos, sort, limit sobre repositório em memória populado).

## WS-10 — Editor de regras (dry-run)

**Dependência real**: só WS-5 (Onda 1, já mergeado). Roda em paralelo total com WS-9 — se `ConditionEvaluator` ainda não tiver sido extraído quando WS-10 começar, aceitar duplicação temporária local e convergir depois (não travar WS-10 esperando WS-9; recomenda-se WS-9 mergear primeiro entre as duas, por ser dona de schema).

**Criar:**
- `lib/application/rule_dry_run.dart` — `RuleDryRunResult(item, wouldExecute: List<ActionInvocation>)`; `RuleDryRunner(WorkItemRepository).run(Rule) → Future<List<RuleDryRunResult>>`, avalia via `ConditionEvaluator` contra todos os WorkItems ativos, **sem publicar eventos nem executar ações**.
- `lib/pages/rule_editor_page.dart` — lista de regras (`RuleRepository.list()` + refresh manual após mutações — não adicionar `watchAll()` à interface nesta workstream, hotspot desnecessário); form de criação/edição (nome, `RuleTrigger` dropdown, builder de `Condition` próprio — não compartilhar widget com WS-9 nesta onda, evita acoplar as duas workstreams; unificação de UI fica como débito técnico futuro), lista de `ActionInvocation` com `actionId` de uma lista estática conhecida (ActionRegistry real só existe em WS-8/consumida de verdade em WS-12/Onda 3); botão "Testar regra" dispara `RuleDryRunner` e mostra itens que casariam + ações que seriam disparadas (sem executar).

**Editar:**
- `lib/pages/settings_page.dart` — nova seção "Automação" (mesmo padrão `Padding+Text` cabeçalho + `Divider` + `ListTile`, inserida após "Categorias"): `ListTile` "Regras de automação" → `Navigator.push` para `RuleEditorPage`.

**Testes**: `rule_dry_run_test.dart` — casos de condição simples/composta retornando os itens esperados, **e assert explícito de que nenhum evento é publicado no `eventBus` durante o dry-run** (o teste mais importante — garante ausência de efeito colateral); smoke de widget de `rule_editor_page.dart`; regressão de `settings_page.dart` após a edição aditiva.

## Sequência de execução e merge

1. **Acordo prévio de assinatura** (feito neste plano — decisão 1 acima): `snoozeItem`/`wakeSnoozedItems`.
2. **WS-7 primeiro e sozinha** (dona da 4ª aba/`main.dart`) → merge.
3. **WS-8 depois de WS-7 mergeada** (consome a interface já com os métodos de snooze) → merge.
4. **WS-9 e WS-10 em paralelo**, a qualquer momento após WS-7 (não dependem de WS-8):
   - WS-9 mergeia primeiro entre as duas (fecha o bump de `schemaVersion` cedo, entrega `ConditionEvaluator`).
   - WS-10 rebasa consumindo `ConditionEvaluator` já existente antes do próprio merge (trocando a cópia local temporária, se usada).
   - Depois que `queue_editor_page.dart` existir, um PR pequeno isolado adiciona o link a partir de `inbox_page.dart` (edição aditiva de um `ListTile`).

**Execução paralela (worktrees)**: seguindo o padrão da Onda 1, cada workstream roda em worktree própria (`git worktree add` a partir de `main` atualizado), com PR individual. Ordem de disparo dos agentes:
- Disparar **WS-7** primeiro isoladamente; aguardar merge em `main`.
- Após merge de WS-7, disparar **WS-8**, **WS-9** e **WS-10** em paralelo (WS-8 depende só da interface já mergeada por WS-7, não de código de WS-9/WS-10). Mergear WS-8 assim que pronta; mergear WS-9 antes de WS-10 pelas razões acima.
- PR final pequeno de ligação Inbox→QueueEditor depois que WS-9 estiver em `main`.

## Riscos e mitigação

| Risco | Mitigação |
|---|---|
| `schemaVersion` 4→5 conflitar com trabalho de schema de outra onda em paralelo | Nenhuma workstream de Onda 3 (ex. WS-13) deve mexer em `tables.dart` antes de WS-9 mergear |
| Extração de `ConditionEvaluator` quebrar `rule_engine_test.dart` | Refactor puro (mover, não reescrever); suíte existente roda inalterada como regressão |
| `IconData` em `Queue` quebrando serialização Freezed | Usar `String? iconName` (decidido) |
| Link Inbox→QueueEditor criando dependência de import entre merges em momentos diferentes | PR aditivo pequeno após WS-9, não faz parte do PR original de WS-7 |
| `StarAction` (local) divergir do star remoto sincronizado via outbox | Documentar explicitamente no docstring — são conceitos distintos nesta onda |
| Onda 3 (WS-11/WS-12) depender de assinaturas de `ActionRegistry`/stub do `RuleEngine` | Congelar `execute(actionId, item, params)` e o loop de ações stub ao final da Onda 2 — WS-12 troca o stub por chamada real, não a assinatura |

## Verificação

- Por workstream, antes do merge: `flutter analyze` limpo + `flutter test --reporter expanded` (baseline atual: 260 testes, deve crescer).
- WS-7: abrir o app, confirmar 4ª aba Inbox aparece sem quebrar `NavigationBar`; adiar um item e confirmar que reaparece após o horário simulado.
- WS-9: teste de repositório cobrindo filtro simples e composto + sort + limit; abrir `QueueEditorPage`, criar uma fila, confirmar preview reativo.
- WS-10: dry-run contra uma regra de exemplo (ex. categoria→tag) confirmando que a lista de resultados bate com os itens esperados e que nenhum evento real foi publicado.
- Fluxo de ponta a ponta pós-Onda 2: artigo novo → aparece no Inbox → ação de triagem (concluir/adiar/arquivar) via ActionRegistry → fila customizada reflete o filtro → regra em dry-run mostra o que aconteceria sem alterar nada.
