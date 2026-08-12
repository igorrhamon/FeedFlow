import 'dart:io';
import 'dart:ui';

import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/infrastructure/connectors/pdf_source_connector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<File> _writePdfFixture(String path, String text) async {
  final document = PdfDocument();
  document.pages.add().graphics.drawString(
        text,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 0, 500, 700),
      );
  final bytes = await document.save();
  document.dispose();

  final file = File(path);
  await file.writeAsBytes(bytes);
  return file;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdf_connector_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('extractPdfText returns the text written to the PDF', () async {
    final file = await _writePdfFixture('${tempDir.path}/single.pdf', 'Hello FeedFlow');

    final text = await extractPdfText(file);

    expect(text, contains('Hello FeedFlow'));
  });

  test('pull() with type=pdf reads a single configured file', () async {
    final path = '${tempDir.path}/doc.pdf';
    await _writePdfFixture(path, 'Conteudo do PDF unico');

    final config = LocalSourceConfig(
      id: 'pdf-1',
      type: LocalSourceType.pdf,
      path: path,
      label: 'Single PDF',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = PdfSourceConnector(config);
    final documents = await connector.pull();

    expect(documents.length, 1);
    expect(documents.first.contentType, 'application/pdf');
    expect(documents.first.rawContent, contains('Conteudo do PDF unico'));
    expect(documents.first.sourceConnectorId, 'pdf:pdf-1');
  });

  test('pull() with type=folder scans recursively for *.pdf', () async {
    await _writePdfFixture('${tempDir.path}/a.pdf', 'Documento A');
    final subDir = Directory('${tempDir.path}/sub')..createSync();
    await _writePdfFixture('${subDir.path}/b.pdf', 'Documento B');
    await File('${tempDir.path}/ignore.txt').writeAsString('not a pdf');

    final config = LocalSourceConfig(
      id: 'pdf-folder',
      type: LocalSourceType.folder,
      path: tempDir.path,
      label: 'PDF folder',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = PdfSourceConnector(config);
    final documents = await connector.pull();

    expect(documents.length, 2);
    expect(documents.any((d) => d.rawContent!.contains('Documento A')), isTrue);
    expect(documents.any((d) => d.rawContent!.contains('Documento B')), isTrue);
  });

  test('pull() returns empty list when file/folder does not exist', () async {
    final config = LocalSourceConfig(
      id: 'pdf-missing',
      type: LocalSourceType.pdf,
      path: '${tempDir.path}/missing.pdf',
      label: 'Missing',
      createdAt: DateTime(2026, 1, 1),
    );

    final connector = PdfSourceConnector(config);
    final documents = await connector.pull();

    expect(documents, isEmpty);
  });
}
