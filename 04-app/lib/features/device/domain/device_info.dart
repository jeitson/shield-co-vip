/// Metadatos no sensibles del dispositivo que se registran en `devices`
/// (DA-02). Nada de PII de hardware; solo marca/modelo/SO para gestión y
/// auditoría de sesiones por el usuario.
class DeviceInfo {
  const DeviceInfo({
    required this.marca,
    required this.modelo,
    required this.so,
    required this.soVersion,
    required this.appVersion,
    required this.idioma,
    required this.zonaHoraria,
  });

  final String marca;
  final String modelo;
  final String so;
  final String soVersion;
  final String appVersion;
  final String idioma;
  final String zonaHoraria;

  Map<String, dynamic> toJson() => {
    'marca': marca,
    'modelo': modelo,
    'so': so,
    'so_version': soVersion,
    'app_version': appVersion,
    'idioma': idioma,
    'zona_horaria': zonaHoraria,
  };
}
