import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Canales de denuncia + reporte comunitario (06-canales-denuncia). Pendiente.
class ReportChannelsScreen extends StatelessWidget {
  const ReportChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Denuncia',
      icon: Icons.gavel_outlined,
      description: 'Canales oficiales y reporte comunitario anónimo.',
    );
  }
}
