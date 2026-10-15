# 4. Especificación funcional

Este documento describe **qué hace** cada capacidad del prototipo y, con el mismo peso, **qué le falta** para ser funcional: carga de datos, errores, estados vacíos, permisos del dispositivo y respuestas de servidor. El prototipo es un mock: casi todo el comportamiento "de servidor" está simulado con `setTimeout` y `Math.random`, y los datos provienen de `mockData.ts`.

Leyenda: ✅ Implementado · 🟡 Simulado · ❌ Ausente.

---

## 4.1 Modelo mental del dominio

La app se presenta como un **filtro telefónico local "zero-knowledge"** que intercepta llamadas y SMS maliciosos (extorsión carcelaria, phishing/vishing bancario, call centers, violaciones de la Ley 2300 de 2023 de Colombia). Promete que ningún dato sale del dispositivo y que la lista de números peligrosos se almacena como hashes locales. Hay un componente comunitario (reportar números para proteger a otros) y canales de denuncia oficiales (GAULA 165, SIC).

**Entidades:** `InterceptedEvent` (evento), `ShieldConfig` (3 capas), listas de números (`trustedNumbers`, `blacklistedNumbers`), usuario (solo en formularios, sin modelo).

**Fuente de verdad actual:** estado React en memoria. Se pierde al recargar. No hay persistencia (localStorage, IndexedDB, SQLite ni backend).

---

## 4.2 Capacidades funcionales

### F-01 · Gestión del escudo (3 capas)
- ✅ Activar/desactivar `extorsion`, `callcenter`, `ley` (toggles en `ShieldScreen`).
- ✅ Estado agregado total/parcial/riesgo reflejado en hero, Header y barra de estado.
- ✅ Panel de consecuencia por capa al desactivar.
- 🟡 El toggle no ejecuta ninguna acción de filtrado real; solo cambia estado visual.
- ❌ **Persistencia** de la configuración.
- ❌ **Permiso del sistema** para interceptar llamadas/SMS (ver §4.5). Sin él, esta función es inoperable en producción.

### F-02 · Registro de eventos interceptados
- ✅ Lista de 6 eventos mock con búsqueda y filtros (tipo y severidad).
- ✅ Empty state por filtro sin resultados.
- 🟡 Telemetría (48 intercepciones, 36m, 7 críticas) **hardcodeada**, no derivada de los eventos.
- ❌ **Carga asíncrona:** no hay fetch, por tanto no hay spinner/skeleton ni manejo de `loading`.
- ❌ **Error de carga** y reintento.
- ❌ **Vacío inicial real** (usuario nuevo, 0 eventos): hoy siempre hay 6.
- ❌ **Paginación / scroll infinito / "cargar más".**
- ❌ **Ordenamiento por fecha** (timestamp es string libre).

### F-03 · Detalle y análisis forense de un evento
- ✅ Metadatos (número, fecha, ubicación, tipo), pestañas vector llamada/SMS, sandbox de payload con resaltado de enlace.
- 🟡 "Reportar y bloquear" simula generación de prueba ZK (1.2s) y marca éxito; "Bloquear solo para mí" marca local.
- ✅ Actualiza estado global (lista negra / confianza del evento).
- ❌ **Error de reporte**, estado "ya reportado", confirmación de la comunidad.
- ❌ Carga del evento (si viniera de API/push).

### F-04 · Listas locales (confianza y negra)
- ✅ Añadir y eliminar números en `AdvancedScreen`; toggles rápidos en `calls` y acciones en `detail`.
- ✅ Reglas de exclusividad: marcar confianza quita de lista negra y viceversa (lógica en `App.tsx`).
- ❌ **Validación/normalización** del número (acepta cualquier texto; permite entradas inconsistentes).
- ❌ **Deduplicación robusta** (compara strings exactos; "+57 300…" vs "300…" se tratan distinto).
- ❌ **Empty state** de listas vacías.
- ❌ Persistencia.

### F-05 · Reglas Ley 2300 (horarios)
- 🟡 Franjas horarias mostradas como texto estático; 2 switches (fin de semana, llamadas fantasma) solo cambian estado local.
- ❌ Edición real de franjas, zonas horarias, festivos dinámicos.
- ❌ Motor que aplique las reglas a eventos entrantes.

