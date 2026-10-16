import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/shield/domain/shield_status.dart';
import 'package:shield_app/features/shield/presentation/sync_time_format.dart';

void main() {
  group('ShieldStatus.fromActiveCount (RN-03)', () {
    test('3 capas → Total', () {
      expect(ShieldStatus.fromActiveCount(3), ShieldStatus.total);
    });
    test('2 capas → Parcial', () {
      expect(ShieldStatus.fromActiveCount(2), ShieldStatus.parcial);
    });
    test('1 capa → Parcial', () {
      expect(ShieldStatus.fromActiveCount(1), ShieldStatus.parcial);
    });
    test('0 capas → Riesgo', () {
      expect(ShieldStatus.fromActiveCount(0), ShieldStatus.riesgo);
    });
    test('total y parcial se consideran protegidos; riesgo no', () {
      expect(ShieldStatus.total.isProtected, isTrue);
      expect(ShieldStatus.parcial.isProtected, isTrue);
      expect(ShieldStatus.riesgo.isProtected, isFalse);
    });
  });

  group('formatSyncTime (es-CO)', () {
    final now = DateTime(2026, 10, 15, 18, 30);
    test('hoy', () {
      expect(
        formatSyncTime(DateTime(2026, 10, 15, 4, 12), now: now),
        'Hoy, 04:12',
      );
    });
    test('ayer', () {
      expect(
        formatSyncTime(DateTime(2026, 10, 14, 22, 5), now: now),
        'Ayer, 22:05',
      );
    });
    test('fecha anterior → dd/MM HH:mm', () {
      expect(
        formatSyncTime(DateTime(2026, 10, 1, 9, 0), now: now),
        '01/10 09:00',
      );
    });
  });
}
