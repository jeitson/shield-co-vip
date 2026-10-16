import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';

/// Caso de uso: observar el historial completo de eventos (orden fecha desc, R2).
class WatchEvents {
  const WatchEvents(this._repository);

  final EventsRepository _repository;

  Stream<List<InterceptedEvent>> call() => _repository.watchAll();
}
