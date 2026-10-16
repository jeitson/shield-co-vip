import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Calcula el hash de un número para el matching: `HMAC-SHA256(pepper, E164)` en
/// hex (`02-seguridad` §02.2, DA-05).
///
/// **Debe** coincidir byte a byte con el servidor. El seed/Edge usan pgcrypto
/// `hmac(numero, pepper, 'sha256')`, es decir: data = número E.164, key = pepper.
/// En Dart: `Hmac(sha256, pepperBytes).convert(e164Bytes)` → hex en minúsculas.
///
/// El pepper se trata como una cadena (su valor base64 tal como lo entrega Vault
/// / `v1-pepper`); se usa como clave en bytes UTF-8, igual que pgcrypto trata el
/// `key` de texto.
abstract final class HmacHasher {
  static String hash({required String pepper, required String numberE164}) {
    final key = utf8.encode(pepper);
    final msg = utf8.encode(numberE164);
    final digest = Hmac(sha256, key).convert(msg);
    return digest.toString(); // hex en minúsculas
  }
}
