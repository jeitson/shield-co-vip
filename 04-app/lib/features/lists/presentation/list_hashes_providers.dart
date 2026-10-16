import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/engine/data/hmac_hasher.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// Convierte un conjunto de **números canónicos** a sus **hashes** HMAC con el
/// pepper del keystore, para alimentar el motor (niveles 1 y 3 del
/// `PrecedenceEngine`), que opera sobre hashes igual que el dataset.
///
/// Si no hay pepper (p. ej. aún sin sincronizar), degrada a conjunto vacío sin
/// romper el motor — coherente con el comportamiento previo de `engineIndex`.
Future<Set<String>> _hashNumbers(Ref ref, Set<String> numbers) async {
  if (numbers.isEmpty) return const {};
  final pepper = await ref.watch(pepperStoreProvider).readPepper();
  if (pepper == null || pepper.isEmpty) return const {};
  return numbers
      .map((n) => HmacHasher.hash(pepper: pepper, numberE164: n))
      .toSet();
}

/// Hashes de la lista de **confianza** (→ `whitelistLocal` del motor, nivel 1).
final confianzaHashesProvider = FutureProvider<Set<String>>((ref) async {
  final numbers = await ref.watch(confianzaNumbersProvider.future);
  return _hashNumbers(ref, numbers);
});

/// Hashes de la **lista negra** local (→ `blacklistLocal` del motor, nivel 3).
final negraHashesProvider = FutureProvider<Set<String>>((ref) async {
  final numbers = await ref.watch(negraNumbersProvider.future);
  return _hashNumbers(ref, numbers);
});
