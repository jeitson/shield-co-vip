import 'package:drift/drift.dart';
import 'package:shield_app/core/db/app_database.dart';
import 'package:shield_app/core/db/tables/intercepted_events_table.dart';

part 'events_dao.g.dart';

/// Acceso tipado al historial de eventos interceptados (`eventos`).
///
/// Lo **escribe** el contrato de inserción (`EventsRepository.record`, alimentado
/// por el puente nativo y el Simulador) y lo **lee** la pantalla de registro
/// (`CallsScreen`) de forma reactiva. Orden canónico: `timestamp` descendente
/// (más reciente primero, RF-CALLS-01 / RN-04).
@DriftAccessor(tables: [InterceptedEventsTable])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(super.db);

  /// Observa el historial completo, orden fecha descendente (R2).
  Stream<List<InterceptedEventRow>> watchAll() {
    final query = select(interceptedEventsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
    return query.watch();
  }

  /// Página del historial para carga incremental (R12). `offset`/`limit` sobre
  /// el mismo orden descendente.
  Stream<List<InterceptedEventRow>> watchPage({
    required int limit,
    required int offset,
  }) {
    final query = select(interceptedEventsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(limit, offset: offset);
    return query.watch();
  }

  /// Carga un evento por id para el detalle (R10); `null` si no existe.
  Future<InterceptedEventRow?> getById(String id) {
    final query = select(interceptedEventsTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Inserta un evento (upsert por `id` para idempotencia del productor).
  Future<void> insertOne(InterceptedEventsTableCompanion row) async {
    await into(interceptedEventsTable).insertOnConflictUpdate(row);
  }

  /// Conteo de eventos en la ventana `[dayStart, dayEnd)` — "intercepciones de
  /// hoy" (RF-CALLS-10, R5). Se calcula en SQL, sin cargar filas.
  Future<int> countBetween(DateTime dayStart, DateTime dayEnd) async {
    final count = interceptedEventsTable.id.count();
    final query = selectOnly(interceptedEventsTable)
      ..addColumns([count])
      ..where(
        interceptedEventsTable.timestamp.isBiggerOrEqualValue(dayStart) &
            interceptedEventsTable.timestamp.isSmallerThanValue(dayEnd),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Conteo de eventos de un `nivel` dado — p. ej. "críticas" = ALTO (R5).
  Future<int> countByLevel(String level) async {
    final count = interceptedEventsTable.id.count();
    final query = selectOnly(interceptedEventsTable)
      ..addColumns([count])
      ..where(interceptedEventsTable.level.equals(level));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Borra todo el historial (p. ej. logout/wipe). No se usa en el flujo normal.
  Future<void> clearAll() => delete(interceptedEventsTable).go();
}
