import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/domain/work_item.dart';
import 'package:feedflow/domain/triage_status.dart';
import 'package:feedflow/models/article.dart';

void main() {
  group('workItemIdFor', () {
    test('combina providerId e articleId', () {
      expect(workItemIdFor('feedbin', '123'), 'feedbin:123');
    });
  });

  group('WorkItem.fromArticle', () {
    test('cria WorkItem novo com status novo e campos do snapshot', () {
      final article = Article(
        id: 'a1',
        feedId: 'f1',
        title: 'Título',
        author: 'Autor',
        summary: 'Resumo',
        content: 'Conteúdo',
        url: 'https://example.com',
        isRead: true,
        isStarred: true,
      );

      final item = WorkItem.fromArticle(article, 'feedbin');

      expect(item.id, 'feedbin:a1');
      expect(item.providerId, 'feedbin');
      expect(item.articleId, 'a1');
      expect(item.feedId, 'f1');
      expect(item.title, 'Título');
      expect(item.status, TriageStatus.novo);
      expect(item.priority, Priority.none);
      expect(item.tags, isEmpty);
      expect(item.isRead, true);
      expect(item.isStarred, true);
      expect(item.isActive, true);
      expect(item.isSnoozed, false);
    });
  });

  group('isValidTriageTransition', () {
    test('permite novo -> triado', () {
      expect(isValidTriageTransition(TriageStatus.novo, TriageStatus.triado), true);
    });

    test('permite pular etapas: novo -> arquivado', () {
      expect(isValidTriageTransition(TriageStatus.novo, TriageStatus.arquivado), true);
    });

    test('permite transição para o mesmo estado', () {
      expect(isValidTriageTransition(TriageStatus.triado, TriageStatus.triado), true);
    });

    test('concluido -> triado é inválida (não está no mapa)', () {
      expect(isValidTriageTransition(TriageStatus.concluido, TriageStatus.triado), false);
    });

    test('arquivado -> concluido é inválida', () {
      expect(isValidTriageTransition(TriageStatus.arquivado, TriageStatus.concluido), false);
    });
  });

  group('WorkItem.isActive / isSnoozed', () {
    test('concluido não é ativo', () {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'x',
        providerId: 'p',
        articleId: 'a',
        feedId: 'f',
        title: 't',
        status: TriageStatus.concluido,
        ingestedAt: now,
        updatedAt: now,
      );
      expect(item.isActive, false);
    });

    test('snoozedUntil no futuro marca isSnoozed true', () {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'x',
        providerId: 'p',
        articleId: 'a',
        feedId: 'f',
        title: 't',
        snoozedUntil: now.add(const Duration(hours: 1)),
        ingestedAt: now,
        updatedAt: now,
      );
      expect(item.isSnoozed, true);
    });

    test('snoozedUntil no passado marca isSnoozed false', () {
      final now = DateTime.now();
      final item = WorkItem(
        id: 'x',
        providerId: 'p',
        articleId: 'a',
        feedId: 'f',
        title: 't',
        snoozedUntil: now.subtract(const Duration(hours: 1)),
        ingestedAt: now,
        updatedAt: now,
      );
      expect(item.isSnoozed, false);
    });
  });
}
