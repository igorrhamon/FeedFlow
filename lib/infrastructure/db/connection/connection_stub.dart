import 'package:drift/drift.dart';

/// Stub usado no build web: nunca deveria ser chamado de fato, já que
/// `DatabaseProvider` (ver `../database_provider.dart`) checa `kIsWeb` antes
/// de instanciar `AppDatabase` e devolve `null` em todos os getters nessa
/// plataforma. Existe apenas para que `database.dart` compile sem depender
/// de `package:drift/native.dart` (que puxa `dart:ffi`, indisponível no
/// dart2js).
QueryExecutor openConnection() {
  throw UnsupportedError('AppDatabase (drift/sqlite3) não é suportado na web nesta fase.');
}
