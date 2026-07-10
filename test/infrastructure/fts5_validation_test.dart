import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FTS5 Validation', () {
    test('FTS5 virtual table can be created and queried', () async {
      final db = NativeDatabase.memory();

      try {
        // Tenta criar uma tabela virtual FTS5
        await db.customStatement(
          'CREATE VIRTUAL TABLE test_fts USING fts5(title, content, author)',
        );

        // Insere dados de teste
        await db.customStatement(
          "INSERT INTO test_fts(title, content, author) VALUES(?, ?, ?)",
          ['Flutter é ótimo', 'Este é um artigo sobre Flutter', 'João'],
        );

        // Faz uma busca simples
        final result = await db.select(
          'SELECT * FROM test_fts WHERE test_fts MATCH ?',
          ['Flutter'],
        );

        expect(result, isNotEmpty, reason: 'FTS5 query should return results');
        expect(result.first['title'], 'Flutter é ótimo');

        // Testa com BM25 ranking
        final rankedResult = await db.select(
          'SELECT *, bm25(test_fts) as rank FROM test_fts WHERE test_fts MATCH ? ORDER BY rank',
          ['Flutter'],
        );

        expect(rankedResult, isNotEmpty, reason: 'BM25 ranking should work');

        print('✓ FTS5 validation passed: virtual table created, inserted, and queried successfully');
      } catch (e, st) {
        fail('FTS5 failed: $e\n$st');
      } finally {
        await db.close();
      }
    });

    test('FTS5 with accent characters (Portuguese)', () async {
      final db = NativeDatabase.memory();

      try {
        await db.customStatement(
          'CREATE VIRTUAL TABLE test_accents USING fts5(title, content)',
        );

        await db.customStatement(
          "INSERT INTO test_accents(title, content) VALUES(?, ?)",
          ['Artigo com acentuação', 'São Paulo é uma cidade incrível'],
        );

        // Busca por acentos
        final result = await db.select(
          'SELECT * FROM test_accents WHERE test_accents MATCH ?',
          ['São'],
        );

        expect(result, isNotEmpty, reason: 'FTS5 should handle Portuguese accents');

        print('✓ FTS5 accent test passed');
      } catch (e, st) {
        fail('FTS5 accent test failed: $e\n$st');
      } finally {
        await db.close();
      }
    });
  });
}
