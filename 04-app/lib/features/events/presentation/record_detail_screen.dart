import 'package:flutter/material.dart';
import 'package:shield_app/core/widgets/placeholder_screen.dart';

/// Detalle de evento (04-detalle-evento). Recibe el id del evento vía ruta;
/// en producción debe manejar "evento no encontrado". Lógica pendiente.
class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: PlaceholderScreen(
        title: 'Detalle del evento',
        icon: Icons.info_outline,
        description: 'Evento: $eventId',
      ),
    );
  }
}
