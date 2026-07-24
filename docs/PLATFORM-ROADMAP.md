# FeedFlow → Plataforma de Planejamento Inteligente
## Roadmap Técnico de Evolução (Ondas 5-34)

> **Contexto**: as Ondas 0-3 (`docs/PARALLEL-EXECUTION-PLAN.md`) já entregaram um leitor
> RSS multi-provider com uma camada local-first de triagem: `WorkItem`/FSM, `RuleEngine`,
> `ActionRegistry`/`ActionExecutor` (13 ações), FTS5, e 3 adapters de LLM. A Onda 4
> (WS-16, undo de regras) está pronta no branch `worktree-ws16-rule-undo`, ainda não
> mergeada em `novaVersao`.
>
> Este documento planeja o que falta para transformar isso em uma plataforma de
> inteligência pessoal: ingestão universal, knowledge base, knowledge graph,
> enriquecimento industrial, planejamento, execução com aprovação, agentes, memória e
> plataforma (SDK/API/MCP/marketplace). Índice e decisões de alto nível em
> `C:\Users\F4352981\.claude\plans\planejamento-de-evolu-o-sorted-pizza.md`.

---

## 0. Premissas corrigidas antes de planejar

O pedido original presumia que o projeto já tinha "arquitetura baseada em eventos",
"sincronização offline" e "clustering inicial". A exploração do código mostrou que:

- **EventBus é síncrono, em memória, não persistido** (`lib/application/event_bus.dart`),
  com um único subscriber (`RuleEngine`) cujo handler é `async void` sobre um bus
  síncrono (`rule_engine.dart:40`) — publish() retorna antes das ações terminarem.
- **Sincronização** hoje é só outbox de read/star para o provider remoto
  (`lib/application/sync_service.dart`), não sync entre dispositivos.
- **Clustering/embeddings/vetores/knowledge graph: não existem** no código.
- **FTS5 é real** (`lib/infrastructure/db/database.dart:100`, triggers de sync) — ponto
  forte a reaproveitar.
- **`WorkflowRunner` é linear e em memória**, não um DAG persistido.

O roadmap abaixo começa corrigindo essas bases (Ondas 5-6) antes de construir em cima.

---

## Fase A — Fundações e ingestão universal (Ondas 5-14)

### Onda 5 — Journal de eventos + higiene

**Objetivo**: dar ao sistema uma trilha de eventos persistida e assíncrona, e fechar o
débito de auditoria/undo que já está pronto em branch.

**Motivação**: sem um journal durável, undo, replay, workers e observabilidade não têm
onde se apoiar. É a mudança de menor risco com maior alavancagem para tudo que segue.

**Problema resolvido**: eventos hoje se perdem (bus em memória); `RuleEngine` não
espera suas próprias ações completarem; não há como saber "o que aconteceu ontem".

**Funcionalidades**: mergear WS-16 (undo de regras); `EventBus` publica de forma
assíncrona e aguardável; todo evento de domínio grava uma linha em journal persistido
(reaproveitando a tabela `WorkItemEvents` já existente, generalizada).

**Arquitetura**: `EventBus.publish` retorna `Future<void>` e aguarda todos os
subscribers; um subscriber padrão (`PersistentJournalListener`) grava cada
`DomainEvent` serializado. Não muda a assinatura pública de `DomainEvent` (evita
`build_runner` em cascata).

**Novos componentes**: `lib/infrastructure/repositories/work_item_event_repository_drift.dart`
(de WS-16), `lib/application/rule_undo_use_case.dart` (de WS-16),
`lib/application/journal_listener.dart` (novo, grava qualquer `DomainEvent`, não só
`ruleMatched`).

**Alterações em componentes existentes**: `event_bus.dart` (publish assíncrono);
`rule_engine.dart` (remove `async void`, usa `await`); `database_provider.dart`
(getters `workItemEventRepository`/`ruleUndoUseCase`, no fim da classe).

**Modelo de dados**: nenhuma tabela nova — `WorkItemEvents` (schema atual) já cobre;
`type` ganha os valores que hoje são só publicados no bus e nunca persistidos
(`enrichmentCompleted`, `enrichmentFailed`, `syncCompleted`, `syncFailed`,
`snoozeExpired`).

**Eventos**: todos os já existentes em `domain_event.dart` passam a ser persistidos,
não só os que já tinham `logEvent` manual.

**APIs**: nenhuma pública nesta onda (só interna).

**Fluxo completo**: ação dispara evento → `EventBus.publish` (await) → `RuleEngine`
processa e só então retorna → `JournalListener` grava linha em `WorkItemEvents` →
`RuleUndoUseCase` pode consultar essas linhas para desfazer últimas 24h.

**Dependências**: nenhuma — pode começar imediatamente.

**Critérios de aceite**: `flutter test` verde incluindo os testes já escritos de WS-16;
nenhum evento definido em `domain_event.dart` fica sem persistência; suite de regras
não regride em tempo de execução (handler aguardável não deve travar UI).

**Riscos**: mudar `publish` para `Future<void>` pode expor exceções antes escondidas
(bug pré-existente do `async void`) — tratar com try/catch por subscriber, sem engolir
silenciosamente (logar).

**Débito técnico**: nenhum introduzido; reduz débito existente (undo, silent-fail).

**Estimativa**: 2 semanas (WS-16 já pronto reduz o trabalho a merge + generalização do
listener).

**Impacto usuário**: "desfazer regra" passa a funcionar de fato.

**Impacto monetização**: nenhum direto — é fundação.

---

### Onda 6 — Job queue + DAG runner persistido

**Objetivo**: dar a qualquer trabalho caro (LLM, embeddings, crawl, export) uma fila
com retry, idempotência e progresso visível, e transformar `WorkflowRunner` de lista
linear em DAG persistido.

**Motivação**: toda a Fase B (enriquecimento, embeddings, clustering) e a Fase D
(execução, agentes) dependem de rodar trabalho assíncrono de forma confiável.

**Problema resolvido**: hoje uma ação de LLM roda inline dentro do `ActionExecutor`
sem retry nem cancelamento; um workflow com 10 passos não sobrevive a um crash no
passo 5.

**Funcionalidades**: enfileirar job com payload tipado; execução em background com
backoff exponencial; workflows viram grafo de jobs com dependências, não lista.

**Arquitetura**: tabela `jobs` (fila) + `job_runs` (histórico de tentativas). Um
`JobRunner` consome `jobs` pendentes (poll ou stream reativo do drift), delega ao
handler registrado por `jobType` (mesmo padrão de `ActionRegistry`).

