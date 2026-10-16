import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';

/// Contrato del historial de eventos interceptados (feature `events`).
///
/// `record` es el **contrato de inserción** (spec 03 §3, fuera de alcance el
/// productor real): lo usarán el puente nativo (CallScreeningService / receiver
/// SMS) y el Simulador para persistir interceptaciones reales. `watchAll` y
/// `getById` alimentan la pantalla de registro y el detalle.
abstract interface class EventsRepository {
  /// Historial completo, orden fecha descendente (R2). Reactivo.
  Stream<List<InterceptedEvent>> watchAll();

  /// Carga un evento por id para el detalle (R10); `null` si no existe.
  Future<Result<InterceptedEvent?>> getById(String id);

  /// Inserta/actualiza un evento interceptado (idempotente por id).
  Future<Result<void>> record(InterceptedEvent event);
}
