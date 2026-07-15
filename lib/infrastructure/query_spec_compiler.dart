import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../domain/query_spec.dart';
import '../domain/rule.dart';
import '../domain/work_item.dart';
import 'db/database.dart';

/// Compila um [QuerySpec] para uma query SQL drift, executando-a contra o
/// banco de dados. Serve como alternativa otimizada em memória (via
/// [QueryEvaluator]) para consultas que precisam filtrar/ordenar o banco.
///
/// **Limitações implementadas nesta versão:**
/// - Suporta `SimpleCondition` com operadores: equals, notEquals, contains,
///   notContains, in, notIn, startsWith, endsWith, greaterThan, lessThan,
///   exists, notExists.
/// - Suporta `CompoundCondition` com combinadores: 'all' (AND), 'any' (OR),
///   'not' (NOT).
/// - Campos suportados: status, priority, tags, feedId, providerId, title,
///   author, summary, content, url, isRead, isStarred, isSnoozed, published,
///   updated, ingestedAt, updatedAt.
/// - Operadores/campos não suportados no compilador SQL retornam em log de
///   warning e a query ignora essa parte (comportamento degradado, não erro).
class QuerySpecCompiler {
  QuerySpecCompiler(this._db);

  final AppDatabase _db;

  /// Executa o [QuerySpec] contra o banco, retornando a lista de [WorkItem]s
  /// que casam com o filtro, ordenados conforme especificado.
  Future<List<WorkItem>> run(QuerySpec spec) async {
    // Constrói a expressão WHERE a partir do filtro
    Expression<bool>? whereClause;
    try {
      whereClause = _compileCondition(spec.filter);
    } catch (e) {
      developer.log(
        'QuerySpecCompiler: erro ao compilar filtro — $e',
        name: 'feedflow.query_spec_compiler',
        level: 900,
      );
      // Se falhar, retorna vazio
      return [];
    }

    // Constrói a query sobre work_items
    var query = _db.select(_db.workItems);

    if (whereClause != null) {
      query = query..where((_) => whereClause);
    }

    // Aplica ordenação se especificada
    if (spec.sortField != null) {
      query = _applySortOrder(query, spec.sortField!, spec.sortDescending);
    }

    // Executa e mapeia para [WorkItem]
    final rows = await query.get();
    return rows.map(_workItemRowToDomain).toList();
  }

  Expression<bool> _compileCondition(Condition condition) {
    if (condition is SimpleCondition) {
      return _compileSimpleCondition(condition);
    } else if (condition is CompoundCondition) {
      return _compileCompoundCondition(condition);
    }
    throw StateError('Condição desconhecida: $condition');
  }

  Expression<bool> _compileSimpleCondition(SimpleCondition cond) {
    final col = _getColumn(cond.field);
    if (col == null) {
      developer.log(
        'QuerySpecCompiler: campo não suportado — ${cond.field}',
        name: 'feedflow.query_spec_compiler',
        level: 900,
      );
      // Retorna "true" (nenhum filtro) se campo não for reconhecido
      return const Constant<bool>(true);
    }

    switch (cond.operator) {
      case 'equals':
        return col.equals(cond.value);

      case 'notEquals':
        return col.not().equals(cond.value);

      case 'contains':
        if (col is TextColumn) {
          return col.like('%${cond.value}%');
        }
        return const Constant<bool>(true); // fallback para tipo incompatível

      case 'notContains':
        if (col is TextColumn) {
          return col.like('%${cond.value}%').not();
        }
        return const Constant<bool>(true);

      case 'in':
        if (cond.value is List) {
          return col.isIn(cond.value as List);
        }
        return const Constant<bool>(true);

      case 'notIn':
        if (cond.value is List) {
          return col.isNotIn(cond.value as List);
        }
        return const Constant<bool>(true);

      case 'startsWith':
        if (col is TextColumn) {
          return col.like('${cond.value}%');
        }
        return const Constant<bool>(true);

      case 'endsWith':
        if (col is TextColumn) {
          return col.like('%${cond.value}');
        }
        return const Constant<bool>(true);

      case 'greaterThan':
        return col.isBiggerThan(cond.value);

      case 'lessThan':
        return col.isSmallerThan(cond.value);

      case 'exists':
        return col.isNotNull();

      case 'notExists':
        return col.isNull();

      default:
        developer.log(
          'QuerySpecCompiler: operador não suportado — ${cond.operator}',
          name: 'feedflow.query_spec_compiler',
          level: 900,
        );
        return const Constant<bool>(true);
    }
  }

