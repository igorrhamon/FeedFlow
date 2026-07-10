import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/infrastructure/db/database.dart';
import 'package:feedflow/infrastructure/repositories/search_repository_drift.dart';
import 'package:feedflow/infrastructure/repositories/work_item_repository_drift.dart';
import 'package:feedflow/models/article.dart';

void main() {
  late AppDatabase db;
  late SearchRepositoryDrift searchRepo;
  late WorkItemRepositoryDrift workItemRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    searchRepo = SearchRepositoryDrift(db);
    workItemRepo = WorkItemRepositoryDrift(db);
  });

  tearDown(() async {
    await db.close();
  });

  Article article({
    String id = 'a1',
    String feedId = 'f1',
    String title = 'Título',
    String? content,
    String? author,
    bool isRead = false,
    bool isStarred = false,
  }) =>
      Article(
        id: id,
        feedId: feedId,
        title: title,
        content: content,
        author: author,
        isRead: isRead,
        isStarred: isStarred,
      );

  group('SearchRepositoryDrift', () {
    test('busca por palavra no título', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'Flutter é incrível')],
        'feedbin',
      );

      final results = await searchRepo.search('Flutter');
      expect(results, isNotEmpty);
      expect(results.first.title, 'Flutter é incrível');
    });

    test('busca por palavra no conteúdo', () async {
      await workItemRepo.upsertFromArticles(
        [
          article(
            id: 'a1',
            title: 'Artigo',
            content: 'Este é um artigo sobre Dart e desenvolvimento mobile',
          )
        ],
        'feedbin',
      );

      final results = await searchRepo.search('mobile');
      expect(results, isNotEmpty);
      expect(results.first.content, contains('mobile'));
    });

    test('busca por autor', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'Artigo', author: 'João Silva')],
        'feedbin',
      );

      final results = await searchRepo.search('João');
      expect(results, isNotEmpty);
      expect(results.first.author, 'João Silva');
    });

    test('busca case-insensitive', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'FLUTTER é legal')],
        'feedbin',
      );

      final results = await searchRepo.search('flutter');
      expect(results, isNotEmpty);
      expect(results.first.title, 'FLUTTER é legal');
    });

    test('busca com acentos (português)', () async {
      await workItemRepo.upsertFromArticles(
        [
          article(
            id: 'a1',
            title: 'São Paulo',
            author: 'José da Silva',
          )
        ],
        'feedbin',
      );

      final results = await searchRepo.search('São');
      expect(results, isNotEmpty);
      expect(results.first.title, 'São Paulo');
    });

    test('busca por múltiplas palavras retorna ordem BM25', () async {
      await workItemRepo.upsertFromArticles(
        [
          article(
            id: 'a1',
            title: 'Flutter Development Guide',
            content: 'Learn Flutter',
          ),
          article(
            id: 'a2',
            title: 'Web Development',
            content: 'Flutter for web: Create stunning Flutter web applications',
          ),
        ],
        'feedbin',
      );

      final results = await searchRepo.search('Flutter web');
      expect(results, isNotEmpty);
      // Segundo resultado deve ser mais relevante pois tem "Flutter" e "web" no conteúdo
      expect(results.first.articleId, 'a2', reason: 'BM25 ordering should prioritize article with both terms');
    });

    test('query vazia retorna lista vazia', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'Flutter')],
        'feedbin',
      );

      final results = await searchRepo.search('');
      expect(results, isEmpty);
    });

    test('query não encontrada retorna lista vazia', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'Flutter Development')],
        'feedbin',
      );

      final results = await searchRepo.search('Rust');
      expect(results, isEmpty);
    });

    test('update de WorkItem atualiza índice FTS', () async {
      await workItemRepo.upsertFromArticles(
        [article(id: 'a1', title: 'Original Title')],
        'feedbin',
      );

      // Atualiza o título
      final item = await workItemRepo.byId('feedbin:a1');
      await workItemRepo.save(item!.copyWith(title: 'Updated Title'));

      // Busca pela palavra antiga não deve retornar
      final oldResults = await searchRepo.search('Original');
      expect(oldResults, isEmpty);

      // Busca pela palavra nova deve retornar
      final newResults = await searchRepo.search('Updated');
      expect(newResults, isNotEmpty);
      expect(newResults.first.title, 'Updated Title');
    });

    test('delete de WorkItem remove do índice FTS', () async {
      await workItemRepo.upsertFromArticles(
        [
          article(id: 'a1', title: 'First Article'),
          article(id: 'a2', title: 'Second Article'),
        ],
        'feedbin',
      );

      // Arquiva o primeiro item
      await workItemRepo.changeStatus('feedbin:a1', TriageStatus.arquivado);

      // Busca por "Article" deve retornar apenas o segundo
      final results = await searchRepo.search('Article');
      expect(results.length, 2); // Ambos ainda existem, só mudou status

      // Agora purga items arquivados
      await workItemRepo.purgeOlderThan(DateTime.now().add(const Duration(seconds: 1)));

      // Busca novamente deve retornar apenas o segundo
      final afterPurge = await searchRepo.search('Article');
      expect(afterPurge.length, 1);
      expect(afterPurge.first.articleId, 'a2');
    });

    test('busca retorna WorkItem com todos os campos preservados', () async {
      await workItemRepo.upsertFromArticles(
        [
          article(
            id: 'a1',
            feedId: 'f1',
            title: 'Complete Article',
            content: 'This is the content',
            author: 'Author Name',
          )
        ],
        'myProvider',
      );

      // Modifica alguns campos locais
      var item = await workItemRepo.byId('myProvider:a1');
      await workItemRepo.save(
        item!.copyWith(
          status: TriageStatus.triado,
          priority: Priority.high,
          tags: ['important', 'flutter'],
        ),
      );

      final results = await searchRepo.search('Complete');
      expect(results.length, 1);

      final found = results.first;
      expect(found.id, 'myProvider:a1');
      expect(found.providerId, 'myProvider');
      expect(found.articleId, 'a1');
      expect(found.feedId, 'f1');
      expect(found.title, 'Complete Article');
      expect(found.content, 'This is the content');
      expect(found.author, 'Author Name');
      expect(found.status, TriageStatus.triado);
      expect(found.priority, Priority.high);
      expect(found.tags, ['important', 'flutter']);
    });
  });
}