### F-06 · Auditoría de integridad ZK
- 🟡 Botón que simula verificación (1.5s) y muestra "14,892 Hashes Íntegros". Número fijo.
- ❌ Verificación criptográfica real, resultado de "integridad comprometida", log de auditoría.

### F-07 · Sincronización de lista local
- 🟡 `ShieldScreen` simula sync (1.2s) y aumenta `hashCount` con `Math.random`.
- ❌ Descarga real de firmas, control de versión del dataset, error de red, timestamp real.

### F-08 · Exportar evidencia SIC
- 🟡 Modal en `App.tsx`: compone texto con los datos del evento y un **hash falso** (`Math.random`). Copia al portapapeles.
- 🟡 `ReportChannelsScreen` tiene su propia copia de plantilla (otra lógica, otro texto). ⚠️ Duplicación.
- ❌ Generación de PDF/firma real, radicado, verificación de integridad.
- ❌ Manejo de fallo de `navigator.clipboard` en el modal (en `report` sí hay fallback, pero marca "copiado" aunque falle).

### F-09 · Autenticación (login / registro)
- 🟡 Login simula éxito tras 1s **sin validar credenciales**; credenciales pre-rellenadas. Registro simula 2.4s.
- ✅ Gate por checkboxes (no envía sin aceptar términos/privacidad).
- ✅ Toggle de visibilidad de contraseña; `minLength=8` en registro.
- ❌ Validación de credenciales, errores de auth (401, usuario inexistente, cuenta bloqueada).
- ❌ Verificación de correo / OTP del celular (+57 bloqueado sin verificar).
- ❌ Recuperación de clave (hoy un `alert`), 2FA, sesión/token, logout.

### F-10 · Simulador en vivo
- ✅ Demo de notificación heads-up (llamada/SMS), acciones con toast, descartar/reactivar.
- 🟡 No persiste ni afecta el estado global; sandbox puramente visual.

### F-11 · Canales de denuncia
- ✅ Tabs GAULA/SIC, botón `tel:165`, enlaces externos al portal SIC, guía de pasos.
- 🟡 `tel:165` muestra un pseudo-modal "Marcando…" en vez de depender del dialer.
- ❌ Estado sin conexión al abrir enlaces externos; verificación de que el dispositivo pueda llamar.

### F-12 · Chrome del prototipo (no productivo)
- Toolbar de salto entre pantallas, marco emulador, toggle marco/pantalla completa. **Debe eliminarse** al portar a Flutter.

---

## 4.3 Estados de carga de datos

| Flujo | Estado de carga | Hoy |
|-------|-----------------|-----|
| Lista de eventos | spinner/skeleton | ❌ data síncrona mock |
| Detalle de evento | carga de ficha | ❌ |
| Sincronización lista | spinner | 🟡 `setTimeout` 1.2s |
| Auditoría integridad | spinner | 🟡 `setTimeout` 1.5s |
| Login | "Descifrando…" | 🟡 `setTimeout` 1s |
| Registro | "Blindando…" | 🟡 `setTimeout` 1.2s + 1.2s |
| Reportar+bloquear | "Generando prueba…" | 🟡 `setTimeout` 1.2s |

**Recomendación:** definir estados `loading / success / error / empty` por cada operación asíncrona y skeletons para listas.

---

## 4.4 Estados de error (todos ausentes)

Ninguna pantalla maneja errores reales. Para producción se requieren, como mínimo:

- **Red:** sin conexión, timeout, 5xx del servidor de firmas/comunidad.
- **Autenticación:** credenciales inválidas (401), cuenta inexistente/bloqueada, token expirado.
- **Validación de formularios:** correo mal formado, teléfono inválido, contraseña débil, campos duplicados (email/teléfono ya registrados).
- **Portapapeles:** `navigator.clipboard` ausente o permiso denegado (hoy se marca "copiado" igualmente).
- **Permisos denegados** del sistema (ver §4.5).
- **Datos corruptos / integridad ZK comprometida** en la auditoría.
- **Enlaces externos:** no se puede abrir el navegador o el dialer.

