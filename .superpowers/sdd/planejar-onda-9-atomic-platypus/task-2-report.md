# Task 2 — SourceConnectors de arquivos locais — Report

## Commits

- `733d25a` — `feat(onda9): implementa 4 SourceConnectors de ingestão de arquivos locais`
  - `lib/infrastructure/connectors/folder_source_connector.dart`
  - `lib/infrastructure/connectors/markdown_vault_connector.dart`
  - `lib/infrastructure/connectors/pdf_source_connector.dart`
  - `lib/infrastructure/connectors/office_source_connector.dart`
  - `test/infrastructure/connectors/folder_source_connector_test.dart`
  - `test/infrastructure/connectors/markdown_vault_connector_test.dart`
  - `test/infrastructure/connectors/pdf_source_connector_test.dart`
  - `test/infrastructure/connectors/office_source_connector_test.dart`

## O que foi implementado

Quatro `SourceConnector`s em `lib/infrastructure/connectors/`, todos implementando
`lib/domain/source_connector.dart` e produzindo `lib/domain/document.dart`:

1. **`FolderSourceConnector`** (`id = 'folder:<config.id>'`) — varre `config.path`
   recursivamente até 3 níveis de profundidade, ignora arquivos/pastas ocultos
   (prefixo `.` ou `_`), suporta `.txt`, `.md`, `.pdf`, `.docx`, `.xlsx`, delegando
   a extração de conteúdo para as funções livres dos outros três conectores.
   Processa arquivos em lotes de 50 para não carregar tudo em memória de uma vez.
   Filtra por `since` via `File.lastModified()`.

2. **`MarkdownVaultConnector`** (`id = 'markdown-vault:<config.id>'`) — varre um
   vault Obsidian, lê apenas `.md`, ignora `.obsidian/` e qualquer segmento oculto.
   Expõe a função livre `readMarkdownFile(File)` (hoje retorna o conteúdo bruto,
   incluindo frontmatter YAML se houver — parsing de frontmatter fica para
   iteração futura, não bloqueia a Task 2).

3. **`PdfSourceConnector`** (`id = 'pdf:<config.id>'`) — dois modos conforme
   `config.type`: `pdf` (arquivo único) ou `folder` (varredura recursiva por
   `*.pdf`). Usa `syncfusion_flutter_pdf` (`PdfTextExtractor`) via a função livre
   `extractPdfText(File)`, com normalização de espaços em branco.

4. **`OfficeSourceConnector`** (`id = 'office:<config.id>'`) — varre recursivamente
   por `.docx`/`.xlsx`. `extractDocxText` descompacta o pacote OOXML com
   `archive` e concatena elementos `<w:t>` por parágrafo (`<w:p>`).
   `extractXlsxText` resolve `xl/sharedStrings.xml` + todas as `xl/worksheets/sheet*.xml`,
   produzindo uma tabela em formato Markdown (`| célula | célula |`).

Convenções seguidas (por instrução da task):
- `Document.id = '<connectorId>:<sourceId>'`, `sourceId` = path relativo a `config.path`
  (dedupe natural em reingestão).
- `sourceConnectorId` fixo por tipo + `config.id` (ex.: `pdf:config-uuid`).
- Erros de parse por arquivo (PDF corrompido, zip inválido, etc.) são capturados
  e o arquivo é pulado — não interrompe o lote.
- `close()` é no-op nos 4 conectores (não há recurso persistente a fechar).

## Testes

```
flutter test test/infrastructure/connectors/ --reporter expanded
```

**13 de 13 testes passaram** (0 falhas):

- `folder_source_connector_test.dart` — 3 testes (extração multi-tipo + hidden files
  + subpastas, filtro por `since`, pasta inexistente)
- `markdown_vault_connector_test.dart` — 2 testes (leitura `.md` ignorando
  `.obsidian/`, `readMarkdownFile` isolado)
- `pdf_source_connector_test.dart` — 4 testes (extração de texto de PDF real
  gerado via Syncfusion em runtime, modo arquivo único, modo pasta, path
  inexistente)
- `office_source_connector_test.dart` — 5 testes (`extractDocxText`,
  `extractXlsxText`, `pull()` de pasta com docx+xlsx, pasta inexistente)

PDFs e .docx/.xlsx de teste são gerados em runtime (Syncfusion `PdfDocument`
para PDF; `archive.ZipEncoder` com XML OOXML mínimo para docx/xlsx) — não há
fixtures binárias versionadas.

## `flutter analyze`

```
flutter analyze
```

**Sem erros nem warnings** — nem nos arquivos novos, nem no restante do projeto
(rodado no worktree completo).

## Concerns

- **Performance de extração de PDF grande**: `syncfusion_flutter_pdf` extrai
  texto página a página; PDFs muito grandes (centenas de páginas) podem ser
  lentos. Não medido nesta task — fica para Task 6 (testes de performance).
- **Frontmatter YAML não é parseado**: `readMarkdownFile` retorna o arquivo
  Markdown como está, incluindo blocos `---\n...\n---`. Se a Task 3/enriquecimento
  precisar de frontmatter estruturado separadamente do corpo, será um follow-up.
- **`.docx`/`.xlsx` corrompidos ou fora do padrão OOXML** (ex.: gerados por
  ferramentas não-Microsoft com estrutura de zip diferente) podem não ter
  `word/document.xml` ou `xl/sharedStrings.xml` nos paths esperados — o código
  trata ausência retornando string vazia / pulando o arquivo, mas não há teste
  específico para "arquivo docx sem shared strings" (xlsx sem apenas números,
  por exemplo, já funciona pois sharedStrings é opcional no código).
- **`_isSupported`/limite de profundidade em `FolderSourceConnector` são
  hardcoded** (3 níveis, extensões fixas) — se a Task 3 (UI) precisar tornar
  isso configurável por `LocalSourceConfig`, será necessário estender o modelo
  (fora do escopo desta task).

## Próximos passos (fora do escopo desta task)

- Task 3 (UI) e Task 5 (registry + job handler) consomem estes 4 conectores.
- Nenhuma mudança foi feita em `LocalSourceConfig`, tabela drift ou repositório
  (Task 1, já completa) — apenas leitura de `config.id`/`config.type`/`config.path`.
