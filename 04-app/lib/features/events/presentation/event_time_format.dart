/// Formatea la marca de tiempo de un evento en es-CO (RN-09), sin dependencias
/// externas: "Hoy HH:mm" / "Ayer HH:mm" / "dd/MM HH:mm".
String formatEventTime(DateTime at, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  final time = '$hh:$mm';

  final today = DateTime(ref.year, ref.month, ref.day);
  final thatDay = DateTime(at.year, at.month, at.day);
  final diffDays = today.difference(thatDay).inDays;

  if (diffDays == 0) return 'Hoy $time';
  if (diffDays == 1) return 'Ayer $time';

  final dd = at.day.toString().padLeft(2, '0');
  final mo = at.month.toString().padLeft(2, '0');
  return '$dd/$mo $time';
}

/// Formatea una duración en minutos/horas legibles para "tiempo ahorrado" (R5).
/// Ej.: 36 → "36m", 90 → "1h 30m", 120 → "2h".
String formatSecondsSaved(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final rem = minutes % 60;
  return rem == 0 ? '${hours}h' : '${hours}h ${rem}m';
}
