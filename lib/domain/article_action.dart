import 'work_item.dart';

/// Interface base para todas as ações que podem ser executadas sobre um [WorkItem].
/// Uma ação encapsula uma transformação do estado de um item: mudar status,
/// adicionar tag, compartilhar, etc.
abstract class ArticleAction {
  /// ID único e imutável da ação. Usado para referência em regras e logs.
  /// Exemplos: 'complete', 'archive', 'snooze', 'toggleStar', 'share',
  /// 'copyLink', 'addTag'.
  String get id;

  /// Label legível para exibição em UIs (ex: "Marcar como concluído",
  /// "Compartilhar", "Arquivar").
  String get label;

  /// Executa a ação sobre um [WorkItem] com os parâmetros fornecidos.
  /// Nunca deve lançar — qualquer erro deve ser capturado pelo [ActionExecutor]
  /// (ou retornado via Future).
  ///
  /// Parâmetros:
  /// - [item]: o item sobre o qual a ação é executada.
  /// - [params]: mapa de parâmetros específicos da ação (ex: {'days': 1} para snooze,
  ///   {'tag': 'urgent'} para addTag). Pode estar vazio.
  Future<void> execute(WorkItem item, Map<String, dynamic> params);
}
