import '../domain/local_source_config.dart';
import '../domain/source_connector.dart';

/// Registry de [SourceConnector]s disponíveis — mirror de [ProviderRegistry].
/// Permite que a aplicação descubra e instancie conectores por id sem conhecer
/// suas implementações concretas.
///
/// Registrado por **tipo** de fonte (ex.: `'folder'`, `'markdown-vault'`,
/// `'pdf'`, `'office'`), não por instância — a factory recebe o
/// [LocalSourceConfig] específico (caminho, label, etc.) escolhido pelo
/// usuário e constrói o conector correspondente (Onda 9).
class SourceConnectorRegistry {
  SourceConnectorRegistry._();

  static final Map<String, SourceConnector Function(LocalSourceConfig)> _connectors = {};

  /// Registra um novo conector, identificado por [id] (tipo de fonte).
  static void register(String id, SourceConnector Function(LocalSourceConfig) factory) {
    _connectors[id] = factory;
  }

  /// Cria uma instância do conector com o [id] fornecido, configurada com
  /// [config]. Retorna `null` se o conector não estiver registrado.
  static SourceConnector? create(String id, LocalSourceConfig config) {
    final factory = _connectors[id];
    if (factory == null) return null;
    return factory(config);
  }

  /// Retorna todos os conectores disponíveis.
  static Map<String, SourceConnector Function(LocalSourceConfig)> getAvailable() =>
      Map.from(_connectors);

  /// Limpa o registry (principalmente para testes).
  static void clear() => _connectors.clear();
}
