import 'package:shield_app/core/db/daos/events_dao.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/events/data/mappers/event_mapper.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/repositories/events_repository.dart';

/// Implementación de [EventsRepository] sobre [EventsDao] (base local cifrada).
class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._dao);

  final EventsDao _dao;

  @override
  Stream<List<InterceptedEvent>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows.map(EventMapper.toEntity).toList(growable: false),
    );
  }

  @override
  Future<Result<InterceptedEvent?>> getById(String id) async {
    try {
      final row = await _dao.getById(id);
      return Ok(row == null ? null : EventMapper.toEntity(row));
    } catch (e) {
      return Err(UnknownFailure(message: 'No se pudo cargar el evento', cause: e));
    }
  }

  @override
  Future<Result<void>> record(InterceptedEvent event) async {
    try {
      await _dao.insertOne(EventMapper.toCompanion(event));
      return const Ok(null);
    } catch (e) {
      return Err(UnknownFailure(message: 'No se pudo registrar el evento', cause: e));
    }
  }
}
