import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/auth/data/datasources/auth_remote_data_source_fake.dart';
import 'package:shield_app/features/auth/data/dtos/auth_session_dto.dart';
import 'package:shield_app/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('AuthRemoteDataSourceFake', () {
    late AuthRemoteDataSourceFake source;

    setUp(() => source = AuthRemoteDataSourceFake());

    test(
      'login exitoso con el usuario semilla devuelve sesión de 12h',
      () async {
        final result = await source.login(
          identifier: 'seguridad@nodo.zero',
          password: 'cifradocero2026',
        );

        expect(result.isOk, isTrue);
        final dto = (result as Ok<AuthSessionDto>).value;
        expect(dto.user.correo, 'seguridad@nodo.zero');
        // Ventana de 12h (DA-04), con margen de tolerancia.
        final diff = dto.expiresAt.difference(DateTime.now());
        expect(diff.inHours, inInclusiveRange(11, 12));
      },
    );

    test('login con clave incorrecta falla (CA-LOGIN-03)', () async {
      final result = await source.login(
        identifier: 'seguridad@nodo.zero',
        password: 'incorrecta',
      );
      expect(result.isErr, isTrue);
    });

    test('register nuevo crea cuenta y abre sesión', () async {
      final result = await source.register(
        const RegisterData(
          nombre: 'Ana',
          apellido: 'Gómez',
          correo: 'ana@dominio.co',
          password: 'clavesegura1',
          celularE164: '+573011112233',
          terminosAceptados: true,
          privacidadAceptada: true,
        ),
      );
      expect(result.isOk, isTrue);
      expect(
        (result as Ok<AuthSessionDto>).value.user.correo,
        'ana@dominio.co',
      );
    });

    test(
      'register con correo existente falla sin duplicar (CA-REG-05)',
      () async {
        final result = await source.register(
          const RegisterData(
            nombre: 'Otro',
            apellido: 'Usuario',
            correo: 'seguridad@nodo.zero',
            password: 'clavesegura1',
            celularE164: '+573019998877',
            terminosAceptados: true,
            privacidadAceptada: true,
          ),
        );
        expect(result.isErr, isTrue);
      },
    );
  });
}
