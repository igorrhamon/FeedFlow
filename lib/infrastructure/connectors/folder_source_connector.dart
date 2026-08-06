import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/document.dart';
import '../../domain/local_source_config.dart';
import '../../domain/source_connector.dart';
import 'markdown_vault_connector.dart';
import 'office_source_connector.dart';
import 'pdf_source_connector.dart';

/// Profundidade máxima de varredura recursiva a partir de `config.path`.
const int _maxScanDepth = 3;

/// Tamanho do lote de arquivos processados por vez, evitando carregar
/// centenas/milhares de arquivos em memória de uma só vez.
const int _batchSize = 50;

const _docxMimeType =
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
const _xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Conector que varre uma pasta genérica recursivamente (até [_maxScanDepth]
/// níveis) e produz um [Document] por arquivo suportado (`.txt`, `.md`,
/// `.pdf`, `.docx`, `.xlsx`).
///
/// Arquivos/diretórios ocultos (prefixo `.` ou `_`) são ignorados. A extração
/// de conteúdo por tipo é delegada às funções livres reusadas dos demais
/// conectores ([readMarkdownFile], [extractPdfText], [extractDocxText],
/// [extractXlsxText]).
class FolderSourceConnector implements SourceConnector {
  final LocalSourceConfig config;

  FolderSourceConnector(this.config);

  @override
  String get id => 'folder:${config.id}';

  @override
  Future<List<Document>> pull({DateTime? since}) async {
    final root = Directory(config.path);
    if (!await root.exists()) return [];

    final files = <File>[];
    await _scanDirectory(root, 0, files);

    final documents = <Document>[];
    for (var i = 0; i < files.length; i += _batchSize) {
      final batch = files.skip(i).take(_batchSize);
      for (final file in batch) {
        final document = await _documentFor(file, since);
        if (document != null) documents.add(document);
      }
    }

    return documents;
  }

  Future<void> _scanDirectory(Directory dir, int depth, List<File> out) async {
    if (depth > _maxScanDepth) return;

    List<FileSystemEntity> entries;
    try {
      entries = await dir.list(followLinks: false).toList();
    } catch (_) {
      return;
    }

    for (final entity in entries) {
      final name = p.basename(entity.path);
      if (_isHidden(name)) continue;

      if (entity is Directory) {
        await _scanDirectory(entity, depth + 1, out);
      } else if (entity is File) {
        if (_isSupported(entity.path)) out.add(entity);
      }
    }
  }

  bool _isHidden(String name) => name.startsWith('.') || name.startsWith('_');

  bool _isSupported(String path) {
    switch (p.extension(path).toLowerCase()) {
      case '.txt':
      case '.md':
      case '.pdf':
      case '.docx':
      case '.xlsx':
        return true;
      default:
        return false;
    }
  }

  Future<Document?> _documentFor(File file, DateTime? since) async {
    final relative = p.relative(file.path, from: config.path);
    final ext = p.extension(file.path).toLowerCase();

    try {
      final stat = await file.stat();
      if (since != null && !stat.modified.isAfter(since)) return null;

      String contentType;
      String? rawContent;

      switch (ext) {
        case '.txt':
          contentType = 'text/plain';
          rawContent = await file.readAsString();
          break;
        case '.md':
          contentType = 'text/markdown';
          rawContent = await readMarkdownFile(file);
          break;
        case '.pdf':
          contentType = 'application/pdf';
          rawContent = await extractPdfText(file);
          break;
        case '.docx':
          contentType = _docxMimeType;
          rawContent = await extractDocxText(file);
          break;
        case '.xlsx':
          contentType = _xlsxMimeType;
          rawContent = await extractXlsxText(file);
          break;
        default:
          return null;
      }

      return Document(
        id: '$id:$relative',
        sourceConnectorId: id,
        sourceId: relative,
        contentType: contentType,
        title: p.basenameWithoutExtension(file.path),
        rawContent: rawContent,
        capturedAt: stat.modified,
      );
    } catch (_) {
      // Arquivo inválido/ilegível: pula, não interrompe o lote.
      return null;
    }
  }

  @override
  Future<void> close() async {}
}
