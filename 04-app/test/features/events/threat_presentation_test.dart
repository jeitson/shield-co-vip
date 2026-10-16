import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/threat_presentation.dart';

void main() {
  group('ThreatPresentation.levelOf', () {
    test('extorsión y phishing son ALTO (críticas)', () {
      expect(ThreatPresentation.levelOf(ThreatCategory.extorsion), ThreatLevel.alto);
      expect(ThreatPresentation.levelOf(ThreatCategory.phishing), ThreatLevel.alto);
    });

    test('call center y fantasma son MEDIO', () {
      expect(ThreatPresentation.levelOf(ThreatCategory.callcenter), ThreatLevel.medio);
      expect(
        ThreatPresentation.levelOf(ThreatCategory.llamadaFantasma),
        ThreatLevel.medio,
      );
    });

    test('Ley 2300 y comercial son BAJO', () {
      expect(ThreatPresentation.levelOf(ThreatCategory.ley2300), ThreatLevel.bajo);
      expect(ThreatPresentation.levelOf(ThreatCategory.comercial), ThreatLevel.bajo);
    });
  });

  group('ThreatPresentation.categoryForLayer', () {
    test('mapea la capa a su categoría cabecera', () {
      expect(
        ThreatPresentation.categoryForLayer('extorsion'),
        ThreatCategory.extorsion,
      );
      expect(
        ThreatPresentation.categoryForLayer('callcenter'),
        ThreatCategory.callcenter,
      );
      expect(ThreatPresentation.categoryForLayer('ley'), ThreatCategory.ley2300);
    });

    test('capa local/desconocida → comercial (sin riesgo aparente)', () {
      expect(
        ThreatPresentation.categoryForLayer('local'),
        ThreatCategory.comercial,
      );
      expect(ThreatPresentation.categoryForLayer(null), ThreatCategory.comercial);
    });
  });
}
