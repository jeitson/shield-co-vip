/// Rutas de la app, centralizadas para evitar strings mágicos.
///
/// `path` se usa en la definición del router; `name` en navegación por nombre
/// (`context.goNamed`). Mapea el flujo de `01-docs/03-mapa-navegacion.md` a una
/// pila real con deep-link capable (corrige los gaps del prototipo).
abstract final class AppRoutes {
  // --- Auth (fuera del shell) ---
  static const loginPath = '/login';
  static const loginName = 'login';

  static const registerPath = '/register';
  static const registerName = 'register';

  // --- Shell (bottom nav) ---
  static const shieldPath = '/shield';
  static const shieldName = 'shield';

  static const callsPath = '/calls';
  static const callsName = 'calls';

  static const reportPath = '/report';
  static const reportName = 'report';

  static const advancedPath = '/advanced';
  static const advancedName = 'advanced';

  // --- Rutas de detalle / modales (fuera del shell) ---
  /// Detalle de evento. Param: `:id`.
  static const eventDetailPath = '/calls/:id';
  static const eventDetailName = 'event-detail';

  static const simulatorPath = '/simulator';
  static const simulatorName = 'simulator';
}
