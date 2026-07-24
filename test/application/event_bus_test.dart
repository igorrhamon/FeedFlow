import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/event_bus.dart';
import 'package:feedflow/domain/events/domain_event.dart';

void main() {
  late EventBus bus;

  setUp(() {
    bus = EventBus(); // Instância separada para testes, não usa singleton
  });

  DomainEvent event({String workItemId = 'w1'}) =>
      SnoozeExpired(workItemId: workItemId, timestamp: DateTime.now());

  group('EventBus.publish', () {
    test('aguarda um listener assíncrono antes de retornar', () async {
      var counter = 0;

      bus.subscribe((e) async {
        await Future.delayed(const Duration(milliseconds: 20));
        counter++;
      });

      await bus.publish(event());

      expect(counter, 1);
    });

    test('chama múltiplos listeners em sequência na ordem de subscribe', () async {
      final order = <int>[];

      bus.subscribe((e) async {
        await Future.delayed(const Duration(milliseconds: 20));
        order.add(1);
      });
      bus.subscribe((e) {
        order.add(2);
      });
      bus.subscribe((e) async {
        await Future.delayed(const Duration(milliseconds: 5));
        order.add(3);
      });

      await bus.publish(event());

      expect(order, [1, 2, 3]);
    });

    test('exceção de um listener não impede os demais nem propaga', () async {
      var secondCalled = false;

      bus.subscribe((e) {
        throw Exception('falha proposital no primeiro listener');
      });
      bus.subscribe((e) {
        secondCalled = true;
      });

      await bus.publish(event());

      expect(secondCalled, isTrue);
    });
  });

  group('EventBus.unsubscribe', () {
    test('remove o listener, que não é mais chamado após', () async {
      var callCount = 0;
      void listener(DomainEvent e) => callCount++;

      bus.subscribe(listener);
      await bus.publish(event());
      expect(callCount, 1);

      bus.unsubscribe(listener);
      await bus.publish(event());

      expect(callCount, 1); // Não incrementou de novo
    });
  });

  group('EventBus.clear', () {
    test('remove todos os listeners', () async {
      var callCount1 = 0;
      var callCount2 = 0;

      bus.subscribe((e) => callCount1++);
      bus.subscribe((e) => callCount2++);

      bus.clear();
      await bus.publish(event());

      expect(callCount1, 0);
      expect(callCount2, 0);
    });
  });
}
