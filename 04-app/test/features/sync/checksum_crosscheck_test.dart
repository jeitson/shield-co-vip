import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/sync/data/dtos/sync_delta_dto.dart';
import 'package:shield_app/features/sync/data/sync_checksum.dart';

/// Verificación **cruzada cliente↔servidor** del checksum: toma un payload REAL
/// capturado de la Edge Function `v1-sync` desplegada (300 altas) y confirma que
/// el cálculo canónico en Dart (`SyncChecksum`) produce exactamente el mismo
/// `sha256` que calculó el servidor en TypeScript. Si este test pasa, la
/// verificación de integridad del sync funcionará contra el backend real
/// (02-seguridad §02.6). Blinda contra divergencias de serialización canónica.
void main() {
  test('el checksum del payload real del servidor valida en el cliente', () {
    final file = File('test/features/sync/fixtures/real_sync_payload.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final delta = SyncDeltaDto.fromJson(json);

    expect(delta.altas.length, 300);
    expect(delta.full, isTrue);
    // El núcleo: el checksum recomputado en Dart == el del servidor.
    expect(
      SyncChecksum.verify(delta),
      isTrue,
      reason:
          'El checksum canónico de Dart no coincide con el de la Edge Function. '
          'Revisa que `canonical()` (TS) y `SyncChecksum.compute()` (Dart) usen '
          'el mismo formato y orden.',
    );
  });
}
