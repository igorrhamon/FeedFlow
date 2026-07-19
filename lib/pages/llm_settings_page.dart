import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/llm_provider_id.dart';
import '../services/llm_settings.dart';

/// Tela de configuração do provedor de IA usado para enriquecimento
/// (resumir/traduzir/classificar, WS-13): escolhe o provedor ativo
/// ([LlmProviderId]) e sua API key, persistidos via [LlmSettings] e
/// `flutter_secure_storage`. `DatabaseProvider.enricher`
/// (`LlmEnricherRouter`) lê o provedor ativo a cada enriquecimento, então a
/// troca feita aqui tem efeito imediato, sem reiniciar o app.
class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  static const _storage = FlutterSecureStorage();

  final _apiKeyController = TextEditingController();

  LlmProviderId _selectedProvider = LlmProviderId.anthropic;
  bool _hasExistingKey = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final active = await LlmSettings.getActiveProvider();
    await _loadHasExistingKey(active);
    if (!mounted) return;
    setState(() {
      _selectedProvider = active;
      _loading = false;
    });
  }

  Future<void> _loadHasExistingKey(LlmProviderId provider) async {
    final existing = await _storage.read(key: provider.credentialKey);
    if (!mounted) return;
    setState(() => _hasExistingKey = existing != null && existing.isNotEmpty);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_apiKeyController.text.isNotEmpty) {
        await _storage.write(
          key: _selectedProvider.credentialKey,
          value: _apiKeyController.text,
        );
      }
      await LlmSettings.setActiveProvider(_selectedProvider);

      if (!mounted) return;
      setState(() {
        _hasExistingKey = _hasExistingKey || _apiKeyController.text.isNotEmpty;
        _apiKeyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração de IA salva.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IA / Enriquecimento')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<LlmProviderId>(
                    initialValue: _selectedProvider,
                    items: LlmProviderId.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _selectedProvider = value);
                      _apiKeyController.clear();
                      await _loadHasExistingKey(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Provedor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'API key',
                      border: const OutlineInputBorder(),
                      helperText: _hasExistingKey
                          ? 'Chave já configurada — deixe em branco para manter'
                          : 'Nenhuma chave configurada para este provedor',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ),
    );
  }
}
