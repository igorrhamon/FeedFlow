import '../../models/article.dart';
import '../triage_status.dart';
import '../work_item.dart';

/// Porta de persistência local dos [WorkItem]s. Implementações vivem em
/// `lib/infrastructure/repositories/`; nada em `lib/domain` ou
/// `lib/application` deve depender de drift/SQL diretamente.
abstract class WorkItemRepository {
  /// Query reativa por status — a base das filas (`Queue`/`QuerySpec` de
  /// fases futuras começam como filtros sobre este stream).
  Stream<List<WorkItem>> watchByStatus(List<TriageStatus> statuses);

  /// Contagem reativa por status, para badges de fila.
  Stream<int> watchCountByStatus(TriageStatus status);

  Future<WorkItem?> byId(String id);

  /// Ingestão: para cada [Article], cria um [WorkItem] novo se não existir
  /// (status inicial `novo`), ou atualiza apenas o snapshot (título,
  /// conteúdo, read/star) de um item já existente — nunca sobrescreve
  /// status/tags/priority/notes definidos localmente pelo usuário.
  Future<void> upsertFromArticles(List<Article> articles, String providerId);

  Future<void> save(WorkItem item);

  /// Atualiza apenas o status, validando a transição via
  /// [isValidTriageTransition]. Lança [StateError] em transição inválida.
  Future<void> changeStatus(String id, TriageStatus newStatus);

  /// Remove itens concluídos/arquivados mais antigos que [cutoff].
  /// Retorna o número de itens removidos.
  Future<int> purgeOlderThan(DateTime cutoff, {List<TriageStatus>? statuses});

  /// Query reativa por artigos favoritos (starred) — ordenado por data mais recente primeiro.
  Stream<List<WorkItem>> watchStarred();

  /// Contagem reativa de itens não lidos por feed.
  Stream<int> watchUnreadCountByFeed(String feedId);

  /// Query reativa por feedId — filtra [WorkItem]s de um feed específico,
  /// ordenados por ingestão decrescente. Usado por `feed_articles_page.dart`
  /// para carregar artigos localmente.
  Stream<List<WorkItem>> watchByFeedId(String feedId);

  Future<void> close();
}
