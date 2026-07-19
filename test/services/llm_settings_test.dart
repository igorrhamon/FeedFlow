import 'package:feedflow/domain/llm_provider_id.dart';
import 'package:feedflow/services/llm_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('LlmSettings', () {
    test('getActiveProvider defaults to anthropic when never configured',
        () async {
      final active = await LlmSettings.getActiveProvider();
      expect(active, LlmProviderId.anthropic);
    });

    test('setActiveProvider/getActiveProvider round-trip', () async {
      await LlmSettings.setActiveProvider(LlmProviderId.openRouter);
      expect(await LlmSettings.getActiveProvider(), LlmProviderId.openRouter);

      await LlmSettings.setActiveProvider(LlmProviderId.googleAiStudio);
      expect(
          await LlmSettings.getActiveProvider(), LlmProviderId.googleAiStudio);
    });
  });
}
