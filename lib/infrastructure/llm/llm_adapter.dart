import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/enricher.dart';
import '../../domain/enrichment.dart';
import '../../domain/work_item.dart';

/// Configuração de credenciais LLM armazenada em secure storage.
/// Exposta para testes.
@visibleForTesting
class LlmCredentials {
  final String baseUrl;
  final String apiKey;

  LlmCredentials({required this.baseUrl, required this.apiKey});
}

// Para compatibilidade interna
typedef _LlmCredentials = LlmCredentials;

/// Adapter HTTP genérico para chamar APIs LLM configuráveis.
///
/// Usa `flutter_secure_storage` para persistir credenciais (base URL + API key)
/// e `package:http` para fazer as chamadas. Suporta qualquer provider LLM com
/// um endpoint `/complete` ou equivalente que aceita (prompt, model, temperature, etc.).
///
/// A implementação é agnóstica de provider — endpoint e API key são configuráveis.
class LlmAdapter implements Enricher {
  static const _storage = FlutterSecureStorage();
  static const _baseUrlKey = 'llm_base_url';
  static const _apiKeyKey = 'llm_api_key';

  final http.Client _client;
  _LlmCredentials? _credentials;

  /// Para testes: permite injetar credenciais diretamente sem passar por secure storage.
  @visibleForTesting
  LlmAdapter.withCredentials(
    this._credentials, {
    http.Client? client,
  }) : _client = client ?? http.Client();

  LlmAdapter({http.Client? client}) : _client = client ?? http.Client();

  /// Carrega credenciais do secure storage.
  Future<_LlmCredentials?> _loadCredentials() async {
    _credentials ??= await _getStoredCredentials();
    return _credentials;
  }

  Future<_LlmCredentials?> _getStoredCredentials() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final apiKey = await _storage.read(key: _apiKeyKey);

    if (baseUrl == null || apiKey == null) return null;

    return _LlmCredentials(baseUrl: baseUrl, apiKey: apiKey);
  }

  /// Configura as credenciais LLM (base URL e API key).
  /// Persiste em secure storage.
  Future<void> setCredentials(String baseUrl, String apiKey) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _apiKeyKey, value: apiKey);
    _credentials = _LlmCredentials(baseUrl: baseUrl, apiKey: apiKey);
  }

  /// Limpa as credenciais configuradas.
  Future<void> clearCredentials() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
    _credentials = null;
  }

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentType type) async {
    final credentials = await _loadCredentials();
    if (credentials == null) {
      throw StateError('LLM credentials not configured');
    }

    final prompt = _buildPrompt(item, type);
    final model = 'gpt-4'; // Modelo padrão (configurável em fases futuras)

    try {
      final response = await _client.post(
        Uri.parse('${credentials.baseUrl}/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${credentials.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt(type)},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode != 200) {
        throw HttpException(
          'LLM API returned ${response.statusCode}: ${response.body}',
          uri: Uri.parse(credentials.baseUrl),
        );
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = responseBody['choices'] as List<dynamic>? ?? [];
      final firstChoice = choices.isNotEmpty
          ? choices.first as Map<String, dynamic>?
          : null;
      final message = firstChoice?['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String? ?? '';

      return Enrichment(
        id: 0, // PK auto-increment — será atribuído pelo BD
        workItemId: item.id,
        type: type,
        content: content,
        model: model,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  String _buildPrompt(WorkItem item, EnrichmentType type) {
    final text = '${item.title}\n\n${item.content ?? item.summary ?? ''}';

    switch (type) {
      case EnrichmentType.summary:
        return 'Resuma o seguinte artigo em 2-3 frases:\n\n$text';
      case EnrichmentType.translation:
        return 'Traduza o seguinte para português (se não estiver já):\n\n$text';
      case EnrichmentType.classification:
        return 'Classifique o seguinte artigo em categorias (ex: Tech, Saúde, Política, etc.):\n\n$text';
      case EnrichmentType.entities:
        return 'Extraia as entidades mencionadas (pessoas, lugares, organizações):\n\n$text';
      case EnrichmentType.suggestion:
        return 'Sugira uma ação baseada neste artigo:\n\n$text';
    }
  }

  String _getSystemPrompt(EnrichmentType type) {
    switch (type) {
      case EnrichmentType.summary:
        return 'Você é um assistente que resume artigos de forma concisa e útil.';
      case EnrichmentType.translation:
        return 'Você é um tradutor profissional de português e inglês.';
      case EnrichmentType.classification:
        return 'Você é um classificador de conteúdo. Sempre retorne categorias em formato JSON.';
      case EnrichmentType.entities:
        return 'Você é um extrator de entidades nomeadas. Retorne como JSON com arrays.';
      case EnrichmentType.suggestion:
        return 'Você é um assistente que sugere ações baseado em contexto.';
    }
  }
}

/// Exceção para erros HTTP de API LLM.
class HttpException implements Exception {
  final String message;
  final Uri? uri;

  HttpException(this.message, {this.uri});

  @override
  String toString() => 'HttpException: $message (uri: $uri)';
}
