import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/sync/data/sync_checksum.dart';
import 'package:shield_app/features/sync/domain/entities/sync_delta.dart';

/// Verifica que el checksum del cliente es determinista y que `verify` acepta el
/// valor recomputado y rechaza uno alterado. El formato canónico debe coincidir
/// con la Edge Function `v1-sync` (ver sync_checksum.dart).
void main() {
  SyncDelta build(String checksum) => SyncDelta(
    currentVersion: 42,
    pepperVersion: 3,
    altas: [
      const HashSignature(hash: 'bbb', categoria: 'cat', nivel: 'ALTO'),
      const HashSignature(hash: 'aaa', categoria: 'cat', nivel: 'MEDIO'),
    ],
    bajas: const ['zzz', 'yyy'],
    checksum: checksum,
    full: false,
  );

  test('compute es estable e independiente del orden de entrada', () {
    final a = build('');
    final b = SyncDelta(
      currentVersion: 42,
      pepperVersion: 3,
      // Mismas firmas en otro orden.
      altas: [
        const HashSignature(hash: 'aaa', categoria: 'cat', nivel: 'MEDIO'),
        const HashSignature(hash: 'bbb', categoria: 'cat', nivel: 'ALTO'),
      ],
      bajas: const ['yyy', 'zzz'],
      checksum: '',
      full: false,
    );
    expect(SyncChecksum.compute(a), SyncChecksum.compute(b));
  });

  test('verify acepta el checksum recomputado', () {
    final delta = build('');
    final withChecksum = SyncDelta(
      currentVersion: delta.currentVersion,
      pepperVersion: delta.pepperVersion,
      altas: delta.altas,
      bajas: delta.bajas,
      checksum: SyncChecksum.compute(delta),
      full: delta.full,
    );
    expect(SyncChecksum.verify(withChecksum), isTrue);
  });

  test('verify rechaza un checksum alterado', () {
    expect(SyncChecksum.verify(build('sha256:0000')), isFalse);
  });

  test('el checksum tiene el prefijo sha256:', () {
    expect(SyncChecksum.compute(build('')), startsWith('sha256:'));
  });
}
