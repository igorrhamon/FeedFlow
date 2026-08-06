import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/source_connector_registry.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/domain/source_connector.dart';
import 'package:feedflow/infrastructure/connectors/local_connectors_init.dart';
import 'package:feedflow/infrastructure/connectors/folder_source_connector.dart';
import 'package:feedflow/infrastructure/connectors/markdown_vault_connector.dart';
import 'package:feedflow/infrastructure/connectors/office_source_connector.dart';
import 'package:feedflow/infrastructure/connectors/pdf_source_connector.dart';

LocalSourceConfig _config(LocalSourceType type) => LocalSourceConfig(
      id: 's1',
      type: type,
      path: '/tmp/whatever',
      label: 'Fonte de teste',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  setUp(() {
    SourceConnectorRegistry.clear();
  });

  tearDown(() {
    SourceConnectorRegistry.clear();
  });

  group('SourceConnectorRegistry', () {
    test('create() returns null for unregistered id', () {
      final connector = SourceConnectorRegistry.create(
        'unknown',
        _config(LocalSourceType.folder),
      );
      expect(connector, isNull);
    });

    test('register()/create() round-trips with the config passed to the factory', () {
      LocalSourceConfig? received;
      SourceConnectorRegistry.register('folder', (config) {
        received = config;
        return FolderSourceConnector(config);
      });

      final config = _config(LocalSourceType.folder);
      final connector = SourceConnectorRegistry.create('folder', config);

      expect(connector, isA<SourceConnector>());
      expect(received, config);
    });

    test('getAvailable() reflects registered ids', () {
      SourceConnectorRegistry.register('folder', (config) => FolderSourceConnector(config));
      SourceConnectorRegistry.register('pdf', (config) => PdfSourceConnector(config));

      expect(SourceConnectorRegistry.getAvailable().keys, containsAll(['folder', 'pdf']));
    });

    test('clear() empties the registry', () {
      SourceConnectorRegistry.register('folder', (config) => FolderSourceConnector(config));
      SourceConnectorRegistry.clear();

      expect(SourceConnectorRegistry.create('folder', _config(LocalSourceType.folder)), isNull);
      expect(SourceConnectorRegistry.getAvailable(), isEmpty);
    });

    group('initializeLocalConnectors', () {
      setUp(initializeLocalConnectors);

      test('registers all 4 local source types', () {
        expect(
          SourceConnectorRegistry.getAvailable().keys,
          containsAll(['folder', 'markdown-vault', 'pdf', 'office']),
        );
      });

      test('creates the expected connector type for each registered id', () {
        expect(
          SourceConnectorRegistry.create('folder', _config(LocalSourceType.folder)),
          isA<FolderSourceConnector>(),
        );
        expect(
          SourceConnectorRegistry.create('markdown-vault', _config(LocalSourceType.markdownVault)),
          isA<MarkdownVaultConnector>(),
        );
        expect(
          SourceConnectorRegistry.create('pdf', _config(LocalSourceType.pdf)),
          isA<PdfSourceConnector>(),
        );
        expect(
          SourceConnectorRegistry.create('office', _config(LocalSourceType.office)),
          isA<OfficeSourceConnector>(),
        );
      });
    });
  });
}
