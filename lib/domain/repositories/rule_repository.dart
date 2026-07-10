import '../rule.dart';

/// Porta de persistência local das [Rule]s. Implementações vivem em
/// `lib/infrastructure/repositories/`; nada em `lib/domain` ou
/// `lib/application` deve depender de drift/SQL diretamente.
abstract class RuleRepository {
  /// Obtém uma regra pelo ID.
  Future<Rule?> byId(String id);

  /// Cria uma regra nova.
  Future<void> create(Rule rule);

  /// Atualiza uma regra existente.
  Future<void> update(Rule rule);

  /// Remove uma regra.
  Future<void> delete(String id);

  /// Lista todas as regras, ordenadas por [Rule.order].
  Future<List<Rule>> list();

  /// Stream reativo de apenas regras habilitadas, ordenadas por [Rule.order].
  /// Usado pelo [RuleEngine] para se inscrever em mudanças de regras em tempo real.
  Stream<List<Rule>> watchEnabled();

  /// Remove todas as regras. Útil em testes.
  Future<void> clear();

  Future<void> close();
}
