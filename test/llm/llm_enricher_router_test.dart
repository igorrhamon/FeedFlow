import 'package:feedflow/domain/enricher.dart';
import 'package:feedflow/domain/enrichment.dart';
import 'package:feedflow/domain/llm_provider_id.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/infrastructure/llm/llm_enricher_router.dart';
import 'package:feedflow/services/llm_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEnricher implements Enricher {
  _FakeEnricher(this.id);

  @override
  final String id;

  EnrichmentRequest? lastRequest;

  @override
  Set<EnrichmentType> get capabilities => EnrichmentType.values.toSet();

  @override
  Future<Enrichment> enrich(WorkItem item, EnrichmentRequest req) async {
    lastRequest = req;
    return Enrichment(
      workItemId: item.id,
      type: req.type,
      content: 'from $id',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageValues = <String, String>{};

  late _FakeEnricher anthropic;
  late _FakeEnricher openRouter;
  late _FakeEnricher googleAiStudio;
  late LlmEnricherRouter router;

  final item = WorkItem(
    id: 'test-item-1',
    providerId: 'test-provider',
    articleId: 'article-1',
    feedId: 'feed-1',
    title: 'Test Article',
    content: 'Some content.',
    ingestedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    secureStorageValues.clear();
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

    anthropic = _FakeEnricher('llm-anthropic');
    openRouter = _FakeEnricher('llm-openrouter');
    googleAiStudio = _FakeEnricher('llm-google-ai-studio');
    router = LlmEnricherRouter(
      anthropic: anthropic,
      openRouter: openRouter,
      googleAiStudio: googleAiStudio,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('LlmEnricherRouter', () {
    test('delegates to anthropic by default when nothing configured',
        () async {
      final result = await router.enrich(
        item,
        EnrichmentRequest(type: EnrichmentType.summary),
      );

      expect(result.content, 'from llm-anthropic');
      expect(anthropic.lastRequest, isNotNull);
      expect(openRouter.lastRequest, isNull);
      expect(googleAiStudio.lastRequest, isNull);
    });

    test('delegates to openRouter when active', () async {
      await LlmSettings.setActiveProvider(LlmProviderId.openRouter);

      final result = await router.enrich(
        item,
        EnrichmentRequest(type: EnrichmentType.summary),
      );

      expect(result.content, 'from llm-openrouter');
      expect(openRouter.lastRequest, isNotNull);
      expect(anthropic.lastRequest, isNull);
    });

    test('delegates to googleAiStudio when active', () async {
      await LlmSettings.setActiveProvider(LlmProviderId.googleAiStudio);

      final result = await router.enrich(
        item,
        EnrichmentRequest(type: EnrichmentType.summary),
      );

      expect(result.content, 'from llm-google-ai-studio');
      expect(googleAiStudio.lastRequest, isNotNull);
    });

    test('switching active provider changes delegate on next call', () async {
      await router.enrich(item, EnrichmentRequest(type: EnrichmentType.summary));
      expect(anthropic.lastRequest, isNotNull);

      await LlmSettings.setActiveProvider(LlmProviderId.openRouter);
      await router.enrich(item, EnrichmentRequest(type: EnrichmentType.summary));
      expect(openRouter.lastRequest, isNotNull);
    });
  });
}