---

## 4.5 Permisos (ausentes y críticos)

La propuesta de valor (interceptar llamadas y SMS) depende de permisos del sistema operativo que **el prototipo no solicita ni modela**. `metadata.json` declara `requestFramePermissions: []` (ninguno). Para producción, en especial en el port a Flutter:

| Permiso | Para qué | Estado |
|---------|----------|--------|
| Rol de pantalla de llamadas / `CallScreeningService` (Android) / CallKit (iOS) | Interceptar y rechazar llamadas | ❌ |
| Lectura/filtro de SMS (`SmsRetriever` / rol de app SMS por defecto en Android; iOS: `IdentityLookup`/`SMS filter extension`) | Filtrar SMS | ❌ |
| Notificaciones | Mostrar heads-up de interceptación (el simulador la emula) | ❌ |
| Contactos | La app promete explícitamente **no** acceder a contactos — debe respetarse | ✅ (política declarada, sin código) |
| Teléfono (iniciar llamada) | Llamar al GAULA 165 | 🟡 vía `tel:` (no permiso explícito) |

**Flujos de permisos ausentes:** solicitud inicial (onboarding), estado "permiso denegado", enlace a ajustes del sistema, degradación de funciones cuando falta un permiso, re-solicitud. Hoy la app asume que todo está concedido.

---

## 4.6 Respuestas de servidor (ausentes)

No existe backend. Todo lo que parece "servidor" es local y simulado. Para producción habría que definir contratos de API para:

| Dominio | Operación esperada | Estado |
|---------|--------------------|--------|
| Auth | login, registro, refresh token, recuperar clave, verificar OTP | ❌ |
| Comunidad | reportar número, consultar reputación, votos | ❌ (hoy local) |
| Firmas / listas | descargar dataset de hashes, versión, delta sync | 🟡 simulado |
| Eventos | sincronizar historial entre dispositivos (si aplica) | ❌ |
| SIC/GAULA | no hay API pública directa (confirmado en el propio copy del `ReportChannelsScreen`); se resuelve con enlaces y guía manual | N/A |

**Contratos a definir:** formato de error estándar, códigos de estado, paginación, idempotencia de "reportar", esquema de `InterceptedEvent` con `timestamp` como fecha ISO real, y modelo de `User`/`Session`.

---

## 4.7 Reglas de negocio detectadas en el código

1. **Estado del escudo:** `3/3 = Total (verde)`, `1-2 = Parcial (ámbar)`, `0 = Riesgo (rojo)`. (`ShieldScreen`, `Header`.)
2. **Exclusividad de listas:** un número no puede estar simultáneamente en confianza y en lista negra; marcar uno limpia el otro. (`App.tsx handleToggleTrust/handleToggleBlacklist`.)
3. **Botón "Exportar SIC"** aparece solo si `threatTitle` contiene la palabra "Ley". (`CallsScreen`.) ⚠️ Frágil: depende de texto, no de un campo de categoría.
4. **Gate de formularios auth:** no se envía sin aceptar ambos checkboxes.
5. **Franja legal Ley 2300** (texto): L-V 07:00–19:00, Sáb 08:00–15:00, Dom/festivos bloqueo 24h. (`AdvancedScreen`, `ReportChannelsScreen`.)
6. **Fallback de detalle:** sin evento seleccionado se usa `INITIAL_EVENTS[0]` o datos por defecto.

---

## 4.8 Riesgos y deuda para el port a Flutter

- Toda la lógica "de seguridad" (ZK, hashes, interceptación) es **narrativa de UI**, no funcionalidad. El esfuerzo real de ingeniería está por construirse.
- `timestamp` como string impide ordenamiento/filtros temporales.
- Duplicación de la lógica de evidencia SIC (modal en `App.tsx` vs `ReportChannelsScreen`).
- Dependencias muertas en `package.json` (ver inventario de integraciones).
- Sin capa de persistencia ni gestión de estado escalable (todo en `App.tsx`).
- Accesibilidad parcial (switches sin `role` en `advanced`, dependencia de color para severidad).
