import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../application/condition_evaluator.dart';
import '../application/query_evaluator.dart';
import '../domain/query_spec.dart';
import '../domain/queue.dart';
import '../domain/repositories/queue_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';

/// Página de editor CRUD de filas com dry-run.
///
/// MVP simplificado: suporta edição de UMA condição simples (field/operator/value).
/// Condições compostas podem ser criadas manualmente via código ou em iterações futuras.
///
/// Recursos:
/// - Lista todas as filas
/// - Cria, edita, deleta filas
/// - Formulário simplificado: nome, ícone, ordem, condição simples, sortField, sortDescending
/// - Dry-run: avalia o QuerySpec contra uma amostra de WorkItems reais, mostra preview
class QueueEditorPage extends StatefulWidget {
  /// Permite injetar repositórios em testes de widget. Em produção, ambos
  /// ficam `null` e a página resolve via [DatabaseProvider] (singletons).
  final QueueRepository? queueRepository;
  final WorkItemRepository? workItemRepository;

  const QueueEditorPage({
    super.key,
    this.queueRepository,
    this.workItemRepository,
  });

  @override
  State<QueueEditorPage> createState() => _QueueEditorPageState();
}

class _QueueEditorPageState extends State<QueueEditorPage> {
  late QueueRepository _queueRepository;
  late WorkItemRepository _workItemRepository;
  List<Queue> _queues = [];
  bool _loading = true;
  bool _savingQueue = false;
  Queue? _editingQueue;

  // Campos do formulário
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _fieldController;
  late TextEditingController _operatorController;
  late TextEditingController _valueController;
  late TextEditingController _sortFieldController;
  int _order = 1;
  bool _sortDescending = false;
  bool _showDryRun = false;
  List<WorkItem>? _dryRunResults;
  bool _dryRunLoading = false;

  // Operadores suportados
  static const List<String> _operators = [
    'equals',
    'notEquals',
    'contains',
    'notContains',
    'in',
    'notIn',
    'startsWith',
    'endsWith',
    'greaterThan',
    'lessThan',
    'exists',
    'notExists',
  ];

  // Campos suportados
  static const List<String> _fields = [
    'status',
    'priority',
    'tags',
    'feedId',
    'providerId',
    'title',
    'author',
    'summary',
    'content',
    'url',
    'isRead',
    'isStarred',
    'isSnoozed',
  ];

  // Campos suportados para ordenação
  static const List<String> _sortFields = [
    'ingestedAt',
    'updatedAt',
    'title',
    'published',
    'updated',
  ];

  @override
  void initState() {
    super.initState();
    _queueRepository = widget.queueRepository ?? DatabaseProvider.queueRepository!;
    _workItemRepository = widget.workItemRepository ?? DatabaseProvider.repository!;

    _nameController = TextEditingController();
    _iconController = TextEditingController(text: 'inbox');
    _fieldController = TextEditingController();
    _operatorController = TextEditingController(text: 'equals');
    _valueController = TextEditingController();
    _sortFieldController = TextEditingController(text: 'ingestedAt');

    _loadQueues();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _fieldController.dispose();
    _operatorController.dispose();
    _valueController.dispose();
    _sortFieldController.dispose();
    super.dispose();
  }

  Future<void> _loadQueues() async {
    try {
      setState(() => _loading = true);
      final queues = await _queueRepository.list();
      if (mounted) {
        setState(() {
          _queues = queues;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar filas: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  void _resetForm() {
    _editingQueue = null;
    _nameController.clear();
    _iconController.text = 'inbox';
    _fieldController.clear();
    _operatorController.text = 'equals';
    _valueController.clear();
    _sortFieldController.text = 'ingestedAt';
    _order = 1;
    _sortDescending = false;
    _showDryRun = false;
    _dryRunResults = null;
  }

  void _editQueue(Queue queue) {
    _editingQueue = queue;
    _nameController.text = queue.name;
    _iconController.text = queue.icon;
    _order = queue.order;
    _sortFieldController.text = queue.querySpec.sortField ?? 'ingestedAt';
    _sortDescending = queue.querySpec.sortDescending;

    // Preenche a condição simples, se houver
    if (queue.querySpec.filter is SimpleCondition) {
      final simple = queue.querySpec.filter as SimpleCondition;
      _fieldController.text = simple.field;
      _operatorController.text = simple.operator;
      _valueController.text = simple.value.toString();
    } else {
      _fieldController.clear();
      _operatorController.text = 'equals';
      _valueController.clear();
    }

    _showDryRun = false;
    _dryRunResults = null;
  }

  Future<void> _saveQueue() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _savingQueue = true);

      final name = _nameController.text.trim();
      final icon = _iconController.text.trim();
      final field = _fieldController.text.trim();
      final operator = _operatorController.text.trim();
      final value = _valueController.text.trim();
      final sortField = _sortFieldController.text.trim();

      // Constrói a condição simples
      dynamic parsedValue = value;
      if (operator == 'in' || operator == 'notIn') {
        parsedValue = value.split(',').map((s) => s.trim()).toList();
      } else if (operator == 'greaterThan' || operator == 'lessThan') {
        parsedValue = num.tryParse(value) ?? value;
      }

      final condition = Condition.simple(
        field: field,
        operator: operator,
        value: parsedValue,
      );

      final querySpec = QuerySpec(
        filter: condition,
        sortField: sortField.isNotEmpty ? sortField : null,
        sortDescending: _sortDescending,
      );

      final queue = Queue(
        id: _editingQueue?.id ?? const Uuid().v4(),
        name: name,
        icon: icon,
        order: _order,
        querySpec: querySpec,
      );

      if (_editingQueue != null) {
        await _queueRepository.update(queue);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fila atualizada com sucesso')),
          );
        }
      } else {
        await _queueRepository.create(queue);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fila criada com sucesso')),
          );
        }
      }

