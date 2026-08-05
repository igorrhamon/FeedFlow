import 'package:feedflow/domain/local_source_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSourceConfig', () {
    test('construtor cria instância com valores padrão', () {
      final now = DateTime.now();
      final config = LocalSourceConfig(
        id: 'test-1',
        type: LocalSourceType.folder,
        path: '/home/user/documents',
        label: 'My Documents',
        createdAt: now,
      );

      expect(config.id, equals('test-1'));
      expect(config.type, equals(LocalSourceType.folder));
      expect(config.path, equals('/home/user/documents'));
      expect(config.label, equals('My Documents'));
      expect(config.enabled, equals(true)); // default value
      expect(config.lastSyncAt, isNull);
      expect(config.createdAt, equals(now));
    });

    test('construtor aceita todos os parâmetros', () {
      final created = DateTime.now().subtract(const Duration(days: 1));
      final lastSync = DateTime.now();

      final config = LocalSourceConfig(
        id: 'test-2',
        type: LocalSourceType.markdownVault,
        path: '/path/to/vault',
        label: 'Obsidian Vault',
        enabled: false,
        lastSyncAt: lastSync,
        createdAt: created,
      );

      expect(config.id, equals('test-2'));
      expect(config.type, equals(LocalSourceType.markdownVault));
      expect(config.path, equals('/path/to/vault'));
      expect(config.label, equals('Obsidian Vault'));
      expect(config.enabled, equals(false));
      expect(config.lastSyncAt, equals(lastSync));
      expect(config.createdAt, equals(created));
    });

    test('suporta PDF como tipo de fonte', () {
      final config = LocalSourceConfig(
        id: 'test-pdf',
        type: LocalSourceType.pdf,
        path: '/downloads/document.pdf',
        label: 'PDF Document',
        createdAt: DateTime.now(),
      );

      expect(config.type, equals(LocalSourceType.pdf));
    });

    test('suporta Office como tipo de fonte', () {
      final config = LocalSourceConfig(
        id: 'test-office',
        type: LocalSourceType.office,
        path: '/docs/spreadsheet.xlsx',
        label: 'Excel Spreadsheet',
        createdAt: DateTime.now(),
      );

      expect(config.type, equals(LocalSourceType.office));
    });

    test('Freezed copyWith funciona corretamente', () {
      final original = LocalSourceConfig(
        id: 'test-3',
        type: LocalSourceType.folder,
        path: '/original/path',
        label: 'Original Label',
        createdAt: DateTime.now(),
      );

      final copied = original.copyWith(
        label: 'Updated Label',
        enabled: false,
      );

      expect(copied.id, equals(original.id));
      expect(copied.type, equals(original.type));
      expect(copied.path, equals(original.path));
      expect(copied.label, equals('Updated Label'));
      expect(copied.enabled, equals(false));
      expect(copied.createdAt, equals(original.createdAt));
    });

    test('JSON serialization funciona', () {
      final now = DateTime.now();
      final config = LocalSourceConfig(
        id: 'test-json',
        type: LocalSourceType.markdownVault,
        path: '/path/to/vault',
        label: 'Test Vault',
        enabled: true,
        lastSyncAt: now,
        createdAt: now,
      );

      final json = config.toJson();
      expect(json['id'], equals('test-json'));
      expect(json['type'], equals('markdownVault'));
      expect(json['path'], equals('/path/to/vault'));
      expect(json['label'], equals('Test Vault'));
      expect(json['enabled'], equals(true));

      final restored = LocalSourceConfig.fromJson(json);
      expect(restored.id, equals(config.id));
      expect(restored.type, equals(config.type));
      expect(restored.path, equals(config.path));
      expect(restored.label, equals(config.label));
      expect(restored.enabled, equals(config.enabled));
    });
  });
}
