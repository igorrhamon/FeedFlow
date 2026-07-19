import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Conexão sqlite3 nativa (Android/iOS/desktop), via FFI. Só é importado
/// quando `dart.library.io` está disponível — nunca no build web, onde
/// `dart:ffi` (puxado transitivamente por `package:drift/native.dart`) não
/// existe e quebraria a compilação com dart2js.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'feedflow_workitems.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
