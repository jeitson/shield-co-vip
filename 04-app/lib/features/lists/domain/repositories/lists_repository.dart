import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';

/// Contrato de las listas locales confianza/negra (feature mínima de la spec 03).
///
/// Garantiza la **exclusividad RN-05**: un número no puede estar en ambas listas.
/// El motor de bloqueo consume `watchConfianza`/`watchNegra` (niveles 1 y 3 del
/// `PrecedenceEngine`) tras hashear los números con el pepper del keystore.
abstract interface class ListsRepository {
  /// Observa la lista a la que pertenece [numero] (ya canónico); `null` = en
  /// ninguna. Alimenta los badges CONFIABLE/BLOQUEADO del timeline (R7.5).
  Stream<ListKind?> watchMembership(String numero);

  /// Clasifica [numero] en [kind] con **exclusividad atómica** (RN-05):
  /// escribir en una lista lo retira de la otra. `kind == null` = desmarcar.
  Future<Result<void>> classify({
    required String numero,
    required ListKind? kind,
    ListOrigin origin,
  });

  /// Conjunto de números de confianza (→ whitelist local del motor).
  Stream<Set<String>> watchConfianza();

  /// Conjunto de números en lista negra (→ blacklist local del motor).
  Stream<Set<String>> watchNegra();
}
