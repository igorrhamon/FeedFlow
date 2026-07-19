import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../application/action_executor.dart';
import '../application/action_registry.dart';
import '../application/event_bus.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/feed_provider.dart';
import 'article_page.dart';
import 'queue_editor_page.dart';

const _accent = Color(0xFFFF6B2C);

/// Fila de triagem local: lista [WorkItem]s por [TriageStatus], com chips de
/// filtro e ações rápidas. Ações dinâmicas via [ActionRegistry] (WS-11),
/// executadas através de [ActionExecutor].
class InboxPage extends StatefulWidget {
  final FeedProvider provider;
  final dynamic workItemRepository; // Optional, for testing; uses DatabaseProvider.repository if null

  const InboxPage({
    super.key,
    required this.provider,
    this.workItemRepository,
  });

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  static const _enrichmentActionIds = {'summarize', 'translate', 'classify'};

  static const _filterableStatuses = [
    TriageStatus.novo,
    TriageStatus.triado,
    TriageStatus.emAndamento,
    TriageStatus.concluido,
    TriageStatus.arquivado,
  ];

  final Set<TriageStatus> _selectedStatuses = {
    TriageStatus.novo,
    TriageStatus.triado,
    TriageStatus.emAndamento,
  };

  late ActionExecutor _actionExecutor;

  @override
  void initState() {
    super.initState();
    _actionExecutor = ActionExecutor(eventBus: eventBus);
  }

  void _toggleStatus(TriageStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        if (_selectedStatuses.length > 1) _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  Future<void> _executeAction(
    WorkItem item,
    String actionId,
    Map<String, dynamic> params,
  ) async {
    developer.log(
      'action tap: action=$actionId workItem=${item.id} params=$params',
      name: 'FeedFlow.InboxPage',
    );
    try {
      final invocation = ActionInvocation(actionId: actionId, params: params);
      final result = await _actionExecutor.execute(item, invocation);

      if (!mounted) return;

      if (!result.success) {
        developer.log(
          'action failed: action=$actionId workItem=${item.id} error=${result.error}',
          name: 'FeedFlow.InboxPage',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao executar ação: ${result.error}')),
        );
        return;
      }

      developer.log(
        'action success: action=$actionId workItem=${item.id}',
        name: 'FeedFlow.InboxPage',
      );

      if (_enrichmentActionIds.contains(actionId)) {
        await _showLatestEnrichment(item, actionId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação executada.')),
        );
      }
    } catch (e) {
      developer.log(
        'action unexpected error: action=$actionId workItem=${item.id}: $e',
        name: 'FeedFlow.InboxPage',
        error: e,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  Future<void> _showLatestEnrichment(WorkItem item, String actionId) async {
    final repository = DatabaseProvider.enrichmentRepository;
    if (repository == null) return;

    final enrichments = await repository.listByWorkItemId(item.id);
    if (enrichments.isEmpty || !mounted) return;

    final latest = enrichments.first;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_enrichmentResultTitle(actionId)),
        content: SingleChildScrollView(child: Text(latest.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _enrichmentResultTitle(String actionId) {
    switch (actionId) {
      case 'summarize':
        return 'Resumo';
      case 'translate':
        return 'Tradução';
      case 'classify':
        return 'Classificação';
      default:
        return 'Resultado';
    }
  }

  Future<void> _showSnoozeDialog(WorkItem item) async {
    final controller = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adiar item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quantos dias?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Dias',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adiar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final days = int.tryParse(controller.text) ?? 1;
      controller.dispose();
      await _executeAction(item, 'snooze', {'days': days});
    } else {
      controller.dispose();
    }
  }

  Future<void> _showAddTagDialog(WorkItem item) async {
    String tag = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar tag'),
        content: TextField(
          autofocus: true,
          onChanged: (value) {
            tag = value;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Digite a tag',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, tag.isNotEmpty),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (confirmed == true && tag.isNotEmpty) {
      await _executeAction(item, 'addTag', {'tag': tag});
    }
  }

  String _statusLabel(TriageStatus status) {
    switch (status) {
      case TriageStatus.novo:
        return 'Novo';
      case TriageStatus.triado:
        return 'Triado';
      case TriageStatus.emAndamento:
        return 'Em andamento';
      case TriageStatus.concluido:
        return 'Concluído';
      case TriageStatus.arquivado:
        return 'Arquivado';
    }
  }

  Future<void> _handleActionTap(WorkItem item, String actionId) async {
    switch (actionId) {
      case 'snooze':
        await _showSnoozeDialog(item);
        break;
      case 'addTag':
        await _showAddTagDialog(item);
        break;
      default:
        // Ações sem diálogo: execute direto
        await _executeAction(item, actionId, {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.workItemRepository ?? DatabaseProvider.repository;

    if (repository == null) {
      return const Center(
        child: Text('Inbox não disponível nesta plataforma (requer persistência local).'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: _filterableStatuses.map((status) {
                    final selected = _selectedStatuses.contains(status);
                    return FilterChip(
                      label: Text(_statusLabel(status)),
                      selected: selected,
                      onSelected: (_) => _toggleStatus(status),
                      selectedColor: const Color(0x33FF6B2C),
                      checkmarkColor: _accent,
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filas',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QueueEditorPage()),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<WorkItem>>(
            stream: repository.watchByStatus(_selectedStatuses.toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('Nada na Inbox para os filtros selecionados.'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final availableActions = ActionRegistry.getAvailable();

                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text('${_statusLabel(item.status)} · ${item.author ?? ''}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticlePage(article: item, provider: widget.provider),
                      ),
                    ),
                    trailing: availableActions.isEmpty
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (actionId) async {
                              await _handleActionTap(item, actionId);
                            },
                            itemBuilder: (context) => availableActions
                                .map(
                                  (action) => PopupMenuItem(
                                    value: action.id,
                                    child: Text(action.label),
                                  ),
                                )
                                .toList(),
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
