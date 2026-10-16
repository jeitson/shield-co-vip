import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inyecta las cabeceras de autenticación de Supabase en cada request a las
/// Edge Functions: el `apikey` (anon, público), el `Authorization: Bearer` con
/// el `access_token` de la sesión activa, y —si se provee— el `x-device-id`
/// (DA-02) para que el backend verifique "dispositivo activo" (DA-03/04).
///
/// Así el sync (`v1-sync`/`v1-pepper`/`v1-session`) queda **autenticado de
/// verdad** y pasa por el mismo pipeline Dio que el resto (versión de app DA-15,
/// mapeo de errores), en vez de usar `functions.invoke` del SDK.
class SupabaseAuthInterceptor extends Interceptor {
  SupabaseAuthInterceptor(this._anonKey, {this.deviceId});

  final String _anonKey;

  /// Proveedor opcional del device_id de instalación (lectura asíncrona del
  /// secure storage). Si es `null`, no se añade el header.
  final Future<String?> Function()? deviceId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['apikey'] = _anonKey;
    // `Supabase.instance` lanza si el SDK no se inicializó (p. ej. build sin
    // credenciales). Se protege para no romper el request ni la UI que lo dispara.
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Sin Supabase inicializado: seguir sin Authorization (el backend rechaza).
    }
    final id = await deviceId?.call();
    if (id != null && id.isNotEmpty) {
      options.headers['x-device-id'] = id;
    }
    handler.next(options);
  }
}