**Novos componentes**: `lib/domain/job.dart` (`Job`, `JobStatus`, `JobRun`),
`lib/domain/repositories/job_repository.dart`, `job_repository_drift.dart`,
`lib/application/job_runner.dart`, `lib/application/job_registry.dart`.

**Alterações em componentes existentes**: `workflow_runner.dart` passa a enfileirar
cada `ActionInvocation` como job com `dependsOn: [jobId]` em vez de rodar inline;
`main.dart` chama `initializeJobHandlers()`.

**Modelo de dados**:
```
Jobs: id(pk), type, payloadJson, status(pending|running|done|failed),
      dependsOnJson, attempts, maxAttempts, nextRunAt, createdAt
JobRuns: id(pk autoinc), jobId, startedAt, finishedAt, success, error
```
Dona do schema desta onda (próximo `schemaVersion` após 7).

**Eventos**: `JobEnqueued`, `JobStarted`, `JobSucceeded`, `JobFailed`, `JobRetried`.

**APIs**: `JobRunner.enqueue(type, payload, {dependsOn})`, `JobRepository.watchByStatus`.

**Fluxo completo**: `WorkflowRunner` decompõe uma `Rule.actions` em jobs com aresta de
dependência → `JobRunner` executa respeitando ordem topológica → cada sucesso/falha
grava `JobRun` e publica evento → journal (Onda 5) registra tudo.

**Dependências**: Onda 5 (journal para auditoria de jobs).

**Critérios de aceite**: um workflow de 3 passos sobrevive a reinício do app (retoma
do job pendente); job com falha permanente após `maxAttempts` fica visível como
`failed`, não trava a fila inteira.

**Riscos**: overengineering de DAG genérico — mitigar limitando a v1 a grafos lineares
com "fan-out" simples (1 job → N filhos independentes), sem join complexo.

**Débito técnico**: `WorkflowRunner` atual (linear, em memória) fica marcado deprecated
até esta onda substituir seu uso interno.

**Estimativa**: 3 semanas.

**Impacto usuário**: workflows não "somem" se o app fechar no meio.

**Impacto monetização**: base técnica para cotas de uso (jobs de IA contam tokens/custo
por usuário — pré-requisito de billing na Onda 34).

---

### Onda 7 — `Document` + `SourceConnector`

**Objetivo**: generalizar a unidade de conteúdo ingerido, para que RSS deixe de ser a
única fonte possível sem quebrar o que existe.

**Motivação**: "ingestão universal" é o pedido central da Onda 1-14; sem esse passo,
cada fonte nova reimplementaria `WorkItem` do zero.

**Problema resolvido**: `WorkItem` hoje tem `providerId`/`articleId`/`feedId` cravados
como se todo conteúdo viesse de um feed RSS.

**Funcionalidades**: `Document` (conteúdo bruto + proveniência: fonte, autor, url,
timestamps, tipo de mídia); `WorkItem` passa a referenciar `documentId` em vez de
duplicar campos de conteúdo; `SourceConnector` como interface abstrata (mirror de
`FeedProvider`), com `RssSourceConnector` sendo o primeiro (adaptando `FeedProvider`
existente).

**Arquitetura**: `SourceConnector.pull()` retorna `List<Document>`; `SyncService`
passa a converter `Document → WorkItem` (não mais `Article → WorkItem` direto) —
`Article` vira um caso particular de `Document` via adaptador, sem tocar nos 9
providers.

**Novos componentes**: `lib/domain/document.dart`, `lib/domain/source_connector.dart`,
`lib/application/source_connector_registry.dart`,
`lib/infrastructure/connectors/rss_source_connector.dart` (wrap de `FeedProvider`).

**Alterações em componentes existentes**: `WorkItems` table ganha `documentId`
nullable (migração aditiva, dados existentes continuam válidos sem documentId — leem
do próprio `WorkItem` como fallback); `sync_service.dart` refeito para usar o
connector genérico.

**Modelo de dados**:
```
Documents: id(pk), sourceConnectorId, sourceId, contentType, title, author,
           rawContent, url, capturedAt, metadataJson
WorkItems: + documentId (nullable, FK lógica)
```
Dona do schema desta onda.

**Eventos**: `DocumentIngested` (substitui parcialmente `ArticleIngested`, que
continua existindo para compatibilidade de regras já salvas).

**APIs**: `SourceConnectorRegistry.create(id)`, `SourceConnector.pull({since})`.

**Fluxo completo**: connector busca conteúdo novo → `Document` persistido →
`WorkItem.fromDocument()` cria/atualiza a unidade de triagem → regras/ações
continuam operando sobre `WorkItem` sem mudança de contrato.

**Dependências**: nenhuma bloqueante; idealmente após Onda 6 (jobs) para que `pull()`
de conectores lentos rode como job.

**Critérios de aceite**: os 9 providers RSS continuam funcionando sem alteração
própria; testes de `sync_service_test.dart` passam com o novo caminho `Document`.

**Riscos**: maior risco arquitetural do roadmap — migração de schema tocando
`WorkItems`. Mitigação: `documentId` nullable, sem backfill obrigatório, migração
reversível.

**Débito técnico**: por um tempo existem dois caminhos (`Article` direto e via
`Document`) — remover o caminho antigo é trabalho futuro adiável, não bloqueante.

**Estimativa**: 4 semanas.

**Impacto usuário**: nenhum visível ainda (é fundação), mas destrava as 7 ondas
seguintes de ingestão.

**Impacto monetização**: nenhum direto.

---

### Onda 8 — Knowledge Base

**Objetivo**: um lugar único para documentos, notas próprias, anexos, versionamento e
histórico — não só artigos ingeridos.

**Motivação**: sem uma KB, "correlacionar informações" (pedido nº 4) não tem sobre o
que operar além de RSS.

**Problema resolvido**: hoje não há como o usuário criar uma nota própria ligada a um
`WorkItem`, nem anexar arquivos.

**Funcionalidades**: notas Markdown vinculadas a `WorkItem`/`Document`; anexos
(arquivo local); histórico de versões de uma nota; página de "biblioteca" navegável.

**Arquitetura**: `Note` é um tipo de `Document` (sourceConnectorId = `'local-note'`);
versionamento via tabela `document_versions` append-only (nunca sobrescreve).

**Novos componentes**: `lib/domain/note.dart`,
`lib/infrastructure/repositories/document_version_repository_drift.dart`,
`lib/pages/note_editor_page.dart`, `lib/pages/knowledge_base_page.dart`.

**Alterações em componentes existentes**: `search_repository.dart` passa a indexar
`Documents` além de `WorkItems` (FTS5 sobre a tabela nova, trigger próprio).

