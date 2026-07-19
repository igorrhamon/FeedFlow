import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/llm_provider_id.dart';
import 'package:feedflow/pages/llm_settings_page.dart';

void main() {
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageValues = <String, String>{};

  setUp(() {
    secureStorageValues.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final args = (call.arguments as Map).cast<String, dynamic>();
      switch (call.method) {
        case 'read':
          return secureStorageValues[args['key']];
        case 'write':
          secureStorageValues[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          secureStorageValues.remove(args['key']);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LlmSettingsPage()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows anthropic as default active provider', (tester) async {
    await pumpPage(tester);

    expect(find.text('Anthropic Claude'), findsOneWidget);
    expect(
        find.text('Nenhuma chave configurada para este provedor'), findsOneWidget);
  });

  testWidgets('typing an API key and saving persists it and shows a snackbar',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'sk-test-123');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Configuração de IA salva.'), findsOneWidget);
    expect(secureStorageValues['llm_anthropic_api_key'], 'sk-test-123');
    expect(secureStorageValues['active_llm_provider'], 'llm-anthropic');
  });

  testWidgets('switching provider in the dropdown persists the new active provider',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(DropdownButtonFormField<LlmProviderId>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OpenRouter').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'or-test-key');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(secureStorageValues['llm_openrouter_api_key'], 'or-test-key');
    expect(secureStorageValues['active_llm_provider'], 'llm-openrouter');
  });

  testWidgets(
      'switching provider after a key was saved for another provider shows no existing key hint',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'sk-test-123');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<LlmProviderId>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google AI Studio (Gemini)').last);
    await tester.pumpAndSettle();

    expect(
        find.text('Nenhuma chave configurada para este provedor'), findsOneWidget);
  });
}
