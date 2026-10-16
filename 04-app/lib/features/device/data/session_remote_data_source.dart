import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/core/network/api_client.dart';
import 'package:shield_app/features/device/domain/device_info.dart';
import 'package:shield_app/features/device/domain/device_repository.dart';

/// Fuente remota del subsistema de dispositivos: habla con la Edge Function
/// `v1-session` (acciones register / activate / refresh) vía el [ApiClient]
/// autenticado (Bearer JWT + `x-device-id`).
class SessionRemoteDataSource {
  SessionRemoteDataSource(this._client);

  final ApiClient _client;

  /// `register`: registra/actualiza el dispositivo y calcula la exclusividad.
  Future<Result<Map<String, dynamic>>> register({
    required String deviceId,
    required DeviceInfo info,
    required String numeroProtegido,
  }) {
    return _client.post<Map<String, dynamic>>(
      'v1-session',
      data: {
        'action': 'register',
        'device_id': deviceId,
        'numero_protegido': numeroProtegido,
        ...info.toJson(),
      },
    );
  }

  /// `activate`: confirma la exclusividad (revoca el anterior, activa este).
  Future<Result<Map<String, dynamic>>> activate({
    required String deviceId,
    required String numeroProtegido,
  }) {
    return _client.post<Map<String, dynamic>>(
      'v1-session',
      data: {
        'action': 'activate',
        'device_id': deviceId,
        'numero_protegido': numeroProtegido,
      },
    );
  }

  /// `refresh`: renueva la sesión de dispositivo (12h, DA-04).
  ///
  /// Distingue con precisión por el **cuerpo** del error, para no borrar material
  /// por un 401 transitorio de sesión:
  /// - 200 → `activo`.
  /// - 401 con `{error: device_revocado}` → `revocado` (dispara el wipe, DA-04).
  /// - 404 `device_not_found` (aún no registrado) → `noRegistrado` (no borra).
  /// - cualquier otro error/red → `Err(Failure)` para reintentar (no borra).
  Future<Result<DeviceSessionStatus>> refresh({
    required String deviceId,
  }) async {
    final res = await _client.postRaw(
      'v1-session',
      data: {'action': 'refresh', 'device_id': deviceId},
    );

    final status = res.status;
    final body = res.body;
    final errorCode = body is Map && body['error'] is String
        ? body['error'] as String
        : null;

    if (status == 200) return const Ok(DeviceSessionStatus.activo);

    if (status == 401 && errorCode == 'device_revocado') {
      return const Err(DeviceRevokedFailure());
    }
    // 404 (no registrado aún) u otros: no revocado. Se trata como "no activo
    // todavía", sin borrar material. Se propaga un fallo recuperable.
    if (status == 404 || errorCode == 'device_not_found') {
      return const Ok(DeviceSessionStatus.noRegistrado);
    }
    if (status == null) {
      return const Err(NetworkFailure());
    }
    return Err(ServerFailure('refresh_failed', statusCode: status));
  }
}