**Modelo de dados**:
```
DocumentVersions: id(pk autoinc), documentId, contentSnapshot, createdAt, changeNote
```
Dona do schema desta onda.

**Eventos**: `NoteCreated`, `NoteVersioned`, `DocumentAttached`.

**APIs**: `KnowledgeBaseRepository.createNote`, `.attachFile`, `.history(documentId)`.

**Fluxo completo**: usuário cria nota a partir de um `WorkItem` (ação "criar nota") →
nota vira `Document` versionado → aparece na busca (FTS5) e fica disponível para
regras/enriquecimento como qualquer outro documento.

**Dependências**: Onda 7 (`Document`).

**Critérios de aceite**: editar uma nota gera nova versão sem perder a anterior; busca
retorna notas junto com artigos.

**Riscos**: escopo de editor rico (Markdown) pode inflar — v1 é texto simples com
preview, sem WYSIWYG.

**Débito técnico**: nenhum novo.

**Estimativa**: 3 semanas.

**Impacto usuário**: alto — primeira feature "não-RSS" visível.

**Impacto monetização**: indireto (retenção — usuário com notas próprias no app troca
menos de ferramenta).

---

### Onda 9 — Conectores de arquivos (pasta local, Markdown/Obsidian, PDF, Office)

**Objetivo**: ingerir conteúdo de arquivos sem precisar de rede.

**Motivação**: alto valor, zero dependência de backend — cabe perfeitamente no
princípio local-first.

**Problema resolvido**: hoje só RSS entra no sistema; qualquer PDF ou vault de notas
fica fora.

**Funcionalidades**: watcher de pasta local; parser de vault Markdown/Obsidian
(reaproveita a integração `obsidian_integration.dart` já existente, invertendo a
direção: import em vez de só export); extração de texto de PDF; leitura de
`.docx`/`.xlsx` básica (texto).

**Arquitetura**: cada um vira `SourceConnector` (Onda 7): `FolderSourceConnector`,
`MarkdownVaultConnector`, `PdfSourceConnector`, `OfficeSourceConnector`.

**Novos componentes**: `lib/infrastructure/connectors/folder_source_connector.dart`,
`markdown_vault_connector.dart`, `pdf_source_connector.dart` (nova dependência: parser
de PDF em Dart puro), `office_source_connector.dart`.

**Alterações em componentes existentes**: `application/integrations/obsidian_integration.dart`
ganha método `readVault()` complementando o `export()` já existente.

**Modelo de dados**: nenhuma tabela nova (usa `Documents` da Onda 7).

**Eventos**: `DocumentIngested` (reaproveitado).

**APIs**: `SourceConnectorRegistry` ganha 4 novas entradas.

**Fluxo completo**: usuário aponta uma pasta → connector varre e ingere cada arquivo
suportado como `Document` → aparece na KB e na busca.

**Dependências**: Onda 7.

**Critérios de aceite**: PDF de texto simples extrai conteúdo pesquisável; vault
Obsidian com 100 notas ingere em menos de 10s.

**Riscos**: parsing de PDF/Office em Dart é limitado (sem OCR) — documentar
explicitamente como limitação, não prometer PDFs escaneados.

**Débito técnico**: parser de Office pode precisar de biblioteca nativa por
plataforma — avaliar caso a caso, adiar Windows-only se necessário.

**Estimativa**: 3 semanas.

**Impacto usuário**: alto para power users com vaults/PDFs.

**Impacto monetização**: nenhum direto (free).

---

### Onda 10 — Email (IMAP) como fonte

**Objetivo**: caixa de entrada de email participando do mesmo pipeline de triagem.

**Motivação**: email é a fonte de informação nº 1 para a maioria dos usuários —
maior alavancagem de adoção da Fase A.

**Problema resolvido**: hoje nada conecta ao email.

**Funcionalidades**: conexão IMAP (credenciais via `flutter_secure_storage`, mesmo
padrão de `provider_settings.dart`); import de emails como `Document`; regras podem
disparar sobre email (remetente, assunto).

**Arquitetura**: `ImapSourceConnector` usando um cliente IMAP Dart; autenticação
reaproveita `AuthType.basicAuth`/`oauth2` já modelados em `auth_config.dart`.

**Novos componentes**: `lib/infrastructure/connectors/imap_source_connector.dart`,
`lib/providers/auth/imap_auth_config.dart` (se OAuth2 de provedor específico for
necessário, reaproveita `OAuth2AuthConfig`).

**Alterações em componentes existentes**: `login_screen.dart`/settings ganham forma
de conexão de "fonte" (distinta de "provider" de feed) — novo fluxo de configuração,
não substitui o de login de provider.

**Modelo de dados**: nenhuma tabela nova.

**Eventos**: `DocumentIngested`.

**APIs**: `ImapSourceConnector.pull({since})` com paginação por UID.

**Fluxo completo**: usuário configura conta IMAP → connector faz poll periódico
(via job da Onda 6) → cada email novo vira `Document` → condição de regra
`field: 'sender'` já suportada pelo `ConditionEvaluator` existente (`equals`/`contains`).

**Dependências**: Onda 7, Onda 6 (poll como job).

**Critérios de aceite**: conectar Gmail/Outlook via IMAP+senha de app; 50 emails
ingeridos sem duplicar em polls subsequentes (idempotência por UID).

**Riscos**: OAuth2 de provedores de email (Gmail exige OAuth, não senha simples em
muitos casos) — v1 documenta suporte só a IMAP+senha de app; OAuth de Gmail/Outlook
fica como extensão futura.

**Débito técnico**: sem suporte a anexos de email nesta v1 (só corpo texto/HTML).

**Estimativa**: 3 semanas.

**Impacto usuário**: muito alto — email é gatilho de adoção.

**Impacto monetização**: nenhum direto ainda (free), mas alimenta o funil para
Premium (regras+IA sobre email é o gancho natural).

---

### Onda 11 — FeedFlow Hub (backend opcional)

**Objetivo**: introduzir o primeiro componente de servidor, estritamente opcional.

**Motivação**: webhooks reais, workers pesados e sync entre dispositivos exigem um
endpoint sempre-ligado — impossível 100% no dispositivo.

**Problema resolvido**: sem servidor, "Webhooks" (ingestão) e qualquer conector SaaS
que empurre dados (em vez de o app puxar) são inviáveis.

**Funcionalidades**: servidor mínimo (self-hosted, Docker) que recebe webhooks e
relay para o app via long-poll/websocket quando online, ou fila para quando offline;
endpoint de autenticação por token de dispositivo.

