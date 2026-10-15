import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/auth/presentation/widgets/auth_scaffold.dart';

/// Pantalla de arranque neutra mientras se resuelve el estado de sesión
/// (R3.3). El guard redirige a login o al escudo cuando el estado deja de ser
/// `unknown`.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface2.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadii.cardLarge),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.accentCyan,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Verificando enclave…', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
