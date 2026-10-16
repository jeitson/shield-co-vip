# Spec · 03 Registro de eventos — Requerimientos

> Pantalla `PANT-CALLS` (`CallsScreen`): **timeline** de eventos interceptados
> (llamadas y SMS) que el escudo neutralizó, con búsqueda, filtros por tipo y
> severidad, telemetría real, acciones rápidas de clasificación (confianza /
> lista negra) y navegación al detalle (`PANT-DETAIL`, spec 04).
>
> Fuente de negocio: [`02-business/03-registro-eventos`](../../../02-business/03-registro-eventos/03-registro-eventos.md)
> y [`00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md)
> (entidad `EventoInterceptado`, RN-04 número canónico, RN-05 exclusividad,
> RN-07 categorías, §00.4 persistencia, §00.5 estados async).
> Arquitectura: [`03-architecture`](../../../03-architecture/) (DA-13 Clean Arch por
> features, DA-14 cifrado local, RN-01 Zero-Knowledge).
> Referencia visual: `app_desing/src/components/screens/CallsScreen.tsx` +
> [design system](../../../01-docs/06-design-system.md).
> Depende de: `03-persistencia-local` (base cifrada drift/SQLCipher),
> `05-motor-bloqueo` (catálogo `ThreatCategory`, `ThreatLevel`).

---

## 1. Introducción

El prototipo mantiene los eventos en memoria con valores fijos y los pierde al
recargar; la telemetría (48 / 36m / 7) está hardcodeada y la elegibilidad de
exportación SIC se decide buscando la palabra "Ley" en el título (regla frágil).
Producción exige:

- Un **historial persistido localmente y cifrado** (§00.4, DA-14): los eventos
  viven en la base local SQLCipher, nunca en texto plano fuera del dispositivo
  (RN-01).
- Un timeline **real**, ordenado por fecha (RN-04), filtrable y buscable, con los
  **cuatro estados async** (§00.5): cargando, con datos, vacío y error — además
  del vacío inicial de bienvenida.
- **Acciones rápidas de clasificación** (confianza / lista negra) que apliquen la
  **exclusividad RN-05** y re-alimenten el motor de bloqueo. Esto exige una
  feature de **listas locales** (`numeros_listados`) que aún no existe; esta spec
  la crea en su versión mínima y la enchufa al `engineIndexProvider` (niveles 1 y
  3 del motor de precedencia).
- **Elegibilidad SIC estructurada** por categoría (RN-07 / RN-CALLS-02), no por
  texto.

> **Alcance confirmado con el usuario (opción A):** esta spec entrega la feature
> `events` completa (dominio + datos cifrados + pantalla) **y** la feature
> `lists` mínima (tabla + exclusividad RN-05 + re-cableado del motor). El
> **origen de datos real** (puente nativo→Dart que notifica las interceptaciones
> del `CallScreeningService` y las persiste) queda **fuera de alcance** y se
> declara en §3; la pantalla se alimenta de la persistencia local a través de una
> vía de inserción documentada (que luego conectarán el motor y el simulador).
> Precedente: la spec `06-escudo-dashboard` difirió igual la interceptación
> física a la spec del motor.

---

## 2. Requerimientos

### R1 · Persistencia local cifrada del historial (§00.4, DA-14, RN-01)
**Historia:** como usuario, mi historial de eventos sobrevive a reinicios y vive
cifrado en mi dispositivo, sin salir de él.

Criterios (EARS):
1. EL SISTEMA DEBERÁ persistir cada `EventoInterceptado` en la base local
   **cifrada** (drift + SQLCipher), en una tabla `eventos` nueva.
2. CUANDO la app arranca, EL SISTEMA DEBERÁ leer los eventos desde la base local
   (no desde memoria volátil) y conservarlos entre sesiones.
3. EL SISTEMA DEBERÁ versionar el esquema de la base (de v1 a v2) con una
   **migración incremental** que cree la tabla sin perder los datos existentes
   (`shield_config`, `phone_hashes`).
4. EL SISTEMA NO DEBERÁ transmitir eventos, números legibles ni contenido de
   mensajes fuera del dispositivo (RN-01); el historial es, por defecto, local.

### R2 · Listar eventos ordenados (RF-CALLS-01, RN-04)
**Historia:** como usuario, al abrir la pantalla veo todo lo que el escudo
neutralizó, de lo más reciente a lo más antiguo.

Criterios (EARS):
1. CUANDO abro la pantalla con eventos en el historial, EL SISTEMA DEBERÁ
   mostrarlos ordenados por `marcaTiempo` **descendente** (más reciente primero).
2. EL SISTEMA DEBERÁ representar cada evento con su tipo (llamada/SMS), nivel
   (ALTO/MEDIO/BAJO), título de amenaza, etiqueta de reputación, diagnóstico y,
   si es SMS, su contenido en cuarentena.
3. EL SISTEMA DEBERÁ exponer la lista de forma **reactiva**: un alta o un cambio
   de clasificación se refleja sin recargar manualmente la pantalla.

### R3 · Buscar por texto libre (RF-CALLS-02)
**Historia:** como usuario, filtro el historial escribiendo parte de un número o
texto.

Criterios (EARS):
1. CUANDO escribo en el buscador, EL SISTEMA DEBERÁ reducir la lista a los eventos
   cuyo **remitente, título de amenaza, etiqueta de reputación, diagnóstico o
   contenido en cuarentena** contengan el texto.
2. EL SISTEMA DEBERÁ hacer la coincidencia **insensible a mayúsculas/acentos**.
3. CUANDO el buscador queda vacío, EL SISTEMA DEBERÁ restaurar la lista sin filtro
   de texto (respetando el chip activo).

### R4 · Filtrar por chip y combinar con búsqueda (RF-CALLS-03/04, RN-CALLS-05)
**Historia:** como usuario, acoto la lista por tipo o severidad y combino el
filtro con la búsqueda.

Criterios (EARS):
1. EL SISTEMA DEBERÁ ofrecer los chips: **Todos (N)**, **Llamadas**, **SMS**,
   **Alto**, **Medio**, **Bajo**.
2. CUANDO selecciono "SMS", EL SISTEMA DEBERÁ mostrar solo eventos de tipo SMS
   (CA-CALLS-03); análogo para "Llamadas".
3. CUANDO selecciono "Alto", EL SISTEMA DEBERÁ mostrar solo eventos de nivel ALTO
   (CA-CALLS-04); análogo para Medio/Bajo.
4. CUANDO selecciono "Todos", EL SISTEMA DEBERÁ quitar el filtro de chip.
5. CUANDO hay un chip activo **y** un término de búsqueda, EL SISTEMA DEBERÁ
   aplicar **ambas condiciones simultáneamente (AND)** (CA-CALLS-05).
6. EL SISTEMA DEBERÁ mostrar en "Todos (N)" el **total del historial sin filtrar**
   (RN-CALLS-05).

### R5 · Telemetría real (RF-CALLS-10)
**Historia:** como usuario, las tres micro-tarjetas reflejan mi actividad real,
no números inventados.

Criterios (EARS):
1. EL SISTEMA DEBERÁ calcular **"intercepciones de hoy"** como el conteo de
   eventos cuya `marcaTiempo` cae en el día local actual (es-CO).
2. EL SISTEMA DEBERÁ calcular **"críticas"** como el conteo de eventos de nivel
   **ALTO** en el historial visible.
3. EL SISTEMA DEBERÁ calcular **"tiempo ahorrado"** con una fórmula explícita y
   documentada (ver §4, decisión de negocio), no un valor fijo.
4. EL SISTEMA DEBERÁ actualizar las tres métricas de forma **reactiva** ante
   altas o cambios en el historial.

### R6 · Estados de carga, error, vacío por filtro y vacío inicial (§00.5, RF-CALLS-09/11/12)
**Historia:** como usuario, la pantalla me dice con claridad qué está pasando en
cada situación.

Criterios (EARS):
1. MIENTRAS se cargan los eventos desde la base, EL SISTEMA DEBERÁ mostrar un
   **skeleton/indicador de carga** (EST-CALLS-04).
2. SI la carga falla (p. ej. la base no abre), EL SISTEMA DEBERÁ mostrar un
   mensaje de error con acción de **reintentar** (EST-CALLS-05, CA-CALLS-13).
3. CUANDO un filtro o búsqueda no arroja resultados, EL SISTEMA DEBERÁ mostrar
   **"No hay eventos con este criterio"** (EST-CALLS-02, CA-CALLS-06).
4. CUANDO el usuario no tiene **ningún** evento en el historial, EL SISTEMA DEBERÁ
   mostrar un **estado vacío de bienvenida** distinto del vacío por filtro
   (EST-CALLS-03, CA-CALLS-12).

### R7 · Clasificar como lista negra o confianza con exclusividad (RF-CALLS-05/06, RN-05, RN-CALLS-03)
**Historia:** como usuario, clasifico rápidamente un número desde su tarjeta y la
clasificación es coherente (no puede estar en ambas listas).

Criterios (EARS):
1. CUANDO toco **"Lista Negra"** en un evento no bloqueado, EL SISTEMA DEBERÁ
   añadir el número (canónico, RN-04) a la lista negra local, **retirarlo de
   confianza** si estaba, actualizar los badges del evento y mostrar un **toast**
   de confirmación (CA-CALLS-07).
2. CUANDO toco **"De confianza"** en un evento, EL SISTEMA DEBERÁ añadirlo a la
   lista de confianza, **retirarlo de la lista negra** si estaba, y mostrar toast.
3. CUANDO toco de nuevo una clasificación ya activa, EL SISTEMA DEBERÁ
   **desmarcarla** (quitar el número de esa lista) (CA-CALLS-08).
4. EL SISTEMA NO DEBERÁ permitir que un número quede simultáneamente en confianza
   y en lista negra (RN-05): escribir en una **retira** de la otra de forma
   atómica.
5. CUANDO cambia la clasificación de un número, EL SISTEMA DEBERÁ reflejarlo de
   inmediato en **todos** los eventos de ese mismo número en el timeline.
6. EL SISTEMA DEBERÁ reproyectar las listas locales al **motor de bloqueo**
   (niveles 1 y 3 del `PrecedenceEngine`) para que la clasificación afecte el
   filtrado real.
7. EL SISTEMA DEBERÁ mostrar el toast de confirmación de forma **efímera** (~2.5 s,
   RN-CALLS-06, EST-CALLS-06).

### R8 · Preview de cuarentena solo en SMS, en sandbox (RF-CALLS, RN-CALLS-04)
**Historia:** como usuario, veo el SMS neutralizado sin riesgo de interactuar con
él.

Criterios (EARS):
1. CUANDO un evento es **SMS** y tiene `contenidoCuarentena`, EL SISTEMA DEBERÁ
   mostrar el texto en un bloque tipo **sandbox** (CA-CALLS-11).
2. EL SISTEMA NO DEBERÁ hacer navegables los enlaces del contenido en cuarentena
   (no clicables, RN-06 de privacidad del detalle heredada).
3. CUANDO un evento es **llamada**, EL SISTEMA NO DEBERÁ mostrar el bloque de
   contenido.

### R9 · Elegibilidad y disparo de exportación SIC (RF-CALLS-07, RN-CALLS-02, RN-07)
**Historia:** como usuario, solo veo "Exportar SIC" cuando el evento aplica, por
categoría, no por texto.

Criterios (EARS):
1. CUANDO la **categoría** del evento es `Violación franja Ley 2300`
   (`ThreatCategory.ley2300`), EL SISTEMA DEBERÁ mostrar la acción **"Exportar
   SIC"** (CA-CALLS-09).
2. CUANDO la categoría es cualquier otra, EL SISTEMA NO DEBERÁ mostrar la acción.
3. CUANDO toco "Exportar SIC", EL SISTEMA DEBERÁ **invocar el enganche** del flujo
   de evidencia SIC. El flujo completo de generación/exportación pertenece a la
   spec `06-canales-denuncia`; esta spec entrega únicamente la elegibilidad y el
   punto de entrada (ver §3).

### R10 · Abrir el detalle del evento (RF-CALLS-08, CA-CALLS-10)
**Historia:** como usuario, abro la ficha forense de un evento.

Criterios (EARS):
1. CUANDO toco "Ver detalles" (o el menú del evento), EL SISTEMA DEBERÁ navegar a
   `PANT-DETAIL` (`AppRoutes.eventDetailName`) pasando el **id** del evento.
2. EL SISTEMA DEBERÁ permitir que el detalle **recargue el evento por id** desde
   el repositorio (ruta deep-link-capable `/calls/:id`), sin depender de pasar el
   objeto en memoria.

### R11 · Fidelidad visual y accesibilidad (RN-CALLS-01, §6.8/§6.9)
**Historia:** como usuario, la pantalla es coherente con la identidad de marca y
usable por lectores de pantalla / daltonismo.

Criterios (EARS):
1. EL SISTEMA DEBERÁ reproducir la jerarquía de `CallsScreen.tsx`: 3 micro-tarjetas
   de telemetría, buscador, chips de filtro, encabezado "Registro Criptográfico"
   + indicador de motor, lista de tarjetas con glow de severidad, y banner
   "Aislamiento Criptográfico Local".
2. EL SISTEMA DEBERÁ derivar color/glow/icono/acentos del `nivel` usando el helper
   `ThreatLevel` y **exclusivamente** tokens de `core/theme` (nada hardcodeado).
3. EL SISTEMA NO DEBERÁ comunicar la severidad **solo por color**: cada evento
   debe llevar la etiqueta textual del nivel (y/o forma/icono) redundante
   (RN-CALLS-01 [PROPUESTO], WCAG).
4. EL SISTEMA DEBERÁ garantizar objetivos táctiles ≥ 48 dp y labels/semántica
   accesibles en acciones y chips.

### R12 · Paginación / carga incremental para historiales largos (RF-CALLS-13)
**Historia:** como usuario con mucho historial, la lista se mantiene fluida.

Criterios (EARS):
1. EL SISTEMA DEBERÁ cargar los eventos en **páginas** (p. ej. 50) y cargar más
   bajo scroll, en lugar de materializar todo el historial de una vez.
2. EL SISTEMA DEBERÁ mantener la búsqueda y el filtro de chip coherentes con la
   paginación.

> **Nota:** R12 puede implementarse de forma incremental; su prioridad es menor
> que R1–R11. Se marca como objetivo de la spec pero es aceptable entregarlo tras
> el núcleo funcional (ver tasks).

---

## 3. Fuera de alcance (esta spec)

- **Origen de datos real (puente nativo→Dart).** La notificación de las
  interceptaciones desde el `CallScreeningService`/receiver de SMS (Android) hacia
  Dart y su persistencia automática pertenece a la capa nativa / spec del motor.
  Esta spec define el **contrato de inserción** (`EventsRepository.record(...)`)
  para que ese puente —y el Simulador (spec 07)— inserten eventos reales; aquí se
  valida la pantalla contra la persistencia local.
- **Flujo completo de evidencia SIC** (generación del artefacto, formato del PDF/
  export, envío): pertenece a `06-canales-denuncia`. Esta spec entrega la
  **elegibilidad** (R9) y el enganche de navegación/acción.
- **Pantalla de detalle `PANT-DETAIL`** (reportar + bloquear, sandbox forense):
  es la spec `04-detalle-evento`. Aquí solo se entrega la **navegación** hacia
  ella (R10) y el repositorio que le permitirá cargar el evento por id.
- **Gestión completa de listas** (pantalla de administración, importación,
  allowlist global): es la spec `05-listas-y-configuracion`. Esta spec crea la
  feature `lists` **mínima** (tabla + exclusividad RN-05 + providers) necesaria
  para las acciones rápidas; la UI de administración queda para 05.
- **Retención/purga del historial** (pregunta abierta de negocio #2): se deja
  documentada; esta spec no implementa purga automática.
- **Reporte comunitario / reversibilidad** (preguntas de negocio #3): pertenece al
  detalle (04) y canales (06).

---

## 4. Decisiones de negocio tomadas en esta spec (resuelven preguntas abiertas)

Las preguntas abiertas del documento de negocio se resuelven así para no bloquear
la implementación; quedan como decisiones revisables:

1. **Telemetría (pregunta #1).**
   - **Intercepciones de hoy** = eventos con `marcaTiempo` en el día local actual.
   - **Críticas** = eventos de nivel `ALTO`.
   - **Tiempo ahorrado** = `nº eventos × 45 s` (estimación de tiempo medio por
     contacto no deseado), presentado en minutos/horas. Constante única y
     documentada en el código; ajustable sin tocar la UI.
2. **Orden y agrupación (pregunta #4).** Orden por fecha **descendente**; el
   agrupado por "Hoy / Ayer / fecha" es un refinamiento visual opcional (no
   bloqueante).
3. **Retención (pregunta #2) y reversibilidad del reporte (pregunta #3):** fuera
   de alcance (§3).

---

## 5. Trazabilidad (negocio → requisitos de esta spec)

| Negocio | Aquí |
|---|---|
| RF-CALLS-01 (listar, orden real) | R2 |
| RF-CALLS-02 (buscar) | R3 |
| RF-CALLS-03/04 (filtrar + combinar) | R4 |
| RF-CALLS-05/06 (clasificar), RN-05, RN-CALLS-03 | R7 |
| RF-CALLS-07, RN-CALLS-02 (SIC por categoría) | R9 |
| RF-CALLS-08 (abrir detalle) | R10 |
| RF-CALLS-09 (vacío por filtro) | R6.3 |
| RF-CALLS-10 (telemetría real) | R5 |
| RF-CALLS-11 (carga async + error) | R6.1/6.2 |
| RF-CALLS-12 (vacío inicial) | R6.4 |
| RF-CALLS-13 (paginación) | R12 |
| RN-CALLS-01 (severidad + accesibilidad) | R11 |
| RN-CALLS-04 (sandbox SMS) | R8 |
| RN-CALLS-05 (conteo "Todos") | R4.6 |
| RN-CALLS-06 (toast efímero) | R7.7 |
| §00.4 persistencia, DA-14, RN-01 | R1 |
