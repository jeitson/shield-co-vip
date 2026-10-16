import 'package:drift/drift.dart';

/// Dataset local de **hashes** de números peligrosos (`03-datos-y-sincronizacion`
/// §03.1/§03.3).
///
/// Al dispositivo **solo** llega el `hash` (HMAC-SHA256 del número con el pepper);
/// el número legible vive únicamente en el servidor (RN-01, Zero-Knowledge). El
/// motor de bloqueo hashea el número entrante con el mismo pepper y busca aquí.
///
/// `addedAtVersion` / `removedAtVersion` habilitan el **delta sync versionado**
/// (soft delete): una baja no borra la fila, marca `removedAtVersion`. Un
/// `pepperVersion` distinto del vigente obliga a un full-resync (rotación de
/// pepper, `02-seguridad` §02.2). Esta tabla la escribe `features/sync`.
class PhoneHashesTable extends Table {
  @override
  String get tableName => 'phone_hashes';

  /// HMAC-SHA256(pepper, número normalizado). Opaco para el cliente. PK.
  TextColumn get hash => text()();

  /// Categoría de amenaza (catálogo RN-07).
  TextColumn get categoria => text()();

  /// Nivel de severidad: `ALTO` | `MEDIO` | `BAJO`.
  TextColumn get nivel => text()();

  /// Versión del dataset en la que entró esta firma.
  IntColumn get addedAtVersion => integer()();

  /// Versión en la que se dio de baja; `null` = activa (soft delete).
  IntColumn get removedAtVersion => integer().nullable()();

  /// Versión del pepper con el que se calculó el hash (detecta rotación).
  IntColumn get pepperVersion => integer()();

  @override
  Set<Column> get primaryKey => {hash};
}
