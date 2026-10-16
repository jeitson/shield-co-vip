import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Instancia compartida del almacén seguro del SO (Android Keystore / iOS
/// Keychain) [DA-14, `02-seguridad` §02.3].
///
/// Único punto de verdad para `FlutterSecureStorage` en toda la app: lo
/// consumen la sesión de auth (`AuthSessionStore`), la **DEK** de la base local
/// cifrada (`LocalCryptoKeys`) y, más adelante, el **pepper** del dataset. Vive
/// en `core/secure` para no acoplar el almacén a una feature concreta.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// Opciones de Android para respaldar las claves en el Keystore vía
/// `EncryptedSharedPreferences`. Se reutilizan donde se persista material
/// sensible para mantener un comportamiento homogéneo.
const secureAndroidOptions = AndroidOptions(encryptedSharedPreferences: true);
