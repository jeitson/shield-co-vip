import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/features/auth/domain/value_objects/colombian_phone.dart';
import 'package:shield_app/features/auth/domain/value_objects/email.dart';
import 'package:shield_app/features/auth/domain/value_objects/password.dart';

void main() {
  group('Email', () {
    test('acepta un correo válido y lo normaliza a minúsculas', () {
      final r = Email.tryParse('  Usuario@Proton.ME ');
      expect(r.error, isNull);
      expect(r.value?.value, 'usuario@proton.me');
    });

    test('rechaza vacío', () {
      expect(Email.tryParse('').value, isNull);
    });

    test('rechaza formato inválido (CA-REG-04)', () {
      expect(Email.tryParse('no-es-correo').value, isNull);
      expect(Email.tryParse('a@b').value, isNull);
      expect(Email.tryParse('a@@b.com').value, isNull);
    });
  });

  group('Password', () {
    test('acepta >= 8 caracteres', () {
      final r = Password.tryParse('12345678');
      expect(r.error, isNull);
      expect(r.value, isNotNull);
    });

    test('rechaza < 8 caracteres (RN-REG-02 / CA-REG-02)', () {
      final r = Password.tryParse('1234567');
      expect(r.value, isNull);
      expect(r.error, contains('8'));
    });

    test('toString no revela el valor', () {
      final r = Password.tryParse('supersecreta');
      expect(r.value.toString(), isNot(contains('supersecreta')));
    });
  });

  group('ColombianPhone', () {
    test('canoniza a E.164 un móvil válido (RN-04)', () {
      final r = ColombianPhone.tryParse('300 123 4567');
      expect(r.error, isNull);
      expect(r.value?.e164, '+573001234567');
      expect(r.value?.nationalNumber, '3001234567');
    });

    test('tolera que el usuario reescriba 57 como indicativo', () {
      final r = ColombianPhone.tryParse('57 300 123 4567');
      expect(r.value?.e164, '+573001234567');
    });

    test('rechaza longitud distinta de 10', () {
      expect(ColombianPhone.tryParse('30012345').value, isNull);
    });

    test('rechaza móvil que no inicia en 3 (RN-REG-04)', () {
      final r = ColombianPhone.tryParse('6011234567');
      expect(r.value, isNull);
      expect(r.error, contains('3'));
    });
  });
}
