import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/document.dart';
import '../../domain/local_source_config.dart';
import '../../domain/source_connector.dart';

/// Lê um arquivo Markdown do disco.
///
/// Por enquanto retorna o conteúdo bruto (incluindo eventual frontmatter YAML).
/// Reusada por [MarkdownVaultConnector] e por [FolderSourceConnector] para
/// arquivos `.md` encontrados dentro de uma pasta genérica.
Future<String> readMarkdownFile(File file) async {
  return file.readAsString();
}

/// Conector que varre um vault Obsidian (ou qualquer pasta de notas Markdown)
/// e produz um [Document] por arquivo `.md` encontrado.
///
/// Ignora a pasta `.obsidian/` (configurações internas do Obsidian) e qualquer
/// diretório/arquivo oculto (prefixo `.`).
class MarkdownVaultConnector implements SourceConnector {
  final LocalSourceConfig config;

  MarkdownVaultConnector(this.config);

  @override
  String get id => 'markdown-vault:${config.id}';

  @override
  Future<List<Document>> pull({DateTime? since}) async {
    final root = Directory(config.path);
    if (!await root.exists()) {
      return [];
    }

    final documents = <Document>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      final relative = p.relative(entity.path, from: config.path);
      if (_isHiddenOrObsidianInternal(relative)) continue;
      if (p.extension(entity.path).toLowerCase() != '.md') continue;

      try {
        final stat = await entity.stat();
        if (since != null && !stat.modified.isAfter(since)) continue;

        final content = await readMarkdownFile(entity);
        documents.add(
          Document(
            id: '$id:$relative',
            sourceConnectorId: id,
            sourceId: relative,
            contentType: 'text/markdown',
            title: p.basenameWithoutExtension(entity.path),
            rawContent: content,
            capturedAt: stat.modified,
          ),
        );
      } catch (_) {
        // Arquivo inválido/ilegível: pula, não interrompe o lote.
        continue;
      }
    }

    return documents;
  }

  @override
  Future<void> close() async {}

  bool _isHiddenOrObsidianInternal(String relativePath) {
    final segments = p.split(relativePath);
    return segments.any((segment) => segment.startsWith('.'));
  }
}
