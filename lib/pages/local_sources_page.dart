import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../application/source_connector_registry.dart';
import '../domain/local_source_config.dart';
import '../domain/local_source_type_ext.dart';
import '../domain/repositories/local_source_config_repository.dart';
import '../infrastructure/db/database_provider.dart';

/// Página de gestão de fontes locais de documentos (Onda 9): pastas,
/// vaults Obsidian/Markdown, PDFs isolados e arquivos Office.
///
/// Permite adicionar/remover fontes, habilitar/desabilitar, e disparar uma
/// sincronização manual que resolve o [SourceConnector] apropriado ao tipo
/// e ingere os documentos resultantes via [SyncService.ingestDocuments].
class LocalSourcesPage extends StatefulWidget {
  /// Permite injetar o repositório em testes de widget. Em produção fica
  /// `null` e a página resolve via [DatabaseProvider] (singleton).
  final LocalSourceConfigRepository? repository;

  const LocalSourcesPage({super.key, this.repository});

  @override
  State<LocalSourcesPage> createState() => _LocalSourcesPageState();
}

class _LocalSourcesPageState extends State<LocalSourcesPage> {
  LocalSourceConfigRepository? _repository;
  final Set<String> _syncingIds = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DatabaseProvider.localSourceConfigRepository;
  }

  IconData _iconFor(LocalSourceType type) {
    switch (type) {
      case LocalSourceType.folder:
        return Icons.folder;
      case LocalSourceType.markdownVault:
        return Icons.note;
      case LocalSourceType.pdf:
        return Icons.picture_as_pdf;
      case LocalSourceType.office:
        return Icons.table_chart;
    }
  }

  String _typeLabel(LocalSourceType type) {
    switch (type) {
      case LocalSourceType.folder:
        return 'Pasta';
      case LocalSourceType.markdownVault:
        return 'Vault Markdown';
      case LocalSourceType.pdf:
        return 'PDF';
      case LocalSourceType.office:
        return 'Office';
    }
  }

  String _lastSyncLabel(DateTime? lastSyncAt) {
    if (lastSyncAt == null) return 'Nunca';
    final diff = DateTime.now().difference(lastSyncAt);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inHours < 1) return 'Sincronizado há ${diff.inMinutes}min';
    if (diff.inDays < 1) return 'Sincronizado há ${diff.inHours}h';
    return 'Sincronizado há ${diff.inDays}d';
  }

  Future<void> _syncNow(LocalSourceConfig config) async {
    final repository = _repository;
    if (repository == null) return;

    setState(() => _syncingIds.add(config.id));
    try {
      final connector = SourceConnectorRegistry.create(config.type.toShortString(), config);
      if (connector == null) {
        throw StateError('Conector não registrado para tipo: ${config.type}');
      }
      final documents = await connector.pull(since: config.lastSyncAt);
      await connector.close();

      final syncService = DatabaseProvider.syncService;
      if (syncService != null) {
        await syncService.ingestDocuments(documents, connector.id);
      }

      await repository.updateLastSync(config.id, DateTime.now());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${documents.length} documentos sincronizados de "${config.label}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sincronizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncingIds.remove(config.id));
    }
  }

  Future<void> _deleteSource(String id) async {
    final repository = _repository;
    if (repository == null) return;
    await repository.delete(id);
  }

  Future<void> _toggleEnabled(LocalSourceConfig config, bool enabled) async {
    final repository = _repository;
    if (repository == null) return;
    await repository.save(config.copyWith(enabled: enabled));
  }

  Future<void> _showAddSourceSheet() async {
    final type = await showModalBottomSheet<LocalSourceType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Pasta'),
              onTap: () => Navigator.pop(context, LocalSourceType.folder),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Vault Markdown'),
              onTap: () => Navigator.pop(context, LocalSourceType.markdownVault),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () => Navigator.pop(context, LocalSourceType.pdf),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Office'),
              onTap: () => Navigator.pop(context, LocalSourceType.office),
            ),
          ],
        ),
      ),
    );

    if (type == null) return;
    await _pickAndAddSource(type);
  }

  Future<void> _pickAndAddSource(LocalSourceType type) async {
    final repository = _repository;
    if (repository == null) return;

    String? path;
    try {
      switch (type) {
        case LocalSourceType.folder:
        case LocalSourceType.markdownVault:
          path = await FilePicker.platform.getDirectoryPath();
          break;
        case LocalSourceType.pdf:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          path = result?.files.single.path;
          break;
        case LocalSourceType.office:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['docx', 'xlsx'],
          );
          path = result?.files.single.path;
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar: $e')),
        );
      }
      return;
    }

    if (path == null || path.isEmpty) return;

    final segments = path.split(RegExp(r'[\\/]'));
    final defaultLabel = segments.isNotEmpty && segments.last.isNotEmpty
        ? segments.last
        : path;

    final config = LocalSourceConfig(
      id: const Uuid().v4(),
      type: type,
      path: path,
      label: defaultLabel,
      createdAt: DateTime.now(),
    );

    await repository.save(config);
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes locais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: repository == null ? null : _showAddSourceSheet,
          ),
        ],
      ),
      body: repository == null
          ? const Center(
              child: Text('Fontes locais não disponíveis nesta plataforma (requer persistência local).'),
            )
          : StreamBuilder<List<LocalSourceConfig>>(
              stream: repository.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final sources = snapshot.data ?? [];
                if (sources.isEmpty) {
                  return const Center(child: Text('Nenhuma fonte local configurada.'));
                }
                return ListView.builder(
                  itemCount: sources.length,
                  itemBuilder: (context, index) {
                    final config = sources[index];
                    final syncing = _syncingIds.contains(config.id);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(_iconFor(config.type)),
                        title: Text(config.label),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(config.path),
                            Text('${_typeLabel(config.type)} · ${_lastSyncLabel(config.lastSyncAt)}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: config.enabled,
                              onChanged: (value) => _toggleEnabled(config, value),
                            ),
                            IconButton(
                              icon: syncing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.sync),
                              tooltip: 'Sincronizar agora',
                              onPressed: syncing ? null : () => _syncNow(config),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remover',
                              onPressed: () => _deleteSource(config.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
