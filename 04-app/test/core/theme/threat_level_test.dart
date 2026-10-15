import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/threat_level.dart';

void main() {
  group('ThreatLevel', () {
    test('mapea cada nivel a su color semántico', () {
      expect(ThreatLevel.alto.color, AppColors.danger);
      expect(ThreatLevel.medio.color, AppColors.warning);
      expect(ThreatLevel.bajo.color, AppColors.success);
    });

    test('expone label textual redundante para accesibilidad', () {
      expect(ThreatLevel.alto.label, 'ALTO');
      expect(ThreatLevel.medio.label, 'MEDIO');
      expect(ThreatLevel.bajo.label, 'BAJO');
    });
  });
}
