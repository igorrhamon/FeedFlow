# Onda 4 — WS-16: undo de regras (auditoria/undo)

> Plano de implementacao. Escopo conforme docs/PARALLEL-EXECUTION-PLAN.md:
> "WS-16: rule_undo_use_case.dart + WorkItemEventRepository (leitura da tabela
> WorkItemEvents, que so e escrita hoje, nunca lida) para 'desfazer ultimas 24h
> de uma regra'. Depende de WS-12 (payload de RuleMatched). Sem conflito de schema."

## Contexto

O objetivo e permitir desfazer o efeito de uma regra de automacao nas ultimas
24h. Antes de desenhar o "undo" em si, a exploracao do codigo revelou um gap
critico: hoje nada grava eventos de regra na tabela WorkItemEvents -- o
RuleEngine so publica RuleMatched no EventBus em memoria, que nao e
persistido em lugar nenhum. Sem essa gravacao, nao existe dado algum para o
undo consultar. Entao esta workstream tem duas partes: (1) fazer o
RuleEngine persistir o evento de match com payload suficiente, e (2) ler
esse historico e reverter o que for reversivel.

## Achados-chave

- WorkItemEvents (lib/infrastructure/db/tables.dart:41-51): id, workItemId,
  timestamp, type, actor, payloadJson. schemaVersion atual = 7. Sem
  @DataClassName -> row class gerada pelo drift e WorkItemEvent (singular) --
  cuidado para nao colidir o nome com o novo DTO de dominio.
- Unico metodo de escrita hoje: WorkItemRepository.logEvent(workItemId,
  {required type, required actor, payload}), ja implementado em
  work_item_repository_drift.dart:177-190, hoje so chamado por WorkflowRunner.
- RuleMatched (lib/domain/events/domain_event.dart) guarda ruleId,
  workItemId, ruleName, actionId (so a PRIMEIRA acao da regra) e um payload
  pre-execucao (status/priority/tags/triggerType) -- sem isStarred,
  necessario para reverter toggleStar.
- Acoes reversiveis: addTag, archive/complete (via changeStatus), toggleStar.
  NAO reversiveis (side-effects externos ou ja consumidos): copyLink, share,
  webhook, notionExport, obsidianExport, summarize/translate/classify.
  snooze nao e reversivel nesta primeira versao porque SnoozeUseCase tambem
  nao persiste evento nenhum hoje (mesmo gap sistemico do RuleEngine).
- Bug pre-existente (nao corrigido nesta workstream, so documentado):
  ActionExecutor.executeAll passa o MESMO snapshot de WorkItem para cada
  acao da regra -- acoes em sequencia nao veem a mutacao da anterior. Por
  isso o undo deve comparar estado atual vs. esperado antes de reverter,
  nunca sobrescrever cegamente.

## Decisoes de design

**A. Persistencia do match** -- sem mudar o shape Freezed de RuleMatched
(evita build_runner/risco de conflito). O RuleEngine, DEPOIS de
`await _actionExecutor.executeAll(...)` (para saber quais acoes tiveram
sucesso), chama `_workItemRepository.logEvent(workItemId, type: 'ruleMatched',
actor: 'rule', payload: {...})` com:
```json
{
  "ruleId": "...", "ruleName": "...", "triggerType": "...",
  "before": {"status": "...", "priority": "...", "tags": [...], "isStarred": true},
  "actionIds": ["addTag", "toggleStar"],
  "actionResults": [{"actionId": "addTag", "success": true}]
}
```
O RuleMatched do bus continua publicado antes de executeAll, sem mudanca de
timing (preserva os testes existentes).

**B. WorkItemEventRepository** -- sem coluna ruleId nova (mantem "sem
conflito de schema"). Le `type == 'ruleMatched' AND timestamp >= cutoff` e
filtra `payload['ruleId']` em Dart. Volume de 24h e pequeno o suficiente
para nao justificar indice/coluna nova agora.

**C. RuleUndoUseCase** -- `undoRule(String ruleId, {Duration window = 24h})`.
Por workItemId afetado (pegando o match mais recente dentro da janela):
- Guarda de seguranca: se `item.updatedAt` for posterior ao `matchedAt` do
  log (com tolerancia pequena), PULA o item inteiro (modifiedAfterMatch) --
  nao sobrescreve edicao/mudanca posterior.
- archive/complete: reverte via changeStatus para before.status, so se a
  transicao reversa for valida (isValidTriageTransition).
- toggleStar: reverte isStarred para before.isStarred.
- addTag: precisa resolver qual tag foi adicionada consultando
  RuleRepository.byId(ruleId); se a regra foi excluida depois, reporta
  ruleDeletedCannotResolveParams.
- snooze e acoes irreversiveis: sempre reportadas em actionsSkipped, nunca
  revertidas.
- Resultado: RuleUndoResult { ruleId, matchesFound, reverted: [...],
  skipped: [...] }, cada item com fieldsReverted/actionsSkipped (motivo).

**D. Wiring** -- DatabaseProvider ganha getters workItemEventRepository e
ruleUndoUseCase (padrao null sob kIsWeb, acrescentados no FIM da classe,
respeitando a regra de hotspot do arquivo).

**E. Sem UI** -- Onda 4 nao pede tela nova; entregavel e 100% logica/backend,
testavel via testes de integracao.

## Arquivos a criar/editar

1. lib/domain/repositories/work_item_event_repository.dart (novo) --
   interface + DTO WorkItemEventLog (plain Dart, sem Freezed -- mesmo padrao
   de ActionExecutionResult).
2. lib/infrastructure/repositories/work_item_event_repository_drift.dart
   (novo) -- implementacao drift, findSince(DateTime since, {String? type}).
3. lib/application/rule_engine.dart (editar) -- chamada a logEvent apos
   executeAll.
4. lib/application/rule_undo_use_case.dart (novo) -- RuleUndoUseCase +
   RuleUndoResult/WorkItemUndoOutcome/ActionUndoSkip.
5. lib/infrastructure/db/database_provider.dart (editar) -- getters novos,
   no fim da classe.

## Testes

- test/infrastructure/work_item_event_repository_drift_test.dart (novo):
  vazio sem eventos; filtra por since/type; decodifica payload aninhado;
  ordena por timestamp.
- test/application/rule_undo_use_case_test.dart (novo): reverte
  status/isStarred/tags; nao reverte item modificado depois do match; nao
  reverte fora da janela de 24h; reporta acoes irreversiveis; nao reverte
  acao que falhou originalmente.
- test/application/rule_engine_test.dart (editar): grupo existente
  "RuleMatched event" nao deve quebrar (so usa payload['status']/
  ['triggerType'], inalterados); novo grupo validando a persistencia real em
  db.workItemEvents (mesmo padrao de leitura de
  workflow_runner_test.dart:138-152).
- Rodar suite completa (flutter test --reporter expanded) ao final.

## Ordem de execucao

1. work_item_event_repository.dart (domain)
2. work_item_event_repository_drift.dart (infra) + teste
3. Editar rule_engine.dart (chamada a logEvent) + atualizar rule_engine_test.dart
4. rule_undo_use_case.dart + teste
5. Wiring em database_provider.dart
6. flutter analyze + flutter test completo

## Limitacoes conhecidas (comunicar, nao esconder)

- Undo de snooze nao suportado nesta versao (evento nao persistido hoje).
- Undo de addTag depende da regra ainda existir para resolver o parametro.
- Divergencia de estado por bug pre-existente do ActionExecutor e tratada
  defensivamente (compara antes de reverter), nao corrigida aqui.
