import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok reporta isOk y conserva el valor', () {
      const result = Ok<int>(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect((result).value, 42);
    });

    test('Err reporta isErr y conserva el failure', () {
      const failure = NetworkFailure();
      const result = Err<int>(failure);
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect((result).failure, failure);
    });

    test('map transforma el valor de éxito', () {
      const Result<int> result = Ok(2);
      final mapped = result.map((v) => v * 10);
      expect(mapped, isA<Ok<int>>());
      expect((mapped as Ok<int>).value, 20);
    });

    test('map preserva el error sin invocar la transformación', () {
      const Result<int> result = Err(ServerFailure('boom'));
      var called = false;
      final mapped = result.map((v) {
        called = true;
        return v;
      });
      expect(called, isFalse);
      expect(mapped, isA<Err<int>>());
    });

    test('fold colapsa ambos casos', () {
      const Result<int> ok = Ok(5);
      const Result<int> err = Err(UnknownFailure());
      expect(ok.fold((v) => 'ok:$v', (f) => 'err'), 'ok:5');
      expect(err.fold((v) => 'ok', (f) => 'err'), 'err');
    });
  });
}
