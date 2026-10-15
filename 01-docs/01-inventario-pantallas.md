# 1. Inventario de pantallas

Las pantallas se renderizan condicionalmente en `App.tsx` según el estado `activeScreen: ActiveScreen`. No hay rutas URL; la "navegación" es un `switch` de renderizado. El tipo `ActiveScreen` enumera: `'shield' | 'calls' | 'report' | 'simulator' | 'advanced' | 'detail' | 'login' | 'register'`.

## Resumen

| ID (`activeScreen`) | Nombre | Componente | Archivo | En BottomNav | Header |
|---------------------|--------|------------|---------|:---:|--------|
| `shield` | Escudo / Dashboard | `ShieldScreen` | `screens/ShieldScreen.tsx` | ✅ | Estándar |
| `calls` | Llamadas / Registro | `CallsScreen` | `screens/CallsScreen.tsx` | ✅ | Estándar |
| `report` | Canales de denuncia | `ReportChannelsScreen` | `screens/ReportChannelsScreen.tsx` | ✅ | Estándar |
| `advanced` | Configuración avanzada | `AdvancedScreen` | `screens/AdvancedScreen.tsx` | ✅ | Estándar |
| `simulator` | Simulador en vivo | `LiveSimulatorScreen` | `screens/LiveSimulatorScreen.tsx` | ❌ (acceso por botón) | Estándar |
| `detail` | Detalle de registro | `RecordDetailScreen` | `screens/RecordDetailScreen.tsx` | ❌ | Variante "detalle" (botón Volver) |
| `login` | Acceso seguro | `LoginScreen` | `screens/LoginScreen.tsx` | ❌ | Variante "auth" |
| `register` | Crear cuenta | `RegisterScreen` | `screens/RegisterScreen.tsx` | ❌ | Variante "auth" |

Pantalla inicial: `shield` (valor por defecto de `useState`). No hay gate de autenticación: la app arranca autenticada de hecho.

---

## 1.1 `shield` — Escudo / Dashboard

**Propósito:** Panel principal. Muestra el estado global del blindaje y permite activar/desactivar las tres capas de protección.

**Contenido:**
- Barra de estado del filtro "Zero-Knowledge" con contador `N / 3 ACTIVOS`.
- Hero con escudo SVG dinámico (color y mensaje cambian según capas activas: total / parcial / en riesgo).
- 3 tarjetas-módulo con switch táctil: `extorsion`, `callcenter`, `ley`. Cada una muestra un panel de advertencia al desactivarse.
- 2 métricas: contador de hashes locales y botón de sincronización manual.
- Tarjeta de acceso rápido al simulador.

**Estado local propio:** `syncing`, `lastSyncTime`, `hashCount`.
**Props:** `config`, `onToggle`, `onNavigateToSimulator`.

**Estados cubiertos:** total (3/3), parcial (1-2/3), riesgo (0/3), sincronizando.
**Estados ausentes:** sin estado de error de sincronización; `hashCount` crece con `Math.random`, no refleja data real.

---

## 1.2 `calls` — Llamadas / Registro criptográfico

**Propósito:** Timeline de eventos interceptados (llamadas y SMS). Permite buscar, filtrar, marcar confianza/lista negra y exportar evidencia SIC.

**Contenido:**
- 3 micro-tarjetas de telemetría (**valores hardcodeados**: 48 intercepciones, 36m ahorrados, 7 críticas).
- Buscador por texto (número, entidad, diagnóstico, contenido en cuarentena).
- Chips de filtro: Todos, Llamadas, SMS, Alto, Medio, Bajo.
- Lista de tarjetas de evento con diagnóstico, contenido en cuarentena (si es SMS) y acciones rápidas.
- Banner de privacidad Zero-Knowledge.

**Estado local propio:** `searchTerm`, `activeFilter`, `toastMessage`.
**Props:** `events`, `onSelectEvent`, `onToggleTrust`, `onToggleBlacklist`, `onExportSicReport`.

**Estados cubiertos:** lista con datos, **vacío por filtro** (empty state "No hay eventos con este criterio"), toast de feedback.
**Estados ausentes:** carga (skeleton/spinner), error de carga, vacío inicial real (siempre hay 6 eventos mock), paginación/scroll infinito.

---

## 1.3 `detail` — Detalle de registro

**Propósito:** Ficha forense de un evento. Permite reportar+bloquear (comunitario) o bloquear solo localmente.

**Contenido:**
- Tarjeta de inspección del número (número, nivel de peligro, metadatos: fecha, ubicación, tipo de actividad).
- Pestañas Llamada / SMS.
- Sandbox del payload SMS con resaltado del enlace peligroso.
- Módulo de doble protección: selección de categoría, nota opcional, botón "Reportar y bloquear" (con estados generating/success) y botón "Bloquear solo para mí".
- Nota de privacidad.

**Estado local propio:** `activeVector`, `selectedCategory`, `extraDetails`, `dualActionStatus` (`idle|generating|success`), `localActionDone`.
**Props:** `event?`, `onBack`, `onBlockAndReport`, `onBlockLocal`.

**Estados cubiertos:** idle, generando, éxito; fallback a datos por defecto si `event` es `null`.
**Estados ausentes:** error al reportar, estado "ya reportado", validación de categoría/nota, estado de carga del evento.

