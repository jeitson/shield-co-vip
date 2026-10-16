/// Desenlace de un reporte comunitario (gobierna la UI del estado de acción).
///
/// Los tres son respuestas válidas del servidor (no errores de transporte): un
/// error de red/servidor se modela como `Err(Failure)` y es reintentable (R8).
enum ReportOutcome {
  /// Aceptado; queda en moderación hasta superar el umbral (DA-10).
  pendiente,

  /// Dedup: este dispositivo ya había reportado el número (idempotente, R9).
  yaReportado,

  /// Rechazado por la allowlist de protección de números legítimos (R8.3).
  /// No es un error reintentable; el bloqueo local se mantiene.
  rechazadoProtegido,
}
