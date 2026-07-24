# Onda 5 — WS-18: journal de eventos assincrono + fecho da Onda 4 (WS-16)

> Plano de implementacao. Escopo conforme docs/PLATFORM-ROADMAP.md, secao
> "Onda 5 — Journal de eventos + higiene": mergear WS-16 (undo de regras, pronto
> em branch, nao mergeado) e tornar o EventBus assincrono/aguardavel, com todo
> DomainEvent persistido, nao so ruleMatched.

## Contexto

A Onda 4 (WS-16) foi implementada e testada no branch `worktree-ws16-rule-undo`
(commit `fdd1361`, sobre `78e972f`) mas nunca foi mergeada em `novaVersao`. A
exploracao para o roadmap de plataforma (docs/PLATFORM-ROADMAP.md) confirmou dois
problemas no `EventBus` atual (`lib/application/event_bus.dart`):

- `publish()` e sincrono, mas o unico subscriber (`RuleEngine._onEvent`,
  `rule_engine.dart:38`) e `async void` — o publish retorna antes das acoes da
  regra terminarem, e excecoes dentro do handler nunca chegam a quem publicou.
- Eventos como `EnrichmentCompleted`/`EnrichmentFailed`/`SyncCompleted`/
  `SyncFailed`/`SnoozeExpired` sao publicados no bus (alguns nem isso) mas nunca
  persistidos em lugar nenhum — nao ha journal, so a tabela `WorkItemEvents`
  gravada manualmente via `logEvent` em pontos especificos.

Esta onda tem duas partes independentes que devem ser feitas nesta ordem: (1)
trazer WS-16 pronto (menor risco, ja testado) e (2) generalizar a persistencia
de eventos para qualquer `DomainEvent`, nao so `ruleMatched`/`workflowCompleted`.
E a fundacao de que toda a Fase B/C/D do roadmap (jobs, embeddings, agentes)
depende — nao pode ser pulada nem adiada.

## Achados-chave

- `EventBus.publish` (`event_bus.dart:26`): loop `for` sincrono sobre
  `List<void Function(DomainEvent)>`. Mudar a assinatura do listener para
  `FutureOr<void> Function(DomainEvent)` e do `publish` para `Future<void>`
  quebra qualquer chamador que trate `publish` como fire-and-forget — checar
  todos os `.publish(` antes de mudar (achados: `event_emitting_work_item_repository.dart:49,79`,
  `snooze_use_case.dart:24,37`, `action_executor.dart:77`, `rule_engine.dart:70`,
  `workflow_runner.dart:45,59`).
- `RuleEngine._onEvent` e a unica assinatura que precisa deixar de ser
  `async void` — vira `Future<void> Function(DomainEvent)`, compativel com a
  nova assinatura do bus.
- `WorkItemEvents` (`lib/infrastructure/db/tables.dart:41-51`) ja tem o shape
  certo (`workItemId`, `timestamp`, `type`, `actor`, `payloadJson`) — nenhuma
  coluna nova necessaria para o journal generico, so um novo listener que grava
  qualquer `DomainEvent`, nao so os que ja tinham `logEvent` manual espalhado.
- `DomainEvent` (`lib/domain/events/domain_event.dart`) e uma uniao Freezed
  fechada (`ArticleIngested`, `StatusChanged`, `ItemSnoozed`, `SnoozeExpired`,
  `ActionExecuted`, `RuleMatched`, `EnrichmentCompleted`, `EnrichmentFailed`,
  `WorkflowStepExecuted`, `WorkflowCompleted`, `SyncCompleted`, `SyncFailed`) —
  o journal generico usa `event.when(...)`/`event.map(...)` (ja gerado pelo
  Freezed) para extrair `workItemId`/`type`/payload de qualquer variante, sem
  mudar o shape de nenhuma.
- WS-16 (branch `worktree-ws16-rule-undo`) ja resolve exatamente o caso
  `ruleMatched`; esta onda generaliza o padrao para as demais variantes sem
  tocar no que WS-16 fez.

## Decisoes de design

**A. Merge de WS-16 primeiro, sem alteracoes** — trazer os 5 arquivos do
commit `fdd1361` como estao (ja testados: `test/application/rule_engine_test.dart`
+ `test/application/rule_undo_use_case_test.dart`). Nenhuma mudanca de
comportamento nesta etapa, so integracao.

**B. `EventBus.publish` assincrono, `Future<void>`** — cada listener e chamado
com `await`; excecao de um listener e capturada e logada (`developer.log`),
nao propaga e nao interrompe os demais listeners (mantém a garantia de "um
listener com bug nao trava os outros", mas agora de forma explicita em vez de
acidental). `subscribe`/`unsubscribe`/`clear` sem mudanca de assinatura.

**C. `RuleEngine._onEvent` vira `Future<void>`** — remove o `async void`; o
`await _actionExecutor.executeAll(...)` ja existente passa a ser de fato
aguardado pelo bus.