> Nota: si se entra a `detail` sin seleccionar evento, `App.tsx` carga `INITIAL_EVENTS[0]` como fallback (desde el toolbar superior). Dentro del componente también hay valores por defecto hardcodeados.

---

## 1.4 `report` — Canales de denuncia

**Propósito:** Orientación legal. Dos pestañas: GAULA (línea 165, extorsión) y SIC (Ley 2300, acoso comercial).

**Contenido:**
- Pestaña GAULA: botón de llamada `tel:165` + recomendaciones.
- Pestaña SIC: guía de 4 pasos + enlace al portal oficial + botón "Copiar evidencia".

**Estado local propio:** `activeTab` (`gaula|sic`), `copied`, `showCallConfirm`.
**Props:** ninguna.

**Estados cubiertos:** cambio de pestaña, confirmación de llamada, "copiado" con feedback.
**Estados ausentes:** manejo de fallo de `navigator.clipboard` (hay fallback que marca "copiado" aunque no copie), estado sin conexión para abrir portal externo.

---

## 1.5 `simulator` — Simulador en vivo

**Propósito:** Demostrar la notificación flotante de interceptación en pantalla bloqueada. Pantalla puramente demostrativa.

**Contenido:**
- Selector Llamada bloqueada / SMS interceptado.
- Lienzo de "lockscreen" con wallpaper (imagen remota), reloj y notificación heads-up.
- Acciones: Reportar, De confianza, Descartar (todas solo muestran toast).
- Tarjeta educativa explicando cada opción.

**Estado local propio:** `simulatorTab`, `toastFeedback`, `cardDismissed`.
**Props:** ninguna.

**Estados cubiertos:** llamada, SMS, descartado, toasts.
**Estados ausentes:** nada persiste; las acciones no modifican el estado global (a diferencia de `calls`/`detail`). Es un sandbox aislado.

---

## 1.6 `login` — Acceso seguro

**Propósito:** Formulario de inicio de sesión.

**Contenido:** campo identificador/correo, clave con toggle de visibilidad, 2 checkboxes (términos, privacidad), botón de envío, enlace a registro.

**Estado local propio:** `identifier`, `password`, `showPassword`, `termsAccepted`, `privacyAccepted`, `loading`.
**Props:** `onSuccess`, `onGoToRegister`.

**Estados cubiertos:** idle, cargando ("Descifrando Enclave…"), gate por checkboxes (no envía si falta aceptar).
**Estados ausentes:** validación de credenciales, error de login, bloqueo por intentos, recuperación real de clave (hoy solo un `alert`). **Credenciales pre-rellenadas hardcodeadas.**

---

## 1.7 `register` — Crear cuenta

**Propósito:** Formulario de registro.

**Contenido:** nombre, apellido, correo, contraseña (mín. 8), celular con prefijo +57 bloqueado, 2 checkboxes obligatorios, botón de envío, enlace a login.

**Estado local propio:** `firstName`, `lastName`, `email`, `password`, `phone`, `showPassword`, `termsAccepted`, `privacyAccepted`, `isSubmitting`, `isDone`.
**Props:** `onSuccess`, `onGoToLogin`.

**Estados cubiertos:** idle, enviando ("Blindando Identidad…"), hecho ("Identidad Generada"), gate por checkboxes.
**Estados ausentes:** validación de formato (más allá de `type=email`/`minLength`), correo/teléfono ya existente, verificación OTP del celular, error de servidor.

---

## 1.8 `advanced` — Configuración avanzada

**Propósito:** Reglas del motor, auditoría de la bóveda de hashes y gestión de listas (confianza / negra).

**Contenido:**
- Switch de modo marco móvil (meta-control del prototipo, no de la app).
- Reglas Ley 2300: franjas horarias (estáticas) + 2 switches (bloqueo fin de semana, silenciar llamadas fantasma).
- Auditoría de integridad ZK (botón con estados checking/verified).
- Gestor lista de confianza (añadir/eliminar).
- Gestor lista negra (añadir/eliminar).
- Acceso rápido al simulador.

**Estado local propio:** `newTrustedInput`, `newBlacklistInput`, `integrityChecking`, `integrityVerified`, `strictWeekendBlock`, `autoMuteGhostCalls`.
**Props:** `trustedNumbers`, `blacklistedNumbers`, `onRemoveTrusted`, `onRemoveBlacklisted`, `onAddTrusted`, `onAddBlacklisted`, `onLaunchSimulator`, `isMobileFramed`, `onToggleMobileFrame`.

**Estados cubiertos:** auditando, verificado, listas con items.
**Estados ausentes:** **lista vacía** (no hay empty state al borrar todos los números), validación/normalización de número al añadir (acepta cualquier texto, permite duplicados visuales), persistencia (todo se pierde al recargar), error de auditoría.

---

## Marco contenedor (no es pantalla, pero envuelve todas)

`App.tsx` dibuja un chrome que **no forma parte de la app final**: un toolbar superior para saltar entre pantallas (demo), un marco de emulador móvil con status bar simulado (09:41, notch, batería) y el indicador home inferior. En Flutter esto desaparece; es andamiaje de presentación del prototipo.
