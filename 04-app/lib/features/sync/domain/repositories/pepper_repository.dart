import 'package:shield_app/core/error/result.dart';

/// Pepper vigente del dataset: su valor (clave HMAC) y su versión.
class PepperMaterial {
  const PepperMaterial({required this.pepper, required this.version});

  final String pepper;
  final int version;
}

/// Obtiene y custodia el **pepper** del dataset (`02-seguridad` §02.2).
///
/// El pepper se guarda en keystore tras obtenerlo de `v1-pepper`; de ahí lo
/// toma el motor de bloqueo para hashear el número entrante.
abstract interface class PepperRepository {
  /// Devuelve el pepper local; si no existe, lo obtiene de `v1-pepper` y lo
  /// guarda. Falla si no hay sesión o red.
  Future<Result<PepperMaterial>> getOrFetchPepper();

  /// Fuerza una recarga del pepper desde el servidor (rotación / full-resync).
  Future<Result<PepperMaterial>> refreshPepper();

  /// Borra el pepper local (logout / revocación).
  Future<void> clear();
}
