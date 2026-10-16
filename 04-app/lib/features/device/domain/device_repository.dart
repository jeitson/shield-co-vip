import 'package:shield_app/core/error/result.dart';

/// Resultado del registro/activación del dispositivo (DA-03).
enum DeviceRegistrationStatus {
  /// Dispositivo activo: protección tomada en este dispositivo.
  activo,

  /// El número ya está protegido en otro dispositivo; requiere confirmación del
  /// usuario para revocar aquel y tomar la protección aquí.
  pendienteConfirmacion,
}

/// Resultado del refresh de sesión de dispositivo (DA-04).
enum DeviceSessionStatus {
  /// El dispositivo sigue activo; la sesión continúa.
  activo,

  /// El dispositivo fue revocado (p. ej. el número se activó en otro device):
  /// la app debe borrar el material sensible y volver a login.
  revocado,

  /// El dispositivo aún no está registrado en el servidor (p. ej. primer login
  /// antes del `register`). No se borra material; se procede a registrar.
  noRegistrado,
}

/// Gestiona el registro del dispositivo y la sesión de dispositivo (DA-02/03/04).
abstract interface class DeviceRepository {
  /// Registra este dispositivo tras el login (con el número del perfil).
  /// Devuelve `activo` o `pendienteConfirmacion` (exclusividad por número).
  Future<Result<DeviceRegistrationStatus>> registerThisDevice({
    required String numeroProtegido,
  });

  /// Confirma la exclusividad: revoca el dispositivo anterior y activa este.
  Future<Result<void>> confirmExclusivity({required String numeroProtegido});

  /// Refresca la sesión de dispositivo (12h). `revocado` dispara el wipe.
  Future<Result<DeviceSessionStatus>> refresh();
}
