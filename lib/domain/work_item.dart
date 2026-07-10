import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/article.dart';
import 'triage_status.dart';

part 'work_item.freezed.dart';

/// Identidade estável de um [WorkItem]: `{providerId}:{articleId}`.
///
/// O `Article` de um provider não tem identidade local persistente — este id
/// é o que permite ao FeedFlow rastrear o mesmo artigo entre syncs.
String workItemIdFor(String providerId, String articleId) => '$providerId:$articleId';

/// Aggregate root do processamento local de artigos: o `Article` ingerido de
/// um provider é apenas um DTO de entrada (snapshot); o `WorkItem` é quem
/// carrega o estado de triagem, tags, prioridade e enriquecimentos, sempre
/// independente do estado read/unread do provider remoto.
@freezed
class WorkItem with _$WorkItem {
  const WorkItem._();

  const factory WorkItem({
    required String id,
    required String providerId,
    required String articleId,
    required String feedId,
    required String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    @Default(TriageStatus.novo) TriageStatus status,
    @Default(Priority.none) Priority priority,
    @Default([]) List<String> tags,
    @Default(false) bool isRead,
    @Default(false) bool isStarred,
    DateTime? snoozedUntil,
    String? notes,
    required DateTime ingestedAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) = _WorkItem;

  /// Constrói um [WorkItem] novo a partir do snapshot de ingestão de um
  /// [Article]. Usado pelo `upsertFromArticles` do repositório — em um
  /// upsert de item já existente, apenas os campos de snapshot (título,
  /// conteúdo, read/star) são atualizados; status/tags/priority locais
  /// não são tocados (ver `WorkItemRepository.upsertFromArticles`).
  factory WorkItem.fromArticle(Article article, String providerId) {
    final now = DateTime.now();
    return WorkItem(
      id: workItemIdFor(providerId, article.id),
      providerId: providerId,
      articleId: article.id,
      feedId: article.feedId,
      title: article.title,
      author: article.author,
      summary: article.summary,
      content: article.content,
      url: article.url,
      published: article.published,
      updated: article.updated,
      isRead: article.isRead,
      isStarred: article.isStarred,
      ingestedAt: now,
      updatedAt: now,
    );
  }

  bool get isSnoozed => snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  bool get isActive => status != TriageStatus.concluido && status != TriageStatus.arquivado;
}
