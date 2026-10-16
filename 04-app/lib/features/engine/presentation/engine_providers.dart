import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/db/db_providers.dart';
import 'package:shield_app/features/engine/data/native_snapshot_writer.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/engine/domain/precedence_engine.dart';
import 'package:shield_app/features/lists/presentation/list_hashes_providers.dart';

/// Escritor del snapshot al nativo.
final nativeSnapshotWriterProvider = Provider<NativeSnapshotWriter>(
  (ref) => NativeSnapshotWriter(),
);

/// Construye el [EngineIndex] vigente a partir de la base local (dataset de
/// hashes + categorías), las **listas locales** del usuario y la configuración
/// del escudo.
///
/// Las listas blanca/negra locales (niveles 1 y 3 del `PrecedenceEngine`) se
/// alimentan desde la feature `lists` (spec 03), ya hasheadas con el pepper. Si
/// aún no hay pepper, esos providers degradan a conjuntos vacíos sin romper el
/// motor. Cualquier reclasificación dispara estos streams → recomputa el índice
/// → `engineProjectionProvider` reproyecta al nativo (R7.6).
final engineIndexProvider = FutureProvider<EngineIndex>((ref) async {
  final phoneDao = await ref.watch(phoneHashesDaoProvider.future);

  // Reaccionar a cambios de config (reproyecta al togglear una capa).
  final config = await ref.watch(shieldConfigStreamProvider.future);

  // Listas locales del usuario, ya como hashes (reactivas a la clasificación).
  final whitelistLocal = await ref.watch(confianzaHashesProvider.future);
  final blacklistLocal = await ref.watch(negraHashesProvider.future);

  final blacklistGlobal = await phoneDao.activeHashes();
  final categoryRaw = await phoneDao.activeCategoryByHash();
  final categoryByHash = <String, ThreatCategory>{};
  for (final e in categoryRaw.entries) {
    final cat = ThreatCategory.fromLabel(e.value);
    if (cat != null) categoryByHash[e.key] = cat;
  }

  return EngineIndex(
    whitelistLocal: whitelistLocal,
    blacklistLocal: blacklistLocal,
    allowlistGlobal: const {},
    blacklistGlobal: blacklistGlobal,
    categoryByHash: categoryByHash,
    config: EngineShieldConfig(
      extorsion: config.extorsion,
      callcenter: config.callcenter,
      ley: config.ley,
    ),
  );
});

/// Stream de la configuración del escudo (fuente de reactividad para el índice).
final shieldConfigStreamProvider = StreamProvider((ref) async* {
  final dao = await ref.watch(shieldConfigDaoProvider.future);
  yield* dao.watchConfig();
});

/// Observa el índice y lo **proyecta** al nativo cada vez que cambia (config o
/// dataset). Mantener vivo este provider = RF-SHIELD-04 real: el toggle del
/// Dashboard reconfigura el motor que filtra.
final engineProjectionProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<EngineIndex>>(engineIndexProvider, (_, next) {
    final index = next.valueOrNull;
    if (index != null) {
      ref.read(nativeSnapshotWriterProvider).project(index);
    }
  }, fireImmediately: true);
});