**Arquitetura**: novo serviço (`hub/`, Node.js — reaproveitando a experiência já
existente com `proxy/`), stateless na parte de relay, com fila (Redis ou SQLite
própria) para persistência mínima de mensagens pendentes.

**Novos componentes**: `hub/server.js`, `hub/webhook_relay.js`,
`lib/infrastructure/connectors/hub_relay_connector.dart` (cliente do relay).

**Alterações em componentes existentes**: nenhuma no client-side além do novo
connector — grau de opcionalidade total (app funciona sem o Hub configurado).

**Modelo de dados** (no Hub, fora do SQLite do app): `devices`, `pending_messages`.
No app: nenhuma tabela nova (mensagens relayed viram `Document` como qualquer outro).

**Eventos**: `HubMessageReceived` (client-side, ao consumir do relay).

**APIs**: `POST /hub/webhook/:token`, `GET /hub/poll/:deviceId` (ou websocket
equivalente).

**Fluxo completo**: serviço externo (GitHub, Slack) envia webhook → Hub recebe e
enfileira → app conectado recebe via long-poll → vira `Document` → pipeline normal.

**Dependências**: Onda 7 (Document), Onda 6 (jobs, para processar mensagens
recebidas de forma confiável).

**Critérios de aceite**: um webhook de teste (curl) chega ao app em menos de 5s com o
app aberto; mensagem sobrevive a app fechado e é entregue na próxima abertura.

**Riscos**: primeira peça de infraestrutura hospedada — custo operacional e
superfície de segurança novos (autenticação de webhook, rate limit). Mitigar com
self-hosted como opção padrão documentada, gerenciado como upsell (Onda 12).

**Débito técnico**: sem alta disponibilidade nem multi-região nesta v1 — aceitável
para uso individual.

**Estimativa**: 4 semanas.

**Impacto usuário**: nenhum direto ainda (é infraestrutura) — mas único gate para as
6 ondas seguintes.

**Impacto monetização**: define o próprio produto "Hub gerenciado" (Premium).

---

### Onda 12 — Sync multi-dispositivo

**Objetivo**: o mesmo estado de triagem (`WorkItem`, tags, regras) disponível em mais
de um dispositivo.

**Motivação**: primeiro recurso claramente premium — justifica cobrança recorrente.

**Problema resolvido**: hoje cada instalação do app tem seu próprio SQLite isolado.

**Funcionalidades**: replicação do journal de eventos (Onda 5) via Hub; resolução de
conflito last-write-wins por campo, com merge manual para casos ambíguos (nota
editada em dois lugares).

**Arquitetura**: cada dispositivo envia seus eventos do journal ao Hub (append-only);
Hub distribui a outros dispositivos do mesmo usuário; app aplica eventos recebidos
como replay sobre o `WorkItemRepository` local (mesma máquina de estados que já
processa eventos locais).

**Novos componentes**: `lib/application/sync_journal_use_case.dart`,
`hub/replication_service.js`.

**Alterações em componentes existentes**: `event_bus.dart`/journal (Onda 5) ganha
campo `deviceId`/`syncedAt` para dedupe.

**Modelo de dados**: `WorkItemEvents` ganha `deviceId` (nullable, default local);
no Hub, `event_log` por usuário.

**Eventos**: `RemoteEventReceived`, `ConflictDetected`.

**APIs**: `POST /hub/sync/push`, `GET /hub/sync/pull?since=`.

**Fluxo completo**: dispositivo A muda status de um `WorkItem` → evento local +
enviado ao Hub → dispositivo B faz pull periódico (job) → replay do evento → mesmo
estado em ambos.

**Dependências**: Onda 11 (Hub), Onda 5 (journal).

**Critérios de aceite**: marcar como lido em um dispositivo reflete no outro em até
1 minuto (poll); edição concorrente do mesmo campo não corrompe dado (LWW
determinístico por timestamp).

**Riscos**: CRDT "de verdade" é complexo — v1 aceita LWW simples e documenta
perda de escrita concorrente rara como limitação conhecida, não como bug.

**Débito técnico**: merge manual de notas conflitantes fica para depois (v1: a
versão mais recente vence, a anterior fica no histórico da Onda 8).

**Estimativa**: 4 semanas.

**Impacto usuário**: alto para quem usa celular + desktop.

**Impacto monetização**: **gatilho de cobrança nº 1** do roadmap.

---

### Onda 13 — Conectores SaaS I (GitHub, Slack, Discord)

**Objetivo**: primeiras integrações de terceiros via webhook real, validando o Hub.

**Motivação**: valida a Onda 11 com tráfego de produção real antes de expandir para
mais conectores.

**Funcionalidades**: issues/PRs do GitHub, mensagens de canal do Slack/Discord viram
`Document`; ações de saída (já existentes: `webhook_action.dart`) podem responder.

**Arquitetura**: cada um é um `SourceConnector` que consome do Hub relay (Onda 11)
com parsing específico do payload do webhook.

**Novos componentes**: `lib/infrastructure/connectors/github_source_connector.dart`,
`slack_source_connector.dart`, `discord_source_connector.dart`.

**Dependências**: Onda 11.

**Critérios de aceite**: abrir uma issue no GitHub gera um `WorkItem` triável em
menos de 10s.

**Riscos**: rate limits e formatos de payload variáveis — versionar parser por
conector.

**Estimativa**: 3 semanas. **Impacto monetização**: parte do pacote Premium (Hub).

---

### Onda 14 — Conectores SaaS II (Notion, Telegram, Teams, feeds privados)

**Objetivo**: completar a cobertura de "ingestão universal" do pedido original.

**Funcionalidades**: Notion (API oficial, complementa `notion_integration.dart` já
existente, agora também como fonte de leitura); Telegram (Bot API); Teams (webhook
connector oficial); feeds privados autenticados genéricos.

**Arquitetura**: mesmo padrão `SourceConnector`; Notion reaproveita
`notion_integration.dart` estendendo com método de leitura.

**Dependências**: Onda 11 (Teams/Telegram via webhook), Onda 7 (feeds privados via
pull direto, não precisa de Hub).

**Nota de escopo**: WhatsApp fica **fora** deste roadmap (API oficial de negócios é
paga e exige verificação de empresa — não é viável como capacidade de plataforma
gratuita; pode voltar como conector pago no marketplace, Onda 34).

**Estimativa**: 3 semanas. **Impacto monetização**: Premium.

---

## Fase B — Inteligência (Ondas 15-22)

### Onda 15 — Pipeline de enriquecimento industrial

**Objetivo**: transformar o enriquecimento por LLM de chamada síncrona-dentro-de-ação
em job de primeira classe com cache, dedupe e orçamento.

