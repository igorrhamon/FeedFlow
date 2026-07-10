/// Estado de triagem local de um [WorkItem], independente do estado
/// read/unread do provider remoto.
enum TriageStatus {
  novo,
  triado,
  emAndamento,
  concluido,
  arquivado;

  static TriageStatus fromName(String name) => TriageStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => TriageStatus.novo,
      );
}

/// Transições válidas da máquina de estados de triagem.
///
/// Regras podem pular etapas (ex.: `novo` -> `arquivado` direto); transições
/// manuais do usuário devem respeitar este mapa.
const Map<TriageStatus, Set<TriageStatus>> kTriageTransitions = {
  TriageStatus.novo: {
    TriageStatus.triado,
    TriageStatus.emAndamento,
    TriageStatus.concluido,
    TriageStatus.arquivado,
  },
  TriageStatus.triado: {
    TriageStatus.emAndamento,
    TriageStatus.concluido,
    TriageStatus.arquivado,
    TriageStatus.novo,
  },
  TriageStatus.emAndamento: {
    TriageStatus.triado,
    TriageStatus.concluido,
    TriageStatus.arquivado,
  },
  TriageStatus.concluido: {
    TriageStatus.arquivado,
    TriageStatus.emAndamento,
  },
  TriageStatus.arquivado: {
    TriageStatus.novo,
    TriageStatus.triado,
  },
};

bool isValidTriageTransition(TriageStatus from, TriageStatus to) {
  if (from == to) return true;
  return kTriageTransitions[from]?.contains(to) ?? false;
}

enum Priority {
  none,
  low,
  medium,
  high,
  urgent;

  static Priority fromName(String name) => Priority.values.firstWhere(
        (p) => p.name == name,
        orElse: () => Priority.none,
      );
}
