/// Formatea la marca de tiempo de la última sincronización en es-CO (RN-09),
/// sin dependencias externas: "Hoy, HH:mm" / "Ayer, HH:mm" / "dd/MM HH:mm".
String formatSyncTime(DateTime at, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  final time = '$hh:$mm';

  final today = DateTime(ref.year, ref.month, ref.day);
  final thatDay = DateTime(at.year, at.month, at.day);
  final diffDays = today.difference(thatDay).inDays;

  if (diffDays == 0) return 'Hoy, $time';
  if (diffDays == 1) return 'Ayer, $time';

  final dd = at.day.toString().padLeft(2, '0');
  final mo = at.month.toString().padLeft(2, '0');
  return '$dd/$mo $time';
}