**Motivação**: sem isso, custo de LLM escala linearmente e sem controle assim que o
volume de fontes cresce (Fase A completa).

**Problema resolvido**: hoje `summarize/translate/classify_action.dart` chamam o
`Enricher` inline, sem retry, sem cache (o mesmo documento pode ser resumido duas
vezes), sem teto de gasto.

**Funcionalidades**: enfileirar enriquecimento como job (Onda 6); cache por
hash-de-conteúdo (não reprocessa o mesmo texto); painel de custo agregado por
usuário/modelo/dia.

**Arquitetura**: `EnrichmentJobHandler` registrado no `JobRegistry` da Onda 6,
chamando o `LlmEnricherRouter` já existente — nenhuma mudança nos adapters.

**Novos componentes**: `lib/application/enrichment_job_handler.dart`,
`lib/infrastructure/repositories/enrichment_cache_repository_drift.dart`,
`lib/pages/llm_usage_page.dart` (painel de custo).

**Alterações em componentes existentes**: `summarize/translate/classify_action.dart`
passam a enfileirar em vez de chamar `enrich()` direto.

**Modelo de dados**: `EnrichmentCache: contentHash(pk), type, result, model, createdAt`.
Dona do schema desta onda.

**Eventos**: `EnrichmentQueued`, `EnrichmentCacheHit` (além dos já existentes
`EnrichmentCompleted/Failed`, agora finalmente publicados de verdade — hoje mortos).

**Dependências**: Onda 6.

**Critérios de aceite**: reenriquecer o mesmo documento não gera nova chamada de API;
painel mostra custo do dia corrente.

**Riscos**: cache por hash pode colidir entre idiomas de tradução diferentes —
chave de cache inclui `type + targetLanguage + contentHash`.

**Estimativa**: 3 semanas. **Impacto monetização**: pré-requisito de cota
Premium/BYO-key no free tier.

---

### Onda 16 — Embeddings + busca híbrida

**Objetivo**: busca semântica local, somada (não substituindo) o FTS5 existente.

**Motivação**: "knowledge base" só é útil em volume se a busca for por significado,
não só palavra-chave.

**Problema resolvido**: FTS5 não encontra sinônimos/paráfrases.

**Funcionalidades**: embedding de cada `Document`/`WorkItem` (via LLM provider ativo
ou modelo local leve); busca híbrida = FTS5 (BM25) + similaridade vetorial, fundidos
por Reciprocal Rank Fusion.

**Arquitetura**: **spike de 1 dia primeiro** validando `sqlite-vec` carregando como
extensão do `sqlite3_flutter_libs` em Android e Windows (mesma disciplina usada na
WS-17 para FTS5) — é o único risco técnico real desta onda.

**Novos componentes**: `lib/infrastructure/db/vector_helpers.dart`,
`lib/application/embedding_job_handler.dart`,
`lib/domain/repositories/vector_search_repository.dart` + impl drift.

**Alterações em componentes existentes**: `search_page.dart` passa a fundir os dois
resultados; `search_repository.dart` ganha `hybridSearch()`.

**Modelo de dados**: `DocumentEmbeddings: documentId(pk), vector(blob), model,
createdAt` (tabela virtual `vec0` se `sqlite-vec` disponível). Dona do schema.

**Eventos**: `EmbeddingComputed`.

**Dependências**: Onda 15 (job de embedding é um `EnrichmentJobHandler` irmão),
Onda 7.

**Critérios de aceite**: busca por "problema de autenticação" encontra documento que
fala em "erro de login" sem a palavra "autenticação".

**Riscos**: **se o spike falhar** (extensão não carrega em alguma plataforma), plano
B é fallback para busca vetorial em memória (Dart puro, sem índice, aceitável até
~5k documentos) documentado explicitamente como degradação por plataforma.

**Estimativa**: 4 semanas (inclui spike). **Impacto monetização**: Premium.

---

### Onda 17 — Deduplicação e clustering

**Objetivo**: colapsar a mesma história vinda de N fontes em um cluster único.

**Motivação**: ingestão universal (Fase A) multiplica ruído — a mesma notícia chega
por RSS, email e Slack.

**Funcionalidades**: agrupamento por similaridade de embedding (threshold + hierarchical
clustering leve); UI mostra "12 fontes sobre isto" em vez de 12 itens soltos.

**Arquitetura**: job periódico (Onda 6) que roda clustering incremental sobre
embeddings novos (Onda 16), não recomputa tudo a cada vez.

**Novos componentes**: `lib/domain/cluster.dart`,
`lib/application/clustering_job_handler.dart`,
`lib/infrastructure/repositories/cluster_repository_drift.dart`.

**Modelo de dados**: `Clusters: id(pk), centroidVector, label, createdAt`;
`ClusterMembers: clusterId, documentId, similarity`. Dona do schema.

**Eventos**: `ClusterFormed`, `DocumentClustered`.

**Dependências**: Onda 16.

**Critérios de aceite**: 3 artigos sobre o mesmo evento de fontes diferentes viram 1
cluster navegável.

**Riscos**: clustering incremental pode divergir de um recompute completo com o
tempo — job de "reconciliação" mensal completo como salvaguarda.

**Estimativa**: 3 semanas. **Impacto monetização**: Premium (reduz ruído = retenção).

---

### Onda 18 — Extração de entidades → grafo

**Objetivo**: popular pessoas/empresas/projetos/produtos/tecnologias/eventos como
entidades estruturadas, não só texto solto.

**Motivação**: `EnrichmentType.entities` já existe no enum mas nunca foi implementado
— é o gancho natural para o knowledge graph pedido.

**Funcionalidades**: extração de entidades via LLM (saída estruturada/JSON) por
documento; grafo simples (tabelas `nodes`/`edges`), suficiente para escala individual
sem precisar de Neo4j.

**Arquitetura**: `EntityExtractionJobHandler` (mais um handler de enriquecimento);
resolução ingênua de entidade (match por nome normalizado) nesta v1 — merge de
duplicatas fica para a Onda 19.

**Novos componentes**: `lib/domain/graph_node.dart`, `lib/domain/graph_edge.dart`,
`lib/infrastructure/repositories/graph_repository_drift.dart`.

**Modelo de dados**:
```
GraphNodes: id(pk), type(person|company|project|product|tech|event),
            label, metadataJson
GraphEdges: id(pk autoinc), fromNodeId, toNodeId, relation, documentId, weight
```
Dona do schema.

**Eventos**: `EntityExtracted`, `EdgeCreated`.

**Dependências**: Onda 15.

**Critérios de aceite**: um documento mencionando "Empresa X lançou Produto Y" gera
2 nós e 1 aresta.

