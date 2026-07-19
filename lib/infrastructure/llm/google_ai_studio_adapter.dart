import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/llm_provider_id.dart';
import '../../domain/work_item.dart';
import 'llm_prompts.dart';

/// Adapter de Google AI Studio (Gemini, via `generateContent`) para
/// enriquecimento de artigos.
///
/// Chave de API lida via `flutter_secure_storage`
/// (`LlmProviderId.googleAiStudio.credentialKey`) e enviada como query
/// parameter `key` — diferente da Anthropic/OpenRouter, que usam header.
///
/// Padrão de uso em testes: injetar um `http.Client` customizado
/// (via `MockClient`) para evitar chamadas de rede reais.
class GoogleAiStudioAdapter implements Enricher {
  GoogleAiStudioAdapter({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  static const String _apiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static final String _credentialKey =
      LlmProviderId.googleAiStudio.credentialKey;
  static final String _modelKey = LlmProviderId.googleAiStudio.modelKey;
  static final String _defaultModel = LlmProviderId.googleAiStudio.defaultModel;

  @override
  String get id => LlmProviderId.googleAiStudio.id;

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
          'Google AI Studio API key not configured. Set it via secure storage.');
    }

    final model = await _storage.read(key: _modelKey);
    final effectiveModel = (model == null || model.isEmpty) ? _defaultModel : model;

    final content = resolveEnrichmentContent(
      content: item.content,
      summary: item.summary,
      title: item.title,
    );
    if (content.isEmpty) {
      developer.log(
        'no content to enrich for workItem=${item.id}',
        name: 'FeedFlow.LLM.GoogleAiStudio',
      );
      throw Exception('Article has no content to enrich');
    }

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt(content)}
          ],
        }
      ],
    };

    developer.log(
      'enrich start: type=${type.name} model=$effectiveModel workItem=${item.id}',
      name: 'FeedFlow.LLM.GoogleAiStudio',
    );

    try {
      final response = await _httpClient.post(
        Uri.parse(
            '$_apiBaseUrl/models/$effectiveModel:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log(
        'enrich response: status=${response.statusCode} workItem=${item.id}',
        name: 'FeedFlow.LLM.GoogleAiStudio',
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        developer.log(
          'enrich error body: ${response.body}',
          name: 'FeedFlow.LLM.GoogleAiStudio',
        );
        throw Exception(
            'API error (${response.statusCode}): ${errorBody['error']?['message'] ?? response.body}');
      }

      final responseData = jsonDecode(response.body);
      final candidates = responseData['candidates'] as List<dynamic>?;
      List<dynamic>? parts;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>?;
        parts = content?['parts'] as List<dynamic>?;
      }
      String? resultText;
      if (parts != null && parts.isNotEmpty) {
        resultText = parts.first['text'] as String?;
      }

      if (resultText == null || resultText.isEmpty) {
        throw Exception('Empty response from Google AI Studio API');
      }

      final usage = responseData['usageMetadata'] as Map<String, dynamic>?;
      final tokensUsed =
          usage == null ? null : usage['totalTokenCount'] as int?;

      return Enrichment(
        workItemId: item.id,
        type: type,
        content: resultText.trim(),
        model: effectiveModel,
        createdAt: DateTime.now(),
        language: language,
        tokensUsed: tokensUsed,
      );
    } on http.ClientException catch (e) {
      developer.log(
        'network error: ${e.message}',
        name: 'FeedFlow.LLM.GoogleAiStudio',
      );
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      developer.log(
        'enrich failed: $e',
        name: 'FeedFlow.LLM.GoogleAiStudio',
        error: e,
      );
      rethrow;
    }
  }
}
