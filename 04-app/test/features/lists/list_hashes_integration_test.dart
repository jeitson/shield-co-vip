import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/secure/pepper_store.dart';
import 'package:shield_app/features/engine/data/hmac_hasher.dart';
import 'package:shield_app/features/lists/presentation/list_hashes_providers.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// `PepperStore` de prueba con un pepper fijo (o ausente) en memoria.
class _FakePepperStore extends PepperStore {
  _FakePepperStore(this._pepper) : super(const FlutterSecureStorage());
  final String? _pepper;

  @override
  Future<String?> readPepper() async => _pepper;
}

ProviderContainer _container({
  required String? pepper,
  required Set<String> confianza,
  required Set<String> negra,
}) {
  return ProviderContainer(
    overrides: [
      pepperStoreProvider.overrideWithValue(_FakePepperStore(pepper)),
      confianzaNumbersProvider.overrideWith((ref) => Stream.value(confianza)),
      negraNumbersProvider.overrideWith((ref) => Stream.value(negra)),
    ],
  );
}

void main() {
  test('confianza/negra se hashean con el pepper (R7.6)', () async {
    final c = _container(
      pepper: 'pepper-de-prueba',
      confianza: {'+573001112233'},
      negra: {'+573009998877'},
    );
    addTearDown(c.dispose);

    final confianza = await c.read(confianzaHashesProvider.future);
    final negra = await c.read(negraHashesProvider.future);

    expect(confianza, {
      HmacHasher.hash(pepper: 'pepper-de-prueba', numberE164: '+573001112233'),
    });
    expect(negra, {
      HmacHasher.hash(pepper: 'pepper-de-prueba', numberE164: '+573009998877'),
    });
  });

  test('sin pepper degrada a conjuntos vacíos (no rompe el motor)', () async {
    final c = _container(
      pepper: null,
      confianza: {'+573001112233'},
      negra: {'+573009998877'},
    );
    addTearDown(c.dispose);

    expect(await c.read(confianzaHashesProvider.future), isEmpty);
    expect(await c.read(negraHashesProvider.future), isEmpty);
  });

  test('listas vacías → hashes vacíos', () async {
    final c = _container(pepper: 'p', confianza: {}, negra: {});
    addTearDown(c.dispose);

    expect(await c.read(confianzaHashesProvider.future), isEmpty);
    expect(await c.read(negraHashesProvider.future), isEmpty);
  });
}
