import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/search_repository_drift.dart';

void main() {
  group('SearchRepositoryDrift - FTS5 Full-Text Search', () {
    late AppDatabase db;
    late SearchRepositoryDrift searchRepo;

    setUp(() async {
      // Cria banco em memória para testes
      db = AppDatabase(NativeDatabase.memory());
      searchRepo = SearchRepositoryDrift(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('search() returns empty list for empty query', () async {
      final results = await searchRepo.search('');
      expect(results, isEmpty);
    });

    test('search() returns empty list when no items match', () async {
      // Insere um item
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Hello World',
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Busca por algo que não existe
      final results = await searchRepo.search('nonexistent');
      expect(results, isEmpty);
    });

    test('search() finds items by title', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Flutter Tips and Tricks',
              author: const Value('John Doe'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      final results = await searchRepo.search('Flutter');
      expect(results, hasLength(1));
      expect(results.first.title, 'Flutter Tips and Tricks');
    });

    test('search() finds items by author', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Some Article',
              author: const Value('Jane Smith'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      final results = await searchRepo.search('Jane');
      expect(results, hasLength(1));
      expect(results.first.author, 'Jane Smith');
    });

    test('search() finds items by content', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Blockchain Tutorial',
              content: const Value(
                  'Learn about distributed ledgers and cryptography in this comprehensive guide.'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      final results = await searchRepo.search('distributed');
      expect(results, hasLength(1));
      expect(results.first.content, contains('distributed'));
    });

    test('search() finds items with HTML content (not stripped yet)', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Article with HTML',
              content: const Value('<p>This is important content</p><br><p>More details here</p>'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // O FTS5 indexa o HTML como-está (TODO: stripar HTML em novos inserts via triggers)
      final results = await searchRepo.search('important');
      expect(results, hasLength(1));
    });

    test('search() finds items by an individual tag (via tags_plaintext column)', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Some article without the search term in its title',
              tagsJson: const Value('["urgent","work","followup"]'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Regressao: os triggers antigos gravavam o JSON bruto
      // ('["urgent","work","followup"]') na coluna tags_plaintext do FTS5,
      // entao uma busca pela tag isolada "urgent" nunca casava (o FTS5
      // tokeniza o texto, e o token literal com colchetes/aspas nao bate
      // com a palavra "urgent" pesquisada). Buscar apenas pela tag - sem
      // nenhuma palavra do titulo - prova que o trigger agora achata o JSON
      // em texto plano antes de indexar.
      final results = await searchRepo.search('urgent');
      expect(results, hasLength(1));
      expect(results.first.tags, contains('urgent'));
    });

    test('search() does not match on tag JSON punctuation/other tags', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Some article without the search term in its title',
              tagsJson: const Value('["urgent","work","followup"]'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Nao deve casar contra o JSON bruto (colchetes/aspas) nem contra uma
      // tag que nao esta presente no item.
      final noMatch = await searchRepo.search('personal');
      expect(noMatch, isEmpty);
    });

    test('search() handles accents and diacritics', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Programação em português',
              author: const Value('José Silva'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // FTS5 deve buscar por acentos
      var results = await searchRepo.search('Programação');
      expect(results, hasLength(1));

      results = await searchRepo.search('José');
      expect(results, hasLength(1));
    });

    test('search() respects limit parameter', () async {
      final now = DateTime.now();
      for (int i = 0; i < 10; i++) {
        await db.into(db.workItems).insert(
              WorkItemsCompanion.insert(
                id: 'test$i',
                providerId: 'local',
                articleId: 'article$i',
                feedId: 'feed1',
                title: 'Search Result $i',
                ingestedAt: now,
                updatedAt: now,
              ),
            );
      }

      final results = await searchRepo.search('Search', limit: 5);
      expect(results, hasLength(5));
    });

    test('INSERT trigger keeps FTS5 synchronized', () async {
      final now = DateTime.now();

      // Insere 3 itens
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Item One',
              ingestedAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test2',
              providerId: 'local',
              articleId: 'article2',
              feedId: 'feed1',
              title: 'Item Two',
              ingestedAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test3',
              providerId: 'local',
              articleId: 'article3',
              feedId: 'feed1',
              title: 'Item Three',
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Busca por todas
      var results = await searchRepo.search('Item');
      expect(results, hasLength(3));
    });

    test('UPDATE trigger keeps FTS5 synchronized', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Original Title',
              content: const Value('original content'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Atualiza o item
      await (db.update(db.workItems)..where((t) => t.id.equals('test1'))).write(
            WorkItemsCompanion(
              title: const Value('Updated Title'),
              content: const Value('updated content'),
              updatedAt: Value(now.add(const Duration(seconds: 1))),
            ),
          );

      // A busca anterior não deve mais encontrar
      var results = await searchRepo.search('Original');
      expect(results, isEmpty);

      // A busca pelo novo conteúdo deve funcionar
      results = await searchRepo.search('Updated');
      expect(results, hasLength(1));
      expect(results.first.title, 'Updated Title');
    });

    test('DELETE trigger keeps FTS5 synchronized', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Item to Delete',
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      // Confirma que a busca funciona
      var results = await searchRepo.search('Delete');
      expect(results, hasLength(1));

      // Deleta o item
      await (db.delete(db.workItems)..where((t) => t.id.equals('test1'))).go();

      // A busca não deve mais encontrar
      results = await searchRepo.search('Delete');
      expect(results, isEmpty);
    });

    test('search() returns WorkItems with correct status field', () async {
      final now = DateTime.now();
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Searchable Item',
              status: const Value('triado'),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      final results = await searchRepo.search('Searchable');
      expect(results, hasLength(1));
      expect(results.first.status, TriageStatus.triado);
    });

    test('search() returns WorkItems with tags correctly deserialized', () async {
      final now = DateTime.now();
      const tags = '["work","urgent","followup"]';
      await db.into(db.workItems).insert(
            WorkItemsCompanion.insert(
              id: 'test1',
              providerId: 'local',
              articleId: 'article1',
              feedId: 'feed1',
              title: 'Tagged Item',
              tagsJson: const Value(tags),
              ingestedAt: now,
              updatedAt: now,
            ),
          );

      final results = await searchRepo.search('Tagged');
      expect(results, hasLength(1));
      expect(results.first.tags, ['work', 'urgent', 'followup']);
    });
  });
}
