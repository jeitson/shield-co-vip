import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';

/// Normaliza texto para búsqueda insensible a mayúsculas y acentos (RF-CALLS-02,
/// es-CO). Convierte a minúsculas y pliega los diacríticos del español.
String normalizeForSearch(String input) {
  var s = input.toLowerCase();
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    final idx = from.indexOf(ch);
    buffer.write(idx >= 0 ? to[idx] : ch);
  }
  return buffer.toString();
}

/// `true` si [event] coincide con el término [query] en alguno de sus campos de
/// texto (remitente, título, etiqueta de reputación, diagnóstico o contenido en
/// cuarentena). Búsqueda normalizada (RF-CALLS-02).
bool eventMatchesQuery(InterceptedEvent event, String query) {
  final q = normalizeForSearch(query.trim());
  if (q.isEmpty) return true;
  final haystack = normalizeForSearch(
    [
      event.sender,
      event.threatTitle,
      event.reputationTag,
      event.diagnosis,
      event.quarantinedContent ?? '',
    ].join(' '),
  );
  return haystack.contains(q);
}
