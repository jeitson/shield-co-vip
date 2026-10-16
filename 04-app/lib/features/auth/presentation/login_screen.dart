import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shield_app/core/error/failure.dart';
import 'package:shield_app/core/router/app_routes.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/core/widgets/primary_button.dart';
import 'package:shield_app/features/auth/presentation/auth_providers.dart';
import 'package:shield_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:shield_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:shield_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:shield_app/features/auth/presentation/widgets/brand_header.dart';

/// PANT-LOGIN · Acceso seguro (01-autenticacion).
///
/// Arranque de la app con guard de auth (DN-02). Formulario vacío (RN-LOGIN-02),
/// gate de consentimiento (RN-LOGIN-01), estados cargando/éxito/error (§00.5).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = await ref.read(loginSubmissionProvider.notifier).submit();
    if (ok && mounted) {
      context.goNamed(AppRoutes.shieldName);
    }
  }

  Future<void> _resendConfirmation(String email) async {
    // Si no tenemos un correo con formato válido, pedirlo.
    var target = email;
    if (!target.contains('@')) {
      target = await _promptEmail() ?? '';
    }
    if (target.isEmpty || !mounted) return;

    final result = await ref
        .read(resendConfirmationUseCaseProvider)
        .call(target);
    if (!mounted) return;

    final message = result.fold(
      (_) =>
          'Si la cuenta existe y está sin confirmar, te reenviamos el enlace.',
      (failure) => failure.message,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  /// Pide un correo en un diálogo (para reenvío/recuperación cuando el campo
  /// de identificador no es un correo).
  Future<String?> _promptEmail() async {
    final ctrl = TextEditingController(
      text: _identifierCtrl.text.contains('@') ? _identifierCtrl.text : '',
    );
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text('Tu correo'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'tu@correo.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return value;
  }

  Future<void> _onForgotPassword() async {
    // Prefill con el identificador si ya parece un correo.
    final emailCtrl = TextEditingController(
      text: _identifierCtrl.text.contains('@') ? _identifierCtrl.text : '',
    );

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: const Text('Recuperar clave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Te enviaremos un enlace de recuperación por correo. Tus datos '
              'locales no se ven afectados.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'tu@correo.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(emailCtrl.text.trim()),
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );

    emailCtrl.dispose();
    if (email == null || email.isEmpty || !mounted) return;

    final result = await ref
        .read(requestPasswordResetUseCaseProvider)
        .call(email);
    if (!mounted) return;

    final message = result.fold(
      (_) => 'Si el correo existe, te enviamos un enlace de recuperación.',
      (failure) => failure.message,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final submission = ref.watch(loginSubmissionProvider);
    final loading = submission.isLoading;
    final textTheme = Theme.of(context).textTheme;

    // Mostrar error de envío sin romper el formulario (CA-LOGIN-03/06).
    ref.listen(loginSubmissionProvider, (prev, next) {
      if (next is! AsyncError) return;
      final failure = next.error;

      // Correo sin confirmar (R7): bloquear acceso y ofrecer reenviar el enlace.
      if (failure is EmailNotConfirmedFailure) {
        final email = failure.email ?? _identifierCtrl.text.trim();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                failure.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Reenviar',
                textColor: AppColors.bgRoot,
                onPressed: () => _resendConfirmation(email),
              ),
            ),
          );
        return;
      }

      final message = failure is Failure
          ? failure.message
          : 'No se pudo iniciar sesión';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.dangerStrong,
            behavior: SnackBarBehavior.floating,
          ),
        );
    });

    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const BrandHeader(
            icon: Icons.lock_clock_outlined,
            title: 'Acceso Seguro',
            subtitle: 'Cifrado Cero • Enclave Seguro',
          ),
          const SizedBox(height: AppSpacing.xl),

          // Identificador / correo.
          AuthTextField(
            label: 'Identificador o Correo',
            icon: Icons.alternate_email,
            hint: 'usuario@nodo.zero',
            controller: _identifierCtrl,
            onChanged: controller.setIdentifier,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !loading,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Clave maestra con enlace de recuperación.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CLAVE MAESTRA',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: loading ? null : _onForgotPassword,
                child: Text(
                  '¿Olvidaste tu clave?',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.accentCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          TextField(
            controller: _passwordCtrl,
            onChanged: controller.setPassword,
            obscureText: !form.showPassword,
            enabled: !loading,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => form.canSubmit ? _submit() : null,
            autofillHints: const [AutofillHints.password],
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••••••',
              fillColor: AppColors.surface1.withValues(alpha: 0.8),
              prefixIcon: const Icon(
                Icons.key_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              suffixIcon: IconButton(
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
          ),
          const SizedBox(height: AppSpacing.xl),

          // Botón primario con estados (EST-LOGIN-02).
          PrimaryButton(
            label: loading ? 'Descifrando Enclave…' : 'Iniciar Sesión',
            loading: loading,
            trailingIcon: loading ? null : Icons.arrow_forward,
            onPressed: (form.canSubmit && !loading) ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Enlace a registro (CA-LOGIN-05).
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('¿No tienes cuenta? ', style: textTheme.bodyMedium),
              GestureDetector(
                onTap: loading
                    ? null
                    : () => context.goNamed(AppRoutes.registerName),
                child: Text(
                  'Regístrate',
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
