import 'package:workmanager/workmanager.dart';

import '../application/actions/actions_init.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/provider_init.dart';
import '../widget/feed_widget_service.dart';
import 'background_sync.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await FeedWidgetService.initialize();
    initializeProviders();
    // ActionRegistry é estático em memória — precisa ser (re)registrado
    // neste isolate de background, separado do isolate principal do app
    // (senão RuleScheduler, via BackgroundSync.run(), não encontra as ações).
    final repo = DatabaseProvider.repository;
    if (repo != null) {
      initializeActions(
        repo,
        enricher: DatabaseProvider.enricher,
        enrichmentRepository: DatabaseProvider.enrichmentRepository,
      );
    }
    await BackgroundSync.run();
    return true;
  });
}

class BackgroundSyncScheduler {
  static const _taskName = 'feedflow.backgroundSync';
  static const _uniqueName = 'feedflow-active-provider-sync';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _taskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
