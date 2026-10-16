# Spec · 06 Escudo / Dashboard — Plan de implementación

> Pantalla real que integra A (persistencia), B (sync/contador) y C (motor).
> Reemplaza el `PlaceholderScreen` del `ShieldScreen`.

## 1. Dominio del estado agregado
- [x] 1.1 `shield_status.dart`: `ShieldStatus` (total/parcial/riesgo) +
  `fromActiveCount` (RN-03) + color/icono/título/descripción/isProtected.
- _Req: R1_

## 2. Providers (`shield_providers.dart`)
- [x] 2.1 `shieldConfigProvider` (stream de `watchConfig`), `activeLayerCountProvider`,
  `shieldStatusProvider`.
- [x] 2.2 `ShieldController.toggleLayer` (setLayer → persiste → el stream recalcula →
  engineIndex se recomputa → engineProjection reproyecta al motor).
- [x] 2.3 `blockingEngineProvider` (createBlockingEngine) + `enginePermissionsProvider`
  (refrescable).
- [x] 2.4 La pantalla observa `engineProjectionProvider` (mantiene viva la proyección).
- _Req: R1, R2, R7_

## 3. Widgets (fidelidad a ShieldScreen.tsx, tokens de core/theme)
- [x] 3.1 `StatusBar` (punto + glow, label mono, píldora N/3 + icono; label flexible).
- [x] 3.2 `ShieldHero` (anillo pulsante con AnimationController, escudo dinámico, textos).
- [x] 3.3 `LayerCard` + `LayerSpec` (icono/título/badge/desc/switch accesible + panel
  ALTA rojo para extorsion / MEDIA ámbar para callcenter|ley; textos del doc).
- [x] 3.4 `MetricTiles` (lista local = `datasetCountProvider` agrupado es-CO; sync =
  botón + estados sincronizando/éxito-fecha/error-reintento con spinner).
- [x] 3.5 `SimulatorShortcut` (botón "Probar" → `pushNamed(simulator)`).
- _Req: R1, R3, R4, R5, R6, R8_

## 4. Pantalla + priming
- [x] 4.1 `shield_screen.dart`: compone los widgets (ListView móvil-first), consume
  providers; reemplaza el `PlaceholderScreen`.
- [x] 4.2 `PermissionPriming` (si falta call screening) + refresco en `resumed`
  (WidgetsBindingObserver); degradación honesta.
- [x] 4.3 `formatSyncTime` es-CO (Hoy/Ayer/dd-MM).
- _Req: R1–R8_

## 5. Verificación
- [x] 5.1 Tests: `shield_status` (fromActiveCount + formatSyncTime, 8), `layer_card`
  (severidad ALTA/MEDIA, toggle, mapeo, 7), `shield_screen` (3/3 total, parcial,
  riesgo, priming, 5). Suite completa **105 tests OK**.
- [x] 5.2 `flutter analyze` + `dart format` limpios.
- [x] 5.3 `flutter build apk` + instalado en Moto g04s; **Dashboard renderiza y
  scrollea completo en dispositivo** (login real, sesión activa): StatusBar 3/3,
  priming de call screening, ShieldHero "Protección Total Activa", las 3 LayerCards
  con sus switches, MetricTiles ("LISTA LOCAL · 300 hashes" + "ACTUALIZACIÓN ·
  Hoy") y el acceso al Simulador. La base cifrada abre OK (sin StateError de
  cipher → cierra también la verificación de cifrado en device de la spec A).
  **Fix del body en blanco:** `MetricTiles` usaba un `Row` con
  `CrossAxisAlignment.stretch` que, dentro del `ListView` (alto no acotado),
  disparaba "BoxConstraints forces an infinite height" y tiraba el layout del
  `SliverList` → viewport en blanco; se acotó con `IntrinsicHeight`. Además,
  `LayerCard` y el cuerpo del `ShieldScreen` aportan su propio `Material` (el
  `Switch`/`InkWell` lo requieren) para ser autónomos del `Scaffold` del shell.
  **PENDIENTE acción física del usuario:** conceder el rol de call screening y
  disparar una llamada para ver la interceptación real (no automatizable aquí).
- _Req: todos_
