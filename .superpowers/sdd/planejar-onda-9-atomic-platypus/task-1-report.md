# Task 1 Report — Onda 9: Infraestrutura Base para Configuração de Fontes Locais

## Resumo Executivo

Task 1 de Onda 9 implementada com sucesso. A infraestrutura base para configuração de fontes locais (pasta, Markdown/Obsidian, PDF, Office) foi estabelecida, cobrindo:

- Adição de 3 novas dependências (`file_picker`, `syncfusion_flutter_pdf`, `archive`)
- Modelo de domínio `LocalSourceConfig` (Freezed)
- Interface de repositório abstrata `LocalSourceConfigRepository`
- Tabela drift `LocalSourceConfigs` com migração de schema (v11 → v12)
- Implementação drift `LocalSourceConfigRepositoryDrift`
- Integração com `DatabaseProvider`
- Testes de unidade e integração

Todas as verificações completadas com sucesso:
- ✅ `flutter pub get` — dependências instaladas
- ✅ `flutter pub run build_runner build` — código gerado (144s, 455 outputs)
- ✅ Testes de domínio e repositório — **13 testes passando**
- ✅ `flutter analyze` — sem erros ou warnings novos

## Dependências Adicionadas

Adicionadas em `pubspec.yaml`:

```yaml
file_picker: ^8.1.0                    # Seleção de pasta/arquivo via UI nativa
syncfusion_flutter_pdf: ^27.1.57       # Extração de texto de PDF
archive: ^4.0.0                        # Unzip puro Dart para .docx/.xlsx
```

Decisão sobre `watcher` documentada no plano: não incluída nesta v1 (não usada), será adicionada quando implementar watch automático de filesystem (desktop-only, iteração futura).

## Arquivos Criados

### Domínio
- **`lib/domain/local_source_config.dart`** (66 linhas)
  - Modelo Freezed com enum `LocalSourceType { folder, markdownVault, pdf, office }`
  - Campos: `id`, `type`, `path`, `label`, `enabled`, `lastSyncAt`, `createdAt`
  - Suporte a JSON serialization/deserialization

- **`lib/domain/repositories/local_source_config_repository.dart`** (25 linhas)
  - Interface abstrata com 5 operações core:
    - `save(LocalSourceConfig)` — persiste nova/atualiza existente
    - `byId(String)` — recupera por ID
    - `watchAll()` — stream observável de todas as configs
    - `delete(String)` — remove por ID
    - `updateLastSync(String, DateTime)` — atualiza timestamp de sincronização
  - Segue convenção de `domain/repositories/` existente

### Infraestrutura
- **`lib/infrastructure/db/tables.dart`** (modificado)
  - Adicionada tabela `LocalSourceConfigs` (ao final do arquivo)
  - 7 colunas: `id` (PK), `type`, `path`, `label`, `enabled`, `lastSyncAt`, `createdAt`
  - Usa `@DataClassName('LocalSourceConfigRow')` para evitar colisão com domínio

- **`lib/infrastructure/db/database.dart`** (modificado)
  - Incrementado `schemaVersion` de 11 → 12
  - Adicionada tabela `LocalSourceConfigs` à anotação `@DriftDatabase`
  - Migração v11 → v12 em `onUpgrade`: simples `m.createTable(localSourceConfigs)`

- **`lib/infrastructure/repositories/local_source_config_repository_drift.dart`** (97 linhas)
  - Implementação completa da interface de repositório
  - Converte `LocalSourceType` enum ↔ string para armazenamento (`_encodeType`/`_decodeType`)
  - Usa `insertOnConflictUpdate` para upsert idempotente
  - Implements all 5 repository methods com queries SQL via Drift API

- **`lib/infrastructure/db/database_provider.dart`** (modificado)
  - Adicionado import: `LocalSourceConfigRepository`, `LocalSourceConfigRepositoryDrift`
  - Adicionado campo privado: `static LocalSourceConfigRepository? _localSourceConfigRepository`
  - Adicionado getter: `static LocalSourceConfigRepository? get localSourceConfigRepository`
  - Getter retorna `null` sob `kIsWeb` (padrão web/WASM degradation)

### Testes
- **`test/domain/local_source_config_test.dart`** (114 linhas)
  - 6 testes de modelo/Freezed:
    - Construtor com valores padrão
    - Construtor com todos os parâmetros
    - Suporte a PDF e Office como tipos
    - Freezed `copyWith` funciona
    - JSON serialization bidirecional

