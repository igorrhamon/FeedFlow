import 'package:drift/drift.dart';
import 'package:feedflow/domain/local_source_config.dart';
import 'package:feedflow/domain/repositories/local_source_config_repository.dart';
import 'package:feedflow/infrastructure/db/database.dart';

/// Implementação drift do repositório de configurações de fontes locais.
class LocalSourceConfigRepositoryDrift implements LocalSourceConfigRepository {
  final AppDatabase _database;

  LocalSourceConfigRepositoryDrift(this._database);

  @override
  Future<void> save(LocalSourceConfig config) async {
    await _database.into(_database.localSourceConfigs).insertOnConflictUpdate(
          LocalSourceConfigsCompanion(
            id: Value(config.id),
            type: Value(_encodeType(config.type)),
            path: Value(config.path),
            label: Value(config.label),
            enabled: Value(config.enabled),
            lastSyncAt: Value(config.lastSyncAt),
            createdAt: Value(config.createdAt),
          ),
        );
  }

  @override
  Future<LocalSourceConfig?> byId(String id) async {
    final row = await (_database.select(_database.localSourceConfigs)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (row == null) return null;

    return _rowToModel(row);
  }

  @override
  Stream<List<LocalSourceConfig>> watchAll() {
    return (_database.select(_database.localSourceConfigs))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(_database.localSourceConfigs)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> updateLastSync(String id, DateTime syncedAt) async {
    await (_database.update(_database.localSourceConfigs)
          ..where((t) => t.id.equals(id)))
        .write(LocalSourceConfigsCompanion(lastSyncAt: Value(syncedAt)));
  }

  @override
  Future<void> close() async {
    // Drift gerencia o ciclo de vida do banco — não fechamos aqui.
  }

  /// Converte LocalSourceType enum para string para armazenamento.
  static String _encodeType(LocalSourceType type) {
    return type.toString().split('.').last;
  }

  /// Converte string de armazenamento de volta para LocalSourceType enum.
  static LocalSourceType _decodeType(String typeStr) {
    return LocalSourceType.values.firstWhere(
      (t) => t.toString().split('.').last == typeStr,
      orElse: () => LocalSourceType.folder,
    );
  }

  /// Converte uma linha do banco em LocalSourceConfig de domínio.
  LocalSourceConfig _rowToModel(LocalSourceConfigRow row) {
    return LocalSourceConfig(
      id: row.id,
      type: _decodeType(row.type),
      path: row.path,
      label: row.label,
      enabled: row.enabled,
      lastSyncAt: row.lastSyncAt,
      createdAt: row.createdAt,
    );
  }
}
