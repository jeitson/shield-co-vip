import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';

/// Mapea el JSON de `GET /v1/sync` a [SyncDelta].
///
/// Contrato (`05-backend-api-metricas` §05.2):
/// ```json
/// { "current_version": 1540, "pepper_version": 3,
///   "altas": { "phone_hashes": [ { "hash": "...", "categoria": "...", "nivel": "..." } ] },
///   "bajas": { "phone_hashes": ["h1","h2"] },
///   "checksum": "sha256:...", "full": false }
/// ```
abstract final class SyncDeltaDto {
  static SyncDelta fromJson(Map<String, dynamic> json) {
    final altasObj = json['altas'] as Map<String, dynamic>?;
    final bajasObj = json['bajas'] as Map<String, dynamic>?;
    final altasRaw = (altasObj?['phone_hashes'] as List?) ?? const <dynamic>[];
    final bajasRaw = (bajasObj?['phone_hashes'] as List?) ?? const <dynamic>[];

    return SyncDelta(
      currentVersion: (json['current_version'] as num?)?.toInt() ?? 0,
      pepperVersion: (json['pepper_version'] as num?)?.toInt() ?? 1,
      altas: altasRaw
          .whereType<Map<String, dynamic>>()
          .map(
            (h) => HashSignature(
              hash: h['hash'] as String,
              categoria: h['categoria'] as String? ?? '',
              nivel: h['nivel'] as String? ?? 'MEDIO',
            ),
          )
          .toList(),
      bajas: bajasRaw.whereType<String>().toList(),
      checksum: json['checksum'] as String? ?? '',
      full: json['full'] as bool? ?? false,
    );
  }
}
