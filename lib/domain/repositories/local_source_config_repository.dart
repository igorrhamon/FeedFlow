import 'package:feedflow/domain/local_source_config.dart';

/// Repositório abstrato de configurações de fontes locais (Onda 9).
/// Persiste e recupera as preferências do usuário sobre quais pastas/arquivos ingerir.
abstract class LocalSourceConfigRepository {
  /// Persiste uma nova configuração de fonte ou atualiza uma existente.
  Future<void> save(LocalSourceConfig config);

  /// Recupera uma configuração de fonte pelo ID.
  Future<LocalSourceConfig?> byId(String id);

  /// Observa todas as configurações de fonte cadastradas.
  /// Emite a lista atual e reatualiza sempre que há mudança.
  Stream<List<LocalSourceConfig>> watchAll();

  /// Remove uma configuração de fonte pelo ID.
  Future<void> delete(String id);

  /// Atualiza o timestamp da última sincronização bem-sucedida.
  Future<void> updateLastSync(String id, DateTime syncedAt);

  /// Fecha recursos associados ao repositório.
  Future<void> close();
}
