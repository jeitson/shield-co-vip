import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';

/// Render estándar de los cuatro estados obligatorios del dominio
/// (`00-modelo-dominio` §00.5 / `04-app-flutter` §04.3):
/// cargando / éxito / error / vacío.
///
/// Centraliza el patrón `AsyncValue.when` para que todas las pantallas traten
/// los cuatro estados de forma consistente. El estado "vacío" se detecta con
/// [isEmpty] sobre los datos.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.isEmpty,
    this.onRetry,
    this.loading,
    this.empty,
    super.key,
  });

  /// Estado asíncrono a renderizar.
  final AsyncValue<T> value;

  /// Builder del caso con datos no vacíos.
  final Widget Function(T data) data;

  /// Determina si los datos deben tratarse como "vacío".
  final bool Function(T data)? isEmpty;

  /// Acción de reintento mostrada en el estado de error.
  final VoidCallback? onRetry;

  /// Override del widget de carga.
  final Widget? loading;

  /// Override del widget de vacío.
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(error: error, onRetry: onRetry),
      data: (value) {
        final treatAsEmpty = isEmpty?.call(value) ?? false;
        if (treatAsEmpty) {
          return empty ?? const EmptyStateView();
        }
        return data(value);
      },
    );
  }
}

/// Estado de error con reintento.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Algo salió mal',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$error',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacío genérico.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    this.message = 'No hay nada por aquí todavía.',
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
