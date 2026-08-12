import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../../domain/document.dart';
import '../../domain/local_source_config.dart';
import '../../domain/source_connector.dart';

const _docxMimeType =
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
const _xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

Archive _decodeZip(List<int> bytes) => ZipDecoder().decodeBytes(bytes);

String? _readEntry(Archive archive, String name) {
  final file = archive.findFile(name);
  if (file == null) return null;
  final content = file.content as List<int>;
  return utf8.decode(content, allowMalformed: true);
}

/// Extrai texto de um arquivo `.docx` (`word/document.xml`).
///
/// Descompacta o pacote OOXML e concatena todos os elementos `<w:t>`,
/// inserindo quebras de linha em parágrafos (`<w:p>`).
Future<String> extractDocxText(File file) async {
  final archive = _decodeZip(await file.readAsBytes());
  final xmlContent = _readEntry(archive, 'word/document.xml');
  if (xmlContent == null) return '';

  final document = XmlDocument.parse(xmlContent);
  final buffer = StringBuffer();

  for (final paragraph in document.findAllElements('w:p')) {
    final texts = paragraph.findAllElements('w:t').map((e) => e.innerText).join();
    if (texts.trim().isEmpty) continue;
    buffer.writeln(texts);
  }

  return buffer.toString().trim();
}

/// Extrai texto tabular de um arquivo `.xlsx`.
///
/// Lê `xl/sharedStrings.xml` (strings compartilhadas) e cada
/// `xl/worksheets/sheetN.xml`, resolvendo células `<v>` (referência a shared
/// string ou número) e `<is>` (string inline), retornando uma tabela em
/// formato Markdown simples (`| célula | célula |`).
Future<String> extractXlsxText(File file) async {
  final archive = _decodeZip(await file.readAsBytes());

  final sharedStrings = <String>[];
  final sharedStringsXml = _readEntry(archive, 'xl/sharedStrings.xml');
  if (sharedStringsXml != null) {
    final doc = XmlDocument.parse(sharedStringsXml);
    for (final si in doc.findAllElements('si')) {
      sharedStrings.add(si.findAllElements('t').map((e) => e.innerText).join());
    }
  }

  final sheetFiles = archive.files
      .where((f) => f.name.startsWith('xl/worksheets/sheet') && f.name.endsWith('.xml'))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  final buffer = StringBuffer();

  for (final sheetFile in sheetFiles) {
    final content = utf8.decode(sheetFile.content as List<int>, allowMalformed: true);
    final doc = XmlDocument.parse(content);

    for (final row in doc.findAllElements('row')) {
      final cells = <String>[];
      for (final cell in row.findElements('c')) {
        cells.add(_cellValue(cell, sharedStrings));
      }
      if (cells.any((c) => c.isNotEmpty)) {
        buffer.writeln('| ${cells.join(' | ')} |');
      }
    }
  }

  return buffer.toString().trim();
}

String _cellValue(XmlElement cell, List<String> sharedStrings) {
  final type = cell.getAttribute('t');

  final inlineString = cell.findElements('is').firstOrNull;
  if (inlineString != null) {
    return inlineString.findAllElements('t').map((e) => e.innerText).join();
  }

  final value = cell.findElements('v').firstOrNull?.innerText;
  if (value == null) return '';

  if (type == 's') {
    final index = int.tryParse(value);
    if (index != null && index >= 0 && index < sharedStrings.length) {
      return sharedStrings[index];
    }
    return '';
  }

  return value;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Conector que extrai texto de arquivos Office (`.docx`/`.xlsx`) encontrados
/// recursivamente em `config.path`.
class OfficeSourceConnector implements SourceConnector {
  final LocalSourceConfig config;

  OfficeSourceConnector(this.config);

  @override
  String get id => 'office:${config.id}';

  @override
  Future<List<Document>> pull({DateTime? since}) async {
    final root = Directory(config.path);
    if (!await root.exists()) return [];

    final documents = <Document>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      final ext = p.extension(entity.path).toLowerCase();
      if (ext != '.docx' && ext != '.xlsx') continue;

      final relative = p.relative(entity.path, from: config.path);
      if (p.split(relative).any((segment) => segment.startsWith('.'))) continue;

      final document = await _documentFor(entity, relative, ext, since);
      if (document != null) documents.add(document);
    }

    return documents;
  }

  Future<Document?> _documentFor(
    File file,
    String sourceId,
    String ext,
    DateTime? since,
  ) async {
    try {
      final stat = await file.stat();
      if (since != null && !stat.modified.isAfter(since)) return null;

      final isDocx = ext == '.docx';
      final text = isDocx ? await extractDocxText(file) : await extractXlsxText(file);

      return Document(
        id: '$id:$sourceId',
        sourceConnectorId: id,
        sourceId: sourceId,
        contentType: isDocx ? _docxMimeType : _xlsxMimeType,
        title: p.basenameWithoutExtension(file.path),
        rawContent: text,
        capturedAt: stat.modified,
      );
    } catch (_) {
      // Arquivo inválido/corrompido: pula, não interrompe o lote.
      return null;
    }
  }

  @override
  Future<void> close() async {}
}
