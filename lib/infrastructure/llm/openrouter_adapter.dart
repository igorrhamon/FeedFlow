import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/llm_provider_id.dart';
import '../../domain/work_item.dart';
import 'llm_prompts.dart';

/// Adapter de OpenRouter (API compatível com o formato de chat completions
/// da OpenAI) para enriquecimento de artigos.
///
/// Chave de API lida via `flutter_secure_storage`
/// (`LlmProviderId.openRouter.credentialKey`).
///
/// Padrão de uso em testes: injetar um `http.Client` customizado
/// (via `MockClient`) para evitar chamadas de rede reais.
class OpenRouterAdapter implements Enricher {
  OpenRouterAdapter({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  static const String _apiBaseUrl = 'https://openrouter.ai/api/v1';
  static final String _credentialKey = LlmProviderId.openRouter.credentialKey;
  static const String _model = 'openai/gpt-4o-mini';

  @override
  String get id => LlmProviderId.openRouter.id;

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
        return _run(item, type: EnrichmentType.summary, prompt: summaryPrompt);
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
          prompt: (content) => translationPrompt(content, targetLanguage),
        );
      case EnrichmentType.classification:
        return _run(
          item,
          type: EnrichmentType.classification,
          prompt: classificationPrompt,
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
          'OpenRouter API key not configured. Set it via secure storage.');
    }

    final content = resolveEnrichmentContent(
      content: item.content,
      summary: item.summary,
      title: item.title,
    );
    if (content.isEmpty) {
      throw Exception('Article has no content to enrich');
    }

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': prompt(content),
        }
      ],
    };

    try {
      final response = await _httpClient.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'API error (${response.statusCode}): ${errorBody['error']?['message'] ?? response.body}');
      }

      final responseData = jsonDecode(response.body);
      final choices = responseData['choices'] as List<dynamic>?;
      String? resultText;
      if (choices != null && choices.isNotEmpty) {
        final message = choices.first['message'] as Map<String, dynamic>?;
        resultText = message?['content'] as String?;
      }

      if (resultText == null || resultText.isEmpty) {
        throw Exception('Empty response from OpenRouter API');
      }

      final usage = responseData['usage'] as Map<String, dynamic>?;
      final tokensUsed = usage == null ? null : usage['total_tokens'] as int?;

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
