import 'package:drift/drift.dart';

/// Historial local de **eventos interceptados** (`EventoInterceptado` de
/// `00-fundamentos` §00.2). Persistido en la base local **cifrada** (DA-14): el
/// historial no sale del dispositivo (RN-01, Zero-Knowledge).
///
/// La clasificación del número (confianza/negra) **no** vive aquí: es
/// responsabilidad de `numeros_listados` y se consulta por [sender]. Así un
/// cambio de clasificación se refleja en todos los eventos del mismo número y la
/// exclusividad (RN-05) tiene una sola fuente de verdad (ver spec 03 §design.2).
///
/// Lo escribe el **contrato de inserción** `EventsRepository.record()` (que
/// conectarán el puente nativo y el Simulador); lo lee la pantalla de registro.
@DataClassName('InterceptedEventRow')
class InterceptedEventsTable extends Table {
  @override
  String get tableName => 'eventos';

  /// Identificador único del evento (ordenable por tiempo). PK.
  TextColumn get id => text()();

  /// Remitente en formato canónico E.164 (RN-04).
  TextColumn get sender => text()();

  /// Vector del evento: `call` | `sms` (enum `ContactChannel`).
  TextColumn get type => text()();

  /// Severidad: `ALTO` | `MEDIO` | `BAJO` (enum `ThreatLevel`).
  TextColumn get level => text()();

  /// Momento del evento (fecha real, RN-04): gobierna el orden descendente y la
  /// ventana "intercepciones de hoy".
  DateTimeColumn get timestamp => dateTime()();

  /// Clasificación legible: "Extorsión Carcelaria", "Phishing Bancario SMS"…
  TextColumn get threatTitle => text()();

  /// Categoría estructurada (catálogo RN-07, enum `ThreatCategory`); gobierna la
  /// elegibilidad de exportación SIC (RN-CALLS-02). Se guarda el `label`.
  TextColumn get category => text()();

  /// Origen/razón de la detección: "VoIP no registrado", "Ley 2300 Aplicada".
  TextColumn get reputationTag => text()();

  /// Explicación de por qué se interceptó.
  TextColumn get diagnosis => text()();

  /// Texto del SMS aislado; solo para `sms` (`null` en llamadas).
  TextColumn get quarantinedContent => text().nullable()();

  /// Metadatos forenses opcionales (ubicación, duración, operador, intentos)
  /// serializados como JSON. Se materializan en `EventDetails` al mapear.
  TextColumn get detailsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
