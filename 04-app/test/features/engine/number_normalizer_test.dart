import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/engine/domain/number_normalizer.dart';

void main() {
  test('móvil CO de 10 dígitos se normaliza a E.164', () {
    expect(NumberNormalizer.normalize('3001234567'), '+573001234567');
  });

  test('acepta formato con espacios y guiones', () {
    expect(NumberNormalizer.normalize('300 123 4567'), '+573001234567');
    expect(NumberNormalizer.normalize('300-123-4567'), '+573001234567');
  });

  test('normaliza aunque venga con +57 / 57 delante', () {
    expect(NumberNormalizer.normalize('+57 300 123 4567'), '+573001234567');
    expect(NumberNormalizer.normalize('573001234567'), '+573001234567');
  });

  test('mismo número en distintos formatos colapsa al mismo E.164', () {
    final a = NumberNormalizer.normalize('+57 300 123 4567');
    final b = NumberNormalizer.normalize('3001234567');
    expect(a, b); // corrige la deuda del prototipo (comparaba strings exactos)
  });

  test('código corto SMS se devuelve tal cual (no E.164)', () {
    expect(NumberNormalizer.normalize('890123'), '890123');
    expect(NumberNormalizer.isShortCode('890123'), isTrue);
  });

  test('número que no es móvil CO ni código corto → null', () {
    expect(NumberNormalizer.normalize('123456789012345'), isNull);
    expect(NumberNormalizer.normalize('6012345678'), isNull); // fijo, no 3xx
  });

  test('entrada vacía o sin dígitos → null', () {
    expect(NumberNormalizer.normalize(''), isNull);
    expect(NumberNormalizer.normalize('abc'), isNull);
  });

  test('E.164 válido no se marca como código corto', () {
    expect(NumberNormalizer.isShortCode('+573001234567'), isFalse);
  });
}