      await _loadQueues();
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar fila: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingQueue = false);
    }
  }

  Future<void> _deleteQueue(String queueId) async {
    try {
      await _queueRepository.delete(queueId);
      await _loadQueues();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fila removida com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover fila: $e')),
        );
      }
    }
  }

  Future<void> _runDryRun() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _dryRunLoading = true);

      final field = _fieldController.text.trim();
      final operator = _operatorController.text.trim();
      final value = _valueController.text.trim();
      final sortField = _sortFieldController.text.trim();

      // Constrói a condição simples
      dynamic parsedValue = value;
      if (operator == 'in' || operator == 'notIn') {
        parsedValue = value.split(',').map((s) => s.trim()).toList();
      } else if (operator == 'greaterThan' || operator == 'lessThan') {
        parsedValue = num.tryParse(value) ?? value;
      }

      final condition = Condition.simple(
        field: field,
        operator: operator,
        value: parsedValue,
      );

      final querySpec = QuerySpec(
        filter: condition,
        sortField: sortField.isNotEmpty ? sortField : null,
        sortDescending: _sortDescending,
      );

      // Carrega uma amostra de WorkItems de todos os status
      final allItems =
          await _workItemRepository.watchByStatus(TriageStatus.values).first;

      // Avalia o QuerySpec contra todos os items
      final evaluator = QueryEvaluator();
      final matchedItems = evaluator.apply(querySpec, allItems);

      if (mounted) {
        setState(() {
          _dryRunResults = matchedItems;
          _showDryRun = true;
          _dryRunLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no dry-run: $e')),
        );
        setState(() => _dryRunLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filas'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Formulário de edição/criação
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingQueue == null ? 'Nova Fila' : 'Editar Fila',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome da Fila',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Nome é obrigatório'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _iconController,
                              decoration: const InputDecoration(
                                labelText: 'Ícone (ex: inbox, star, check)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Ícone é obrigatório'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _order.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Ordem',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                _order = int.tryParse(v) ?? 1;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Filtro',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _fieldController.text.isNotEmpty
                                  ? _fieldController.text
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Campo',
                                border: OutlineInputBorder(),
                              ),
                              items: _fields
                                  .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  _fieldController.text = v;
                                }
                              },
                              validator: (v) =>
                                  v?.isEmpty ?? true
                                      ? 'Campo é obrigatório'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _operatorController.text,
                              decoration: const InputDecoration(
                                labelText: 'Operador',
                                border: OutlineInputBorder(),
                              ),
                              items: _operators
                                  .map((o) => DropdownMenuItem(
                                        value: o,
                                        child: Text(o),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  _operatorController.text = v;
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _valueController,
                              decoration: const InputDecoration(
                                labelText: 'Valor',
                                border: OutlineInputBorder(),
                                hintText: 'Para "in": item1,item2,item3',
                              ),
                              validator: (v) => v?.isEmpty ?? true
                                  ? 'Valor é obrigatório'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ordenação',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _sortFieldController.text.isNotEmpty
                                  ? _sortFieldController.text
                                  : 'ingestedAt',
                              decoration: const InputDecoration(
                                labelText: 'Campo de Ordenação',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Nenhuma ordenação'),
                                ),
                                ..._sortFields
                                    .map((f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ))
                                    .toList(),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  _sortFieldController.text = v;
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              value: _sortDescending,
                              onChanged: (v) {
                                setState(() => _sortDescending = v ?? false);
                              },
                              title: const Text('Ordenação Descendente'),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _dryRunLoading ? null : _runDryRun,
                                  icon: const Icon(Icons.preview),
                                  label: const Text('Preview'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _savingQueue ? null : _saveQueue,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Salvar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Seção de dry-run
                if (_showDryRun)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview (${_dryRunResults?.length ?? 0} itens)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_dryRunResults?.isEmpty ?? true)
                          const Text('Nenhum item encontrado.')
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: _dryRunResults!.length,
                              itemBuilder: (context, idx) {
                                final item = _dryRunResults![idx];
                                return ListTile(
                                  title: Text(item.title),
                                  subtitle: Text(item.feedId),
                                  dense: true,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                // Lista de filas
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filas Salvas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (_queues.isEmpty)
                        const Text('Nenhuma fila criada.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _queues.length,
                          itemBuilder: (context, idx) {
                            final queue = _queues[idx];
                            return ListTile(
                              leading: Icon(_iconForName(queue.icon)),
                              title: Text(queue.name),
                              subtitle: Text(
                                'Ordem: ${queue.order} | Filtro: ${_getFilterSummary(queue.querySpec.filter)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editQueue(queue),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteQueue(queue.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _iconForName(String name) {
    return switch (name) {
      'inbox' => Icons.inbox,
      'star' => Icons.star,
      'check' => Icons.check,
      'archive' => Icons.archive,
      'delete' => Icons.delete,
      'flag' => Icons.flag,
      _ => Icons.category,
    };
  }

  String _getFilterSummary(Condition condition) {
    if (condition is SimpleCondition) {
      return '${condition.field} ${condition.operator} ${condition.value}';
    } else if (condition is CompoundCondition) {
      return '${condition.combinator} de ${condition.conditions.length}';
    }
    return 'Filtro desconhecido';
  }
}
