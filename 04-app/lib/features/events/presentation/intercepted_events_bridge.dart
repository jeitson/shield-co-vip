import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/engine/data/hmac_hasher.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/engine/domain/number_normalizer.dart';
import 'package:shield_app/features/engine/presentation/engine_providers.dart';
import 'package:shield_app/features/events/data/native_event_queue.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/domain/threat_presentation.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';
import 'package:uuid/uuid.dart';

/// Lector de la cola de interceptaciones nativa.
final nativeEventQueueProvider = Provider<NativeEventQueue>(
  (ref) => NativeEventQueue(),
);

/// Drena la cola nativa de interceptaciones, **rehidrata** cada una a un
/// `InterceptedEvent` completo y la **persiste** vía `RecordEvent`. Devuelve
/// cuántos eventos se registraron.
///
/// Rehidratación de la categoría (que el nativo no envía): se rehashea el número
/// con el pepper del keystore y se busca en `engineIndexProvider.categoryByHash`
/// (misma info del dataset). Si no se resuelve, se usa la capa que trajo el
/// nativo (`ThreatPresentation.categoryForLayer`). El resto de atributos
/// (nivel, título, reputación, diagnóstico) se sintetizan de la categoría.
final drainInterceptedEventsProvider = Provider<Future<int> Function()>((ref) {
  return () async {
    final raws = await ref.read(nativeEventQueueProvider).drain();
    if (raws.isEmpty) return 0;

    final pepper = await ref.read(pepperStoreProvider).readPepper();
    final index = await ref.read(engineIndexProvider.future);
    final record = ref.read(recordEventProvider);
    const uuid = Uuid();

    var persisted = 0;
    for (final raw in raws) {
      final normalized = NumberNormalizer.normalize(raw.rawNumber);
      final sender = normalized ?? raw.rawNumber.trim();
      if (sender.isEmpty) continue;

      // Resolver categoría: preferir el dataset (hash→categoría); si no, la capa.
      ThreatCategory? category;
      if (pepper != null && pepper.isNotEmpty && normalized != null) {
        final hash = HmacHasher.hash(pepper: pepper, numberE164: normalized);
        category = index.categoryByHash[hash];
      }
      category ??= ThreatPresentation.categoryForLayer(raw.layer);

      final event = InterceptedEvent(
        id: uuid.v4(),
        sender: sender,
        type: raw.channel,
        level: ThreatPresentation.levelOf(category),
        timestamp: raw.timestamp,
        threatTitle: ThreatPresentation.titleOf(category),
        category: category,
        reputationTag: ThreatPresentation.reputationTagOf(category),
        diagnosis: ThreatPresentation.diagnosisOf(category),
        quarantinedContent: raw.body,
      );

      final result = await record(event);
      if (result.isOk) persisted++;
    }
    return persisted;
  };
});

/// Mantiene el drenado de la cola vivo mientras la app está en primer plano:
/// drena al montar y cada vez que la app vuelve a `resumed` (tras una llamada o
/// SMS interceptados con la UI en background). Se activa observando este
/// provider desde el shell de navegación.
final interceptedEventsDrainerProvider = Provider<void>((ref) {
  final observer = _AppLifecycleDrainer(ref);
  WidgetsBinding.instance.addObserver(observer);
  // Drenado inicial (eventos acumulados mientras la app estuvo cerrada).
  ref.read(drainInterceptedEventsProvider)();
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
});

class _AppLifecycleDrainer with WidgetsBindingObserver {
  _AppLifecycleDrainer(this._ref);
  final Ref _ref;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ref.read(drainInterceptedEventsProvider)();
    }
  }
}
