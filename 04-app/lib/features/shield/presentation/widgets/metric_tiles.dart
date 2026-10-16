import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/shield/presentation/sync_time_format.dart';
import 'package:shield_app/features/sync/domain/entities/sync_state.dart';
import 'package:shield_app/features/sync/presentation/sync_controller.dart';
import 'package:shield_app/features/sync/presentation/sync_providers.dart';

/// Las dos métricas operativas: contador de la lista local (reactivo) y el botón
/// de sincronización manual con sus estados (ShieldScreen.tsx · Operational
/// Metric & Integrity Snapshot).
class MetricTiles extends ConsumerWidget {
  const MetricTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `IntrinsicHeight` acota el alto del `Row` a su contenido: sin él, dentro
    // de un scrollable (alto no acotado) un `Row` con `crossAxisAlignment:
    // stretch` recibiría constraints de alto infinito y fallaría la medición
    // ("BoxConstraints forces an infinite height"), dejando el viewport en
    // blanco. Con el alto acotado, ambas tarjetas igualan su altura.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(child: _LocalListTile()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _SyncTile()),
        ],
      ),
    );
  }
}

class _LocalListTile extends ConsumerWidget {
  const _LocalListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(datasetCountProvider);
    final textTheme = Theme.of(context).textTheme;

    final value = count.when(
      data: (n) => n == 0 ? 'Sin firmas aún' : '${_grouped(n)} hashes',
      loading: () => '…',
      error: (_, _) => 'No disponible',
    );

    return _MetricShell(
      icon: Icons.verified_user_outlined,
      iconColor: AppColors.accentCyan2,
      label: 'LISTA LOCAL',
      value: value,
      valueStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Agrupa miles con punto (es-CO): 14892 → "14.892".
  String _grouped(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _SyncTile extends ConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final syncState = ref.watch(syncControllerProvider);
    final state = syncState.valueOrNull;
    final syncing = state is SyncInProgress;

    final (label, value) = switch (state) {
      SyncInProgress() => ('SINCRONIZANDO', 'Verificando firmas…'),
      SyncFailure() => ('ERROR DE SYNC', 'Toca para reintentar'),
      SyncSuccess(:final syncedAt) => (
        'ACTUALIZACIÓN',
        formatSyncTime(syncedAt),
      ),
      SyncIdle(:final lastSyncedAt) => (
        'ACTUALIZACIÓN',
        lastSyncedAt == null ? 'Nunca' : formatSyncTime(lastSyncedAt),
      ),
      _ => ('ACTUALIZACIÓN', '—'),
    };

    final isError = state is SyncFailure;

    return InkWell(
      onTap: syncing
          ? null
          : () => ref.read(syncControllerProvider.notifier).sync(),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: _MetricShell(
        icon: Icons.sync,
        iconColor: isError ? AppColors.danger : AppColors.success,
        spinning: syncing,
        label: label,
        value: value,
        valueStyle: textTheme.labelMedium?.copyWith(
          color: isError ? AppColors.danger : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Contenedor común de una métrica (icono + label + valor).
class _MetricShell extends StatefulWidget {
  const _MetricShell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueStyle,
    this.spinning = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool spinning;

  @override
  State<_MetricShell> createState() => _MetricShellState();
}

class _MetricShellState extends State<_MetricShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didUpdateWidget(covariant _MetricShell old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.spinning && _spin.isAnimating) {
      _spin.stop();
      _spin.reset();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.4),
              ),
            ),
            child: RotationTransition(
              turns: _spin,
              child: Icon(widget.icon, size: 18, color: widget.iconColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.value,
                  style: widget.valueStyle ?? textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
