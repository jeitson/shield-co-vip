import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/engine/data/native_snapshot_writer.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/engine/domain/precedence_engine.dart';

void main() {
  test(
    'encode serializa hashes, config y layerByHash sin números legibles',
    () {
      final index = EngineIndex(
        whitelistLocal: {'wl'},
        blacklistLocal: {'bl'},
        allowlistGlobal: {'al'},
        blacklistGlobal: {'bg'},
        categoryByHash: {'bg': ThreatCategory.extorsion},
        config: const EngineShieldConfig(
          extorsion: true,
          callcenter: false,
          ley: true,
        ),
      );

      final json = jsonDecode(
        NativeSnapshotWriter.encode(index),
      ) as Map<String, dynamic>;

      expect(json['version'], 1);
      expect(json['whitelistLocal'], ['wl']);
      expect(json['blacklistLocal'], ['bl']);
      expect(json['allowlistGlobal'], ['al']);
      expect(json['blacklistGlobal'], ['bg']);
      expect((json['layerByHash'] as Map)['bg'], 'extorsion');
      expect((json['config'] as Map)['callcenter'], false);
      // No debe haber ninguna clave con números legibles.
      expect(json.containsKey('numeros'), isFalse);
    },
  );

  test('phishing se proyecta como capa extorsion', () {
    final index = EngineIndex(
      whitelistLocal: const {},
      blacklistLocal: const {},
      allowlistGlobal: const {},
      blacklistGlobal: {'h'},
      categoryByHash: {'h': ThreatCategory.phishing},
      config: const EngineShieldConfig(
        extorsion: true,
        callcenter: true,
        ley: true,
      ),
    );
    final json =
        jsonDecode(NativeSnapshotWriter.encode(index)) as Map<String, dynamic>;
    expect((json['layerByHash'] as Map)['h'], 'extorsion');
  });
}
