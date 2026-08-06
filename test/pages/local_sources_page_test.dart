import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/domain/repositories/local_source_config_repository.dart';
import 'package:feedflow/pages/local_sources_page.dart';

/// Fake em memória de [LocalSourceConfigRepository], seguindo o mesmo
/// padrão de injeção via construtor usado em `rule_editor_page_test.dart`
/// (RuleRepository/WorkItemRepository reais em SQLite in-memory; aqui, como
/// não há necessidade de exercitar SQL, um fake simples basta).
class _FakeLocalSourceConfigRepository implements LocalSourceConfigRepository {
  final Map<String, LocalSourceConfig> _store = {};
  final _controller = StreamController<List<LocalSourceConfig>>.broadcast();

  void _emit() => _controller.add(_store.values.toList());

  @override
  Future<void> save(LocalSourceConfig config) async {
    _store[config.id] = config;
    _emit();
  }

  @override
  Future<LocalSourceConfig?> byId(String id) async => _store[id];

  @override
  Stream<List<LocalSourceConfig>> watchAll() {
    // Emite o estado atual assim que alguém escuta.
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
    _emit();
  }

  @override
  Future<void> updateLastSync(String id, DateTime syncedAt) async {
    final existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(lastSyncAt: syncedAt);
      _emit();
    }
  }

  @override
  Future<void> close() async {
    await _controller.close();
  }
}

void main() {
  late _FakeLocalSourceConfigRepository repository;

  setUp(() {
    repository = _FakeLocalSourceConfigRepository();
  });

  tearDown(() async {
    await repository.close();
  });

  Widget buildPage() => MaterialApp(
        home: LocalSourcesPage(repository: repository),
      );

  group('LocalSourcesPage', () {
    testWidgets('renders empty state when no sources configured', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Fontes locais'), findsOneWidget);
      expect(find.text('Nenhuma fonte local configurada.'), findsOneWidget);
    });

    testWidgets('tapping + opens type-selection bottom sheet', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // A folha de tipo deve exibir as 4 opções, sem precisar acionar o
      // file_picker de verdade (esse é baseado em platform channel e não
      // é exercitado aqui — ver nota de limitação abaixo).
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Vault Markdown'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
    });

    testWidgets('renders a Card for an existing source config', (tester) async {
      await repository.save(
        LocalSourceConfig(
          id: 's1',
          type: LocalSourceType.folder,
          path: '/home/user/notas',
          label: 'Minhas notas',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Minhas notas'), findsOneWidget);
      expect(find.text('/home/user/notas'), findsOneWidget);
      expect(find.textContaining('Nunca'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsWidgets);
    });
  });

  // NOTA / limitação documentada: o fluxo real de seleção via
  // `package:file_picker` (getDirectoryPath/pickFiles) usa platform
  // channels nativos e não é exercitado nestes testes de widget — cobrimos
  // apenas a UI de seleção de tipo que precede a chamada ao picker.
}
