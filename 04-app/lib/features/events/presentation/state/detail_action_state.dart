import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';

/// Qué acción se está ejecutando (o ninguna) en el detalle del evento.
enum DetailActionKind { none, dualReport, localBlock }

/// Fase de la acción en curso.
enum DetailActionPhase { idle, generating, success, error }

/// Estado de las dos vías de acción del detalle (reportar+bloquear / bloquear
/// local), consumido por `BlockOptionsModule` (spec 04 §6).
class DetailActionState {
  const DetailActionState({
    this.kind = DetailActionKind.none,
    this.phase = DetailActionPhase.idle,
    this.outcome,
    this.errorMessage,
    this.localBlockDone = false,
  });

  /// Acción asociada a la fase actual.
  final DetailActionKind kind;

  /// Fase de la acción (idle/generating/success/error).
  final DetailActionPhase phase;

  /// Desenlace del reporte comunitario tras éxito (pendiente/yaReportado/
  /// rechazadoProtegido); `null` mientras no haya reporte resuelto.
  final ReportOutcome? outcome;

  /// Mensaje de error del reporte (reintentable); `null` si no hubo error.
  final String? errorMessage;

  /// `true` cuando el bloqueo local quedó aplicado ("Número Silenciado
  /// Localmente" / parte local de "Reportar y bloquear").
  final bool localBlockDone;

  /// `true` si el reporte está en curso (botón dual en "Generando…").
  bool get isGenerating =>
      kind == DetailActionKind.dualReport &&
      phase == DetailActionPhase.generating;

  /// `true` si el flujo dual terminó con éxito (reporte resuelto).
  bool get isDualSuccess =>
      kind == DetailActionKind.dualReport && phase == DetailActionPhase.success;

  /// `true` si el reporte quedó en error reintentable.
  bool get hasReportError =>
      kind == DetailActionKind.dualReport && phase == DetailActionPhase.error;

  DetailActionState copyWith({
    DetailActionKind? kind,
    DetailActionPhase? phase,
    ReportOutcome? outcome,
    String? errorMessage,
    bool? localBlockDone,
    bool clearOutcome = false,
    bool clearError = false,
  }) {
    return DetailActionState(
      kind: kind ?? this.kind,
      phase: phase ?? this.phase,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localBlockDone: localBlockDone ?? this.localBlockDone,
    );
  }
}
