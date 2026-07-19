import 'package:flutter/material.dart';

import '../application/event_bus.dart';
import '../application/snooze_use_case.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/feed_provider.dart';
import 'article_page.dart';
import 'queue_editor_page.dart';

const _accent = Color(0xFFFF6B2C);

/// Fila de triagem local: lista [WorkItem]s por [TriageStatus], com chips de
/// filtro e ações rápidas (concluir/adiar/arquivar). Ações aqui chamam
/// diretamente `changeStatus`/[SnoozeUseCase] — a troca para ações dinâmicas
/// via `ActionRegistry` é escopo da WS-11, feita depois que a WS-8 existir.
class InboxPage extends StatefulWidget {
  final FeedProvider provider;
  const InboxPage({super.key, required this.provider});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
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

  void _toggleStatus(TriageStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        if (_selectedStatuses.length > 1) _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  Future<void> _changeStatus(WorkItem item, TriageStatus newStatus) async {
    final repository = DatabaseProvider.repository;
    if (repository == null) return;
    try {
      await repository.changeStatus(item.id, newStatus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível mudar o status: $e')),
      );
    }
  }

  Future<void> _snooze(WorkItem item) async {
    final repository = DatabaseProvider.repository;
    if (repository == null) return;
    final useCase = SnoozeUseCase(workItemRepository: repository, eventBus: eventBus);
    await useCase.snooze(item, DateTime.now().add(const Duration(days: 1)));
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

  @override
  Widget build(BuildContext context) {
    final repository = DatabaseProvider.repository;

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
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text('${_statusLabel(item.status)} · ${item.author ?? ''}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticlePage(article: item, provider: widget.provider),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        switch (action) {
                          case 'concluir':
                            _changeStatus(item, TriageStatus.concluido);
                            break;
                          case 'arquivar':
                            _changeStatus(item, TriageStatus.arquivado);
                            break;
                          case 'adiar':
                            _snooze(item);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'concluir', child: Text('Concluir')),
                        PopupMenuItem(value: 'adiar', child: Text('Adiar 1 dia')),
                        PopupMenuItem(value: 'arquivar', child: Text('Arquivar')),
                      ],
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
