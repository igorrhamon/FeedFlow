import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../application/condition_evaluator.dart';
import '../domain/repositories/rule_repository.dart';
import '../domain/repositories/work_item_repository.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';

/// Página de editor CRUD de regras com dry-run.
///
/// MVP simplificado: suporta edição de UMA condição simples (field/operator/value).
/// Condições compostas podem ser criadas manualmente via código ou em iterações futuras.
///
/// Recursos:
/// - Lista todas as regras (habilitadas e desabilitadas)
/// - Cria, edita, deleta regras
/// - Formulário simplificado: nome, trigger, enabled, stopOnMatch, order, condição simples, actionId
/// - Dry-run: avalia a condição contra uma amostra de WorkItems reais, mostra preview
class RuleEditorPage extends StatefulWidget {
  /// Permite injetar repositórios em testes de widget. Em produção, ambos
  /// ficam `null` e a página resolve via [DatabaseProvider] (singletons).
  final RuleRepository? ruleRepository;
  final WorkItemRepository? workItemRepository;

  const RuleEditorPage({super.key, this.ruleRepository, this.workItemRepository});

  @override
  State<RuleEditorPage> createState() => _RuleEditorPageState();
}

class _RuleEditorPageState extends State<RuleEditorPage> {
  late RuleRepository _ruleRepository;
  late WorkItemRepository _workItemRepository;
  List<Rule> _rules = [];
  bool _loading = true;
  bool _savingRule = false;
  Rule? _editingRule;

  // Campos do formulário
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _fieldController;
  late TextEditingController _operatorController;
  late TextEditingController _valueController;
  late TextEditingController _actionIdController;
  RuleTrigger _selectedTrigger = RuleTrigger.onIngested;
  bool _enabled = true;
  bool _stopOnMatch = false;
  int _order = 1;
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

