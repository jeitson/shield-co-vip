import 'dart:io';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shield_app/core/network/network_providers.dart';
import 'package:shield_app/features/device/domain/device_info.dart';

/// Recopila los metadatos no sensibles del dispositivo (DA-02) con
/// `device_info_plus`. Solo marca/modelo/SO; nunca IMEI/Android ID.
abstract final class DeviceInfoLoader {
  static Future<DeviceInfo> load() async {
    final plugin = DeviceInfoPlugin();
    final locale = ui.PlatformDispatcher.instance.locale.toLanguageTag();
    final tz = DateTime.now().timeZoneName;

    if (Platform.isAndroid) {
      final a = await plugin.androidInfo;
      return DeviceInfo(
        marca: a.manufacturer,
        modelo: a.model,
        so: 'android',
        soVersion: a.version.release,
        appVersion: kAppVersion,
        idioma: locale,
        zonaHoraria: tz,
      );
    }
    if (Platform.isIOS) {
      final i = await plugin.iosInfo;
      return DeviceInfo(
        marca: 'Apple',
        modelo: i.utsname.machine,
        so: 'ios',
        soVersion: i.systemVersion,
        appVersion: kAppVersion,
        idioma: locale,
        zonaHoraria: tz,
      );
    }
    return DeviceInfo(
      marca: 'desconocido',
      modelo: 'desconocido',
      so: Platform.operatingSystem,
      soVersion: Platform.operatingSystemVersion,
      appVersion: kAppVersion,
      idioma: locale,
      zonaHoraria: tz,
    );
  }
}