**Riscos**: extração via LLM tem taxa de erro/alucinação — v1 marca entidades como
"sugeridas", exige confirmação do usuário antes de virarem nó definitivo (evita
grafo poluído).

**Estimativa**: 4 semanas. **Impacto monetização**: Premium.

---

### Onda 19 — Grafo navegável + busca por contexto

**Objetivo**: tornar o grafo da Onda 18 utilizável, não só armazenado.

**Funcionalidades**: página "tudo sobre X" (nó + vizinhos + documentos de origem);
visualização simples (force-directed, poucas dezenas de nós por vez); merge manual de
entidades duplicadas.

**Arquitetura**: CTE recursiva SQLite para expansão de vizinhança (`WITH RECURSIVE`)
— evita dependência de motor de grafo externo.

**Novos componentes**: `lib/pages/entity_page.dart`, `lib/pages/graph_explorer_page.dart`,
`lib/application/entity_merge_use_case.dart`.

**Dependências**: Onda 18.

**Critérios de aceite**: clicar num nó "Empresa X" mostra todos os documentos e
entidades relacionadas em profundidade 2.

**Riscos**: performance de CTE recursiva em grafos grandes — limitar profundidade
(2-3 saltos) e paginar.

**Estimativa**: 3 semanas. **Impacto monetização**: Premium.

---

### Onda 20 — Briefings e sumarização multi-documento

**Objetivo**: digest diário/semanal por tema, cluster ou projeto.

**Funcionalidades**: job agendado (Onda 6, `RuleTrigger.schedule` já existe via
`RuleScheduler`) que sumariza N documentos de um cluster/tag em um briefing único.

**Novos componentes**: `lib/application/briefing_job_handler.dart`,
`lib/pages/briefing_page.dart`.

**Dependências**: Onda 17 (clusters), Onda 15 (jobs de LLM).

**Critérios de aceite**: briefing diário gerado às 7h resume os clusters novos das
últimas 24h em menos de 200 palavras.

**Estimativa**: 2 semanas (paralelizável com Onda 21). **Impacto usuário**: alto.

---

### Onda 21 — Extração estruturada (tarefas, decisões, riscos, oportunidades)

**Objetivo**: sair do texto livre para dados acionáveis.

**Funcionalidades**: LLM com saída tipada (tool-use/JSON schema) extrai
`ExtractedTask`/`ExtractedDecision`/`ExtractedRisk`/`ExtractedOpportunity` de um
documento; usuário confirma antes de virarem itens de planejamento (Fase C).

**Novos componentes**: `lib/domain/extraction.dart` (4 tipos), `extraction_job_handler.dart`.

**Modelo de dados**: `Extractions: id(pk), documentId, type, dataJson, confirmed(bool)`.
Dona do schema.

**Dependências**: Onda 15.

**Critérios de aceite**: um email com "vamos entregar até sexta" extrai 1
`ExtractedTask` com prazo.

**Estimativa**: 3 semanas (paralelizável com Onda 20).

---

### Onda 22 — Correlação e detecção de mudanças

**Objetivo**: "algo mudou no que te importa" como alerta proativo.

**Funcionalidades**: diff temporal por entidade/tema (compara embedding/cluster de
hoje vs. snapshot anterior); regra automática pode disparar notificação.

**Novos componentes**: `lib/application/change_detection_job_handler.dart`.

