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
  ),
  openRouter(
    id: 'llm-openrouter',
    displayName: 'OpenRouter',
    credentialKey: 'llm_openrouter_api_key',
  ),
  googleAiStudio(
    id: 'llm-google-ai-studio',
    displayName: 'Google AI Studio (Gemini)',
    credentialKey: 'llm_google_ai_studio_api_key',
  );

  const LlmProviderId({
    required this.id,
    required this.displayName,
    required this.credentialKey,
  });

  /// Mesmo valor retornado por `Enricher.id` na implementação correspondente.
  final String id;

  /// Nome legível para exibição na UI de configuração.
  final String displayName;

  /// Chave usada em `flutter_secure_storage` para a API key deste provedor.
  final String credentialKey;

  static LlmProviderId fromId(String id) =>
      values.firstWhere((v) => v.id == id, orElse: () => anthropic);
}
