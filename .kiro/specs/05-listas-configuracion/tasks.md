# Spec · 05 Listas locales y configuración avanzada — Plan de implementación

> Opción A (confirmada): **gestión real de listas** en `AdvancedScreen`
> reutilizando toda la plomería de `lists` (sin tocar dominio/datos/motor) +
> acceso al Simulador + retiro del placeholder. **Ley 2300 y auditoría ZK quedan
> diferidas** (ver requirements §3). Orden: estado/controller → widgets →
> integración en pantalla → verificación.
> Dispositivo de prueba de referencia: Moto g04s, Android 14.

- [x] 1. Estado y controller del alta
  - [x] 1.1 `features/settings/presentation/state/list_admin_state.dart`: enum `AddPhase { idle, invalid, duplicate }` y `ListAdminState { phase }` con `hasError`/`message`.
  - [x] 1.2 `features/settings/presentation/controllers/list_admin_controller.dart`: `ListAdminController` (StateNotifier) con `add(String raw)` (normaliza con `canonicalizeNumber`→`invalid`; chequea duplicado contra el `Set` de la lista→`duplicate`; si no, `classifyNumber(raw, kind, origin: ListOrigin.manual)`) y `clearError()`. Exponer `listAdminControllerProvider` como `StateNotifierProvider.family<..., ListKind>`.
  - _Req: R2, R3, R4, R5_

- [x] 2. Widgets de presentación
  - [x] 2.1 `features/settings/presentation/widgets/number_chip.dart`: `NumberChip` (número canónico + `onDeleted`), estética del design system, `semanticLabel` "Eliminar <n>".
  - [x] 2.2 `features/settings/presentation/widgets/list_manager_card.dart`: `ListManagerCard(kind, title, addLabel, accentColor)` — encabezado + contador (del provider), fila `TextField`(phone)+`PrimaryButton`, error bajo el input (del controller), cuerpo con **estado vacío** (R7) o `Wrap` de `NumberChip` (R1/R6). `clearError` al editar.
  - _Req: R1, R2, R3, R4, R6, R7_

- [x] 3. Integración en `AdvancedScreen`
  - [x] 3.1 Añadir sección **LISTAS** con `ListManagerCard(confianza)` (cyan, "Añadir") y `ListManagerCard(negra)` (danger, "Bloquear"); eliminar el `_SectionHint` placeholder de listas (R9.2).
  - [x] 3.2 Añadir acceso **"Abrir Simulador"** → `context.pushNamed(AppRoutes.simulatorName)` (R8). Conservar logout y, solo en dev, el sembrador (R9.1). No introducir "Modo Marco Móvil" (R10).
  - [x] 3.3 Añadir sección **LEY 2300 (solo lectura)** con las 3 franjas de RN-08 y una nota breve "bloqueo offline; festivos calculados en el dispositivo" (R11). Sin switches ni edición. Widget `law2300_hours_card.dart` + fuente única `core/legal/ley2300_hours.dart` (reutilizable por el motor en la spec 08).
  - _Req: R8, R9, R10, R11_

- [x] 4. Pruebas
  - [x] 4.1 Test del `ListAdminController`: inválido→`invalid`; duplicado por forma canónica (`300 123 4567` vs `+573001234567`)→`duplicate`; alta válida→`idle` con `classifyNumber(origin: manual)` invocado. (+ `clearError`.)
  - [x] 4.2 Widget test de `ListManagerCard`: estado vacío con lista vacía; N chips + contador N; tocar X dispara baja; error visible bajo el input.
  - [x] 4.3 Integración de exclusividad RN-05 en alta manual: negra ← número en confianza lo retira de confianza (test del controller con fake reactivo, sin base cifrada).
  - _Req: R1–R7_

- [x] 5. Navegación de Avanzados (listas en pantalla propia + horario en acordeón) (R8b)
  - [x] 5.1 Ruta `/advanced/lists` (`listsPath`/`listsName`) sobre el navegador raíz + `ListsScreen` (AppBar con back; las dos `ListManagerCard`).
  - [x] 5.2 `AdvancedScreen` como **menú**: tarjeta PROTECCIÓN con acceso a listas (con conteo), acordeón del horario Ley 2300 (`Law2300HoursCard(embedded)`), y acceso al Simulador. Helper `_Card`.
  - _Req: R8b, R11_

- [~] 6. Verificación
  - [x] 6.1 `flutter analyze` limpio y suite completa verde.
  - [ ] 6.2 Build e instalación del flavor dev en el Moto g04s; validar manualmente: abrir "Listas locales" (pantalla propia + back), añadir a confianza y a negra, mover un número entre listas (exclusividad), duplicado bloqueado, inválido con error, eliminar, estado vacío; acordeón del horario Ley 2300; conteo en el acceso; y "Abrir Simulador". **Pendiente de prueba en dispositivo físico.**
  - _Req: todos_

---

## Notas

- **No** se modifica `core/db`, `features/lists/{domain,data}`, el motor ni el
  backend. Si algún test requiere la base cifrada y resulta costoso, limitar el
  alcance del test de integración (ver 4.3) sin bloquear la spec.
- **Decisiones de negocio cerradas** (DN-05..DN-09, ver requirements §3): franjas
  fijas de solo lectura (esta spec, tarea 3.3); evaluación de la franja + festivos
  calculados + auditoría real por checksum → **spec de motor `08-motor-franja-ley2300`**;
  importación masiva → fuera de alcance (portal administrativo externo).
- **En esta spec solo entra** la tarjeta de franjas de **solo lectura** (R11). La
  lógica de bloqueo por franja/festivos y la verificación de integridad NO se
  implementan aquí.
