import 'dart:convert';

import 'package:feedflow/domain/enricher.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/llm/llm_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Testes do [LlmAdapter] seguindo o padrao manual-fake do projeto (sem
/// mockito/mocktail): `http.testing.MockClient` para o HTTP client e o
/// `MethodChannel` do `flutter_secure_storage` mockado via
/// `TestDefaultBinaryMessengerBinding`, igual ao usado em
/// `test/services/background_sync_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageValues = <String, String>{};

  const testWorkItemId = 'theoldreader:abc123';
  const apiKeyStorageKey = 'llm_anthropic_api_key';

  final testWorkItem = WorkItem(
    id: testWorkItemId,
    providerId: 'theoldreader',
    articleId: 'abc123',
    feedId: 'feed1',
    title: 'Test Article',
    summary: 'A test summary',
    content: 'This is a test article content that should be summarized.',
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    secureStorageValues.clear();
    secureStorageValues[apiKeyStorageKey] = 'test-api-key-123';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final args = (call.arguments as Map).cast<String, dynamic>();
      switch (call.method) {
        case 'read':
          return secureStorageValues[args['key']];
        case 'write':
          secureStorageValues[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          secureStorageValues.remove(args['key']);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('LlmAdapter', () {
    test('id returns the expected identifier', () {
      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      expect(adapter.id, 'llm-anthropic');
    });

    test('capabilities returns summary, translation and classification', () {
      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      expect(
        adapter.capabilities,
        containsAll([
          EnrichmentType.summary,
          EnrichmentType.translation,
          EnrichmentType.classification,
        ]),
      );
      expect(adapter.capabilities, hasLength(3));
    });

    test(
        'enrich with summary capability calls Anthropic API and returns Enrichment',
        () async {
      final mockResponse = {
        'content': [
          {'text': 'This article discusses test topics and their importance.'}
        ],
      };

      http.Request? capturedRequest;
      String? capturedBody;
      final client = MockClient((request) async {
        capturedRequest = request;
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );

      final request = EnrichmentRequest(type: EnrichmentType.summary);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.summary);
      expect(result.content,
          'This article discusses test topics and their importance.');
      expect(result.model, 'claude-3-5-sonnet-20241022');
      expect(result.workItemId, testWorkItemId);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.toString(),
          'https://api.anthropic.com/v1/messages');
      expect(capturedRequest!.headers['x-api-key'], 'test-api-key-123');
      expect(capturedRequest!.headers['anthropic-version'], '2024-06-01');
      expect(capturedRequest!.headers['Content-Type'], 'application/json');

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(decodedBody['model'], 'claude-3-5-sonnet-20241022');
      expect(decodedBody['max_tokens'], 300);
      expect((decodedBody['messages'] as List)[0]['content'],
          contains(testWorkItem.content));
    });

    test('enrich with unsupported capability throws StateError', () async {
      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.entities);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<StateError>()),
      );
    });

    test('enrich with translation requires targetLanguage', () async {
      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.translation);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'enrich with translation calls Anthropic API and returns Enrichment with language and tokensUsed',
        () async {
      final mockResponse = {
        'content': [
          {'text': 'Este artigo discute tópicos de teste.'}
        ],
        'usage': {'input_tokens': 40, 'output_tokens': 12},
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(
        type: EnrichmentType.translation,
        targetLanguage: 'pt',
      );
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.translation);
      expect(result.content, 'Este artigo discute tópicos de teste.');
      expect(result.language, 'pt');
      expect(result.tokensUsed, 52);

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect((decodedBody['messages'] as List)[0]['content'], contains('pt'));
    });

    test(
        'enrich with classification calls Anthropic API and returns Enrichment',
        () async {
      final mockResponse = {
        'content': [
          {'text': 'tecnologia, testes'}
        ],
      };

      final client = MockClient(
          (request) async => http.Response(jsonEncode(mockResponse), 200));

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.classification);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.classification);
      expect(result.content, 'tecnologia, testes');
      expect(result.language, isNull);
    });

    test(
        'enrich falls back to summary when content is an empty string (not null)',
        () async {
      // Feedbin/Miniflux/NewsBlur/TT-RSS/TheOldReader preenchem `content` com
      // '' (não null) quando o artigo não tem esse campo — regressão da
      // Exception "Article has no content to enrich" mesmo com summary presente.
      final workItemWithEmptyContent =
          testWorkItem.copyWith(content: '', summary: 'A real summary.');

      final mockResponse = {
        'content': [
          {'text': 'Summary from real summary field.'}
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);
      await adapter.enrich(workItemWithEmptyContent, request);

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect((decodedBody['messages'] as List)[0]['content'],
          contains('A real summary.'));
    });

    test('enrich throws exception when API key is not configured', () async {
      secureStorageValues.remove(apiKeyStorageKey);

      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message',
                contains('API key not configured'))),
      );
    });

    test('enrich throws exception when article has no content', () async {
      final emptyWorkItem = testWorkItem.copyWith(
        content: null,
        summary: null,
        title: '',
      );

      final adapter = LlmAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);

      expect(
        () => adapter.enrich(emptyWorkItem, request),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('no content'))),
      );
    });

    test('enrich handles API error response correctly', () async {
      final errorResponse = {
        'error': {'message': 'Invalid API key'}
      };

      final client = MockClient((request) async =>
          http.Response(jsonEncode(errorResponse), 401));

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('API error'))),
      );
    });

    test('enrich falls back to summary field when content is null',
        () async {
      final workItemWithoutContent = testWorkItem.copyWith(content: null);

      final mockResponse = {
        'content': [
          {'text': 'Summary from fallback.'}
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);
      await adapter.enrich(workItemWithoutContent, request);

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect((decodedBody['messages'] as List)[0]['content'],
          contains(workItemWithoutContent.summary!));
    });

    test('enrich handles empty API response gracefully', () async {
      final client = MockClient(
          (request) async => http.Response(jsonEncode({'content': []}), 200));

      final adapter = LlmAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<Exception>()),
      );
    });
  });
}