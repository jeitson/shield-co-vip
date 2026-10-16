import 'package:shield_app/core/db/daos/phone_hashes_dao.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';
import 'package:shield_app/core/secure/pepper_store.dart';

/// Borra el **material sensible local** cuando el dispositivo es revocado
/// (DA-04) o en un logout duro: pepper (keystore), DEK (keystore) y el dataset
/// de hashes (base cifrada). Tras esto el dispositivo queda "desprotegido" y la
/// base local deja de ser legible (se recreará vacía en el próximo arranque).
///
/// `02-seguridad` §02.3/§04.6: la revocación hace que el refresh falle y el
/// cliente borre el material; no es recuperable desde el servidor (ZK).
class SessionWiper {
  SessionWiper({
    required this.pepperStore,
    required this.cryptoKeys,
    required this.phoneHashesDao,
  });

  final PepperStore pepperStore;
  final LocalCryptoKeys cryptoKeys;
  final PhoneHashesDao phoneHashesDao;

  /// Ejecuta el borrado completo. Es tolerante a fallos parciales: intenta
  /// borrar todo aunque una parte falle, para no dejar material a medias.
  Future<void> wipe() async {
    // 1) Vaciar el dataset local (lo que se puede leer con la DEK aún presente).
    try {
      await phoneHashesDao.clearAll();
    } catch (_) {
      // Si la base ya no abre, el borrado de la DEK la vuelve inservible igual.
    }
    // 2) Borrar el pepper (sin él, el matching es imposible).
    await pepperStore.clear();
    // 3) Borrar la DEK (vuelve ilegible la base local).
    await cryptoKeys.deleteDek();
  }
}
