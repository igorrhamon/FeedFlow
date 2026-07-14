import '../domain/events/domain_event.dart';

/// Bus de eventos de domínio — síncrono, simples, sem dependências externas.
/// Qualquer componente pode assinar eventos e reagir a mudanças de domínio
/// (ex.: RuleEngine, Enricher, logging, telemetria).
///
/// **Nota de design**: é síncrono por intenção — regras são avaliadas
/// imediatamente após eventos, sem assincronicidade implícita que pudesse
/// deixar o estado inconsistente. Se um listener falhar, a exceção propaga
/// (comportamento esperado: bugs devem estourar cedo).
class EventBus {
  final List<void Function(DomainEvent)> _listeners = [];

  /// Inscreve um listener para todos os eventos. Callbacks síncronos.
  void subscribe(void Function(DomainEvent) listener) {
    _listeners.add(listener);
  }

  /// Remove um listener.
  void unsubscribe(void Function(DomainEvent) listener) {
    _listeners.remove(listener);
  }

  /// Publica um evento para todos os listeners inscritos. Execução é síncrona
  /// e sequencial — exceções em listeners propagam para o chamador.
  void publish(DomainEvent event) {
    for (final listener in _listeners.toList()) {
      listener(event);
    }
  }

  /// Limpa todos os listeners. Útil em testes.
  void clear() {
    _listeners.clear();
  }
}

/// Instância padrão usada pela app em produção (`DatabaseProvider`, etc.).
/// Testes devem criar sua própria `EventBus()` para isolar assinantes.
final eventBus = EventBus();
