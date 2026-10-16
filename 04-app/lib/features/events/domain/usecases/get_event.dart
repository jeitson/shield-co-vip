import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';

/// Caso de uso: cargar un evento por id para el detalle (R10).
class GetEvent {
  const GetEvent(this._repository);

  final EventsRepository _repository;

  Future<Result<InterceptedEvent?>> call(String id) =>
      _repository.getById(id);
}
