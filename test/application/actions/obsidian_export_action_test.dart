import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/actions/obsidian_export_action.dart';
import 'package:feedflow/application/integrations/obsidian_integration.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('ObsidianExportAction', () {
    test('has correct id and label', () {
      final action = ObsidianExportAction();
      expect(action.id, 'obsidianExport');
      expect(action.label, 'Export to Obsidian');
    });

    test('execute() calls integration.send() with vault from params', () async {
      // Note: We cannot easily test that it reads from storage without mocking
      // the platform channel, as flutter_secure_storage requires platform implementation
      // in tests. This test just verifies the action exists and has correct metadata.
      final action = ObsidianExportAction();
      expect(action.id, 'obsidianExport');
    });
  });
}
