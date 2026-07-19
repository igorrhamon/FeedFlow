import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/llm_provider_id.dart';

/// Persistência do provedor de LLM ativo (namespace próprio, separado de
/// `ProviderSettings` — que é moldado para os `FeedProvider`s remotos, não
/// para provedores de IA).
class LlmSettings {
  static const _storage = FlutterSecureStorage();
  static const _activeProviderKey = 'active_llm_provider';

  static Future<void> setActiveProvider(LlmProviderId provider) async {
    await _storage.write(key: _activeProviderKey, value: provider.id);
  }

  /// Retorna o provedor ativo, ou [LlmProviderId.anthropic] se nunca
  /// configurado.
  static Future<LlmProviderId> getActiveProvider() async {
    final stored = await _storage.read(key: _activeProviderKey);
    if (stored == null) return LlmProviderId.anthropic;
    return LlmProviderId.fromId(stored);
  }
}
