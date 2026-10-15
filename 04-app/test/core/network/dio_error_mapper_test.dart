import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/network/dio_error_mapper.dart';

DioException _responseError(int statusCode, {Object? data}) {
  final requestOptions = RequestOptions(path: '/x');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  group('DioErrorMapper', () {
    test('timeout -> NetworkFailure', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(DioErrorMapper.map(error), isA<NetworkFailure>());
    });

    test('401 -> AuthFailure', () {
      expect(DioErrorMapper.map(_responseError(401)), isA<AuthFailure>());
    });

    test('426 -> UpgradeRequiredFailure con min_version', () {
      final failure = DioErrorMapper.map(
        _responseError(426, data: {'min_version': '1.2.0'}),
      );
      expect(failure, isA<UpgradeRequiredFailure>());
      expect((failure as UpgradeRequiredFailure).minVersion, '1.2.0');
    });

    test('500 -> ServerFailure con statusCode', () {
      final failure = DioErrorMapper.map(
        _responseError(500, data: {'error': 'interno'}),
      );
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
      expect(failure.message, 'interno');
    });

    test('error no-Dio -> UnknownFailure', () {
      expect(DioErrorMapper.map(Exception('x')), isA<UnknownFailure>());
    });
  });
}
