import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shield_app/core/theme/threat_level.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';
import 'package:shield_app/features/engine/domain/entities/threat_category.dart';
import 'package:shield_app/features/events/domain/entities/intercepted_event.dart';
import 'package:shield_app/features/events/presentation/events_providers.dart';
import 'package:uuid/uuid.dart';

/// Siembra de eventos de **desarrollo** para validar el timeline en dispositivo
/// (spec 03, tarea 8.5) sin depender de llamadas/SMS reales ni del simulador de
/// negocio (que es sandbox puro, RN-SIM-01). Usa el mismo contrato `RecordEvent`
/// que el puente nativo, así que ejercita el camino real de persistencia.
///
/// Solo debe exponerse en flavors de desarrollo.
final devEventSeederProvider = Provider<Future<int> Function()>((ref) {
  return () async {
    final record = ref.read(recordEventProvider);
    const uuid = Uuid();
    final now = DateTime.now();

    final samples = <InterceptedEvent>[
      InterceptedEvent(
        id: uuid.v4(),
        sender: '+573001112233',
        type: ContactChannel.call,
        level: ThreatLevel.alto,
        timestamp: now.subtract(const Duration(minutes: 3)),
        threatTitle: 'Extorsión / amenaza',
        category: ThreatCategory.extorsion,
        reputationTag: 'Número peligroso (comunidad)',
        diagnosis: 'Coincide con una firma de extorsión de la lista comunitaria.',
      ),
      InterceptedEvent(
        id: uuid.v4(),
        sender: '890123',
        type: ContactChannel.sms,
        level: ThreatLevel.alto,
        timestamp: now.subtract(const Duration(hours: 2)),
        threatTitle: 'Phishing / suplantación',
        category: ThreatCategory.phishing,
        reputationTag: 'Suplantación detectada',
        diagnosis: 'Patrón de phishing detectado por el motor local.',
        quarantinedContent:
            'Su cuenta fue bloqueada. Verifique en http://banco-seguro.co/acceso',
      ),
      InterceptedEvent(
        id: uuid.v4(),
        sender: '+573009998877',
        type: ContactChannel.call,
        level: ThreatLevel.bajo,
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
        threatTitle: 'Violación franja Ley 2300',
        category: ThreatCategory.ley2300,
        reputationTag: 'Ley 2300 aplicada',
        diagnosis:
            'Contacto comercial fuera de la franja horaria legal (Ley 2300).',
      ),
    ];

    var n = 0;
    for (final e in samples) {
      final r = await record(e);
      if (r.isOk) n++;
    }
    return n;
  };
});
