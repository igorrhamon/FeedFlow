import '../domain/article_action.dart';

/// Registro factory-based de todas as ações disponíveis no sistema.
/// Inspirado em [ProviderRegistry], permite que diferentes componentes
/// consultem, criem e litem ações por ID sem acoplamento direto.
///
/// Uso típico:
/// ```dart
/// // Registrar (feito uma única vez em initializeActions())
/// ActionRegistry.register('complete', () => CompleteAction(...));
///
/// // Consultar em tempo de execução (ex: RuleEngine, WorkflowRunner)
/// final action = ActionRegistry.get('complete');
/// if (action != null) await action.execute(item, params);
///
/// // Listar todas as ações disponíveis
/// final all = ActionRegistry.getAvailable();
/// ```
class ActionRegistry {
  ActionRegistry._();

  static final Map<String, ArticleAction Function()> _factories = {};

  /// Registra uma ação com sua factory (construtora).
  /// Chamado por [initializeActions] durante boot.
  static void register(String actionId, ArticleAction Function() factory) {
    _factories[actionId] = factory;
  }

  /// Retorna a ação com [actionId], ou `null` se não registrada.
  static ArticleAction? get(String actionId) {
    return _factories[actionId]?.call();
  }

  /// Lista de todas as ações registradas, instanciadas. Útil para UIs
  /// que exibem ações disponíveis.
  static List<ArticleAction> getAvailable() {
    return _factories.values.map((factory) => factory()).toList();
  }

  /// Verificação simples: se uma ação está registrada.
  static bool isRegistered(String actionId) {
    return _factories.containsKey(actionId);
  }

  /// Limpa todos os registros. Útil em testes.
  static void clear() {
    _factories.clear();
  }
}
