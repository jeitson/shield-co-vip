import 'package:flutter/services.dart';

/// Lee el identificador estable del dispositivo desde la capa nativa.
///
/// En Android devuelve `Settings.Secure.ANDROID_ID`: estable entre
/// reinstalaciones (misma firma de app + mismo usuario del SO), sin permisos y
/// sin ser IMEI/serial. En otras plataformas o si no está disponible, devuelve
/// `null` y el `DeviceIdStore` cae al UUID aleatorio persistido.
class HardwareIdSource {
  const HardwareIdSource();

  static const _channel =
      MethodChannel('com.cifradocero.shield_app/platform_device');

  /// Identificador de hardware estable, o `null` si no se puede obtener.
  ///
  /// Nunca propaga: cualquier fallo (plataforma no Android, canal ausente, o
  /// binding de servicios no inicializado en tests) degrada a `null` para que
  /// el `DeviceIdStore` caiga a su fallback sin romper la identidad del equipo.
  Future<String?> stableHardwareId() async {
    try {
      final id = await _channel.invokeMethod<String>('getAndroidId');
      if (id == null || id.isEmpty) return null;
      // Android puede devolver un valor comodín (todo ceros) en estados raros.
      if (RegExp(r'^0+$').hasMatch(id)) return null;
      return id;
    } catch (_) {
      // PlatformException / MissingPluginException / binding no inicializado.
      return null;
    }
  }
}
