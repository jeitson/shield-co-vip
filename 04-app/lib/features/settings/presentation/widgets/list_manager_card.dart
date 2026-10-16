import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/core/widgets/primary_button.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/lists/presentation/lists_providers.dart';
import 'package:shield_app/features/settings/presentation/controllers/list_admin_controller.dart';
import 'package:shield_app/features/settings/presentation/widgets/number_chip.dart';

/// Gestor de una lista local (confianza o negra) en la configuración avanzada
/// (spec 05). Input de alta + contador + chips con eliminar + estado vacío.
///
/// Toda la lista es reactiva sobre `confianza/negraNumbersProvider`; el único
/// estado de UI propio es el error del alta (`listAdminControllerProvider`).
class ListManagerCard extends ConsumerStatefulWidget {
  const ListManagerCard({
    required this.kind,
    required this.title,
    required this.addLabel,
    required this.accentColor,
    super.key,
  });

  final ListKind kind;
  final String title;
  final String addLabel;
  final Color accentColor;

  @override
  ConsumerState<ListManagerCard> createState() => _ListManagerCardState();
}

class _ListManagerCardState extends ConsumerState<ListManagerCard> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text;
    final notifier =
        ref.read(listAdminControllerProvider(widget.kind).notifier);
    if (raw.trim().isEmpty) {
      notifier.clearError();
      return;
    }
    final added = await notifier.add(raw);
    if (added) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  void _remove(String numero) {
    // Baja: desmarcar (kind == null). El stream retira el chip.
    ref.read(classifyNumberProvider).call(
      numero,
      null,
      origin: ListOrigin.manual,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final listProvider = widget.kind == ListKind.confianza
        ? confianzaNumbersProvider
        : negraNumbersProvider;
    final numbers =
        ref.watch(listProvider).valueOrNull ?? const <String>{};
    final adminState = ref.watch(listAdminControllerProvider(widget.kind));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado + contador ---
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '${numbers.length}',
                  style: textTheme.labelMedium?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // --- Fila de alta ---
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: (_) => ref
                .read(listAdminControllerProvider(widget.kind).notifier)
                .clearError(),
            onSubmitted: (_) => _submit(),
            style: textTheme.bodyLarge,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            ],
            decoration: InputDecoration(
              hintText: 'Número (p. ej. +57 300 123 4567)',
              errorText: adminState.message,
              filled: true,
              fillColor: AppColors.bgRoot,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
                borderSide: BorderSide(
                  color: AppColors.borderSubtle.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: widget.addLabel,
            leadingIcon: Icons.add,
            backgroundColor: widget.accentColor,
            foregroundColor: AppColors.bgRoot,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.lg),

          // --- Cuerpo: chips o estado vacío ---
          if (numbers.isEmpty)
            _EmptyState(accentColor: widget.accentColor)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final numero in _sorted(numbers))
                  NumberChip(
                    numero: numero,
                    accentColor: widget.accentColor,
                    onDeleted: () => _remove(numero),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<String> _sorted(Set<String> numbers) {
    final list = numbers.toList()..sort();
    return list;
  }
}

/// Estado vacío de una lista (R7).
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 28,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aún no has añadido números a esta lista.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
