import 'dart:convert';

import 'package:feedflow/domain/enricher.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/llm/openrouter_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Testes do [OpenRouterAdapter], espelhando test/llm/llm_adapter_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageValues = <String, String>{};

  const testWorkItemId = 'theoldreader:abc123';
  const apiKeyStorageKey = 'llm_openrouter_api_key';

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

  group('OpenRouterAdapter', () {
    test('id returns the expected identifier', () {
      final adapter = OpenRouterAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      expect(adapter.id, 'llm-openrouter');
    });

    test('capabilities returns summary, translation and classification', () {
      final adapter = OpenRouterAdapter(
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
        'enrich with summary calls OpenRouter chat/completions and returns Enrichment',
        () async {
      final mockResponse = {
        'choices': [
          {
            'message': {'content': 'This article discusses test topics.'}
          }
        ],
        'usage': {'total_tokens': 42},
      };

      http.Request? capturedRequest;
      String? capturedBody;
      final client = MockClient((request) async {
        capturedRequest = request;
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = OpenRouterAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );

      final request = EnrichmentRequest(type: EnrichmentType.summary);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.summary);
      expect(result.content, 'This article discusses test topics.');
      expect(result.model, 'tencent/hy3:free');
      expect(result.workItemId, testWorkItemId);
      expect(result.tokensUsed, 42);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.toString(),
          'https://openrouter.ai/api/v1/chat/completions');
      expect(capturedRequest!.headers['Authorization'],
          'Bearer test-api-key-123');
      expect(capturedRequest!.headers['Content-Type'], 'application/json');

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(decodedBody['model'], 'tencent/hy3:free');
      expect((decodedBody['messages'] as List)[0]['content'],
          contains(testWorkItem.content));
    });

    test('enrich uses a custom model configured in secure storage', () async {
      secureStorageValues['llm_openrouter_model'] = 'anthropic/claude-3-opus';

      final mockResponse = {
        'choices': [
          {
            'message': {'content': 'Summary text.'}
          }
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = OpenRouterAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.model, 'anthropic/claude-3-opus');
      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(decodedBody['model'], 'anthropic/claude-3-opus');
    });

    test('enrich with translation requires targetLanguage', () async {
      final adapter = OpenRouterAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.translation);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('enrich with translation includes targetLanguage and language field',
        () async {
      final mockResponse = {
        'choices': [
          {
            'message': {'content': 'Este artigo discute topicos de teste.'}
          }
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = OpenRouterAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(
        type: EnrichmentType.translation,
        targetLanguage: 'pt',
      );
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.language, 'pt');
      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect((decodedBody['messages'] as List)[0]['content'], contains('pt'));
    });

    test('enrich with classification returns Enrichment', () async {
      final mockResponse = {
        'choices': [
          {
            'message': {'content': 'tecnologia, testes'}
          }
        ],
      };

      final client = MockClient(
          (request) async => http.Response(jsonEncode(mockResponse), 200));

      final adapter = OpenRouterAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.classification);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.classification);
      expect(result.content, 'tecnologia, testes');
    });

    test(
        'enrich falls back to summary when content is an empty string (not null)',
        () async {
      final workItemWithEmptyContent =
          testWorkItem.copyWith(content: '', summary: 'A real summary.');

      final mockResponse = {
        'choices': [
          {
            'message': {'content': 'Summary from real summary field.'}
          }
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = OpenRouterAdapter(
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

      final adapter = OpenRouterAdapter(
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

      final adapter = OpenRouterAdapter(
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

      final adapter = OpenRouterAdapter(
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

    test('enrich handles empty API response gracefully', () async {
      final client = MockClient(
          (request) async => http.Response(jsonEncode({'choices': []}), 200));

      final adapter = OpenRouterAdapter(
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
