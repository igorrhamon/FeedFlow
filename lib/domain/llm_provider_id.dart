/// Identifica um provedor de LLM suportado para enriquecimento (WS-13) e
/// centraliza os valores usados tanto pelos adapters (`Enricher.id`,
/// `flutter_secure_storage` key) quanto pela UI de configuração
/// (`lib/pages/llm_settings_page.dart`) e pelo roteador
/// (`lib/infrastructure/llm/llm_enricher_router.dart`) — única fonte de
/// verdade para evitar strings soltas duplicadas entre esses lugares.
enum LlmProviderId {
  anthropic(
    id: 'llm-anthropic',
    displayName: 'Anthropic Claude',
    credentialKey: 'llm_anthropic_api_key',
    modelKey: 'llm_anthropic_model',
    defaultModel: 'claude-3-5-sonnet-20241022',
  ),
  openRouter(
    id: 'llm-openrouter',
    displayName: 'OpenRouter',
    credentialKey: 'llm_openrouter_api_key',
    modelKey: 'llm_openrouter_model',
    // Modelo gratuito por padrão — não requer créditos na conta OpenRouter.
    // Usuários com conta paga podem trocar via o campo "Modelo (opcional)".
    defaultModel: 'tencent/hy3:free',
  ),
  googleAiStudio(
    id: 'llm-google-ai-studio',
    displayName: 'Google AI Studio (Gemini)',
    credentialKey: 'llm_google_ai_studio_api_key',
    modelKey: 'llm_google_ai_studio_model',
    defaultModel: 'gemini-2.0-flash',
  );

  const LlmProviderId({
    required this.id,
    required this.displayName,
    required this.credentialKey,
    required this.modelKey,
    required this.defaultModel,
  });

  /// Mesmo valor retornado por `Enricher.id` na implementação correspondente.
  final String id;

  /// Nome legível para exibição na UI de configuração.
  final String displayName;

  /// Chave usada em `flutter_secure_storage` para a API key deste provedor.
  final String credentialKey;

  /// Chave usada em `flutter_secure_storage` para o nome do modelo
  /// customizado deste provedor (`lib/pages/llm_settings_page.dart`).
  /// Se ausente/vazio, o adapter usa [defaultModel].
  final String modelKey;

  /// Modelo usado quando o usuário não configurou um customizado.
  final String defaultModel;

  static LlmProviderId fromId(String id) =>
      values.firstWhere((v) => v.id == id, orElse: () => anthropic);
}
