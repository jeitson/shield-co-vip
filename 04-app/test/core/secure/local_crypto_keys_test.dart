import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/secure/local_crypto_keys.dart';

/// `FlutterSecureStorage` en memoria para probar la lógica de la DEK sin el
/// platform channel del keystore.
class _InMemorySecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late LocalCryptoKeys keys;

  setUp(() => keys = LocalCryptoKeys(_InMemorySecureStorage()));

  test('getOrCreateDek genera 256 bits la primera vez', () async {
    final dek = await keys.getOrCreateDek();
    final bytes = base64Decode(dek);
    expect(bytes.length, 32); // 256 bits
  });

  test('getOrCreateDek reutiliza la misma DEK en llamadas sucesivas', () async {
    final first = await keys.getOrCreateDek();
    final second = await keys.getOrCreateDek();
    expect(second, first);
  });

  test('deleteDek fuerza la regeneración de una DEK distinta', () async {
    final first = await keys.getOrCreateDek();
    await keys.deleteDek();
    final regenerated = await keys.getOrCreateDek();
    expect(regenerated, isNot(first));
    expect(base64Decode(regenerated).length, 32);
  });

  test('dos DEK generadas son distintas (aleatoriedad)', () async {
    final a = await LocalCryptoKeys(_InMemorySecureStorage()).getOrCreateDek();
    final b = await LocalCryptoKeys(_InMemorySecureStorage()).getOrCreateDek();
    expect(a, isNot(b));
  });
}
