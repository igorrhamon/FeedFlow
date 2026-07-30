import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/application/job_registry.dart';
import 'package:feedflow/domain/job_handler.dart';
import 'package:feedflow/domain/job.dart';

void main() {
  group('JobRegistry', () {
    setUp(() {
      JobRegistry.clear();
    });

    test('register and get a handler', () {
      final handler = _TestJobHandler('test-job');
      JobRegistry.register('test-job', () => handler);

      final retrieved = JobRegistry.get('test-job');

      expect(retrieved, isNotNull);
      expect(retrieved!.jobType, equals('test-job'));
    });

    test('get returns null for unregistered handler', () {
      final retrieved = JobRegistry.get('nonexistent');
      expect(retrieved, isNull);
    });

    test('isRegistered returns true for registered handlers', () {
      JobRegistry.register('test-job', () => _TestJobHandler('test-job'));

      expect(JobRegistry.isRegistered('test-job'), isTrue);
      expect(JobRegistry.isRegistered('nonexistent'), isFalse);
    });

    test('getAvailable returns all registered job types', () {
      JobRegistry.register('sync', () => _TestJobHandler('sync'));
      JobRegistry.register('enrich', () => _TestJobHandler('enrich'));
      JobRegistry.register('export', () => _TestJobHandler('export'));

      final available = JobRegistry.getAvailable();

      expect(available, hasLength(3));
      expect(available.toSet(), equals({'sync', 'enrich', 'export'}));
    });

    test('getAvailable returns empty list when no handlers registered', () {
      final available = JobRegistry.getAvailable();
      expect(available, isEmpty);
    });

    test('clear removes all registered handlers', () {
      JobRegistry.register('sync', () => _TestJobHandler('sync'));
      JobRegistry.register('enrich', () => _TestJobHandler('enrich'));

      JobRegistry.clear();

      expect(JobRegistry.getAvailable(), isEmpty);
      expect(JobRegistry.get('sync'), isNull);
    });

    test('factory is called each time get is called', () {
      int callCount = 0;
      JobRegistry.register('test-job', () {
        callCount++;
        return _TestJobHandler('test-job');
      });

      JobRegistry.get('test-job');
      JobRegistry.get('test-job');
      JobRegistry.get('test-job');

      expect(callCount, equals(3));
    });
  });
}

class _TestJobHandler implements JobHandler {
  _TestJobHandler(this._jobType);

  final String _jobType;

  @override
  String get jobType => _jobType;

  @override
  Future<void> run(Job job) async {}
}
