# 08 · Navegación global y shell de la app

**Alcance:** Header, BottomNav, flujo de navegación entre pantallas y el "chrome" del prototipo que **no** debe portarse.
**Depende de:** 00-fundamentos (RN-03 estado agregado) y todas las pantallas.
**Componentes del prototipo:** `Header.tsx`, `BottomNav.tsx`, orquestación en `App.tsx`.

Este documento define cómo se mueve el usuario por la app y qué partes del prototipo son solo andamiaje de presentación.

---

## 08.1 Modelo de navegación

> **[PROPUESTO]** El prototipo no usa router: la "navegación" es un único estado (`activeScreen`) con un `switch` de renderizado, **sin pila ni historial**. En Flutter debe implementarse con un **Navigator / router real** que mantenga una pila, de modo que "Volver" regrese a la pantalla de origen real (no siempre a `calls`) y el botón atrás del sistema funcione.
>
> **[DECIDIDO · DN-02]** La navegación se divide en dos zonas: una **zona pública** (`login`, `register`, recuperación) y una **zona autenticada** (todo lo demás). Un **guard de autenticación** protege la zona autenticada: sin sesión activa, cualquier intento de entrar redirige a `login`. La app arranca en `login` salvo que exista una sesión válida persistida.

### Barra de navegación inferior (BottomNav) [PROTOTIPO]
Cuatro destinos principales:

| Ítem | Destino | Icono |
|------|---------|-------|
| Escudo | `PANT-SHIELD` (02) | shield |
| Llamadas | `PANT-CALLS` (03) | call |
| Denunciar | `PANT-REPORT` (06) | report |
| Avanzados | `PANT-ADVANCED` (05) | tune |

- **RN-NAV-01 · Visibilidad del BottomNav.** El BottomNav se **oculta** en `login`, `register` y `detail`. En el resto es visible. [PROTOTIPO]
- **RN-NAV-02 · El Simulador no tiene ítem propio.** Se accede desde el Header, desde el Dashboard ("Probar") y desde Avanzados ("Abrir Simulador"); no aparece en el BottomNav. [PROTOTIPO]
- **RN-NAV-03 · Indicación de activo.** El destino actual se resalta (color cyan, icono relleno, punto indicador). [PROTOTIPO]

### Header [PROTOTIPO]
Tres variantes según la pantalla:

1. **Estándar** (shield, calls, report, advanced, simulator): indicador de estado del escudo (verde/ámbar/rojo según **RN-03**), título "Shield Dashboard", botón de acceso al Simulador y avatar.
2. **Detalle** (detail): botón "Volver" + título "Detalle De Registro" + avatar.
3. **Auth** (login, register): botón "Volver al Escudo" + indicador "ENCLAVE SEGURO".

- **RN-NAV-04 · El indicador del Header refleja el estado del escudo.** Hereda **RN-03** (3→verde "Blindaje Activo", 1-2→ámbar "Blindaje Parcial", 0→rojo "Blindaje Desactivado"). [PROTOTIPO]
- **RN-NAV-05 · El avatar lleva al perfil/cuenta.** Como el login es obligatorio (**DN-02**), al llegar al Dashboard siempre hay sesión; por tanto el avatar lleva a la **pantalla de perfil/cuenta** (con opción de cerrar sesión), no a `login`. **[DECIDIDO · DN-02]** (el prototipo lo mandaba a `login` porque no había sesión).

---

## 08.2 Transiciones de navegación

| Origen | Disparador | Destino | Madurez |
|--------|-----------|---------|:---:|
| Dashboard (02) | BottomNav | calls / report / advanced | [PROTOTIPO] |
| Dashboard (02) | "Probar" / botón Simulador del Header | simulator (07) | [PROTOTIPO] |
| Dashboard / Detalle | Avatar | perfil/cuenta (con logout) | [DECIDIDO · DN-02] |
| App (arranque) | sin sesión → login; con sesión → Dashboard | login / Dashboard | [DECIDIDO · DN-02] |
| Perfil | Cerrar sesión | login | [DECIDIDO · DN-02] |
| Registro (03) | "Ver detalles" / menú de evento | detail (04) | [PROTOTIPO] |
| Detalle (04) | "Volver" | pantalla de origen | [PROPUESTO] (hoy siempre a calls) |
| Avanzados (05) | "Abrir Simulador" | simulator (07) | [PROTOTIPO] |
| Login (01) | éxito | Dashboard (02) | [PROTOTIPO] |
| Login ↔ Registro | enlaces | login / register | [PROTOTIPO] |
| Login / Registro | "Volver al Escudo" | Dashboard (02) | [PROTOTIPO] |
| Cualquiera | Exportar SIC (evento Ley 2300) | Modal evidencia (06) | [PROTOTIPO] |

### Requisitos de navegación

- **RF-NAV-01 — Navegación por BottomNav.** Cambiar entre los 4 destinos principales. [PROTOTIPO]
- **RF-NAV-02 — Volver con pila real.** "Volver" en el detalle regresa a la pantalla de origen; el botón atrás del sistema opera sobre la pila. **[PROPUESTO]**
- **RF-NAV-03 — Deep links / navegación desde notificación.** Abrir una pantalla concreta (p. ej. el detalle de un evento) desde una notificación push. **[PROPUESTO]** (hoy no hay URLs ni deep links; relevante porque el núcleo del producto emite notificaciones de interceptación). Si el usuario no tiene sesión, el deep link debe pasar primero por login y luego continuar al destino (**DN-02**).
- **RF-NAV-04 — Guard de autenticación.** Proteger todas las pantallas internas y redirigir a `login` cuando no hay sesión activa. **[DECIDIDO · DN-02]** (login obligatorio).
- **RF-NAV-05 — Pantalla inicial.** La app abre en `login`. Si existe una sesión válida persistida (token no expirado), se salta login y se va directo al Dashboard. **[DECIDIDO · DN-02]** (sustituye el arranque del prototipo en `shield`).
- **RF-NAV-06 — Cerrar sesión (logout).** El usuario puede cerrar sesión desde el perfil/cuenta; al hacerlo se invalida la sesión local y se vuelve a `login`. **[DECIDIDO · DN-02]** (ausente en el prototipo).

