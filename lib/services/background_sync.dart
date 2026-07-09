import 'dart:async';
import 'dart:io';

import '../providers/provider_registry.dart';
import '../widget/feed_widget_service.dart';
import 'provider_settings.dart';

enum BackgroundSyncOutcome {
  success,
  noActiveSession,
  authFailed,
  networkError,
  unknownError,
}

class BackgroundSync {
  static const _readingListStreamId = 'user/-/state/com.google/reading-list';
  static const _maxWidgetArticles = 5;
  static const _googleReaderCompatibleProviders = {'theoldreader', 'inoreader', 'freshrss'};

  static Future<BackgroundSyncOutcome> run() async {
    try {
      final providerId = await ProviderSettings.getActiveProvider() ?? 'theoldreader';
      final storedAuth = await ProviderSettings.loadAuthConfig(providerId);
      if (storedAuth == null) return BackgroundSyncOutcome.noActiveSession;

      final provider = ProviderRegistry.create(providerId);
      if (provider == null) return BackgroundSyncOutcome.unknownError;

      final authResult = await provider.authenticate(storedAuth);
      if (!authResult.success) return BackgroundSyncOutcome.authFailed;

      await provider.getUnreadCounts();
      if (_googleReaderCompatibleProviders.contains(providerId)) {
        final articlesResult = await provider.getArticles(
          streamId: _readingListStreamId,
          limit: _maxWidgetArticles,
          excludeRead: true,
        );
        await FeedWidgetService.update(articlesResult.articles);
      }
      return BackgroundSyncOutcome.success;
    } on SocketException {
      return BackgroundSyncOutcome.networkError;
    } on TimeoutException {
      return BackgroundSyncOutcome.networkError;
    } catch (_) {
      return BackgroundSyncOutcome.unknownError;
    }
  }
}
