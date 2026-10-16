import 'package:drift/drift.dart';

/// Listas locales del usuario (`NumeroListado` de `00-fundamentos`): un número
/// puede estar en **confianza** o en **negra**, nunca en ambas (RN-05).
///
/// La **exclusividad es estructural**: [numero] es la clave primaria, así que
/// una fila por número — reclasificar es un upsert que cambia [lista]. El
/// repositorio además aplica la exclusividad dentro de una transacción.
///
/// El número se guarda en formato canónico E.164 (RN-04) para que la
/// deduplicación sea real (`+57 300…` y `300…` son el mismo número). El motor de
/// bloqueo consume estas listas (niveles 1 y 3 del `PrecedenceEngine`) tras
/// hashearlas con el pepper del keystore.
@DataClassName('ListedNumberRow')
class ListedNumbersTable extends Table {
  @override
  String get tableName => 'numeros_listados';

  /// Número en formato canónico E.164 (RN-04). PK → unicidad = RN-05.
  TextColumn get numero => text()();

  /// Lista a la que pertenece: `confianza` | `negra` (enum `ListKind`).
  TextColumn get lista => text()();

  /// Cómo entró: `manual` | `evento` | `simulador` (enum `ListOrigin`).
  TextColumn get origen => text()();

  /// Última modificación local (auditoría; no se sincroniza).
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {numero};
}
