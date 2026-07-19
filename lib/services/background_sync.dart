import 'dart:async';
import 'dart:io';

import '../application/action_executor.dart';
import '../application/event_bus.dart';
import '../application/rule_scheduler.dart';
import '../infrastructure/db/database_provider.dart';
import '../models/article.dart';
import '../providers/feed_provider.dart';
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

      // Busca e processa artigos para providers Google Reader-compatible
      if (_googleReaderCompatibleProviders.contains(providerId)) {
        final articlesResult = await provider.getArticles(
          streamId: _readingListStreamId,
          limit: _maxWidgetArticles,
          excludeRead: true,
        );

        // Integra artigos buscados na persistência local (sem quebrar se DB não estiver disponível)
        await _ingestArticlesWithFallback(articlesResult.articles, providerId);

        // Atualiza o widget Android com artigos buscados
        await FeedWidgetService.update(articlesResult.articles);
      }

      // Tenta reenviar mutações pendentes (read/star feitas offline)
      await _flushOutboxWithFallback(provider);

      // Roda regras de gatilho `schedule` vencidas (ver RuleScheduler) —
      // independe do provider, opera sobre WorkItems já persistidos localmente.
      await _runScheduledRulesWithFallback();

      return BackgroundSyncOutcome.success;
    } on SocketException {
      return BackgroundSyncOutcome.networkError;
    } on TimeoutException {
      return BackgroundSyncOutcome.networkError;
    } catch (_) {
      return BackgroundSyncOutcome.unknownError;
    }
  }

  /// Chama `syncService.ingest()` com graceful degradation se DB não estiver disponível.
  /// Erros de ingestão não derubam o job de background — apenas são ignorados com fallback.
  static Future<void> _ingestArticlesWithFallback(
    List<Article> articles,
    String providerId,
  ) async {
    try {
      final syncService = DatabaseProvider.syncService;
      if (syncService != null) {
        await syncService.ingest(articles, providerId);
      }
    } catch (e) {
      // Log ou ignore: ingestão falhou, mas widget já foi atualizado.
      // Não propaga erro — o job continua e tenta novamente na próxima execução.
    }
  }

  /// Tenta reenviar entradas pendentes do outbox (read/star feitas offline).
  /// Graceful degradation: se DB não estiver disponível, ignora silenciosamente.
  /// Erros de flush não derubam o job.
  static Future<void> _flushOutboxWithFallback(FeedProvider provider) async {
    try {
      final syncService = DatabaseProvider.syncService;
      if (syncService != null) {
        await syncService.flushOutbox(provider);
      }
    } catch (e) {
      // Log ou ignore: flush falhou, mas não quebra o job de background.
      // Entradas permanecem no outbox para tentar de novo depois.
    }
  }

  /// Roda `RuleScheduler.runDue()` com graceful degradation se DB não
  /// estiver disponível. Erros não derrubam o job de background.
  static Future<void> _runScheduledRulesWithFallback() async {
    try {
      final ruleRepository = DatabaseProvider.ruleRepository;
      final workItemRepository = DatabaseProvider.repository;
      if (ruleRepository == null || workItemRepository == null) return;

      final scheduler = RuleScheduler(
        ruleRepository: ruleRepository,
        workItemRepository: workItemRepository,
        actionExecutor: ActionExecutor(eventBus: eventBus),
      );
      await scheduler.runDue();
    } catch (e) {
      // Log ou ignore: falha ao rodar regras agendadas não quebra o job.
    }
  }
}
