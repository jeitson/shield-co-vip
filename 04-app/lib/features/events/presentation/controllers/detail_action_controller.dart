import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/presentation/state/detail_action_state.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/reports/domain/entities/community_report.dart';
import 'package:shield_app/features/reports/domain/entities/report_outcome.dart';
import 'package:shield_app/features/reports/presentation/reports_providers.dart';

/// Controla las dos vías de acción del detalle de un evento, parametrizado por
/// el número (`sender`) del evento (spec 04 §6).
///
/// Clave de diseño (R8.2): "Reportar y bloquear" **bloquea primero** y reporta
/// después, para que el usuario quede protegido localmente aunque el reporte
/// comunitario falle. El reintento re-envía solo el reporte (no re-bloquea).
final detailActionControllerProvider = NotifierProvider.family<
    DetailActionController,
    DetailActionState,
    String>(DetailActionController.new);

class DetailActionController
    extends FamilyNotifier<DetailActionState, String> {
  late String _sender;

  @override
  DetailActionState build(String arg) {
    _sender = arg;
    return const DetailActionState();
  }

  /// "Reportar y bloquear" (R5): bloqueo local primero, reporte comunitario
  /// después. Conserva el bloqueo y permite reintentar el reporte ante error.
  Future<void> reportAndBlock(ThreatCategory categoria) async {
    state = state.copyWith(
      kind: DetailActionKind.dualReport,
      phase: DetailActionPhase.generating,
      clearError: true,
      clearOutcome: true,
    );

    // 1) Bloqueo local (lista negra, exclusividad RN-05, reproyección al motor).
    final blocked = await _blockLocally();
    if (!blocked) {
      state = state.copyWith(
        phase: DetailActionPhase.error,
        errorMessage: 'No se pudo bloquear el número. Intenta de nuevo.',
      );
      return;
    }
    state = state.copyWith(localBlockDone: true);

    // 2) Reporte comunitario.
    await _submitReport(categoria);
  }

  /// "Bloquear solo para mí" (R6): solo bloqueo local, sin reporte.
  Future<void> blockLocal() async {
    state = state.copyWith(
      kind: DetailActionKind.localBlock,
      phase: DetailActionPhase.generating,
      clearError: true,
    );
    final blocked = await _blockLocally();
    state = state.copyWith(
      phase: blocked ? DetailActionPhase.success : DetailActionPhase.error,
      localBlockDone: blocked ? true : state.localBlockDone,
      errorMessage: blocked ? null : 'No se pudo bloquear el número.',
      clearError: blocked,
    );
  }

  /// Siembra el estado "ya reportado" al abrir el detalle, según la consulta al
  /// servidor (R9). No dispara ninguna acción; solo refleja que este número ya
  /// fue reportado por este dispositivo. No pisa una acción en curso ni un
  /// desenlace recién producido.
  void seedAlreadyReported() {
    if (state.phase == DetailActionPhase.generating) return;
    if (state.kind == DetailActionKind.dualReport &&
        state.phase == DetailActionPhase.success) {
      return;
    }
    state = state.copyWith(
      kind: DetailActionKind.dualReport,
      phase: DetailActionPhase.success,
      outcome: ReportOutcome.yaReportado,
      localBlockDone: true,
      clearError: true,
    );
  }

  /// Reintenta solo el envío del reporte (el bloqueo local ya está aplicado, R8).
  Future<void> retryReport(ThreatCategory categoria) async {
    state = state.copyWith(
      kind: DetailActionKind.dualReport,
      phase: DetailActionPhase.generating,
      clearError: true,
    );
    await _submitReport(categoria);
  }

  Future<bool> _blockLocally() async {
    final result = await ref
        .read(classifyNumberProvider)
        .call(_sender, ListKind.negra, origin: ListOrigin.evento);
    return result.isOk;
  }

  Future<void> _submitReport(ThreatCategory categoria) async {
    final result = await ref.read(submitReportProvider).call(
          CommunityReport(numero: _sender, categoria: categoria),
        );
    state = result.fold(
      (outcome) => state.copyWith(
        phase: DetailActionPhase.success,
        outcome: outcome,
        clearError: true,
      ),
      (failure) => state.copyWith(
        phase: DetailActionPhase.error,
        errorMessage: failure.message,
      ),
    );
    // Tras un reporte aceptado, la consulta "¿ya lo reporté?" cambia: invalida
    // el cache para que una reapertura refleje el estado real del servidor (R9).
    if (result.isOk) {
      ref.invalidate(reportedStatusProvider(_sender));
    }
  }
}
