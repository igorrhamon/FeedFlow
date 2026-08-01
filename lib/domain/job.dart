import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';
part 'job.g.dart';

/// Status de um job na fila.
enum JobStatus {
  pending, // Aguardando execução
  running, // Executando
  done, // Concluído com sucesso
  failed, // Falhou após retentativas
}

/// Um job a ser executado pela fila de jobs.
///
/// Fluxo: um job é criado com status [JobStatus.pending], aguarda até [nextRunAt],
/// é marcado como [JobStatus.running], executado via [JobHandler.run()], e
/// marcado como [JobStatus.done] ou [JobStatus.failed] dependendo do resultado.
/// Falhas causam retry até [maxAttempts]; depois é marcado como [JobStatus.failed].
@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    required String type,
    @Default({}) Map<String, dynamic> payload,
    @Default(JobStatus.pending) JobStatus status,
    @Default([]) List<String> dependsOn,
    @Default(0) int attempts,
    @Default(3) int maxAttempts,
    required DateTime nextRunAt,
    required DateTime createdAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}

/// Um registro de execução de um job.
///
/// Criado toda vez que um job é executado; rastreia quando começou,
/// quando terminou, se foi bem-sucedido, e qualquer mensagem de erro.
@freezed
class JobRun with _$JobRun {
  const factory JobRun({
    int? id,
    required String jobId,
    required DateTime startedAt,
    DateTime? finishedAt,
    @Default(false) bool success,
    String? error,
  }) = _JobRun;

  factory JobRun.fromJson(Map<String, dynamic> json) => _$JobRunFromJson(json);
}
