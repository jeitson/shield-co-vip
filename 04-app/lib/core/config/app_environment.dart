/// Entornos de ejecución soportados por la app.
///
/// Hoy el backend es un entorno único [DA-15]; estos flavors preparan la
/// separación futura en dos proyectos Supabase (dev/staging + prod) con
/// peppers y secretos distintos (ver `03-architecture/06-entornos-...`).
enum AppEnvironment {
  dev,
  prod;

  bool get isDev => this == AppEnvironment.dev;
  bool get isProd => this == AppEnvironment.prod;
}
