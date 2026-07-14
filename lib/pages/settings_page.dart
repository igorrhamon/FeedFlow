import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/feed_provider.dart';
import '../providers/provider_registry.dart';
import '../services/provider_settings.dart';
import '../services/app_settings.dart';
import 'rule_editor_page.dart';

class SettingsPage extends StatefulWidget {
  final FeedProvider provider;
  final String activeProviderId;
  final Future<void> Function(String providerId) onSwitchProvider;
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.provider,
    required this.activeProviderId,
    required this.onSwitchProvider,
    required this.onLogout,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String>? _categoryNames;
  bool _loadingCategories = true;
  bool _exportingOpml = false;
  Map<String, bool> _connectedProviders = {};
  bool _loadingProviders = true;
  bool? _isHealthy;  // null = verificando, true = ok, false = erro
  bool _markReadOnScroll = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadConnectedProviders();
    _checkHealth();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final markReadOnScroll = await AppSettings.getMarkReadOnScroll();
    if (mounted) {
      setState(() => _markReadOnScroll = markReadOnScroll);
    }
  }

  Future<void> _loadConnectedProviders() async {
    final connected = await ProviderSettings.getConnectedProviders();
    if (mounted) {
      setState(() {
        _connectedProviders = connected;
        _loadingProviders = false;
      });
    }
  }

  Future<void> _checkHealth() async {
    try {
      final ok = await widget.provider.validateToken();
      if (mounted) setState(() => _isHealthy = ok);
    } catch (_) {
      if (mounted) setState(() => _isHealthy = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await widget.provider.getCategories();
      if (mounted) {
        setState(() {
          _categoryNames = cats.map((c) => c.name).toList();
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _categoryNames = []; _loadingCategories = false; });
    }
  }

  Future<void> _exportOpml() async {
    setState(() => _exportingOpml = true);
    try {
      final content = await widget.provider.exportOpml();
      if (!mounted) return;
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum dado para exportar')),
        );
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/subscriptions.opml');
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], text: 'Exportar assinaturas OPML');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingOpml = false);
    }
  }

  Future<void> _removeCategory(String name) async {
    try {
      final cats = await widget.provider.getCategories();
      final cat = cats.where((c) => c.name == name).firstOrNull;
      if (cat != null) {
        await widget.provider.deleteCategory(cat.id);
      }
      setState(() => _categoryNames?.remove(name));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "$name" removida.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover categoria: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(
            _isHealthy == null
                ? Icons.hourglass_empty
                : _isHealthy!
                    ? Icons.wifi
                    : Icons.wifi_off,
            color: _isHealthy == null
                ? Colors.grey
                : _isHealthy!
                    ? Colors.green
                    : Colors.red,
          ),
          title: Text(
            _isHealthy == null
                ? 'Verificando conexão...'
                : _isHealthy!
                    ? 'Conexão ativa'
                    : 'Sem conexão',
          ),
          subtitle: Text(widget.provider.displayName),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Exportar OPML'),
          subtitle: const Text('Baixar lista de assinaturas'),
          trailing: _exportingOpml
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: _exportingOpml ? null : _exportOpml,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sair', style: TextStyle(color: Colors.red)),
          onTap: widget.onLogout,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Leitura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        ListTile(
          title: const Text('Marcar como lido ao rolar'),
          subtitle: const Text('Marca artigos como lidos quando saem da tela'),
          trailing: Switch(
            value: _markReadOnScroll,
            onChanged: (value) {
              AppSettings.setMarkReadOnScroll(value);
              setState(() => _markReadOnScroll = value);
            },
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Automação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        ListTile(
          leading: const Icon(Icons.rule),
          title: const Text('Automações'),
          subtitle: const Text('Criar e gerenciar regras de automação'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RuleEditorPage()),
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Trocar Provedor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        if (_loadingProviders)
          const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator())
        else
          ...ProviderRegistry.getAvailableProviders().map((info) {
            final isActive = info.id == widget.activeProviderId;
            final isConnected = _connectedProviders[info.id] ?? false;
            return ListTile(
              leading: Icon(
                isConnected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isConnected ? Colors.green : Colors.grey,
                size: 20,
              ),
              title: Text(info.name),
              trailing: isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x33FF6B2C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Ativo', style: TextStyle(color: Color(0xFFFF6B2C), fontSize: 11, fontWeight: FontWeight.w600)),
                    )
                  : null,
              tileColor: isActive ? const Color(0x0AFF6B2C) : null,
              onTap: isActive ? null : () => widget.onSwitchProvider(info.id),
            );
          }),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _loadCategories,
                tooltip: 'Recarregar',
              ),
            ],
          ),
        ),
        if (_loadingCategories)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_categoryNames == null || _categoryNames!.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.grey)),
          )
        else
          ...(_categoryNames!.map((name) => Dismissible(
            key: Key(name),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _removeCategory(name),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeCategory(name),
              ),
            ),
          ))),
      ],
    );
  }
}
