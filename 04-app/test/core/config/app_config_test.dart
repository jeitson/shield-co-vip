import 'package:flutter_test/flutter_test.dart';
import 'package:shield_app/core/config/app_config.dart';
import 'package:shield_app/core/config/app_environment.dart';

void main() {
  group('AppConfig', () {
    test('dev usa entorno dev y logging activo', () {
      final config = AppConfig.dev();
      expect(config.environment, AppEnvironment.dev);
      expect(config.environment.isDev, isTrue);
      expect(config.enableLogging, isTrue);
    });

    test('prod usa entorno prod y logging apagado', () {
      final config = AppConfig.prod();
      expect(config.environment, AppEnvironment.prod);
      expect(config.environment.isProd, isTrue);
      expect(config.enableLogging, isFalse);
    });

    test('versionedApiBaseUrl concatena base + versión', () {
      final config = AppConfig.dev();
      // Lleva barra final para que Dio concatene bien los paths relativos
      // (`.../v1/` + `v1-sync` = `.../v1/v1-sync`, no `.../v1v1-sync`).
      expect(
        config.versionedApiBaseUrl,
        '${config.apiBaseUrl}/${config.apiVersion}/',
      );
      expect(config.versionedApiBaseUrl, endsWith('/v1/'));
      expect(config.apiVersion, 'v1');
    });
  });
}
