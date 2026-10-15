/// Interfaz que aísla la interceptación específica de plataforma (`04-app-flutter`
/// §04.5, [DA-12]).
///
/// El dominio no sabe en qué plataforma corre: habla con esta abstracción. La
/// implementación Android (MVP) usa `CallScreeningService` + rol SMS; la de
/// iOS (fase futura) empuja listas a Call Directory / Message Filter sin motor
/// dinámico. Definirla desde el día uno evita reescribir el núcleo al entrar iOS.
///
/// Este scaffolding solo declara el contrato; las implementaciones nativas y el
/// platform channel se añaden al implementar `features/sync` y la capa Android.
abstract interface class BlockingEngine {
  /// Solicita los roles/permisos de interceptación (call screening, SMS).
  Future<bool> requestPermissions();

  /// Estado actual de permisos por capa.
  Future<EnginePermissionStatus> permissionStatus();

  /// Flujo de contactos entrantes (llamada/SMS) a evaluar.
  Stream<IncomingContact> get incoming;

  /// Comunica la decisión (permitir/bloquear) para un contacto entrante.
  Future<void> decide(String contactId, BlockDecision decision);
}

/// Estado de permisos de las capas de protección (degradación honesta: la app
/// nunca finge proteger si una capa está inactiva, `04-app-flutter` §04.5).
class EnginePermissionStatus {
  const EnginePermissionStatus({
    required this.callScreeningGranted,
    required this.smsGranted,
    required this.notificationsGranted,
  });

  final bool callScreeningGranted;
  final bool smsGranted;
  final bool notificationsGranted;
}

/// Tipo de contacto entrante.
enum IncomingContactType { call, sms }

/// Contacto entrante crudo recibido desde la capa nativa.
class IncomingContact {
  const IncomingContact({
    required this.id,
    required this.type,
    required this.rawNumber,
  });

  final String id;
  final IncomingContactType type;
  final String rawNumber;
}

/// Decisión del motor de precedencia sobre un contacto.
enum BlockDecision { allow, block }
