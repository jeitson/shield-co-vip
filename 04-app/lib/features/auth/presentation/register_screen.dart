import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/auth/presentation/controllers/register_controller.dart';
import 'package:shield_app/features/auth/presentation/state/register_submit_state.dart';
import 'package:shield_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:shield_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:shield_app/features/auth/presentation/widgets/brand_header.dart';
import 'package:shield_app/features/auth/presentation/widgets/consent_checkbox.dart';
import 'package:shield_app/features/auth/presentation/widgets/primary_button.dart';

/// PANT-REGISTER · Crear cuenta (01-autenticacion).
///
/// Banner de garantía de privacidad (RN-01), validación de formato (RF-REG-05),
/// prefijo +57 fijo (RF-REG-02), gate de consentimiento (RN-REG-03) y estados
/// idle/enviando/hecho (EST-REG-01..03).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(registerSubmissionProvider.notifier).submit();
    // La navegación/avisos se manejan en el `ref.listen` del build según la
    // fase resultante (éxito con sesión, confirmación pendiente, o error).
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final submission = ref.watch(registerSubmissionProvider);
    final loading = submission.isSubmitting;
    final done = submission.isDone;
    final busy = loading || done;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(registerSubmissionProvider, (prev, next) {
      switch (next.phase) {
        // Cuenta creada con sesión abierta → breve pausa y al Dashboard.
        case RegisterPhase.success:
          final router = GoRouter.of(context);
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            if (mounted) router.goNamed(AppRoutes.shieldName);
          });

        // Éxito con confirmación de correo pendiente → aviso verde y, un par
        // de segundos después, al login (controles ya quedaron deshabilitados).
        case RegisterPhase.pendingConfirmation:
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.successInk,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        next.message ?? 'Cuenta creada. Revisa tu correo.',
                        style: const TextStyle(color: AppColors.successInk),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.successStrong,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          final router = GoRouter.of(context);
          Future<void>.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) router.goNamed(AppRoutes.loginName);
          });

        // Error real: rojo con texto blanco (contraste correcto).
        case RegisterPhase.error:
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  next.message ?? 'No se pudo crear la cuenta',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.dangerStrong,
                behavior: SnackBarBehavior.floating,
              ),
            );

        case RegisterPhase.idle:
        case RegisterPhase.submitting:
          break;
      }
    });

    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const BrandHeader(
            icon: Icons.security_outlined,
            title: 'Crear cuenta',
            subtitle: 'Crea tu cuenta para comenzar tu blindaje',
          ),
          const SizedBox(height: AppSpacing.lg),

          _PrivacyBanner(),
          const SizedBox(height: AppSpacing.lg),

          // Nombre + Apellido en fila.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'Nombre *',
                  icon: Icons.person_outline,
                  hint: 'ej. Carlos',
                  onChanged: controller.setNombre,
                  enabled: !busy,
                  textInputAction: TextInputAction.next,
                  errorText: form.nombreError,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: AuthTextField(
                  label: 'Apellido *',
                  icon: Icons.badge_outlined,
                  hint: 'ej. Rodríguez',
                  onChanged: controller.setApellido,
                  enabled: !busy,
                  textInputAction: TextInputAction.next,
                  errorText: form.apellidoError,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AuthTextField(
            label: 'Correo Electrónico *',
            icon: Icons.alternate_email,
            hint: 'ej. usuario@proton.me',
            onChanged: controller.setCorreo,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !busy,
            errorText: form.correoError,
            autofillHints: const [AutofillHints.newUsername],
          ),
          const SizedBox(height: AppSpacing.md),

          AuthTextField(
            label: 'Contraseña *  ·  mín. 8',
            icon: Icons.key_outlined,
            hint: 'Mínimo 8 caracteres',
            onChanged: controller.setPassword,
            obscureText: !form.showPassword,
            enabled: !busy,
            textInputAction: TextInputAction.next,
            errorText: form.passwordError,
            autofillHints: const [AutofillHints.newPassword],
            suffix: IconButton(
              tooltip: form.showPassword ? 'Ocultar clave' : 'Mostrar clave',
              onPressed: controller.togglePasswordVisibility,
              icon: Icon(
                form.showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Celular con prefijo +57 fijo (RF-REG-02 / CA-REG-07).
          _PhoneField(
            onChanged: controller.setCelular,
            enabled: !busy,
            errorText: form.celularError,
          ),
          const SizedBox(height: AppSpacing.md),

          // Consentimientos (RN-REG-03).
          ConsentCheckbox(
            value: form.termsAccepted,
            onChanged: busy ? (_) {} : controller.setTermsAccepted,
            label: 'Acepto los Términos y Condiciones y la Política de Cero Registros (*)',
          ),
          ConsentCheckbox(
            value: form.privacyAccepted,
            onChanged: busy ? (_) {} : controller.setPrivacyAccepted,
            activeColor: AppColors.success,
            label: 'Confirmo que la app no accederá a mi agenda ni contactos personales (*)',
          ),
          const SizedBox(height: AppSpacing.lg),

          _SubmitButton(
            loading: loading,
            done: done,
            enabled: form.canSubmit && !busy,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.lg),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('¿Ya tienes una cuenta? ', style: textTheme.bodyMedium),
              GestureDetector(
                onTap: busy ? null : () => context.goNamed(AppRoutes.loginName),
                child: Text(
                  'Inicia sesión',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Banner "Garantía Absoluta": no se recolecta agenda ni contactos (RN-01).
class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.successStrong,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(AppRadii.card),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.phonelink_lock_outlined,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GARANTÍA ABSOLUTA',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'No recolectamos tu agenda ni contactos personales. '
                            'Tus datos viajan cifrados.',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de celular con el indicativo +57 bloqueado (RN-REG-01 / RF-REG-02).
class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.onChanged,
    required this.enabled,
    this.errorText,
  });

  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NÚMERO CELULAR *',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 13,
                  color: AppColors.success,
                ),
                const SizedBox(width: 3),
                Text(
                  'Prefijo bloqueado',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prefijo fijo +57.
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(
                  color: AppColors.borderSubtle.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🇨🇴 +57',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.lock_outline,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '300 123 4567',
                  errorText: errorText,
                  prefixIcon: const Icon(
                    Icons.smartphone_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  fillColor: AppColors.surface1.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Botón "Crear cuenta" con sus tres estados (EST-REG-01..03).
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.loading,
    required this.done,
    required this.enabled,
    required this.onPressed,
  });

  final bool loading;
  final bool done;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return const PrimaryButton(
        label: 'Identidad Generada',
        leadingIcon: Icons.verified_user,
        backgroundColor: AppColors.successStrong,
        foregroundColor: AppColors.successInk,
        onPressed: _noop,
      );
    }
    if (loading) {
      return const PrimaryButton(
        label: 'Blindando Identidad…',
        loading: true,
        backgroundColor: AppColors.accentCyan2,
        foregroundColor: AppColors.accentCyanInk,
        onPressed: _noop,
      );
    }
    return PrimaryButton(
      label: 'Crear cuenta',
      leadingIcon: Icons.shield_outlined,
      onPressed: enabled ? onPressed : null,
    );
  }

  // Mantener el botón "activo" visualmente en estados hecho/cargando sin
  // permitir re-tap (el flujo ya está en curso o terminó).
  static void _noop() {}
}
