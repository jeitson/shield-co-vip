import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/db/daos/shield_config_dao.dart';
import 'package:shield_app/core/theme/app_theme.dart';
import 'package:shield_app/features/shield/presentation/widgets/layer_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('capa activa no muestra panel de advertencia', (tester) async {
    await _pump(
      tester,
      LayerCard(spec: LayerSpec.extorsion, enabled: true, onToggle: (_) {}),
    );
    expect(find.text('ADVERTENCIA DE RIESGO ALTO'), findsNothing);
  });

  testWidgets(
    'extorsión desactivada muestra advertencia de severidad ALTA (CA-SHIELD-09)',
    (tester) async {
      await _pump(
        tester,
        LayerCard(spec: LayerSpec.extorsion, enabled: false, onToggle: (_) {}),
      );
      expect(find.text('ADVERTENCIA DE RIESGO ALTO'), findsOneWidget);
    },
  );

  testWidgets('callcenter desactivada muestra advertencia MEDIA (ámbar)', (
    tester,
  ) async {
    await _pump(
      tester,
      LayerCard(spec: LayerSpec.callcenter, enabled: false, onToggle: (_) {}),
    );
    expect(find.text('ADVERTENCIA DE EXPOSICIÓN'), findsOneWidget);
  });

  testWidgets('tocar el switch dispara onToggle con el nuevo valor', (
    tester,
  ) async {
    bool? captured;
    await _pump(
      tester,
      LayerCard(
        spec: LayerSpec.ley,
        enabled: true,
        onToggle: (v) => captured = v,
      ),
    );
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(captured, isFalse); // estaba activa → se apaga
  });

  test('severidades correctas por capa (RN-SHIELD-02)', () {
    expect(LayerSpec.extorsion.severity, LayerSeverity.alta);
    expect(LayerSpec.callcenter.severity, LayerSeverity.media);
    expect(LayerSpec.ley.severity, LayerSeverity.media);
  });

  test('cada LayerSpec mapea a su ShieldLayer', () {
    expect(LayerSpec.extorsion.layer, ShieldLayer.extorsion);
    expect(LayerSpec.callcenter.layer, ShieldLayer.callcenter);
    expect(LayerSpec.ley.layer, ShieldLayer.ley);
  });
}
