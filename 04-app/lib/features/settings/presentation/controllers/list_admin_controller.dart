import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/features/lists/domain/canonical_number.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/settings/presentation/state/list_admin_state.dart';

/// Controla el **alta manual** en una lista (confianza o negra) desde la
/// configuración avanzada (spec 05). Family por [ListKind]: cada tarjeta tiene
/// su propio input y su propio feedback.
///
/// No reimplementa normalización ni exclusividad: delega en `canonicalizeNumber`
/// (RN-04) para validar/deduplicar y en `classifyNumber` (RN-05 atómica) para
/// persistir. La lista en sí se pinta de forma reactiva desde
/// `confianza/negraNumbersProvider`, así que aquí solo vive el estado del error.
class ListAdminController extends StateNotifier<ListAdminState> {
  ListAdminController(this._ref, this._kind) : super(const ListAdminState());

  final Ref _ref;
  final ListKind _kind;

  /// Conjunto reactivo de la lista de este controller (números ya canónicos).
  StreamProvider<Set<String>> get _listProvider =>
      _kind == ListKind.confianza
      ? confianzaNumbersProvider
      : negraNumbersProvider;

  /// Validación de alta manual (CA-ADV-04): aceptamos solo un **móvil CO en
  /// E.164** (`+57XXXXXXXXXX`) o un **código corto numérico** (p. ej. `890123`).
  /// `canonicalizeNumber` por sí solo conserva cualquier texto no vacío (pensado
  /// para remitentes alfanuméricos que *llegan de eventos reales*), pero en el
  /// alta manual eso dejaría pasar basura como `+++` o `abc`. Por eso aquí
  /// exigimos que el resultado sea un número reconocible.
  static final _validManual = RegExp(r'^(\+57\d{10}|\d{3,10})$');

  /// Intenta añadir [raw] a la lista. Devuelve `true` si se agregó (para que la
  /// UI limpie el input). Ante error, deja el detalle en [state].
  Future<bool> add(String raw) async {
    final canonical = canonicalizeNumber(raw);
    if (canonical == null || !_validManual.hasMatch(canonical)) {
      state = state.copyWith(phase: AddPhase.invalid);
      return false;
    }

    // Deduplicación por forma canónica (R4): comparar contra el Set actual.
    final current = await _ref.read(_listProvider.future);
    if (current.contains(canonical)) {
      state = state.copyWith(phase: AddPhase.duplicate);
      return false;
    }

    final result = await _ref
        .read(classifyNumberProvider)
        .call(raw, _kind, origin: ListOrigin.manual);

    return result.fold(
      (_) {
        state = const ListAdminState();
        return true;
      },
      (_) {
        // Fallo del repositorio: reutilizamos "invalid" como "no se pudo".
        state = state.copyWith(phase: AddPhase.invalid);
        return false;
      },
    );
  }

  /// Limpia el error (al editar el input o cambiar de foco).
  void clearError() {
    if (state.hasError) state = const ListAdminState();
  }
}

/// StateNotifier por lista. La clave es la [ListKind] de la tarjeta.
final listAdminControllerProvider =
    StateNotifierProvider.family<ListAdminController, ListAdminState, ListKind>(
      (ref, kind) => ListAdminController(ref, kind),
    );
