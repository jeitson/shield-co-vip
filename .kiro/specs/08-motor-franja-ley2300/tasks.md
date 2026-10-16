# Spec · 08 Motor de franja Ley 2300 + integridad — Plan de implementación

> Lleva al motor la **evaluación horaria** de la Ley 2300 (franja fija RN-08 +
> festivos calculados offline), su **paridad nativa**, y la **verificación real
> de integridad** del dataset. Reutiliza la fuente única `core/legal/ley2300_hours.dart`
> (spec 05) y el checksum del sync (spec 04). Orden: festivos → regla pura →
> motor → contacto/proyección → nativo → integridad → verificación.
> Dispositivo de prueba de referencia: Moto g04s, Android 14.

- [ ] 1. Festivos colombianos (offline, determinista)
  - [ ] 1.1 `core/legal/colombian_holidays.dart`: fijos + movibles Emiliani + derivados de Pascua (algoritmo de cómputo). `of(year) -> Set<DateTime>` y `isHoliday(date, {override})`.
  - [ ] 1.2 Tests con años conocidos (2024–2026): fijos, Emiliani trasladados a lunes, Semana Santa; `isHoliday` con y sin override.
  - _Req: R2_

- [ ] 2. Regla de franja pura
  - [ ] 2.1 `features/engine/domain/ley2300_window_rule.dart`: `isOutsideWindow(localTime, {holidays})` usando `Ley2300Hours` + `ColombianHolidays` (domingo/festivo → fuera; sábado 08–15; L-V 07–19).
  - [ ] 2.2 Tests matriz día×hora (límites exactos dentro/fuera).
  - _Req: R3.1/R3.2, R5 de la fuente única (R3.5)_

- [ ] 3. Integración en el motor
  - [ ] 3.1 Extender `IncomingContact` con `DateTime localTime` (defecto "ahora" si falta, R1.3).
  - [ ] 3.2 Ajustar `PrecedenceEngine` nivel 5: para categorías comerciales (`comercial`/`ley2300`) con capa `ley` activa, bloquear **solo si** `Ley2300WindowRule.isOutsideWindow(...)`; demás categorías sin cambio; niveles 1–4 intactos (R3.1–R3.4).
  - [ ] 3.3 Pasar al `EngineIndex`/snapshot el set de festivos vigente (año ±1) y las franjas fijas.
  - [ ] 3.4 Tests de `PrecedenceEngine`: comercial fuera/dentro de franja, capa `ley` off, extorsión no afectado, precedencia de niveles 1–4.
  - _Req: R1, R3_

- [ ] 4. Paridad nativa (Android)
  - [ ] 4.1 Extender el `NativeSnapshotWriter` + el lado nativo para serializar franjas + festivos y aplicar la franja en el `CallScreeningService` (bloqueo antes de timbrar, DN-07).
  - [ ] 4.2 Coherencia Dart↔nativo para la misma entrada (test de contrato del snapshot según viabilidad).
  - _Req: R4_

- [ ] 5. Verificación real de integridad (DN-08)
  - [ ] 5.1 `VerifyDatasetIntegrity`: recomputar checksum del dataset local vs. último checksum válido del sync; `ok(count)` | `compromised`. Offline.
  - [ ] 5.2 Flujo de reparación: en `compromised`, ofrecer re-sincronizar (reusa sync + `IntegrityFailure`). Decidir ubicación de UI (tarjeta "Integridad"), sin volver a simulación.
  - [ ] 5.3 Tests: checksum coincide → `ok(n)`; alterado → `compromised`.
  - _Req: R5_

- [ ] 6. Verificación
  - [ ] 6.1 `flutter analyze` limpio + suite verde.
  - [ ] 6.2 Validación en el Moto g04s: contacto comercial simulado fuera de franja se bloquea; dentro de franja pasa; capa `ley` off desactiva la regla; auditoría de integridad real (ok y comprometida simulada).
  - _Req: todos_

---

## Notas

- **Decisiones base:** DN-05 (franjas fijas), DN-06 (festivos calculados offline +
  override `app_params`), DN-07 (fantasma = categoría, sin duración), DN-08
  (integridad real por checksum). Ver `02-business/00-fundamentos` RN-07/RN-08 y
  requirements §3.
- **Reutiliza, no reimplementa:** `core/legal/ley2300_hours.dart` (spec 05),
  `ThreatCategory`/`PrecedenceEngine`/snapshot (spec 05-motor), checksum e
  `IntegrityFailure` (spec 04-sync).
- **Trabajo nativo real** en la tarea 4 (Kotlin): es la pieza de mayor riesgo;
  planificar con el entorno Android a mano.
