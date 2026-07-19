import 'dart:convert';

import 'package:feedflow/domain/enricher.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/llm/google_ai_studio_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Testes do [GoogleAiStudioAdapter], espelhando test/llm/llm_adapter_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageValues = <String, String>{};

  const testWorkItemId = 'theoldreader:abc123';
  const apiKeyStorageKey = 'llm_google_ai_studio_api_key';

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

  group('GoogleAiStudioAdapter', () {
    test('id returns the expected identifier', () {
      final adapter = GoogleAiStudioAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      expect(adapter.id, 'llm-google-ai-studio');
    });

    test('capabilities returns summary, translation and classification', () {
      final adapter = GoogleAiStudioAdapter(
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
        'enrich with summary calls generateContent with key as query param and returns Enrichment',
        () async {
      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'This article discusses test topics.'}
              ],
            },
          }
        ],
        'usageMetadata': {'totalTokenCount': 55},
      };

      http.Request? capturedRequest;
      String? capturedBody;
      final client = MockClient((request) async {
        capturedRequest = request;
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = GoogleAiStudioAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );

      final request = EnrichmentRequest(type: EnrichmentType.summary);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.type, EnrichmentType.summary);
      expect(result.content, 'This article discusses test topics.');
      expect(result.model, 'gemini-2.0-flash');
      expect(result.workItemId, testWorkItemId);
      expect(result.tokensUsed, 55);

      expect(capturedRequest, isNotNull);
      expect(
        capturedRequest!.url.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=test-api-key-123',
      );
      expect(capturedRequest!.headers['Content-Type'], 'application/json');
      expect(capturedRequest!.headers.containsKey('Authorization'), isFalse);

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final parts = (decodedBody['contents'] as List)[0]['parts'] as List;
      expect(parts[0]['text'], contains(testWorkItem.content));
    });

    test('enrich uses a custom model configured in secure storage', () async {
      secureStorageValues['llm_google_ai_studio_model'] = 'gemini-1.5-pro';

      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Summary text.'}
              ],
            },
          }
        ],
      };

      http.Request? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = GoogleAiStudioAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.model, 'gemini-1.5-pro');
      expect(
        capturedRequest!.url.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=test-api-key-123',
      );
    });

    test('enrich with translation requires targetLanguage', () async {
      final adapter = GoogleAiStudioAdapter(
        httpClient: MockClient((request) async => http.Response('', 404)),
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.translation);

      expect(
        () => adapter.enrich(testWorkItem, request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('enrich with translation sets language field on result', () async {
      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Este artigo discute topicos de teste.'}
              ],
            },
          }
        ],
      };

      final client = MockClient(
          (request) async => http.Response(jsonEncode(mockResponse), 200));

      final adapter = GoogleAiStudioAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(
        type: EnrichmentType.translation,
        targetLanguage: 'pt',
      );
      final result = await adapter.enrich(testWorkItem, request);

      expect(result.language, 'pt');
    });

    test('enrich with classification returns Enrichment', () async {
      final mockResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'tecnologia, testes'}
              ],
            },
          }
        ],
      };

      final client = MockClient(
          (request) async => http.Response(jsonEncode(mockResponse), 200));

      final adapter = GoogleAiStudioAdapter(
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
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Summary from real summary field.'}
              ],
            },
          }
        ],
      };

      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final adapter = GoogleAiStudioAdapter(
        httpClient: client,
        secureStorage: const FlutterSecureStorage(),
      );
      final request = EnrichmentRequest(type: EnrichmentType.summary);
      await adapter.enrich(workItemWithEmptyContent, request);

      final decodedBody = jsonDecode(capturedBody!) as Map<String, dynamic>;
      final parts = (decodedBody['contents'] as List)[0]['parts'] as List;
      expect(parts[0]['text'], contains('A real summary.'));
    });

    test('enrich throws exception when API key is not configured', () async {
      secureStorageValues.remove(apiKeyStorageKey);

      final adapter = GoogleAiStudioAdapter(
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

      final adapter = GoogleAiStudioAdapter(
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

      final adapter = GoogleAiStudioAdapter(
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
      final client = MockClient((request) async =>
          http.Response(jsonEncode({'candidates': []}), 200));

      final adapter = GoogleAiStudioAdapter(
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
