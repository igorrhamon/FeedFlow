import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/llm_provider_id.dart';
import '../../domain/work_item.dart';
import 'llm_prompts.dart';

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
  static final String _credentialKey = LlmProviderId.anthropic.credentialKey;
  static final String _modelKey = LlmProviderId.anthropic.modelKey;
  static final String _defaultModel = LlmProviderId.anthropic.defaultModel;

  @override
  String get id => LlmProviderId.anthropic.id;

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
          prompt: summaryPrompt,
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
          'Anthropic API key not configured. Set it via secure storage.');
    }

    final model = await _storage.read(key: _modelKey);
    final effectiveModel = (model == null || model.isEmpty) ? _defaultModel : model;

    final content = resolveEnrichmentContent(
      content: item.content,
      summary: item.summary,
      title: item.title,
    );
    if (content.isEmpty) {
      throw Exception('Article has no content to enrich');
    }

    final requestBody = {
      'model': effectiveModel,
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
        model: effectiveModel,
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
