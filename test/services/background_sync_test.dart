import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feedflow/models/article.dart';
import 'package:feedflow/providers/auth/auth_config.dart';
import 'package:feedflow/providers/feed_provider.dart';
import 'package:feedflow/providers/provider_init.dart';
import 'package:feedflow/providers/provider_registry.dart';
import 'package:feedflow/services/background_sync.dart';
import 'package:feedflow/services/provider_settings.dart';

class _FakeFeedProvider implements FeedProvider {
  _FakeFeedProvider({
    this.authenticateResult = const AuthResult(success: true),
    this.articles = const [],
    this.getArticlesError,
  });

  final AuthResult authenticateResult;
  final List<Article> articles;
  final Object? getArticlesError;

  @override
  Future<AuthResult> authenticate(Object config) async => authenticateResult;

  @override
  Future<Map<String, int>> getUnreadCounts() async => {'total': articles.length};

  @override
  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
    bool includeOnlyRead = false,
  }) async {
    if (getArticlesError != null) throw getArticlesError!;
    return ArticleListResult(articles: articles);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const homeWidgetChannel = MethodChannel('home_widget');
  final secureStorageValues = <String, String>{};

  Future<void> seedSession(String providerId, FeedProvider fake) async {
    ProviderRegistry.register(
      providerId,
      () => fake,
      ProviderInfo(id: providerId, name: providerId, authTypes: const [AuthType.googleLogin]),
    );
    await ProviderSettings.setActiveProvider(providerId);
    await ProviderSettings.saveAuthConfig(
      providerId,
      GoogleLoginAuthConfig(providerId: providerId, email: 'user@example.com', authToken: 'token'),
    );
  }

  setUp(() {
    initializeProviders();
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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, (call) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, null);
  });

  group('BackgroundSync.run', () {
    test('retorna noActiveSession quando não há sessão salva', () async {
      final outcome = await BackgroundSync.run();
      expect(outcome, BackgroundSyncOutcome.noActiveSession);
    });

    test('retorna success e busca artigos quando a sessão é válida', () async {
      final fake = _FakeFeedProvider(
        articles: [const Article(id: '1', feedId: 'feed-1', title: 'Artigo novo')],
      );
      await seedSession('theoldreader', fake);

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.success);
    });

    test('retorna authFailed quando a reautenticação falha', () async {
      final fake = _FakeFeedProvider(
        authenticateResult: const AuthResult(success: false, error: 'token expirado'),
      );
      await seedSession('theoldreader', fake);

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.authFailed);
    });

    test('retorna networkError quando a busca de artigos falha por falta de rede', () async {
      final fake = _FakeFeedProvider(getArticlesError: const SocketException('sem rede'));
      await seedSession('theoldreader', fake);

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.networkError);
    });

    test('retorna networkError quando a busca de artigos expira', () async {
      final fake = _FakeFeedProvider(getArticlesError: TimeoutException('timeout'));
      await seedSession('theoldreader', fake);

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.networkError);
    });

    test('retorna unknownError quando o provider ativo não está registrado', () async {
      const providerId = 'ghostprovider';
      await ProviderSettings.setActiveProvider(providerId);
      await ProviderSettings.saveAuthConfig(
        providerId,
        GoogleLoginAuthConfig(providerId: providerId, email: 'user@example.com', authToken: 'token'),
      );

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.unknownError);
    });

    test('não busca artigos nem atualiza o widget para providers que não usam IDs Google Reader', () async {
      final fake = _FakeFeedProvider(
        getArticlesError: Exception('getArticles não deveria ser chamado para este provider'),
      );
      await seedSession('miniflux', fake);

      final outcome = await BackgroundSync.run();

      expect(outcome, BackgroundSyncOutcome.success);
    });
  });
}
