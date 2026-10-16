import 'package:equatable/equatable.dart';

/// Una firma de número peligroso tal como llega del delta (solo hash + metadatos;
/// nunca el número, RN-01).
class HashSignature extends Equatable {
  const HashSignature({
    required this.hash,
    required this.categoria,
    required this.nivel,
  });

  final String hash;
  final String categoria;
  final String nivel;

  @override
  List<Object?> get props => [hash, categoria, nivel];
}

/// Resultado del delta sync (`GET /v1/sync`): altas, bajas y metadatos de
/// versión + el `checksum` para verificar integridad (`02-seguridad` §02.6).
class SyncDelta extends Equatable {
  const SyncDelta({
    required this.currentVersion,
    required this.pepperVersion,
    required this.altas,
    required this.bajas,
    required this.checksum,
    required this.full,
  });

  /// Versión global del dataset tras este delta.
  final int currentVersion;

  /// Versión del pepper vigente en el servidor.
  final int pepperVersion;

  /// Firmas nuevas/actualizadas a insertar.
  final List<HashSignature> altas;

  /// Hashes dados de baja (soft delete) a marcar como removidos.
  final List<String> bajas;

  /// Checksum sha256 del payload canónico (lo recomputa el cliente).
  final String checksum;

  /// `true` si es un dataset completo (full resync), no un delta incremental.
  final bool full;

  @override
  List<Object?> get props => [
    currentVersion,
    pepperVersion,
    altas,
    bajas,
    checksum,
    full,
  ];
}
