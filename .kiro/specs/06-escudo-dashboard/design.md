# Spec · 06 Escudo / Dashboard — Diseño

> Pantalla real `ShieldScreen` cableada a A/B/C. Riverpod + tokens de
> `core/theme`. Fidelidad a `ShieldScreen.tsx`.

---

## 1. Panorama

```
features/shield/
├── domain/
│   └── shield_status.dart          # estado agregado (total/parcial/riesgo) desde RN-03
├── presentation/
│   ├── shield_providers.dart       # config (watch), toggle, estado agregado, permisos
│   ├── shield_screen.dart          # pantalla (reemplaza el placeholder)
│   └── widgets/
│       ├── status_bar.dart         # barra "Filtro Zero-Knowledge" + N/3
│       ├── shield_hero.dart        # escudo dinámico + anillos + textos
│       ├── layer_card.dart         # tarjeta-módulo con switch + panel de advertencia
│       ├── metric_tile.dart        # lista local (contador) y sync (botón+estado)
│       └── simulator_shortcut.dart # tarjeta "Probar"
```

El estado agregado y los textos derivan de RN-03 / del documento de negocio.
El contador y el sync vienen de `features/sync` (B). El toggle persiste vía
`ShieldConfigDao` (A) y reproyecta al motor (C) a través de
`engineProjectionProvider`.

---

## 2. Estado agregado (`shield_status.dart`)

```dart
enum ShieldStatus { total, parcial, riesgo }

ShieldStatus statusFromActiveCount(int active) => switch (active) {
  3 => ShieldStatus.total,
  >= 1 => ShieldStatus.parcial,
  _ => ShieldStatus.riesgo,
};
```

Cada estado resuelve color (success/warning/danger de `AppColors`), icono,
título y descripción (textos de `ShieldScreen.tsx` / RN-03). Lógica pura y
testeable.

---

## 3. Providers (`shield_providers.dart`)

- `shieldConfigProvider` = `StreamProvider<ShieldConfigRow>` desde
  `ShieldConfigDao.watchConfig()` (reactivo, A). De aquí se deriva el número de
  capas activas y el `ShieldStatus`.
- `toggleLayerProvider` / método: llama `ShieldConfigDao.setLayer(layer, value)`.
  La persistencia dispara el stream → recálculo de estado → `engineIndexProvider`
  se recomputa → `engineProjectionProvider` reproyecta al motor (RF-SHIELD-04).
- `datasetCountProvider` (de B) para el contador.
- `syncControllerProvider` (de B) para el botón de sync y sus estados.
- `enginePermissionsProvider` = `FutureProvider<EnginePermissionStatus>` desde
  `createBlockingEngine().permissionStatus()`, refrescable al reanudar (R7).

El Dashboard **mantiene vivo** `engineProjectionProvider` (lo observa) para que
cada cambio de config/dataset se proyecte al motor.

---

## 4. Pantalla y widgets (fidelidad a ShieldScreen.tsx)

Estructura vertical con scroll, `maxWidth` ~420 (móvil-first):

1. **StatusBar**: punto de color (success/warning/danger con glow), label mono
   "FILTRO ZERO-KNOWLEDGE", y píldora "N / 3 ACTIVOS" con icono (lock/shield/warning).
2. **ShieldHero**: anillos (uno con animación de pulso), escudo central con color
   del estado y check (total/parcial) o alerta (riesgo); píldora de estado + texto
   descriptivo. Animaciones con `AnimationController` (reemplaza el `animate-ping`).
3. **LayerCard ×3** (extorsion/callcenter/ley): icono, título, badge
   (Crítico/Spam/Legal), descripción, `Switch` accesible. Cuando la capa está
   **off**, muestra el panel de advertencia con severidad: ALTA (rojo) para
   `extorsion`, MEDIA (ámbar) para las otras (RN-SHIELD-02). Textos del doc.
4. **MetricTile ×2**:
   - "LISTA LOCAL": `datasetCountProvider` → "N hashes" (o estado vacío si 0).
   - "ACTUALIZACIÓN": botón que llama `syncControllerProvider.notifier.sync()`;
     muestra spinner + "Verificando firmas…" (SyncInProgress), fecha es-CO
     (SyncSuccess/Idle) o error con reintento (SyncFailure).
5. **SimulatorShortcut**: tarjeta con botón "Probar" → `context.pushNamed(simulator)`.

Accesibilidad (§6.9): `Switch` con `Semantics`/label, estado no solo por color
(textos "ALTO/MEDIO", iconos), objetivos ≥ 48dp.

### Priming de permisos (R7)

Un banner/acción no intrusivo: si `enginePermissionsProvider` indica que falta el
rol de call screening, se muestra una tarjeta "Activa el filtrado de llamadas"
que explica (priming) y llama `requestPermissions()`. Tras volver de ajustes, se
invalida el provider para refrescar. Degradación honesta: el estado agregado
puede matizarse ("protección limitada: permiso pendiente") sin fingir.

---

## 5. Formato de fecha (es-CO)

Helper local `formatSyncTime(DateTime)` → "Hoy, HH:mm" / "Ayer, HH:mm" /
"dd/MM HH:mm" en es-CO (sin dependencias nuevas; `intl` si ya estuviera, si no un
formateo manual simple). Coherente con RN-09.

---

## 6. Navegación

`SimulatorShortcut` usa `context.pushNamed(AppRoutes.simulatorName)` (ruta ya
existente sobre la raíz). El router no cambia.

---

## 7. Pruebas

- **Unit (dominio):** `statusFromActiveCount` (3→total, 2/1→parcial, 0→riesgo).
- **Widget:**
  - Con 3 capas activas (config sembrada) → "3 / 3 ACTIVOS" y estado verde
    (CA-SHIELD-01).
  - Desactivar `extorsion` → aparece panel ALTO (rojo) y estado pasa a parcial
    (CA-SHIELD-02/09); el `setLayer` se invoca.
  - Reactivar → panel desaparece (CA-SHIELD-04).
  - Botón "Probar" navega al simulador (CA-SHIELD-08).
  - Estados de sync: inProgress muestra "Verificando firmas…"; failure muestra
    error + reintento sin borrar la fecha (CA-SHIELD-06/07).
  Se usan overrides de Riverpod para inyectar DAOs/providers falsos o una base
  `NativeDatabase.memory`.
- `flutter analyze` + `dart format` + suite completa.
- **Dispositivo:** instalar y validar en el Moto g04s que el Dashboard refleja el
  estado real, el toggle persiste y el sync baja los 300 hashes (contador = 300).
