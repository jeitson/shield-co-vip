import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/engine/domain/entities/block_decision.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/engine/domain/precedence_engine.dart';

/// Pruebas exhaustivas de la jerarquía de precedencia de 5 niveles
/// (`03-datos` §03.5) y del respeto a RN-SHIELD-05 (capa off deja pasar).
void main() {
  const allLayersOn = EngineShieldConfig(
    extorsion: true,
    callcenter: true,
    ley: true,
  );

  EngineIndex index({
    Set<String> whitelistLocal = const {},
    Set<String> blacklistLocal = const {},
    Set<String> allowlistGlobal = const {},
    Set<String> blacklistGlobal = const {},
    Map<String, ThreatCategory> categoryByHash = const {},
    EngineShieldConfig config = allLayersOn,
  }) => EngineIndex(
    whitelistLocal: whitelistLocal,
    blacklistLocal: blacklistLocal,
    allowlistGlobal: allowlistGlobal,
    blacklistGlobal: blacklistGlobal,
    categoryByHash: categoryByHash,
    config: config,
  );

  test('nivel 1: blanca local permite aunque esté en negra global', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(whitelistLocal: {'h'}, blacklistGlobal: {'h'}),
    );
    expect(d.action, BlockAction.allow);
    expect(d.level, PrecedenceLevel.whitelistLocal);
  });

  test('nivel 2: allowlist global permite aunque esté en negra global', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(allowlistGlobal: {'h'}, blacklistGlobal: {'h'}),
    );
    expect(d.action, BlockAction.allow);
    expect(d.level, PrecedenceLevel.allowlistGlobal);
  });

  test('nivel 1 gana sobre nivel 2 (soberanía del usuario)', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(whitelistLocal: {'h'}, allowlistGlobal: {'h'}),
    );
    expect(d.level, PrecedenceLevel.whitelistLocal);
  });

  test('nivel 3: negra local bloquea', () {
    final d = PrecedenceEngine.decide('h', index(blacklistLocal: {'h'}));
    expect(d.action, BlockAction.block);
    expect(d.level, PrecedenceLevel.blacklistLocal);
  });

  test('nivel 4: negra global sin categoría bloquea', () {
    final d = PrecedenceEngine.decide('h', index(blacklistGlobal: {'h'}));
    expect(d.action, BlockAction.block);
    expect(d.level, PrecedenceLevel.blacklistGlobal);
  });

  test('nivel 5: amenaza con capa activa bloquea', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(
        blacklistGlobal: {'h'},
        categoryByHash: {'h': ThreatCategory.extorsion},
      ),
    );
    expect(d.action, BlockAction.block);
    expect(d.level, PrecedenceLevel.shieldLayers);
  });

  test(
    'nivel 5: amenaza con su capa DESACTIVADA deja pasar (RN-SHIELD-05)',
    () {
      final d = PrecedenceEngine.decide(
        'h',
        index(
          blacklistGlobal: {'h'},
          categoryByHash: {'h': ThreatCategory.extorsion},
          config: const EngineShieldConfig(
            extorsion: false,
            callcenter: true,
            ley: true,
          ),
        ),
      );
      expect(d.action, BlockAction.allow);
      expect(d.level, PrecedenceLevel.shieldLayers);
    },
  );

  test('capa callcenter off no afecta a amenaza de extorsión', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(
        blacklistGlobal: {'h'},
        categoryByHash: {'h': ThreatCategory.extorsion},
        config: const EngineShieldConfig(
          extorsion: true,
          callcenter: false,
          ley: true,
        ),
      ),
    );
    expect(d.action, BlockAction.block);
  });

  test('phishing lo gobierna la capa extorsión', () {
    final offExtorsion = const EngineShieldConfig(
      extorsion: false,
      callcenter: true,
      ley: true,
    );
    final d = PrecedenceEngine.decide(
      'h',
      index(
        blacklistGlobal: {'h'},
        categoryByHash: {'h': ThreatCategory.phishing},
        config: offExtorsion,
      ),
    );
    expect(d.action, BlockAction.allow);
  });

  test('negra local gana sobre negra global (orden de niveles)', () {
    final d = PrecedenceEngine.decide(
      'h',
      index(
        blacklistLocal: {'h'},
        blacklistGlobal: {'h'},
        categoryByHash: {'h': ThreatCategory.extorsion},
        config: const EngineShieldConfig(
          extorsion: false,
          callcenter: false,
          ley: false,
        ),
      ),
    );
    // Aunque todas las capas estén off, la negra local (nivel 3) ya bloqueó.
    expect(d.action, BlockAction.block);
    expect(d.level, PrecedenceLevel.blacklistLocal);
  });

  test('sin coincidencias: permite por defecto', () {
    final d = PrecedenceEngine.decide('desconocido', index());
    expect(d.action, BlockAction.allow);
    expect(d.level, PrecedenceLevel.defaultAllow);
  });
}
