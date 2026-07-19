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
  static const String _model = 'claude-3-5-sonnet-20241022';

  @override
  String get id => 'llm-anthropic';

  @override
  Set<EnrichmentType> get capabilities => {
        EnrichmentType.summary,
        EnrichmentType.translation,
        EnrichmentType.classification,
      };

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req) async {
    if (!capabilities.contains(req.type)) {
      throw StateError('Capability ${req.type.name} not supported by $id');
    }

    switch (req.type) {
      case EnrichmentType.summary:
        return _run(
          item,
          type: EnrichmentType.summary,
          prompt: (content) => '''Por favor, resuma o seguinte texto em 2-3 frases concisas e bem estruturadas.
Mantenha os pontos-chave e não adicione informações que não estejam no texto original.

Texto:
$content

Resumo:''',
        );
      case EnrichmentType.translation:
        final targetLanguage = req.targetLanguage;
        if (targetLanguage == null || targetLanguage.isEmpty) {
          throw ArgumentError(
              'EnrichmentRequest.targetLanguage is required for translation');
        }
        return _run(
          item,
          type: EnrichmentType.translation,
          language: targetLanguage,
          prompt: (content) => '''Traduza o seguinte texto para o idioma "$targetLanguage".
Preserve o sentido original e não adicione comentários fora da tradução.

Texto:
$content

Tradução:''',
        );
      case EnrichmentType.classification:
        return _run(
          item,
          type: EnrichmentType.classification,
          prompt: (content) => '''Classifique o texto abaixo com uma ou mais categorias curtas
(ex.: tecnologia, política, esporte, economia), separadas por vírgula.
Responda apenas com as categorias, sem explicações.

Texto:
$content

Categorias:''',
        );
      default:
        throw StateError('Unimplemented capability: ${req.type.name}');
    }
  }

  Future<Enrichment> _run(
    WorkItem item, {
    required EnrichmentType type,
    required String Function(String content) prompt,
    String? language,
  }) async {
    final apiKey = await _storage.read(key: _credentialKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'Anthropic API key not configured. Set it via secure storage.');
    }

    final content = item.content ?? item.summary ?? item.title;
    if (content.isEmpty) {
      throw Exception('Article has no content to enrich');
    }

    final requestBody = {
      'model': _model,
      'max_tokens': 300,
      'messages': [
        {
          'role': 'user',
          'content': prompt(content),
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
      final resultText = (contentList != null && contentList.isNotEmpty)
          ? contentList.first['text'] as String?
          : null;

      if (resultText == null || resultText.isEmpty) {
        throw Exception('Empty response from Anthropic API');
      }

      final usage = responseData['usage'] as Map<String, dynamic>?;
      final tokensUsed = usage == null
          ? null
          : ((usage['input_tokens'] as int? ?? 0) +
              (usage['output_tokens'] as int? ?? 0));

      return Enrichment(
        workItemId: item.id,
        type: type,
        content: resultText.trim(),
        model: _model,
        createdAt: DateTime.now(),
        language: language,
        tokensUsed: tokensUsed,
      );
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