**D. Novo `JournalListener`** — subscribe generico no `eventBus` que, para
TODO `DomainEvent` recebido, extrai `workItemId` (quando existir — `SyncCompleted`/
`SyncFailed` nao tem, entao sao gravados com `workItemId = ''` e `type` proprio,
mesma convencao ja usada por eventos globais) e grava via
`WorkItemRepository.logEvent` com `type` = nome da variante em camelCase
(`enrichmentCompleted`, `syncFailed`, etc.) e `payloadJson` = serializacao do
proprio evento (`toJson()`, ja gerado pelo Freezed). Isso NAO substitui os
`logEvent` manuais ja existentes (ex.: `ruleMatched` de WS-16, `workflowCompleted`
de WS-15) — para esses, o `JournalListener` deve pular (checar `type` ja
coberto) para nao duplicar linha. Registrado uma unica vez em
`DatabaseProvider` junto dos demais getters.

**E. Sem UI nesta onda** — 100% backend, mesma convencao de WS-16.

## Arquivos a criar/editar

1. Merge do branch `worktree-ws16-rule-undo` (commit `fdd1361`) em `novaVersao`:
   - `lib/domain/repositories/work_item_event_repository.dart` (novo)
   - `lib/infrastructure/repositories/work_item_event_repository_drift.dart` (novo)
   - `lib/application/rule_undo_use_case.dart` (novo)
   - `lib/application/rule_engine.dart` (editado por WS-16 — chamada a `logEvent`
     apos `executeAll`)
   - `lib/infrastructure/db/database_provider.dart` (editado por WS-16 — getters
     `workItemEventRepository`/`ruleUndoUseCase`, no fim da classe)
   - `test/application/rule_engine_test.dart`, `test/application/rule_undo_use_case_test.dart`
2. `lib/application/event_bus.dart` (editar) — `publish` assincrono, captura de
   excecao por listener.
3. `lib/application/rule_engine.dart` (editar de novo, apos o merge) —
   `_onEvent` deixa de ser `async void`.
4. `lib/application/journal_listener.dart` (novo) — `JournalListener` +
   `initializeJournalListener(eventBus, workItemRepository)`.
5. `lib/infrastructure/db/database_provider.dart` (editar de novo) — chamar
   `initializeJournalListener` na inicializacao (mesmo ponto onde `RuleEngine`
   e instanciado).
6. `lib/main.dart` (conferir apenas — nenhuma mudanca esperada; o wiring fica
   dentro de `DatabaseProvider`, nao em `main()`).

## Testes

- `test/application/event_bus_test.dart` (novo, se nao existir — checar antes):
  publish aguarda todos os listeners assincronos; excecao em um listener nao
  impede os demais de rodar; `clear()` continua funcionando.
- `test/application/rule_engine_test.dart` (ja editado por WS-16): confirmar que
  segue passando com `_onEvent` nao mais `async void` — o teste que aguarda o
  resultado da regra deve ficar mais simples (sem `await Future.delayed`
  artificial, se existir algum).
- `test/application/journal_listener_test.dart` (novo): cada variante de
  `DomainEvent` gera uma linha em `WorkItemEvents` com `type` esperado; eventos
  ja cobertos por `logEvent` manual (`RuleMatched`, `WorkflowCompleted`) nao
  duplicam linha; `SyncCompleted`/`SyncFailed` gravam com `workItemId` vazio
  sem quebrar.
- Rodar suite completa (`flutter test --reporter expanded`) ao final — baseline
  atual antes desta onda deve ser conferida rodando a suite no HEAD de
  `novaVersao` ainda sem o merge, para saber o numero de testes de partida.

## Ordem de execucao

1. `git status`/`git stash` se houver mudanca pendente; merge de
   `worktree-ws16-rule-undo` em `novaVersao` (resolver conflito trivial em
   `database_provider.dart` se houver, respeitando a regra de "getters no fim
   da classe").
2. Rodar `flutter test --reporter expanded` — confirmar que o merge sozinho ja
   deixa tudo verde antes de tocar em mais nada.
3. Editar `event_bus.dart` (assincrono) + `event_bus_test.dart`.
4. Editar `rule_engine.dart` (`_onEvent` sem `async void`).
5. Criar `journal_listener.dart` + `journal_listener_test.dart`.
6. Editar `database_provider.dart` (wiring do `JournalListener`).
7. `flutter analyze` + `flutter test --reporter expanded` completo.

## Riscos e mitigacao

| Risco | Mitigacao |
|---|---|
| Mudar `publish` para `Future<void>` quebra chamador que ignorava o retorno | Dart aceita `Future` descartado sem erro de compilacao — mas revisar cada `.publish(` listado nos achados-chave e adicionar `await` onde o chamador precisa da garantia de ordem (ex.: `event_emitting_work_item_repository.dart`) |
| `JournalListener` duplica linha ja gravada por `logEvent` manual (WS-16/WS-15) | Checar `type` contra a lista de tipos ja cobertos manualmente antes de gravar; teste explicito de nao-duplicacao |
| Excecao engolida silenciosamente no listener vira debito | Usar `developer.log` com `error`/`stackTrace`, nunca `catch (_) {}` vazio |

## Limitacoes conhecidas (comunicar, nao esconder)

- `JournalListener` grava eventos globais (`SyncCompleted`/`SyncFailed`) com
  `workItemId` vazio — nao ha ainda um `documentId`/`syncRunId` generico para
  associar (isso so chega na Onda 7, `Document`).
- Nenhuma UI de "linha do tempo" le esse journal ainda — a leitura fica restrita
  ao `RuleUndoUseCase` (WS-16) nesta onda; expor a UI de historico e trabalho
  futuro, nao pedido aqui.
