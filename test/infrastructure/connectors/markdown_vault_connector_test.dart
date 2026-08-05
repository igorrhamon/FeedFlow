import 'dart:io';

import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/infrastructure/connectors/markdown_vault_connector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('markdown_vault_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  LocalSourceConfig buildConfig() => LocalSourceConfig(
        id: 'vault-1',
        type: LocalSourceType.markdownVault,
        path: tempDir.path,
        label: 'Test vault',
        createdAt: DateTime(2026, 1, 1),
      );

  test('pull() reads .md files and ignores .obsidian/ and non-md files', () async {
    await File('${tempDir.path}/note1.md').writeAsString('# Nota 1\nConteúdo.');
    await File('${tempDir.path}/note2.md').writeAsString('---\ntags: [a, b]\n---\nCorpo.');
    await File('${tempDir.path}/ignore.txt').writeAsString('should be ignored');

    final obsidianDir = Directory('${tempDir.path}/.obsidian')..createSync();
    await File('${obsidianDir.path}/config.json').writeAsString('{}');

    final connector = MarkdownVaultConnector(buildConfig());
    final documents = await connector.pull();

    expect(documents.length, 2);
    expect(documents.every((d) => d.contentType == 'text/markdown'), isTrue);
    expect(documents.every((d) => d.sourceConnectorId == 'markdown-vault:vault-1'), isTrue);

    final note1 = documents.firstWhere((d) => d.sourceId == 'note1.md');
    expect(note1.title, 'note1');
    expect(note1.rawContent, contains('Nota 1'));

    final note2 = documents.firstWhere((d) => d.sourceId == 'note2.md');
    expect(note2.rawContent, contains('tags'));
  });

  test('readMarkdownFile returns raw file content', () async {
    final file = File('${tempDir.path}/plain.md');
    await file.writeAsString('conteúdo simples');

    final content = await readMarkdownFile(file);

    expect(content, 'conteúdo simples');
  });
}
