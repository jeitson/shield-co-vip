import 'package:flutter/material.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/shield/domain/shield_status.dart';

/// Hero con el escudo dinámico y los anillos pulsantes (ShieldScreen.tsx · Hero
/// Shield Section). Color, icono y textos derivan del [ShieldStatus] (RN-03).
class ShieldHero extends StatefulWidget {
  const ShieldHero({required this.status, super.key});

  final ShieldStatus status;

  @override
  State<ShieldHero> createState() => _ShieldHeroState();
}

class _ShieldHeroState extends State<ShieldHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = widget.status.color;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface1, AppColors.surface2],
        ),
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anillo pulsante animado.
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    return Container(
                      width: 120 + 60 * t,
                      height: 120 + 60 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: (1 - t) * 0.4),
                        ),
                      ),
                    );
                  },
                ),
                // Anillo interior estático.
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                ),
                // Núcleo.
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface4.withValues(alpha: 0.8),
                    border: Border.all(
                      color: AppColors.borderSubtle.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // Escudo con icono de estado.
                Icon(
                  widget.status.isProtected
                      ? Icons.shield_outlined
                      : Icons.gpp_bad_outlined,
                  size: 72,
                  color: color,
                ),
                if (widget.status.isProtected)
                  Icon(Icons.check, size: 28, color: color),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Píldora de estado.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.status.title,
              style: textTheme.titleMedium?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.status.description,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
