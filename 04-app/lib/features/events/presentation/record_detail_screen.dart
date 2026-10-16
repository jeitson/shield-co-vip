import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/controllers/detail_action_controller.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:shield_app/features/events/presentation/widgets/block_options_module.dart';
import 'package:shield_app/features/events/presentation/widgets/forensic_metadata.dart';
import 'package:shield_app/features/events/presentation/widgets/inspection_card.dart';
import 'package:shield_app/features/events/presentation/widgets/privacy_footer.dart';
import 'package:shield_app/features/events/presentation/widgets/sms_payload_sandbox.dart';
import 'package:shield_app/features/reports/presentation/reports_providers.dart';

/// Detalle de evento · ficha forense (PANT-DETAIL, spec 04).
///
/// Recibe el `id` por ruta y carga el evento desde el repositorio
/// (`eventByIdProvider`, R1.1/R10: deep-link-capable, no depende de pasar el
/// objeto en memoria). Permite inspeccionar metadatos, revisar el payload del
/// SMS en sandbox y responder con dos vías: reportar+bloquear (comunitario
/// anónimo) o bloquear solo localmente.
class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del evento'),
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          color: AppColors.textPrimary,
          onPressed: () {
            // Vuelve a la pantalla anterior; si no hay pila (deep-link directo),
            // cae al Registro de eventos (R11).
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.callsName);
            }
          },
        ),
      ),
      backgroundColor: AppColors.bgSurface,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _unavailable(context),
        data: (event) =>
            event == null ? _unavailable(context) : _DetailBody(event: event),
      ),
    );
  }

  Widget _unavailable(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Evento no disponible',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'El evento que intentas abrir ya no existe o no está disponible.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuerpo de la ficha forense con estado local del vector activo.
class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.event});

  final InterceptedEvent event;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  late ContactChannel _vector;

  @override
  void initState() {
    super.initState();
    // Pestaña inicial = tipo del evento (R1.4).
    _vector = widget.event.type;
    // Si la consulta "¿ya lo reporté?" ya estaba resuelta en caché, siembra el
    // estado tras el primer frame (evita mutar un provider durante el build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final already =
          ref.read(reportedStatusProvider(widget.event.sender)).valueOrNull;
      if (already == true) {
        ref
            .read(detailActionControllerProvider(widget.event.sender).notifier)
            .seedAlreadyReported();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final textTheme = Theme.of(context).textTheme;

    // R9: consulta al servidor si este dispositivo ya reportó el número y, si
    // así es, siembra el estado "ya reportado" en el controller al abrir.
    ref.listen(reportedStatusProvider(event.sender), (prev, next) {
      if (next.valueOrNull == true) {
        ref
            .read(detailActionControllerProvider(event.sender).notifier)
            .seedAlreadyReported();
      }
    });
    final showSandbox = _vector == ContactChannel.sms && event.hasQuarantine;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Indicador flotante "Número Sospechoso".
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'NÚMERO SOSPECHOSO',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.danger,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                'Identificado por la comunidad',
                textAlign: TextAlign.end,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        InspectionCard(
          event: event,
          activeVector: _vector,
          onVectorChanged: (v) => setState(() => _vector = v),
        ),
        const SizedBox(height: AppSpacing.md),
        if (showSandbox) ...[
          SmsPayloadSandbox(content: event.quarantinedContent!),
          const SizedBox(height: AppSpacing.md),
        ],
        ForensicMetadata(event: event),
        const SizedBox(height: AppSpacing.md),
        BlockOptionsModule(event: event),
        const SizedBox(height: AppSpacing.md),
        const PrivacyFooter(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