  @override
  void initState() {
    super.initState();
    _ruleRepository = widget.ruleRepository ?? DatabaseProvider.ruleRepository!;
    _workItemRepository = widget.workItemRepository ?? DatabaseProvider.repository!;

    _nameController = TextEditingController();
    _fieldController = TextEditingController();
    _operatorController = TextEditingController(text: 'equals');
    _valueController = TextEditingController();
    _actionIdController = TextEditingController();

    _loadRules();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _operatorController.dispose();
    _valueController.dispose();
    _actionIdController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    try {
      setState(() => _loading = true);
      final rules = await _ruleRepository.list();
      if (mounted) {
        setState(() {
          _rules = rules;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar regras: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  void _resetForm() {
    _editingRule = null;
    _nameController.clear();
    _fieldController.clear();
    _operatorController.text = 'equals';
    _valueController.clear();
    _actionIdController.clear();
    _selectedTrigger = RuleTrigger.onIngested;
    _enabled = true;
    _stopOnMatch = false;
    _order = 1;
    _showDryRun = false;
    _dryRunResults = null;
  }

  void _editRule(Rule rule) {
    _editingRule = rule;
    _nameController.text = rule.name;
    _selectedTrigger = rule.trigger;
    _enabled = rule.enabled;
    _stopOnMatch = rule.stopOnMatch;
    _order = rule.order;

    // Preenche a condição simples, se houver
    if (rule.conditions is SimpleCondition) {
      final simple = rule.conditions as SimpleCondition;
      _fieldController.text = simple.field;
      _operatorController.text = simple.operator;
      _valueController.text = simple.value.toString();
    } else {
      _fieldController.clear();
      _operatorController.text = 'equals';
      _valueController.clear();
    }

    // Preenche a primeira ação, se houver
    if (rule.actions.isNotEmpty) {
      _actionIdController.text = rule.actions.first.actionId;
    } else {
      _actionIdController.clear();
    }

    _showDryRun = false;
    _dryRunResults = null;
  }

  Future<void> _saveRule() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _savingRule = true);

      final name = _nameController.text.trim();
      final field = _fieldController.text.trim();
      final operator = _operatorController.text.trim();
      final value = _valueController.text.trim();
      final actionId = _actionIdController.text.trim();

      // Constrói a condição simples
      dynamic parsedValue = value;
      if (operator == 'in' || operator == 'notIn') {
        // Se for 'in' ou 'notIn', tenta fazer parse como lista (ex: "item1,item2")
        parsedValue = value.split(',').map((s) => s.trim()).toList();
      } else if (operator == 'greaterThan' || operator == 'lessThan') {
        // Tenta fazer parse como número
        parsedValue = num.tryParse(value) ?? value;
      }

      final condition = Condition.simple(
        field: field,
        operator: operator,
        value: parsedValue,
      );

      final actions = <ActionInvocation>[
        if (actionId.isNotEmpty) ActionInvocation(actionId: actionId, params: {}),
      ];

      final rule = Rule(
        id: _editingRule?.id ?? const Uuid().v4(),
        name: name,
        enabled: _enabled,
        trigger: _selectedTrigger,
        conditions: condition,
        actions: actions,
        stopOnMatch: _stopOnMatch,
        order: _order,
      );

      if (_editingRule != null) {
        await _ruleRepository.update(rule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Regra atualizada com sucesso')),
          );
        }
      } else {
        await _ruleRepository.create(rule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Regra criada com sucesso')),
          );
        }
      }

      await _loadRules();
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar regra: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingRule = false);
    }
  }

  Future<void> _deleteRule(String ruleId) async {
    try {
      await _ruleRepository.delete(ruleId);
      await _loadRules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Regra removida com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover regra: $e')),
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

      // Carrega uma amostra de WorkItems de todos os status
      final allItems = await _workItemRepository.watchByStatus(TriageStatus.values).first;

      // Avalia a condição contra todos os items
      final evaluator = ConditionEvaluator();
      final matchedItems = allItems.where((item) => evaluator.evaluate(condition, item)).toList();

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
        title: const Text('Automações'),
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
                        _editingRule == null ? 'Nova Regra' : 'Editar Regra',
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
                                labelText: 'Nome da Regra',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<RuleTrigger>(
                              value: _selectedTrigger,
                              items: RuleTrigger.values
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t.name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedTrigger = value);
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Gatilho',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _fieldController.text.isEmpty
                                  ? 'status'
                                  : _fieldController.text,
                              items: _fields
                                  .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _fieldController.text = value;
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Campo',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _operatorController.text,
                              items: _operators
                                  .map((o) => DropdownMenuItem(
                                        value: o,
                                        child: Text(o),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _operatorController.text = value;
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
                                  return null; // Estes operadores não precisam de valor
                                }
                                return value?.isEmpty ?? true ? 'Campo obrigatório' : null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _actionIdController,
                              decoration: const InputDecoration(
                                labelText: 'Action ID (opcional)',
                                border: OutlineInputBorder(),
                                hintText: 'Ex: "complete", "archive"',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _enabled,
                                  onChanged: (value) {
                                    setState(() => _enabled = value ?? true);
                                  },
                                ),
                                const Text('Habilitada'),
                                const SizedBox(width: 24),
                                Checkbox(
                                  value: _stopOnMatch,
                                  onChanged: (value) {
                                    setState(() => _stopOnMatch = value ?? false);
                                  },
                                ),
                                const Text('Parar ao casar'),
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
                                onPressed: _savingRule ? null : _saveRule,
                                child: _savingRule
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Salvar Regra'),
                              ),
                            ),
                            if (_editingRule != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => _resetForm(),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _dryRunLoading ? null : _runDryRun,
                          icon: const Icon(Icons.preview),
                          label: _dryRunLoading
                              ? const Text('Testando...')
                              : const Text('Testar Condição'),
                        ),
                      ),
                      if (_showDryRun && _dryRunResults != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resultado do Teste: ${_dryRunResults!.length} itens casariam',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              if (_dryRunResults!.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Nenhum item corresponde à condição.'),
                                )
                              else
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: _dryRunResults!.length,
                                    itemBuilder: (context, index) {
                                      final item = _dryRunResults![index];
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
                    ],
                  ),
                ),
                const Divider(thickness: 2),
                // Lista de regras
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Regras (${_rules.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (_rules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhuma regra criada.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      return ListTile(
                        title: Text(rule.name),
                        subtitle: Text(
                          'Gatilho: ${rule.trigger.name} | Ordem: ${rule.order} | '
                          '${rule.enabled ? 'Habilitada' : 'Desabilitada'}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Editar'),
                              onTap: () {
                                _editRule(rule);
                                setState(() {});
                              },
                            ),
                            PopupMenuItem(
                              child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                              onTap: () => _deleteRule(rule.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