  Expression<bool> _compileCompoundCondition(CompoundCondition cond) {
    if (cond.conditions.isEmpty) {
      return const Constant<bool>(true);
    }

    final compiled = cond.conditions.map(_compileCondition).toList();

    switch (cond.combinator) {
      case 'all':
        // AND lógico: combina com &
        return compiled.reduce((a, b) => a & b);

      case 'any':
        // OR lógico: combina com |
        return compiled.reduce((a, b) => a | b);

      case 'not':
        // NOT lógico: nega a primeira sub-condition
        return compiled.first.not();

      default:
        developer.log(
          'QuerySpecCompiler: combinador desconhecido — ${cond.combinator}',
          name: 'feedflow.query_spec_compiler',
          level: 900,
        );
        return const Constant<bool>(true);
    }
  }

  /// Retorna a coluna drift correspondente ao nome do campo, ou null
  /// se não for suportada.
  Expression<dynamic>? _getColumn(String field) {
    switch (field) {
      case 'status':
        return _db.workItems.status;
      case 'priority':
        return _db.workItems.priority;
      case 'tags': // Nota: tags_json é serializado; contains faz match no JSON
        return _db.workItems.tagsJson;
      case 'feedId':
        return _db.workItems.feedId;
      case 'providerId':
        return _db.workItems.providerId;
      case 'title':
        return _db.workItems.title;
      case 'author':
        return _db.workItems.author;
      case 'summary':
        return _db.workItems.summary;
      case 'content':
        return _db.workItems.content;
      case 'url':
        return _db.workItems.url;
      case 'isRead':
        return _db.workItems.isRead;
      case 'isStarred':
        return _db.workItems.isStarred;
      case 'isSnoozed':
        // isSnoozed é derivado (snoozedUntil != null && isFuture), simulamos como "snoozedUntil IS NOT NULL"
        return _db.workItems.snoozedUntil.isNotNull();
      case 'published':
        return _db.workItems.published;
      case 'updated':
        return _db.workItems.updated;
      case 'ingestedAt':
        return _db.workItems.ingestedAt;
      case 'updatedAt':
        return _db.workItems.updatedAt;
      default:
        return null;
    }
  }

  SelectStatement _applySortOrder(
    SelectStatement<dynamic, dynamic> query,
    String sortField,
    bool descending,
  ) {
    final term = _getSortTerm(sortField, descending);
    if (term == null) {
      return query;
    }
    return query..orderBy([term]);
  }

  OrderingTerm? _getSortTerm(String sortField, bool descending) {
    final col = _getColumn(sortField);
    if (col == null) {
      developer.log(
        'QuerySpecCompiler: campo de ordenação não suportado — $sortField',
        name: 'feedflow.query_spec_compiler',
        level: 900,
      );
      return null;
    }

    return descending
        ? OrderingTerm.desc(col as Expression<Comparable<dynamic>>)
        : OrderingTerm.asc(col as Expression<Comparable<dynamic>>);
  }

  /// Mapeia [WorkItemRow] para [WorkItem] (reaproveitando o padrão de
  /// [WorkItemRepositoryDrift]).
  WorkItem _workItemRowToDomain(WorkItemRow row) {
    return WorkItem(
      id: row.id,
      providerId: row.providerId,
      articleId: row.articleId,
      feedId: row.feedId,
      title: row.title,
      author: row.author,
      summary: row.summary,
      content: row.content,
      url: row.url,
      published: row.published,
      updated: row.updated,
      status: TriageStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => TriageStatus.novo,
      ),
      priority: Priority.values.firstWhere(
        (p) => p.name == row.priority,
        orElse: () => Priority.none,
      ),
      tags: (row.tagsJson.isNotEmpty)
          ? List<String>.from(jsonDecode(row.tagsJson) as List<dynamic>)
          : [],
      isRead: row.isRead,
      isStarred: row.isStarred,
      snoozedUntil: row.snoozedUntil,
      notes: row.notes,
      ingestedAt: row.ingestedAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }
}
