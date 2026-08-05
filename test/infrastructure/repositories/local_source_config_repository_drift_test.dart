import 'package:drift/native.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/local_source_config_repository_drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSourceConfigRepositoryDrift', () {
    late AppDatabase database;
    late LocalSourceConfigRepositoryDrift repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = LocalSourceConfigRepositoryDrift(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('save e byId funcionam corretamente', () async {
      final now = DateTime.now();
      final config = LocalSourceConfig(
        id: 'source-1',
        type: LocalSourceType.folder,
        path: '/home/user/docs',
        label: 'My Documents',
        enabled: true,
        lastSyncAt: null,
        createdAt: now,
      );

      await repository.save(config);

      final retrieved = await repository.byId('source-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('source-1'));
      expect(retrieved.type, equals(LocalSourceType.folder));
      expect(retrieved.path, equals('/home/user/docs'));
      expect(retrieved.label, equals('My Documents'));
      expect(retrieved.enabled, equals(true));
    });

    test('byId retorna null para ID inexistente', () async {
      final result = await repository.byId('nonexistent');
      expect(result, isNull);
    });

    test('watchAll emite lista de configurações', () async {
      final now = DateTime.now();
      final config1 = LocalSourceConfig(
        id: 'source-1',
        type: LocalSourceType.folder,
        path: '/path1',
        label: 'Config 1',
        createdAt: now,
      );
      final config2 = LocalSourceConfig(
        id: 'source-2',
        type: LocalSourceType.markdownVault,
        path: '/path2',
        label: 'Config 2',
        createdAt: now,
      );

      await repository.save(config1);
      await repository.save(config2);

      final configs = await repository.watchAll().first;
      expect(configs, hasLength(2));
      expect(configs.map((c) => c.id), containsAll(['source-1', 'source-2']));
    });

    test('delete remove configuração', () async {
      final now = DateTime.now();
      final config = LocalSourceConfig(
        id: 'source-to-delete',
        type: LocalSourceType.pdf,
        path: '/path/to/pdf',
        label: 'PDF Config',
        createdAt: now,
      );

      await repository.save(config);
      var retrieved = await repository.byId('source-to-delete');
      expect(retrieved, isNotNull);

      await repository.delete('source-to-delete');
      retrieved = await repository.byId('source-to-delete');
      expect(retrieved, isNull);
    });

    test('updateLastSync atualiza timestamp', () async {
      final now = DateTime.now();
      final config = LocalSourceConfig(
        id: 'source-sync',
        type: LocalSourceType.folder,
        path: '/path',
        label: 'Sync Test',
        lastSyncAt: null,
        createdAt: now,
      );

      await repository.save(config);

      final syncTime = DateTime.now();
      await repository.updateLastSync('source-sync', syncTime);

      final updated = await repository.byId('source-sync');
      expect(updated!.lastSyncAt, isNotNull);
      // Comparar com margem de 1 segundo para contabilizar precisão
      expect(
        updated.lastSyncAt!.difference(syncTime).inSeconds.abs(),
        lessThan(1),
      );
    });

    test('save com mesmo ID atualiza registro', () async {
      final now = DateTime.now();
      final config1 = LocalSourceConfig(
        id: 'source-update',
        type: LocalSourceType.folder,
        path: '/original/path',
        label: 'Original',
        enabled: true,
        createdAt: now,
      );

      await repository.save(config1);

      final config2 = LocalSourceConfig(
        id: 'source-update',
        type: LocalSourceType.markdownVault,
        path: '/updated/path',
        label: 'Updated',
        enabled: false,
        createdAt: now,
      );

      await repository.save(config2);

      final configs = await repository.watchAll().first;
      expect(configs, hasLength(1));

      final retrieved = await repository.byId('source-update');
      expect(retrieved!.type, equals(LocalSourceType.markdownVault));
      expect(retrieved.path, equals('/updated/path'));
      expect(retrieved.label, equals('Updated'));
      expect(retrieved.enabled, equals(false));
    });

    test('suporta todos os tipos de fonte', () async {
      final now = DateTime.now();
      final types = [
        LocalSourceType.folder,
        LocalSourceType.markdownVault,
        LocalSourceType.pdf,
        LocalSourceType.office,
      ];

      for (int i = 0; i < types.length; i++) {
        final config = LocalSourceConfig(
          id: 'source-type-$i',
          type: types[i],
          path: '/path/$i',
          label: 'Type $i',
          createdAt: now,
        );

        await repository.save(config);
      }

      for (int i = 0; i < types.length; i++) {
        final retrieved = await repository.byId('source-type-$i');
        expect(retrieved!.type, equals(types[i]));
      }
    });
  });
}
