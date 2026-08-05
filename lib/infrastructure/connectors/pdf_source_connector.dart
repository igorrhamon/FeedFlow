import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../domain/document.dart';
import '../../domain/local_source_config.dart';
import '../../domain/source_connector.dart';

/// Extrai texto plano de um arquivo PDF usando Syncfusion.
///
/// Itera todas as páginas concatenando o texto extraído e normaliza espaços
/// em branco excessivos. Reusada por [PdfSourceConnector] e por
/// [FolderSourceConnector] para arquivos `.pdf` encontrados numa pasta genérica.
Future<String> extractPdfText(File file) async {
  final bytes = await file.readAsBytes();
  final document = PdfDocument(inputBytes: bytes);
  try {
    final extractor = PdfTextExtractor(document);
    final rawText = extractor.extractText();
    return rawText.replaceAll(RegExp(r'[ \t]+'), ' ').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  } finally {
    document.dispose();
  }
}

/// Conector que extrai texto de arquivos PDF.
///
/// Suporta dois modos, conforme [LocalSourceConfig.type]:
/// - [LocalSourceType.pdf]: `config.path` aponta para um único arquivo PDF.
/// - [LocalSourceType.folder]: `config.path` aponta para uma pasta, varrida
///   recursivamente em busca de `*.pdf`.
class PdfSourceConnector implements SourceConnector {
  final LocalSourceConfig config;

  PdfSourceConnector(this.config);

  @override
  String get id => 'pdf:${config.id}';

  @override
  Future<List<Document>> pull({DateTime? since}) async {
    if (config.type == LocalSourceType.pdf) {
      return _pullSingleFile(since);
    }
    return _pullFolder(since);
  }

  Future<List<Document>> _pullSingleFile(DateTime? since) async {
    final file = File(config.path);
    if (!await file.exists()) return [];

    final document = await _documentFor(file, p.basename(config.path), since);
    return document == null ? [] : [document];
  }

  Future<List<Document>> _pullFolder(DateTime? since) async {
    final root = Directory(config.path);
    if (!await root.exists()) return [];

    final documents = <Document>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (p.extension(entity.path).toLowerCase() != '.pdf') continue;

      final relative = p.relative(entity.path, from: config.path);
      if (p.split(relative).any((segment) => segment.startsWith('.'))) continue;

      final document = await _documentFor(entity, relative, since);
      if (document != null) documents.add(document);
    }

    return documents;
  }

  Future<Document?> _documentFor(File file, String sourceId, DateTime? since) async {
    try {
      final stat = await file.stat();
      if (since != null && !stat.modified.isAfter(since)) return null;

      final text = await extractPdfText(file);
      return Document(
        id: '$id:$sourceId',
        sourceConnectorId: id,
        sourceId: sourceId,
        contentType: 'application/pdf',
        title: p.basenameWithoutExtension(file.path),
        rawContent: text,
        capturedAt: stat.modified,
      );
    } catch (_) {
      // PDF inválido/corrompido: pula, não interrompe o lote.
      return null;
    }
  }

  @override
  Future<void> close() async {}
}
