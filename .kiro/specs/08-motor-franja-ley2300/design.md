# Spec · 08 Motor de franja Ley 2300 + integridad — Diseño

> Diseño técnico de la **evaluación horaria** de la Ley 2300 en el motor, el
> **calendario de festivos** calculado offline, su **paridad nativa**, y la
> **verificación real de integridad** del dataset. Clean Architecture por
> features (DA-13); lógica de dominio pura y testeable; proyección al nativo para
> el filtrado sin FlutterEngine.

---

## 1. Panorama

Toca tres zonas: `core/legal` (festivos + reutiliza franjas), `features/engine`
(regla de franja en el motor + hora en el contacto + proyección nativa), y el
código **nativo Android** (aplicar la franja en el `CallScreeningService`). La
integridad se apoya en `features/sync`.

```
core/
├── legal/
│   ├── ley2300_hours.dart          # YA EXISTE (spec 05): franjas fijas RN-08
│   └── colombian_holidays.dart     # NEW festivos calculados (Emiliani + Pascua)
│
features/
├── engine/
│   ├── domain/
│   │   ├── entities/incoming_contact.dart   # (extender) + DateTime localTime
│   │   ├── ley2300_window_rule.dart          # NEW regla pura: ¿fuera de franja?
│   │   └── precedence_engine.dart            # (ajustar nivel 5: consultar la regla)
│   ├── data/native_snapshot_writer.dart      # (extender) proyectar franjas+festivos
│   └── presentation/engine_providers.dart    # (ajustar) pasar config horaria al índice
│
└── sync/
    └── ...                                    # (reutilizar) checksum del último sync
```

Android nativo (bajo `android/app/src/main/kotlin/...`):

```
CallScreeningService / snapshot nativo
└── aplicar franja: si contacto comercial y fuera de franja/festivo → block
    (mismos datos proyectados desde Dart; decisión antes de timbrar)
```

---

## 2. Festivos (`ColombianHolidays`)

Función pura, sin estado ni red:

```dart
abstract final class ColombianHolidays {
  /// Festivos del [year] (fechas en zona local CO), aplicando:
  /// - Fijos: 1-ene, 1-may, 20-jul, 7-ago, 8-dic, 25-dic.
  /// - Emiliani (se trasladan al lunes siguiente): Reyes, San José,
  ///   San Pedro y San Pablo, Asunción, Día de la Raza, Todos los Santos,
  ///   Independencia de Cartagena.
  /// - Derivados de Pascua: Jueves/Viernes Santo, Ascensión (+Emiliani),
  ///   Corpus Christi (+Emiliani), Sagrado Corazón (+Emiliani).
  static Set<DateTime> of(int year);

  /// `true` si [date] (normalizada a día local) es festivo.
  static bool isHoliday(DateTime date, {Set<DateTime>? override});
}
```

- **Pascua:** algoritmo de cómputo (Gauss/Anonymous Gregorian) → fecha base para
  los festivos religiosos movibles.
- **Emiliani:** si el festivo no cae lunes, se traslada al lunes siguiente.
- **Override (`app_params`):** `isHoliday` acepta un conjunto adicional/exento; el
  motor lo pasa si lo tiene cacheado del último sync. Ausente ⇒ solo cálculo local.
- **Testeable** con años conocidos (p. ej. verificar fechas de 2024/2025/2026).

---

## 3. Regla de franja (`Ley2300WindowRule`)

Lógica pura, independiente del motor, para testear sin el índice completo:

```dart
abstract final class Ley2300WindowRule {
  /// `true` si un contacto COMERCIAL a [localTime] cae FUERA de la franja legal
  /// (RN-08) y, por tanto, debe bloquearse cuando la capa `ley` está activa.
  /// Usa las franjas de `Ley2300Hours` y `ColombianHolidays`.
  static bool isOutsideWindow(DateTime localTime, {Set<DateTime>? holidays});
}
```

