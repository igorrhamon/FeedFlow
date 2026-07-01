import 'package:freezed_annotation/freezed_annotation.dart';

part 'outbox_entry.freezed.dart';

/// Mutação de read/star pendente de confirmação no provider remoto.
enum OutboxAction {
  markRead,
  markUnread,
  star,
  unstar;

  static OutboxAction fromName(String name) => OutboxAction.values.firstWhere((a) => a.name == name);
}

/// Uma entrada da fila de push do outbox: a UI já aplicou a mudança
/// localmente (otimista); esta entrada garante que ela chegue ao provider
/// remoto mesmo que a primeira tentativa falhe (rede indisponível, etc.).
@freezed
class OutboxEntry with _$OutboxEntry {
  const factory OutboxEntry({
    required int id,
    required String workItemId,
    required String articleId,
    required OutboxAction action,
    required DateTime createdAt,
    @Default(0) int attempts,
    String? lastError,
  }) = _OutboxEntry;
}
