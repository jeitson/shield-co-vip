import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/engine/data/hmac_hasher.dart';

/// Vector de prueba REAL contra el backend desplegado: con el pepper real y el
/// número `+573100000007` (seed i=1), el servidor (pgcrypto `hmac(...,'sha256')`)
/// almacenó el hash de abajo. Este test confirma que el `HmacHasher` de Dart
/// produce el **mismo** hash → el matching del motor coincidirá con el dataset.
///
/// Si el seed se regenera con otro pepper, actualizar el vector (el valor del
/// pepper no es secreto en este contexto de prueba; es un entorno dev).
void main() {
  const pepper = 'TGSPncMFdh5TP2hXTXP2pW+k/Mz7kRc/60X3N9Fjb6s=';
  const number = '+573100000007';
  const expected =
      '1b1800608291534a6d1e8d7e3b7ddb4bc33165229e16b7ced6e0700fbb0a5be3';

  test('HMAC-SHA256(pepper, E164) coincide con pgcrypto del servidor', () {
    final hash = HmacHasher.hash(pepper: pepper, numberE164: number);
    expect(hash, expected);
  });

  test('hashes distintos para números distintos', () {
    final a = HmacHasher.hash(pepper: pepper, numberE164: '+573100000007');
    final b = HmacHasher.hash(pepper: pepper, numberE164: '+573100000014');
    expect(a, isNot(b));
  });
}
