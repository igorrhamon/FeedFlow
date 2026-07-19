import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../application/query_spec_compiler.dart';
import '../domain/query_spec.dart';
import '../domain/repositories/queue_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/queue.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';

/// Página de editor CRUD de filas customizadas (`Queue`/`QuerySpec`), com
/// preview ao vivo dos itens que casam com o filtro.
///
/// MVP simplificado: suporta uma condição simples (field/operator/value) e
/// um único critério de ordenação — mesma limitação que `RuleEditorPage`
/// aceita para condições compostas; builder próprio (não compartilhado com
/// `RuleEditorPage` nesta onda, ver `Onda 2.md`/plano WS-9).
class QueueEditorPage extends StatefulWidget {
  /// Permite injetar repositórios em testes de widget. Em produção, ambos
  /// ficam `null` e a página resolve via [DatabaseProvider] (singletons).
  final QueueRepository? queueRepository;
  final WorkItemRepository? workItemRepository;

  const QueueEditorPage({super.key, this.queueRepository, this.workItemRepository});

  @override
  State<QueueEditorPage> createState() => _QueueEditorPageState();
}

class _QueueEditorPageState extends State<QueueEditorPage> {
  late QueueRepository _queueRepository;
  late WorkItemRepository _workItemRepository;
  final _compiler = QuerySpecCompiler();

  /// Streams são armazenados em campos, não recriados a cada `build()` —
  /// cada `StreamBuilder.stream` novo força uma resubscrição no drift, e
  /// recriar a cada rebuild (ex.: a cada tecla digitada em QUALQUER campo do
  /// formulário) causa resubscrições concorrentes que deixam timers internos
  /// do drift pendentes quando o widget é descartado em testes.
  late final Stream<List<Queue>> _queueListStream;
  Stream<List<WorkItem>>? _previewStream;

  Queue? _editingQueue;
  QuerySpec? _previewSpec;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _fieldController;
  late TextEditingController _operatorController;
  late TextEditingController _valueController;
  String? _sortField;
  bool _sortDescending = false;
  int _order = 1;

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

  @override
  void initState() {
    super.initState();
    _queueRepository = widget.queueRepository ?? DatabaseProvider.queueRepository!;
    _workItemRepository = widget.workItemRepository ?? DatabaseProvider.repository!;
    _queueListStream = _queueRepository.watchAll();

    _nameController = TextEditingController();
    _fieldController = TextEditingController(text: 'status');
    _operatorController = TextEditingController(text: 'equals');
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _operatorController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _editingQueue = null;
      _nameController.clear();
      _fieldController.text = 'status';
      _operatorController.text = 'equals';
      _valueController.clear();
      _sortField = null;
      _sortDescending = false;
      _order = 1;
      _previewSpec = null;
      _previewStream = null;
    });
  }

  void _editQueue(Queue queue) {
    final filter = queue.spec.filter;
    setState(() {
      _editingQueue = queue;
      _nameController.text = queue.name;
      _order = queue.order;

      if (filter is SimpleCondition) {
        _fieldController.text = filter.field;
        _operatorController.text = filter.operator;
        _valueController.text = filter.value.toString();
      } else {
        _fieldController.text = 'status';
        _operatorController.text = 'equals';
        _valueController.clear();
      }

      if (queue.spec.sort.isNotEmpty) {
        _sortField = queue.spec.sort.first.field;
        _sortDescending = queue.spec.sort.first.descending;
      } else {
        _sortField = null;
        _sortDescending = false;
      }

      _previewSpec = queue.spec;
      _previewStream = _compiler.compile(queue.spec, _workItemRepository);
    });
  }

  dynamic _parseValue(String operator, String value) {
    if (operator == 'in' || operator == 'notIn') {
      return value.split(',').map((s) => s.trim()).toList();
    } else if (operator == 'greaterThan' || operator == 'lessThan') {
      return num.tryParse(value) ?? value;
    }
    return value;
  }

  QuerySpec? _buildSpec() {
    final field = _fieldController.text.trim();
    final operator = _operatorController.text.trim();
    if (field.isEmpty || operator.isEmpty) return null;

    final value = _valueController.text.trim();
    final filter = Condition.simple(
      field: field,
      operator: operator,
      value: _parseValue(operator, value),
    );

    return QuerySpec(
      filter: filter,
      sort: _sortField == null
          ? const []
          : [QuerySort(field: _sortField!, descending: _sortDescending)],
    );
  }

  void _updatePreview() {
    final spec = _buildSpec();
    if (spec == _previewSpec) return;
    setState(() {
      _previewSpec = spec;
      _previewStream = spec == null ? null : _compiler.compile(spec, _workItemRepository);
    });
  }

  Future<void> _saveQueue() async {
    if (!_formKey.currentState!.validate()) return;

    final spec = _buildSpec();
    if (spec == null) return;

    try {
      final queue = Queue(
        id: _editingQueue?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        spec: spec,
        order: _order,
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

      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar fila: $e')),
        );
      }
    }
  }

  Future<void> _deleteQueue(String id) async {
    try {
      await _queueRepository.delete(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filas')),
      body: ListView(
        children: [
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
                        validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _fieldController.text.isEmpty ? 'status' : _fieldController.text,
                        items: _fields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _fieldController.text = value;
                            _updatePreview();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Campo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _operatorController.text,
                        items: _operators.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _operatorController.text = value;
                            _updatePreview();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Operador',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: "novo" ou "1,2,3" para listas',
                        ),
                        validator: (value) {
                          if (_operatorController.text == 'exists' ||
                              _operatorController.text == 'notExists') {
                            return null;
                          }
                          return value?.isEmpty ?? true ? 'Campo obrigatório' : null;
                        },
                        onChanged: (_) => _updatePreview(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: _sortField,
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Sem ordenação')),
                          ..._fields.map((f) => DropdownMenuItem<String?>(value: f, child: Text(f))),
                        ],
                        onChanged: (value) {
                          _sortField = value;
                          _updatePreview();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Ordenar por',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _sortDescending,
                            onChanged: (value) {
                              setState(() => _sortDescending = value ?? false);
                              _updatePreview();
                            },
                          ),
                          const Text('Descendente'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          initialValue: _order.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Ordem',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _order = int.tryParse(value) ?? 1;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveQueue,
                          child: const Text('Salvar Fila'),
                        ),
                      ),
                      if (_editingQueue != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _resetForm,
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Preview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildPreview(),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Filas', style: Theme.of(context).textTheme.titleLarge),
          ),
          StreamBuilder<List<Queue>>(
            stream: _queueListStream,
            builder: (context, snapshot) {
              final queues = snapshot.data ?? const <Queue>[];
              if (queues.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma fila criada.'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queues.length,
                itemBuilder: (context, index) {
                  final queue = queues[index];
                  return ListTile(
                    title: Text(queue.name),
                    subtitle: Text('Ordem: ${queue.order}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Editar'),
                          onTap: () => _editQueue(queue),
                        ),
                        PopupMenuItem(
                          child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                          onTap: () => _deleteQueue(queue.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final stream = _previewStream;
    if (stream == null) {
      return const Text('Preencha o filtro para ver o preview.');
    }
    return StreamBuilder<List<WorkItem>>(
      stream: stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <WorkItem>[];
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${items.length} itens casariam'),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Nenhum item corresponde ao filtro.')
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.feedId),
                      dense: true,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
