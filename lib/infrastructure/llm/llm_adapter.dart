import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/work_item.dart';

/// Adapter de Anthropic Claude (via Messages API) para enriquecimento de
/// artigos. Suporta resumo automático sob demanda.
///
/// Chave de API lida via `flutter_secure_storage` — armazenada e gerenciada
/// como as demais credenciais de auth do FeedFlow
/// (ver `lib/services/provider_settings.dart`).
///
/// Padrão de uso em testes: injetar um `http.Client` customizado
/// (via `MockClient`) para evitar chamadas de rede reais.
class LlmAdapter implements Enricher {
  LlmAdapter({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  static const String _apiBaseUrl = 'https://api.anthropic.com/v1';
  static const String _apiVersion = '2024-06-01';
  static const String _credentialKey = 'llm_anthropic_api_key';

  @override
  String get id => 'llm-anthropic';

  @override
  Set<EnrichmentType> get capabilities => {EnrichmentType.summary};

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req) async {
    if (!capabilities.contains(req.type)) {
      throw StateError('Capability ${req.type.name} not supported by $id');
    }

    switch (req.type) {
      case EnrichmentType.summary:
        return _summarize(item);
      default:
        throw StateError('Unimplemented capability: ${req.type.name}');
    }
  }

  Future<Enrichment> _summarize(WorkItem item) async {
    final apiKey = await _storage.read(key: _credentialKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'Anthropic API key not configured. Set it via secure storage.');
    }

    final content = item.content ?? item.summary ?? item.title;
    if (content.isEmpty) {
      throw Exception('Article has no content to summarize');
    }

    final prompt = '''Por favor, resuma o seguinte texto em 2-3 frases concisas e bem estruturadas.
Mantenha os pontos-chave e não adicione informações que não estejam no texto original.

Texto:
$content

Resumo:''';

    final requestBody = {
      'model': 'claude-3-5-sonnet-20241022',
      'max_tokens': 300,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    };

    try {
      final response = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'API error (${response.statusCode}): ${errorBody['error']?['message'] ?? response.body}');
      }

      final responseData = jsonDecode(response.body);
      final contentList = responseData['content'] as List<dynamic>?;
      final summaryText = (contentList != null && contentList.isNotEmpty)
          ? contentList.first['text'] as String?
          : null;

      if (summaryText == null || summaryText.isEmpty) {
        throw Exception('Empty response from Anthropic API');
      }

      return Enrichment(
        workItemId: item.id,
        type: EnrichmentType.summary,
        content: summaryText.trim(),
        model: 'claude-3-5-sonnet-20241022',
        createdAt: DateTime.now(),
      );
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
