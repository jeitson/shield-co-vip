import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';

/// Caso de uso: registrar un evento interceptado (contrato de inserción).
///
/// Vía única por la que el **puente nativo** (CallScreeningService / receiver
/// SMS) y el **Simulador** persisten interceptaciones reales (spec 03 §3). Valida
/// invariantes mínimos antes de delegar.
class RecordEvent {
  const RecordEvent(this._repository);

  final EventsRepository _repository;

  Future<Result<void>> call(InterceptedEvent event) {
    if (event.id.trim().isEmpty || event.sender.trim().isEmpty) {
      return Future.value(
        const Err(ServerFailure('Evento inválido: falta id o remitente')),
      );
    }
    return _repository.record(event);
  }
}
