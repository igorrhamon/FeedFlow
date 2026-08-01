import '../domain/source_connector.dart';

/// Registry de [SourceConnector]s disponíveis — mirror de [ProviderRegistry].
/// Permite que a aplicação descubra e instancie conectores por id sem conhecer
/// suas implementações concretas.
class SourceConnectorRegistry {
  SourceConnectorRegistry._();

  static final Map<String, SourceConnector Function()> _connectors = {};

  /// Registra um novo conector.
  static void register(String id, SourceConnector Function() factory) {
    _connectors[id] = factory;
  }

  /// Cria uma instância do conector com o [id] fornecido.
  /// Retorna `null` se o conector não estiver registrado.
  static SourceConnector? create(String id) {
    final factory = _connectors[id];
    if (factory == null) return null;
    return factory();
  }

  /// Retorna todos os conectores disponíveis.
  static Map<String, SourceConnector Function()> getAvailable() => Map.from(_connectors);

  /// Limpa o registry (principalmente para testes).
  static void clear() => _connectors.clear();
}
