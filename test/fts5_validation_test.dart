import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Teste de validação rápida: confirma que sqlite3_flutter_libs foi compilado
/// com FTS5 (e JSON1) habilitados. Estes são os riscos técnicos reais da
/// WS-17: FTS5 para a tabela virtual, JSON1 (json_each) para achatar o JSON
/// de tags em texto plano dentro dos triggers SQL.
///
/// Usa `package:sqlite3` diretamente (em vez do `QueryExecutor` do drift)
/// para evitar o ciclo de vida de abertura/`ensureOpen()` do drift — aqui só
/// queremos validar a biblioteca nativa subjacente.
void main() {
  test('FTS5 module is available in sqlite3_flutter_libs', () {
    final db = sqlite3.openInMemory();

    // Tenta criar uma tabela virtual FTS5
    db.execute('CREATE VIRTUAL TABLE test_fts USING fts5(x)');

    // Se chegou aqui sem lançar exceção, FTS5 está disponível
    db.execute('DROP TABLE test_fts');
    db.dispose();
  });

  test('FTS5 MATCH query works', () {
    final db = sqlite3.openInMemory();

    // Cria tabela FTS5 e insere dados de teste
    db.execute('CREATE VIRTUAL TABLE test_fts USING fts5(title, content)');
    db.execute('INSERT INTO test_fts VALUES (?, ?)', ['Test Article', 'Hello world']);
    db.execute('INSERT INTO test_fts VALUES (?, ?)', ['Another', 'Goodbye world']);

    // Testa busca simples
    final results = db.select(
      'SELECT * FROM test_fts WHERE test_fts MATCH ?',
      ['hello'],
    );

    expect(results, hasLength(1));
    expect(results.first['title'], 'Test Article');

    db.execute('DROP TABLE test_fts');
    db.dispose();
  });

  test('JSON1 json_each is available (necessario para achatar tags_json nos triggers)', () {
    final db = sqlite3.openInMemory();

    final rows = db.select(
      "SELECT COALESCE(GROUP_CONCAT(je.value, ' '), '') AS txt "
      "FROM json_each('[\"a\",\"b\",\"c\"]') je",
    );

    expect(rows.first['txt'], 'a b c');

    db.dispose();
  });
}