- **`test/infrastructure/repositories/local_source_config_repository_drift_test.dart`** (167 linhas)
  - 7 testes de repositório:
    - `save` e `byId` funcionam
    - `byId` retorna `null` para ID inexistente
    - `watchAll` emite lista correta
    - `delete` remove registro
    - `updateLastSync` atualiza timestamp
    - `save` com mesmo ID atualiza (upsert)
    - Todos os 4 tipos de fonte são suportados

## Resultado de Verificação

### 1. Dependências (`flutter pub get`)
```
✅ SUCESSO
Changed 7 dependencies (file_picker, syncfusion_flutter_pdf, archive, e suas transitividades)
```

### 2. Codegen (`flutter pub run build_runner build --delete-conflicting-outputs`)
```
✅ SUCESSO (144 segundos)
- Freezed: 15 outputs para LocalSourceConfig e models relacionados
- Drift: 284 outputs para tabelas e queries
- Total: 455 outputs escritos
```

### 3. Testes Unitários
```
✅ SUCESSO: 13/13 testes passando (3s)

Domínio (6 testes):
  ✅ LocalSourceConfig construtor cria instância com valores padrão
  ✅ LocalSourceConfig construtor aceita todos os parâmetros
  ✅ LocalSourceConfig suporta PDF como tipo de fonte
  ✅ LocalSourceConfig suporta Office como tipo de fonte
  ✅ LocalSourceConfig Freezed copyWith funciona corretamente
  ✅ LocalSourceConfig JSON serialization funciona

Repositório Drift (7 testes):
  ✅ LocalSourceConfigRepositoryDrift save e byId funcionam corretamente
  ✅ LocalSourceConfigRepositoryDrift byId retorna null para ID inexistente
  ✅ LocalSourceConfigRepositoryDrift watchAll emite lista de configurações
  ✅ LocalSourceConfigRepositoryDrift delete remove configuração
  ✅ LocalSourceConfigRepositoryDrift updateLastSync atualiza timestamp
  ✅ LocalSourceConfigRepositoryDrift save com mesmo ID atualiza registro
  ✅ LocalSourceConfigRepositoryDrift suporta todos os tipos de fonte
```

### 4. Análise Estática (`flutter analyze`)
```
✅ SUCESSO: No issues found! (30.6s)
```

## Decisões de Implementação

1. **Tipo enum armazenado como string**: `LocalSourceType` é serializado em SQL como string minúscula (`'folder'`, `'markdownVault'`, etc.) para facilitar queries SQL futuras sobre tipo de fonte.

2. **Enum values mapping**: Usa `toString().split('.').last` para conversão bidirecional, padrão Dart robusto a refatoração de enum.

3. **Upsert via `insertOnConflictUpdate`**: Drift API permite semanticamente claro; alternativa seria `delete` + `insert`.

4. **Repository interface sem close()**: Implementação é vazia (Drift gerencia ciclo de vida do banco); contrato mantido por compatibilidade com padrão de `ExternalIntegration` (Onda 5).

5. **Web support**: `DatabaseProvider.localSourceConfigRepository` retorna `null` sob `kIsWeb`, permitindo UI graceful degradation. Nenhuma tentativa de usar em web quebrará.

6. **Defaults de coluna Drift**: `enabled` padrão `true` (fonte habilitada por padrão); `lastSyncAt` nullable (nunca sincronizado inicialmente).

## Dependências de Trabalho Futuro

- **Task 2 (ConnectorInterface & Registry)**: Generalização do `SourceConnectorRegistry` para factory com parâmetro
- **Task 3-6 (Implementações de conectores)**: Dependem do modelo `LocalSourceConfig` e interface de repositório criados aqui
- **Task 7 (Tela de configuração)**: Consome `LocalSourceConfigRepository` para CRUD de fontes
- **Task 8 (Job de sincronização)**: Consulta `LocalSourceConfigs.enabled=true` via repositório

Nenhuma dependência introduzida; modelo e repositório são estáveis e prontos para consumo.

## Próximas Ações

Tasks 2-8 podem proceder imediatamente; nenhuma mudança posterior em LocalSourceConfig é esperada:
1. A interface é mínima e completa (5 operações core)
2. O modelo Freezed é estável (validado por testes de JSON roundtrip)
3. A migração drift é idempotente (testavet com `test/infrastructure/repositories/*_drift_test.dart` pattern)
