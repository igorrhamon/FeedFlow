import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/infrastructure/connectors/office_source_connector.dart';
import 'package:flutter_test/flutter_test.dart';

const _docxDocumentXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>Primeiro paragrafo.</w:t></w:r></w:p>
    <w:p><w:r><w:t>Segundo paragrafo</w:t></w:r><w:r><w:t> com duas partes.</w:t></w:r></w:p>
  </w:body>
</w:document>
''';

const _xlsxSharedStrings = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="2" uniqueCount="2">
  <si><t>Header1</t></si>
  <si><t>Header2</t></si>
</sst>
''';

const _xlsxSheet1 = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetData>
    <row r="1">
      <c r="A1" t="s"><v>0</v></c>
      <c r="B1" t="s"><v>1</v></c>
    </row>
    <row r="2">
      <c r="A2"><v>10</v></c>
      <c r="B2"><v>20</v></c>
    </row>
  </sheetData>
</worksheet>
''';

Future<File> _writeZipFixture(String path, Map<String, String> entries) async {
  final archive = Archive();
  for (final entry in entries.entries) {
    final bytes = utf8.encode(entry.value);
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }
  final zipBytes = ZipEncoder().encode(archive);
  final file = File(path);
  await file.writeAsBytes(zipBytes);
  return file;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('office_connector_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('extractDocxText concatenates <w:t> elements per paragraph', () async {
    final file = await _writeZipFixture(
      '${tempDir.path}/doc.docx',
      {'word/document.xml': _docxDocumentXml},
    );

    final text = await extractDocxText(file);

    expect(text, contains('Primeiro paragrafo.'));
    expect(text, contains('Segundo paragrafo com duas partes.'));
  });

  test('extractXlsxText resolves shared strings and cell values into a table', () async {
    final file = await _writeZipFixture(
      '${tempDir.path}/sheet.xlsx',
      {
        'xl/sharedStrings.xml': _xlsxSharedStrings,
        'xl/worksheets/sheet1.xml': _xlsxSheet1,
      },
    );

    final text = await extractXlsxText(file);

    expect(text, contains('Header1'));
    expect(text, contains('Header2'));
    expect(text, contains('10'));
    expect(text, contains('20'));
  });

  test('pull() scans folder for .docx and .xlsx and produces Documents', () async {
    await _writeZipFixture(
      '${tempDir.path}/report.docx',
      {'word/document.xml': _docxDocumentXml},
    );
    await _writeZipFixture(
      '${tempDir.path}/data.xlsx',
      {
        'xl/sharedStrings.xml': _xlsxSharedStrings,
        'xl/worksheets/sheet1.xml': _xlsxSheet1,
      },
    );
    await File('${tempDir.path}/ignore.txt').writeAsString('not office');

    final config = LocalSourceConfig(
      id: 'office-1',
      type: LocalSourceType.office,
      path: tempDir.path,
      label: 'Office folder',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = OfficeSourceConnector(config);
    final documents = await connector.pull();

    expect(documents.length, 2);

    final docx = documents.firstWhere((d) => d.sourceId == 'report.docx');
    expect(docx.contentType,
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    expect(docx.rawContent, contains('Primeiro paragrafo.'));

    final xlsx = documents.firstWhere((d) => d.sourceId == 'data.xlsx');
    expect(xlsx.contentType,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    expect(xlsx.rawContent, contains('Header1'));
  });

  test('pull() returns empty list when folder does not exist', () async {
    final config = LocalSourceConfig(
      id: 'office-missing',
      type: LocalSourceType.office,
      path: '${tempDir.path}/missing',
      label: 'Missing',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = OfficeSourceConnector(config);
    final documents = await connector.pull();

    expect(documents, isEmpty);
  });
}