**Dependências**: Ondas 18, 19, 21 (usa entidades e extrações para saber "o que
importa").

**Critérios de aceite**: mudança de status de um projeto acompanhado gera 1 evento
`RiskDetected`/`OpportunityDetected` consumível por regra existente.

**Estimativa**: 3 semanas. Fecha a Fase B.

---

## Fase C — Planejamento (Ondas 23-26)

### Onda 23 — Domínio de planejamento

**Objetivo**: `Objetivo`, `Projeto`, `Épico`, `Milestone`, `Task` como cidadãos de
primeira classe, ligados aos documentos que os originaram.

**Funcionalidades**: CRUD de itens de planejamento; vínculo bidirecional com
`Document`/`WorkItem`/`Extraction` (Onda 21) de origem; dependências entre tasks.

**Novos componentes**: `lib/domain/planning_item.dart` (`Goal`, `Project`, `Epic`,
`Milestone`, `PlanTask`), `lib/domain/repositories/planning_repository.dart` + drift,
`lib/pages/planning_page.dart`.

**Modelo de dados**:
```
PlanningItems: id(pk), type, title, status, parentId(nullable),
               sourceDocumentId(nullable), dueDate, createdAt
PlanningDependencies: fromItemId, toItemId, kind(blocks|relatesTo)
```
Dona do schema.

**Dependências**: Onda 21 (para criar itens a partir de extrações), mas funciona
standalone (criação manual) sem depender da Fase B inteira.

**Critérios de aceite**: converter uma `ExtractedTask` confirmada em `PlanTask` com 1
clique.

**Estimativa**: 3 semanas.

---

### Onda 24 — Roadmaps e cronogramas

**Funcionalidades**: timeline visual, estimativas (esforço/data), caminho crítico
simples, registro de riscos por item.

**Novos componentes**: `lib/pages/roadmap_page.dart`, `lib/application/critical_path_use_case.dart`.

**Dependências**: Onda 23.

**Critérios de aceite**: roadmap de um projeto com 10 tasks mostra caminho crítico
correto (validado com caso de teste conhecido).

**Estimativa**: 3 semanas (paralelizável com Onda 25).

---

### Onda 25 — Planos gerados por IA

**Funcionalidades**: templates (plano estratégico, financeiro, de estudos, de
pesquisa) preenchidos por LLM a partir do grafo (Onda 19) e extrações (Onda 21),
sempre revisáveis antes de salvar.

**Novos componentes**: `lib/application/plan_generation_job_handler.dart`,
`lib/domain/plan_template.dart`.

**Dependências**: Onda 23, Onda 18/19 (contexto do grafo).

**Critérios de aceite**: gerar um "plano de estudos" a partir de 5 documentos sobre
um tema produz um `Project` com `Epic`s e `PlanTask`s coerentes, editável antes de
confirmar.

**Estimativa**: 3 semanas (paralelizável com Onda 24).

---

### Onda 26 — Inteligência contínua

**Funcionalidades**: replanejamento automático ao detectar mudança (usa Onda 22),
repriorização sugerida, "próximos passos" gerados por regra + LLM.

**Novos componentes**: `lib/application/replan_use_case.dart`.

**Dependências**: Onda 22, Onda 25.

**Critérios de aceite**: uma `RiskDetected` sobre um projeto acompanhado gera
sugestão de repriorização, não aplicada automaticamente (aprovação humana — mesma
filosofia da Onda 27).

**Estimativa**: 3 semanas. Fecha a Fase C.

---

## Fase D — Execução e agentes (Ondas 27-31)

### Onda 27 — Executor externo com aprovação

**Objetivo**: enviar email, criar issue/PR, mandar mensagem, disparar webhook,
rodar script — com fila de aprovação humana e dry-run, não automático e cego.

**Motivação**: agentes/execução sem auditoria e aprovação são geradores de
incidente — este é o gate de segurança antes de qualquer agente autônomo.

**Funcionalidades**: nova categoria de `ArticleAction`/job com efeito colateral
externo real (hoje só existem webhook/notion/obsidian export); fila de "pendente de
aprovação" na UI; modo dry-run que mostra o que seria feito sem executar.

**Arquitetura**: reaproveita `ActionExecutor` (Onda existente) + `JobRunner` (Onda 6);
toda execução externa vira `Job` com `requiresApproval: true` por padrão,
configurável por regra.

**Novos componentes**: `lib/application/actions/send_email_action.dart`,
`create_github_issue_action.dart`, `create_pull_request_action.dart`,
`send_message_action.dart`, `run_script_action.dart`,
`lib/pages/approval_queue_page.dart`.

**Modelo de dados**: `Jobs` (Onda 6) ganha `requiresApproval`, `approvedBy`,
`approvedAt`.

**Eventos**: `ExecutionRequested`, `ExecutionApproved`, `ExecutionRejected`.

**Dependências**: Onda 6, Onda 5 (journal para auditoria de toda execução externa).

**Critérios de aceite**: uma regra que "abriria PR" fica pendente até aprovação
explícita; dry-run mostra o payload exato sem chamar a API externa.

**Riscos**: execução de script é a ação de maior superfície de risco do roadmap —
sandboxing obrigatório (processo isolado, sem acesso a filesystem fora de um diretório
whitelisted) e desabilitado por padrão, opt-in explícito.

**Estimativa**: 4 semanas.

---

### Onda 28 — Cliente MCP

**Objetivo**: qualquer MCP server vira conjunto de ações disponíveis para regras e
workflows, sem código novo por servidor.

**Funcionalidades**: FeedFlow conecta como *cliente* MCP a servidores configurados
pelo usuário; ferramentas expostas por esses servidores aparecem no
`ActionRegistry` dinamicamente.

**Novos componentes**: `lib/infrastructure/mcp/mcp_client_adapter.dart`,
`lib/application/mcp_action_bridge.dart` (adapta `tools/list` + `tools/call` do MCP
para o contrato `ArticleAction`).

**Dependências**: Onda 27 (mesma fila de aprovação se aplica a chamadas MCP com
efeito colateral).

**Critérios de aceite**: conectar a um MCP server de exemplo expõe suas tools como
ações selecionáveis num editor de regra, sem rebuild do app.

**Riscos**: confiança em servidor de terceiro — todas as chamadas passam pela mesma
aprovação da Onda 27 por padrão.

**Estimativa**: 3 semanas.

---

### Onda 29 — Runtime de agentes

**Objetivo**: loop de tool-calling com política, orçamento, limite de passos e
trilha auditável — a peça que falta para "agentes" de verdade.

**Funcionalidades**: `AgentRuntime` que roda um loop de raciocínio+tool-call sobre o
conjunto de ações disponíveis (nativas + MCP, Onda 28), com teto de passos e custo
por execução.

**Arquitetura**: cada passo do agente é um `Job` (Onda 6) — reaproveita toda a
infra de retry/idempotência/journal já construída; nenhuma peça nova de
persistência de "execução de agente" fora do que já existe.

**Novos componentes**: `lib/domain/agent_run.dart`, `lib/application/agent_runtime.dart`.

**Modelo de dados**: `AgentRuns: id(pk), goal, status, stepsUsed, maxSteps,
costUsed, budgetLimit, createdAt`. Dona do schema.

**Eventos**: `AgentStepExecuted`, `AgentRunCompleted`, `AgentBudgetExceeded`.

**Dependências**: Ondas 6, 15, 27, 28.

**Critérios de aceite**: um agente com objetivo simples ("resuma os 3 clusters mais
recentes e sugira 1 ação") completa em ≤5 passos e para sozinho ao atingir o
orçamento configurado.

**Riscos**: loop descontrolado de custo — orçamento é hard-limit no runtime, não
sugestão (corta execução, não só avisa).

**Estimativa**: 4 semanas.

---

### Onda 30 — Agentes especialistas colaborativos

**Objetivo**: papéis nomeados (pesquisador, planejador, revisor, executor, analista,
arquiteto, investidor) que podem colaborar via handoff.

**Funcionalidades**: cada especialista é uma configuração de `AgentRuntime` (Onda 29)
com prompt/ferramentas/orçamento próprios; handoff = um agente enfileira um
`AgentRun` para outro papel com contexto resumido.

**Novos componentes**: `lib/domain/agent_role.dart` (7 papéis pré-configurados),
`lib/application/agent_handoff_use_case.dart`.

**Dependências**: Onda 29.

**Critérios de aceite**: "pesquisador" encontra fontes sobre um tema e faz handoff
para "planejador", que gera um `PlanTask` (Onda 23) rastreável até o `AgentRun` de
origem.

**Estimativa**: 4 semanas.

---

### Onda 31 — Memória

**Objetivo**: memória de curto/longo prazo, preferências, contexto de projeto e
feedback contínuo — para agentes (e regras) não repetirem erro nem esquecerem
preferência já dada.

**Funcionalidades**: `MemoryEntry` (fato/preferência/feedback) com escopo
(global/projeto/agente); agentes consultam memória relevante antes de agir; usuário
pode corrigir/apagar uma memória (mesmo princípio de auditabilidade das ondas
anteriores).

**Novos componentes**: `lib/domain/memory_entry.dart`,
`lib/infrastructure/repositories/memory_repository_drift.dart` (busca por embedding,
reaproveitando Onda 16), `lib/pages/memory_page.dart`.

**Modelo de dados**: `MemoryEntries: id(pk), scope, type, content, vector(blob),
createdAt, lastUsedAt`. Dona do schema.

**Dependências**: Ondas 16, 29.

**Critérios de aceite**: corrigir um agente uma vez ("não sugira X") impede a
recorrência em execuções futuras do mesmo papel.

**Estimativa**: 3 semanas. Fecha a Fase D.

---

## Fase E — Plataforma e negócio (Ondas 32-34)

### Onda 32 — Plugin SDK + sandbox

**Objetivo**: contrato formal de extensão (conector/ação/enricher), validado usando
as próprias features internas como primeiro consumidor.

**Funcionalidades**: manifesto de plugin (JSON: nome, versão, permissões,
capacidades); as ações/conectores já existentes migram para implementar o mesmo
contrato de plugin — sem duplicar lógica.

**Novos componentes**: `lib/domain/plugin_manifest.dart`,
`lib/application/plugin_loader.dart`.

**Dependências**: efetivamente todas as ondas anteriores (é o contrato que as
generaliza) — mas tecnicamente só precisa de `ActionRegistry`/`SourceConnectorRegistry`
já existentes.

**Critérios de aceite**: uma das 13 ações internas roda através do `PluginLoader`
sem mudança de comportamento observável.

**Estimativa**: 4 semanas.

---

### Onda 33 — API pública + CLI + MCP Server

**Objetivo**: o FeedFlow acessível de fora — o "SO para informação" exposto.

**Funcionalidades**: FeedFlow expõe **um servidor MCP próprio** (não só cliente,
Onda 28) com suas ações/queries; API REST equivalente; CLI fina sobre a mesma API.

**Novos componentes**: `hub/mcp_server.js` (ou processo Dart separado),
`hub/public_api.js`, `cli/feedflow-cli`.

**Dependências**: Onda 32 (contrato de plugin vira o contrato público também), Onda 11
(Hub como host da API).

**Critérios de aceite**: um cliente MCP externo (ex.: outro assistente) consegue
listar e disparar uma regra do FeedFlow via protocolo MCP.

**Estimativa**: 4 semanas.

---

### Onda 34 — Marketplace + billing

**Objetivo**: monetização plena — entitlements free/premium, checkout, distribuição
de plugins de terceiros.

**Funcionalidades**: billing (assinatura mensal/anual); marketplace de plugins
(incluindo conectores de terceiros para casos de nicho — ex.: WhatsApp via provedor
pago, fora do escopo nativo por decisão da Onda 14); telemetria de produto agregada
(sem dado sensível de conteúdo).

**Novos componentes**: `hub/billing_service.js` (Stripe ou equivalente),
`hub/marketplace_registry.js`, `lib/pages/marketplace_page.dart`,
`lib/pages/billing_page.dart`.

**Dependências**: Onda 32 (SDK como base do marketplace), Onda 12 (sync já provou o
modelo de cobrança).

**Critérios de aceite**: usuário assina, ganha acesso a features Premium
(Ondas 12-31) sem restart do app; plugin de terceiro instala e aparece no
`ActionRegistry` como qualquer ação nativa.

**Riscos**: superfície de segurança de plugins de terceiro executando código —
sandbox obrigatório (mesma disciplina da Onda 27 para scripts), revisão manual antes
de listar no marketplace v1.

**Estimativa**: 5 semanas. Fecha o roadmap.

---

## Roadmap visual

```
Fase A (fundações/ingestão)     5→6→7→8→9,10
                                      └→11→12,13,14
Fase B (inteligência)           6,7→15→16→17→18→19→22
                                         └→20,21 (paralelo)
Fase C (planejamento)           18,19,21→23→24,25(paralelo)→26
Fase D (execução/agentes)       6,15,27→28→29→30→31
Fase E (plataforma/negócio)     7,15,27→32→33→34
```

## Grafo de dependências (texto)

```
5 ──┬─> 6 ──┬─> 7 ──┬─> 8 ──> 9,10
    │       │       └─> 11 ──> 12,13,14
    │       └─> 15 ──┬─> 16 ──> 17 ──> 18 ──> 19 ──> 22
    │                └─> 20, 21
    └─> 27 (journal p/ auditoria)
18,19,21 ──> 23 ──> 24 ──> 25 ──> 26
27 ──> 28 ──> 29 ──> 30 ──> 31
7,15,27 ──> 32 ──> 33 ──> 34
```
Paralelizáveis com folga: 9‖10, 13‖14, 20‖21, 24‖25.

## MVP / Premium / Enterprise

- **MVP (Free)**: Ondas 5-10 + 15 parcial (enriquecimento com chave própria do
  usuário — sem custo marginal para o produto).
- **Premium** (assinatura individual): 11-14 (Hub, sync, conectores SaaS), 16-19
  (busca semântica, clustering, grafo), 20 (briefings), 25-26 (planejamento IA),
  29-31 (agentes, com cota de tokens inclusa).
- **Enterprise** (deliberadamente **fora** deste roadmap): multi-tenant, RBAC, SSO,
  retenção/compliance — documentado como pivô possível, não planejado.

## Estratégia de monetização por etapa

Nenhuma cobrança até a Onda 12 (sync) — antes disso o produto não tem custo
recorrente que justifique preço, e cobrar cedo prejudicaria adoção. A partir da
Onda 12, cada onda de Fase B/C/D soma valor ao plano Premium sem exigir nova decisão
de pricing (mesma assinatura, mais capacidade).

## Riscos estratégicos e pivôs possíveis

- Se `sqlite-vec` (Onda 16) não for viável em alguma plataforma-chave: pivô para
  busca vetorial só no desktop/servidor, mobile fica só com FTS5 até um provedor de
  embedding hospedado (Hub) resolver.
- Se o Hub (Onda 11) tiver custo operacional maior que o previsto: pivô para
  "self-hosted only", cobrando só por conectores SaaS específicos, não pela infra em
  si.
- Se agentes autônomos (Onda 29-30) gerarem incidentes de confiança: reforçar a
  aprovação humana (Onda 27) como padrão inegociável, não afrouxar.

## Funcionalidades que podem ser adiadas indefinidamente

- WhatsApp nativo (inviável sem API paga verificada).
- Enterprise (RBAC/SSO/multi-tenant).
- Visualização de grafo avançada (força-dirigida com milhares de nós) — CTE +
  lista basta para uso individual.
- Merge automático de conflitos de sync (CRDT completo) — LWW é suficiente por
  vários anos de uso individual.

## Visão arquitetural para os próximos 5 anos

O núcleo permanece **local-first com backend opcional**: o dispositivo do usuário
nunca perde a capacidade de operar sozinho, e o Hub cresce apenas como acelerador
(webhooks, sync, workers pesados, distribuição de plugins). O contrato de plugin
(Onda 32) se torna o único ponto de extensão — inclusive features "nativas" futuras
devem nascer como plugins internos, evitando que o núcleo infle. O `JobRunner`/DAG
(Onda 6) é a espinha dorsal de todo trabalho assíncrono, inclusive agentes; nenhuma
feature de IA nova deveria precisar de uma peça de infraestrutura nova além dele.
