import 'dart:io';

import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/infrastructure/connectors/folder_source_connector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('folder_connector_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  LocalSourceConfig buildConfig() => LocalSourceConfig(
        id: 'cfg-1',
        type: LocalSourceType.folder,
        path: tempDir.path,
        label: 'Test folder',
        createdAt: DateTime(2026, 1, 1),
      );

  test('pull() returns a Document for each supported file, skipping hidden ones', () async {
    await File('${tempDir.path}/notes.txt').writeAsString('plain text content');
    await File('${tempDir.path}/readme.md').writeAsString('# Título\n\nCorpo em markdown.');
    await File('${tempDir.path}/.hidden.txt').writeAsString('should be ignored');

    final subDir = Directory('${tempDir.path}/sub')..createSync();
    await File('${subDir.path}/deep.txt').writeAsString('deep content');

    final connector = FolderSourceConnector(buildConfig());
    final documents = await connector.pull();

    expect(documents.length, 3);

    final txtDoc = documents.firstWhere((d) => d.sourceId == 'notes.txt');
    expect(txtDoc.contentType, 'text/plain');
    expect(txtDoc.rawContent, 'plain text content');
    expect(txtDoc.title, 'notes');
    expect(txtDoc.sourceConnectorId, 'folder:cfg-1');
    expect(txtDoc.id, 'folder:cfg-1:notes.txt');

    final mdDoc = documents.firstWhere((d) => d.sourceId == 'readme.md');
    expect(mdDoc.contentType, 'text/markdown');
    expect(mdDoc.rawContent, contains('markdown'));

    final deepDoc = documents.firstWhere((d) => d.sourceId == 'sub${Platform.pathSeparator}deep.txt');
    expect(deepDoc.rawContent, 'deep content');
  });

  test('pull() filters out files not modified after `since`', () async {
    final file = File('${tempDir.path}/old.txt');
    await file.writeAsString('old content');

    final connector = FolderSourceConnector(buildConfig());
    final future = DateTime.now().add(const Duration(days: 1));

    final documents = await connector.pull(since: future);

    expect(documents, isEmpty);
  });

  test('pull() returns empty list when directory does not exist', () async {
    final config = LocalSourceConfig(
      id: 'cfg-missing',
      type: LocalSourceType.folder,
      path: '${tempDir.path}/does-not-exist',
      label: 'Missing',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = FolderSourceConnector(config);
    final documents = await connector.pull();

    expect(documents, isEmpty);
  });
}
