import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de autenticación de alto nivel para el guard de navegación.
///
/// Placeholder del scaffolding: hoy no hay sesión real. Cuando se implemente
/// `01-autenticacion`, este provider se alimentará del repositorio de auth
/// (sesión en secure storage, refresh 12h, revocación de dispositivo [DA-04]).
enum AuthStatus {
  /// Aún no se ha resuelto el estado inicial (p. ej. leyendo secure storage).
  unknown,

  /// Hay sesión válida.
  authenticated,

  /// No hay sesión.
  unauthenticated,
}

/// Expone el estado de auth. Por defecto `unauthenticated` para que el guard
/// lleve a `login` (DN-02: sin modo invitado). Se sobrescribe al integrar auth.
final authStatusProvider = StateProvider<AuthStatus>(
  (ref) => AuthStatus.unauthenticated,
);
