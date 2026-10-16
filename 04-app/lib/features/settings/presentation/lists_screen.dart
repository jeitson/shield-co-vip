import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/app_colors.dart';
import 'package:shield_app/core/theme/app_dimens.dart';
import 'package:shield_app/features/lists/domain/entities/listed_number.dart';
import 'package:shield_app/features/settings/presentation/widgets/list_manager_card.dart';

/// Gestión de las listas locales de **confianza** y **negra** (spec 05).
///
/// Pantalla propia con botón de regreso, abierta desde Avanzados. Las dos listas
/// viven juntas porque comparten la **exclusividad RN-05**: añadir un número a
/// una lo retira de la otra. Reutiliza `ListManagerCard` (toda la lógica está en
/// la feature `lists` + el controller de alta).
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Listas locales')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Gestiona qué números siempre pasan (confianza) y cuáles se bloquean '
            'siempre (negra). Un número solo puede estar en una lista a la vez.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ListManagerCard(
            kind: ListKind.confianza,
            title: 'Lista de confianza',
            addLabel: 'Añadir',
            accentColor: AppColors.accentCyan,
          ),
          const SizedBox(height: AppSpacing.md),
          const ListManagerCard(
            kind: ListKind.negra,
            title: 'Lista negra',
            addLabel: 'Bloquear',
            accentColor: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