---

## 08.3 Reglas de negocio de navegación

- **RN-NAV-06 · Pantalla de arranque = login.** La app inicia en `login`; solo con sesión válida persistida se entra directo al Dashboard. **[DECIDIDO · DN-02]** (el prototipo arrancaba en el Escudo).
- **RN-NAV-07 · Sesión persistente y cierre de sesión.** Existe token de sesión (persistido de forma segura) con expiración, y acción de logout. **[DECIDIDO · DN-02]**; el esquema concreto de token/expiración se define con el backend en la arquitectura (**DN-01**).
- **RN-NAV-08 · Coherencia del "Volver".** "Volver" nunca debe perder el contexto de origen del usuario. **[PROPUESTO]**

---

## 08.4 Criterios de aceptación

- **CA-NAV-01.** Dado que estoy en cualquiera de los 4 destinos principales, cuando toco un ítem del BottomNav, entonces navego a ese destino y el ítem queda resaltado.
- **CA-NAV-02.** Dado que estoy en login, register o detail, cuando miro la pantalla, entonces el BottomNav no se muestra.
- **CA-NAV-03.** Dado que abrí el detalle desde el Registro, cuando toco "Volver", entonces regreso al Registro; dado que lo abrí desde otra ruta, regreso a esa ruta. **[PROPUESTO]**
- **CA-NAV-04.** Dado el estado del escudo, cuando lo cambio, entonces el indicador del Header cambia de color/texto conforme a RN-03.
- **CA-NAV-05.** Dado el botón atrás del sistema, cuando lo pulso, entonces la app retrocede en la pila de navegación (no cierra la app estando en una pantalla interna). **[PROPUESTO]**
- **CA-NAV-06.** Dado que recibo una notificación de interceptación, cuando la toco, entonces la app abre el detalle del evento correspondiente. **[PROPUESTO]**
- **CA-NAV-07.** Dado que no tengo sesión, cuando abro la app o intento entrar a una pantalla protegida, entonces soy llevado a `login`. **[DECIDIDO · DN-02]**
- **CA-NAV-08.** Dado que tengo una sesión válida persistida, cuando abro la app, entonces entro directo al Dashboard sin pasar por login. **[DECIDIDO · DN-02]**
- **CA-NAV-09.** Dado que estoy autenticado, cuando cierro sesión desde el perfil, entonces se invalida la sesión local y regreso a `login`. **[DECIDIDO · DN-02]**

---

## 08.5 Chrome del prototipo — NO portar

El prototipo dibuja alrededor de la app un andamiaje de presentación que **no es funcionalidad del producto** y debe eliminarse al construir en Flutter:

| Elemento del prototipo | Qué es | Acción en Flutter |
|------------------------|--------|-------------------|
| Toolbar superior de salto entre pantallas | Demo para navegar rápido a cualquier pantalla | **Eliminar.** |
| Marco de emulador móvil (bordes, notch) | Simula un dispositivo en el navegador | **Eliminar.** La app corre en un dispositivo real. |
| Barra de estado simulada (09:41, señal, batería) | Imita la barra del SO | **Eliminar.** La provee el sistema. |
| Indicador "home" inferior | Barra decorativa | **Eliminar.** |
| Switch "Modo Marco Móvil" (en Avanzados) | Alterna el marco del prototipo | **Eliminar** (no es ajuste de usuario). |

- **RN-NAV-09 · El chrome no es producto.** Ninguno de los elementos anteriores debe aparecer ni especificarse como funcionalidad. Son exclusivos del prototipo navegable. [PROTOTIPO → eliminar]

---

## 08.6 Dependencias de activos (offline)

> **[PROPUESTO]** El prototipo carga iconos (Material Symbols), tipografías (Space Grotesk, Hanken Grotesk, JetBrains Mono) e imágenes de fondo desde CDN remotos. Sin conexión, la UI pierde iconos y wallpaper. En producción, **empaquetar iconos, fuentes e imágenes como assets locales** para que la app funcione sin red (coherente con la promesa "todo local" del producto).

---

## 08.7 Decisiones confirmadas y preguntas abiertas

**Confirmado:**
- **DN-02 · Login obligatorio.** Arranque en `login`, guard sobre pantallas internas, sesión persistida y logout (RF-NAV-04/05/06, RN-NAV-06/07).
- **DN-01 · Backend.** El esquema de token/sesión y los deep links autenticados se concretan con el contrato de la arquitectura.

**Preguntas abiertas:**
1. **Deep linking desde notificaciones:** ¿qué pantallas deben ser alcanzables directamente (detalle de evento, dashboard)? ¿Comportamiento exacto cuando la sesión expiró?
2. **Expiración de token:** ¿duración, refresh token, re-login silencioso?
3. **Onboarding:** ¿hay un flujo de bienvenida (permisos del SO + simulador) tras el **primer** login, antes del Dashboard?
4. **Perfil de usuario:** la pantalla de perfil/cuenta (destino del avatar) no existe en el prototipo; definir su contenido (datos, logout, gestión de cuenta).
