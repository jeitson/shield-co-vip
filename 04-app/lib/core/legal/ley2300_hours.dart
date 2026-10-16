/// Franja horaria legal de la Ley 2300 de 2023 ("Dejen de Fregar"), RN-08.
///
/// **Fuente única de verdad** de las franjas en que *sí* se permite el contacto
/// comercial/cobranza en Colombia. La configuración avanzada (spec 05) las
/// muestra en solo lectura y el **motor** (spec `08-motor-franja-ley2300`) las
/// evalúa en tiempo de contacto. Son **normativas y fijas** (DN-05): no las edita
/// el usuario. Si la ley cambia, se actualiza aquí y en un solo lugar.
///
/// Los festivos (domingos y festivos → bloqueo 24h) no viven aquí: se calculan
/// de forma determinista (DN-06) en el componente de festivos del motor.
library;

/// Una franja horaria permitida (hora local Colombia, 24h).
class LegalWindow {
  const LegalWindow({
    required this.label,
    required this.startHour,
    required this.endHour,
  });

  /// Etiqueta legible del día o rango de días (es-CO).
  final String label;

  /// Hora de inicio (incluida), 0–23. `null`-equivalente no aplica: un día de
  /// bloqueo total se representa con [blocked24h].
  final int startHour;

  /// Hora de fin (excluida), 1–24.
  final int endHour;

  /// Texto "07:00 – 19:00" para la UI.
  String get rangeText =>
      '${_hh(startHour)}:00 – ${_hh(endHour)}:00';

  static String _hh(int h) => h.toString().padLeft(2, '0');
}

/// Franjas legales por tipo de día (RN-08). Orden de presentación L→D.
abstract final class Ley2300Hours {
  /// Lunes a viernes: 07:00 – 19:00.
  static const weekdays = LegalWindow(
    label: 'Lunes a viernes',
    startHour: 7,
    endHour: 19,
  );

  /// Sábados: 08:00 – 15:00.
  static const saturday = LegalWindow(
    label: 'Sábados',
    startHour: 8,
    endHour: 15,
  );

  /// Etiqueta del día de bloqueo total (domingos y festivos, 24h).
  static const blocked24hLabel = 'Domingos y festivos';

  /// Texto del bloqueo total para la UI.
  static const blocked24hText = 'Bloqueo total (24h)';

  /// Todas las franjas con horario, en orden de presentación.
  static const windows = <LegalWindow>[weekdays, saturday];
}