Lógica:
1. Domingo o festivo → siempre fuera (bloqueo 24h).
2. Sábado → permitido solo 08:00–15:00; fuera de ese rango ⇒ bloquea.
3. L-V → permitido solo 07:00–19:00; fuera ⇒ bloquea.

### Integración en `PrecedenceEngine` (nivel 5)
Hoy el nivel 5 bloquea si la capa de la categoría está activa. Se **refina** solo
para categorías **comerciales** (`comercial`, `ley2300`): además de "capa activa",
se exige "fuera de franja".

```
Nivel 5 (categoría con capa activa):
  si categoría ∈ {comercial, ley2300}:
     bloquea ⇔ Ley2300WindowRule.isOutsideWindow(contacto.localTime, holidays)
  si no (extorsion/phishing/callcenter/llamadaFantasma):
     bloquea (comportamiento actual, sin cambio)
```

> Esto **no** altera los niveles 1–4: listas locales, allowlist y dataset negro
> mandan antes. Un `comercial` en franja legal que no esté en ninguna lista negra
> ahora **pasa** (hoy también pasaba, porque el dataset no lo marcaba); la novedad
> es que un `comercial` **fuera de franja** se bloquea aunque no esté listado.

El `EngineIndex`/snapshot gana la info horaria necesaria (franjas fijas + set de
festivos del periodo vigente) para que la decisión sea reproducible en Dart y en
nativo.

---

## 4. Paridad nativa

El `CallScreeningService` corre sin FlutterEngine, así que la franja debe aplicarse
en nativo con los **mismos datos**:

- El `NativeSnapshotWriter` proyecta, además de los hashes/categorías actuales:
  las franjas fijas (constantes) y el **set de festivos** del rango vigente (p. ej.
  año actual ± 1), serializado en el snapshot.
- El nativo, al recibir una llamada de un número cuya categoría resuelta sea
  comercial y con capa `ley` activa, evalúa hora/día/festivo y **bloquea antes de
  timbrar** (DN-07).
- Pruebas de coherencia: misma entrada (hash, categoría, hora) → misma decisión en
  Dart y en nativo.

---

## 5. Verificación de integridad (R5)

Reutiliza el checksum del dataset del flujo de sync (`02-seguridad §02.6`):

- `VerifyDatasetIntegrity`: recomputa el checksum del dataset local y lo compara
  con el **último checksum válido** persistido tras el último sync correcto.
- Resultado: `ok(countHashes)` o `compromised`. En `compromised`, la UI ofrece
  **re-sincronizar** (dispara el flujo de sync existente; si el servidor responde,
  `IntegrityFailure` se maneja como ya está).
- Es **offline**: compara contra lo guardado, no re-descarga para verificar.

> Dónde vive la UI: puede ser una tarjeta en `AdvancedScreen` (sección "Integridad")
> o en el detalle de sync. Como DN-08 pide verificación **real**, esta spec entrega
> el caso de uso; la ubicación exacta de la UI se decide al implementar (sin volver
> a la simulación del prototipo).

---

## 6. Pruebas

- `ColombianHolidays`: fechas conocidas por año (fijos, Emiliani trasladados,
  Semana Santa); `isHoliday` con y sin override.
- `Ley2300WindowRule`: matriz de día×hora (L-V límite 07:00/19:00, Sáb 08:00/15:00,
  domingo, festivo) dentro/fuera.
- `PrecedenceEngine`: un `comercial` fuera de franja con capa `ley` activa →
  `block`; dentro de franja → `allow`; capa `ley` off → `allow`; un `extorsion`
  no se ve afectado por la hora; niveles 1–4 siguen teniendo precedencia.
- Integridad: checksum coincide → `ok(n)`; alterado → `compromised`.
- Paridad nativa: test instrumentado o de contrato del snapshot (según viabilidad).
- `flutter analyze` limpio + suite verde.
