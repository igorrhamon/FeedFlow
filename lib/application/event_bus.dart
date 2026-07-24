import 'dart:async';
import 'dart:developer' as developer;

import '../domain/events/domain_event.dart';

/// Assinatura de um listener do [EventBus]. Pode ser síncrono ou assíncrono —
/// `publish` aguarda o retorno de qualquer um dos dois casos.
typedef DomainEventListener = FutureOr<void> Function(DomainEvent event);

/// Bus de eventos de domínio — assíncrono e aguardável (Onda 5 / WS-18).
///
/// **Nota de design**: antes desta onda o bus era síncrono e o único
/// subscriber (`RuleEngine`) usava `async void`, o que fazia `publish`
/// retornar antes das ações da regra terminarem e engolia exceções. Agora
/// `publish` aguarda cada listener em sequência; uma exceção de um listener é
/// capturada e logada (não propaga e não interrompe os demais listeners) —
/// um bug num listener não deve travar os outros nem o chamador de
/// `publish`.
class EventBus {
  final List<DomainEventListener> _listeners = [];

  /// Inscreve um listener para todos os eventos.
  void subscribe(DomainEventListener listener) {
    _listeners.add(listener);
  }

  /// Remove um listener.
  void unsubscribe(DomainEventListener listener) {
    _listeners.remove(listener);
  }

  /// Publica um evento para todos os listeners inscritos, aguardando cada um
  /// em sequência. Exceções de um listener são capturadas e logadas, sem
  /// interromper os demais listeners nem propagar ao chamador.
  Future<void> publish(DomainEvent event) async {
    for (final listener in _listeners.toList()) {
      try {
        await listener(event);
      } catch (e, stackTrace) {
        developer.log(
          'EventBus: listener falhou ao processar $event',
          name: 'feedflow.event_bus',
          error: e,
          stackTrace: stackTrace,
        );
      }
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
