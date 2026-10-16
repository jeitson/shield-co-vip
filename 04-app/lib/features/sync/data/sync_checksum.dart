import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';

/// Recomputa el checksum del payload del delta para verificar integridad
/// (`02-seguridad` §02.6). **Debe** producir exactamente el mismo valor que la
/// Edge Function `v1-sync` (función `canonical` + `sha256Hex`), o la verificación
/// fallará siempre.
///
/// Formato canónico del servidor (orden fijo, unido por `|`):
///   current_version | pepper_version | (full?1:0) | altas | bajas
/// donde `altas` = "hash:categoria:nivel" por firma, **ordenado** y unido por
/// `,`; y `bajas` = hashes **ordenados** unidos por `,`. Resultado: `sha256:<hex>`.
abstract final class SyncChecksum {
  static String compute(SyncDelta delta) {
    final altas =
        (delta.altas.map((h) => '${h.hash}:${h.categoria}:${h.nivel}').toList()
              ..sort())
            .join(',');
    final bajas = ([...delta.bajas]..sort()).join(',');

    final canonical = [
      delta.currentVersion,
      delta.pepperVersion,
      delta.full ? '1' : '0',
      altas,
      bajas,
    ].join('|');

    final digest = sha256.convert(utf8.encode(canonical));
    return 'sha256:${digest.toString()}';
  }

  /// `true` si el checksum recomputado coincide con el recibido.
  static bool verify(SyncDelta delta) => compute(delta) == delta.checksum;
}
