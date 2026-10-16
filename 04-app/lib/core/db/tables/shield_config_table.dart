import 'package:drift/drift.dart';

/// Configuración del escudo persistida localmente (`ConfigEscudo` de
/// `00-fundamentos`): las **3 capas** de protección.
///
/// Es una tabla **singleton**: siempre una única fila con `id = 1`. Se modela
/// como tabla (y no como par clave-valor) para tener columnas tipadas y un
/// stream reactivo directo que la UI del Dashboard observa (RN-SHIELD-01/02).
///
/// Defecto: las 3 capas activas (RN-SHIELD-04, máxima protección por defecto).
@DataClassName('ShieldConfigRow')
class ShieldConfigTable extends Table {
  @override
  String get tableName => 'shield_config';

  /// Identificador de la fila singleton (siempre 1).
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Capa anti-extorsión (crítica).
  BoolColumn get extorsion => boolean().withDefault(const Constant(true))();

  /// Capa anti call center / spam.
  BoolColumn get callcenter => boolean().withDefault(const Constant(true))();

  /// Capa de cumplimiento Ley 2300.
  BoolColumn get ley => boolean().withDefault(const Constant(true))();

  /// Última modificación local (auditoría; no se sincroniza).
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
