import 'package:shield_app/features/auth/domain/value_objects/colombian_phone.dart';

/// Normaliza un número a su forma canónica para listar/deduplicar (RN-04).
///
/// - Un móvil colombiano válido se canoniza a E.164 `+57XXXXXXXXXX` (reutiliza
///   el VO `ColombianPhone`), de modo que `+57 300…`, `300…` y `573 00…` son el
///   mismo número.
/// - Un **código corto SMS** (p. ej. `890123`) o cualquier remitente que no sea
///   un móvil CO se trata como categoría aparte (RN-04) y se conserva tal cual,
///   solo recortando espacios. No se fuerza el prefijo +57 sobre él.
///
/// Devuelve `null` si la entrada queda vacía tras limpiar.
String? canonicalizeNumber(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final parsed = ColombianPhone.tryParse(trimmed);
  if (parsed.value != null) return parsed.value!.e164;

  // No es un móvil CO (código corto, línea fija, remitente alfanumérico):
  // se conserva la entrada ya recortada como identificador canónico propio.
  return trimmed;
}
