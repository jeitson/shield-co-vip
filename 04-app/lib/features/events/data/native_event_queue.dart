import 'package:flutter/services.dart';
import 'package:shield_app/features/engine/domain/entities/incoming_contact.dart';

/// Un evento interceptado crudo drenado de la cola nativa (Android). Lleva solo
/// el mínimo producido por el `CallScreeningService`/`SmsReceiver`; Dart
/// rehidrata la categoría/nivel/título a partir del `EngineIndex`.
class RawInterceptedEvent {
  const RawInterceptedEvent({
    required this.rawNumber,
    required this.channel,
    required this.timestamp,
    this.layer,
    this.body,
  });

  /// Número crudo tal como lo entregó el SO (se normaliza en Dart).
  final String rawNumber;

  /// Canal del contacto.
  final ContactChannel channel;

  /// Capa responsable del bloqueo (`extorsion`/`callcenter`/`ley`/`local`), si
  /// el nativo pudo determinarla; `null` = negra global dura o desconocida.
  final String? layer;

  /// Cuerpo del SMS (solo SMS) → contenido en cuarentena.
  final String? body;

  /// Momento de la interceptación (reloj del dispositivo).
  final DateTime timestamp;
}

/// Lee (y vacía) la cola de interceptaciones que el nativo acumula mientras no
/// hay engine Flutter vivo. El `CallScreeningService` corre en otro proceso, así
/// que el puente es **pull**: Dart drena la cola al arrancar/reanudar.
class NativeEventQueue {
  NativeEventQueue([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('cifradocero/engine');

  final MethodChannel _channel;

  /// Drena la cola nativa. Devuelve lista vacía si no hay canal (no-Android) o
  /// si no hay nada encolado.
  Future<List<RawInterceptedEvent>> drain() async {
    final List<dynamic>? raw;
    try {
      raw = await _channel.invokeListMethod<dynamic>('drainEvents');
    } on MissingPluginException {
      return const []; // plataforma sin el canal nativo (tests/iOS/escritorio)
    } on PlatformException {
      return const [];
    }
    if (raw == null) return const [];

    return raw.whereType<Map<Object?, Object?>>().map(_fromMap).toList();
  }

  RawInterceptedEvent _fromMap(Map<Object?, Object?> m) {
    final channelStr = m['channel'] as String?;
    final tsMs = (m['timestampMs'] as num?)?.toInt() ?? 0;
    return RawInterceptedEvent(
      rawNumber: (m['rawNumber'] as String?) ?? '',
      channel: channelStr == 'sms' ? ContactChannel.sms : ContactChannel.call,
      layer: m['layer'] as String?,
      body: m['body'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        tsMs == 0 ? DateTime.now().millisecondsSinceEpoch : tsMs,
      ),
    );
  }
}
