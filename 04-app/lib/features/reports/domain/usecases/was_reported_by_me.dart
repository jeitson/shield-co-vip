import 'package:shield_app/core/error/result.dart';
import 'package:shield_app/features/reports/domain/repositories/reports_repository.dart';

/// Caso de uso: ¿este dispositivo ya reportó el número? (R9).
///
/// Fuente de verdad en el servidor: permite que la UI del detalle refleje
/// "ya reportado" al abrir, incluso tras cerrar y reabrir la pantalla.
class WasReportedByMe {
  const WasReportedByMe(this._repository);

  final ReportsRepository _repository;

  Future<Result<bool>> call(String numero) {
    if (numero.trim().isEmpty) return Future.value(const Ok(false));
    return _repository.wasReportedByMe(numero);
  }
}
