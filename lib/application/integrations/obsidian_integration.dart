import 'package:url_launcher/url_launcher.dart';
import '../../domain/work_item.dart';
import 'external_integration.dart';

/// Converte um [WorkItem] para Markdown.
/// Formato: título como heading, seguido por autor/data/tags, depois conteúdo/resumo.
String workItemToMarkdown(WorkItem item) {
  final buffer = StringBuffer();

  // Título
  buffer.writeln('# ${item.title}');
  buffer.writeln();

  // Metadados
  if (item.author != null && item.author!.isNotEmpty) {
    buffer.writeln('**Author:** ${item.author}');
  }
  if (item.published != null) {
    buffer.writeln('**Published:** ${item.published}');
  }
  if (item.tags.isNotEmpty) {
    buffer.writeln('**Tags:** ${item.tags.join(', ')}');
  }
  if (item.url != null && item.url!.isNotEmpty) {
    buffer.writeln('**URL:** [Link](${item.url})');
  }

  if (item.author != null || item.published != null || item.tags.isNotEmpty || item.url != null) {
    buffer.writeln();
  }

  // Conteúdo
  if (item.content != null && item.content!.isNotEmpty) {
    buffer.writeln('## Content');
    buffer.writeln();
    buffer.writeln(item.content);
    buffer.writeln();
  }

  // Resumo
  if (item.summary != null && item.summary!.isNotEmpty) {
    buffer.writeln('## Summary');
    buffer.writeln();
    buffer.writeln(item.summary);
  }

  return buffer.toString();
}

/// Integração Obsidian: abre o Obsidian com uma nova nota via custom URI.
/// Requer [vault] (nome do vault) no config.
class ObsidianIntegration implements ExternalIntegration {
  ObsidianIntegration();

  @override
  Future<void> send(WorkItem item, Map<String, dynamic> config) async {
    final vault = config['vault'] as String?;

    if (vault == null || vault.isEmpty) {
      throw ArgumentError('Obsidian vault name is required in config[\'vault\']');
    }

    final markdown = workItemToMarkdown(item);
    final vaultEncoded = Uri.encodeComponent(vault);
    final titleEncoded = Uri.encodeComponent(item.title);
    final contentEncoded = Uri.encodeComponent(markdown);

    final obsidianUri =
        'obsidian://new?vault=$vaultEncoded&name=$titleEncoded&content=$contentEncoded';

    final uri = Uri.parse(obsidianUri);
    if (!await launchUrl(uri)) {
      throw Exception('Failed to launch Obsidian URI: $obsidianUri');
    }
  }
}
