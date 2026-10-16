# Spec · 04 Detalle de evento — Requerimientos

> Pantalla `PANT-DETAIL` (`RecordDetailScreen`): **ficha forense** de un evento
> interceptado concreto. Permite inspeccionar metadatos, revisar el payload del
> SMS en un sandbox, y decidir cómo responder: **reportar + bloquear**
> (comunitario anónimo) o **bloquear solo localmente**. Ambas vías bloquean en el
> dispositivo (RN-DETAIL-01); el reporte comunitario es anónimo (RN-DETAIL-02).
>
> Fuente de negocio: [`02-business/04-detalle-evento`](../../../02-business/04-detalle-evento/04-detalle-evento.md)
> y [`00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md)
> (RN-02 reporte anónimo, RN-05 exclusividad, RN-07 categorías).
> Arquitectura: contrato del reporte comunitario `POST /v1/report` en
> [`05-backend-api-metricas §05.2`](../../../03-architecture/05-backend-api-metricas.md)
> y el flujo con moderación en [`03-datos §03.6`](../../../03-architecture/03-datos-y-sincronizacion.md) (DA-10).
> Referencia visual: `app_desing/src/components/screens/RecordDetailScreen.tsx` +
> [design system](../../../01-docs/06-design-system.md).
> Depende de: `03-registro-eventos` (entidad `InterceptedEvent`, `GetEvent`,
> feature `lists` con `classifyNumber`/exclusividad RN-05, ruta `/calls/:id` y el
> stub `RecordDetailScreen`), `05-motor-bloqueo` (catálogos `ThreatCategory`,
> `ThreatLevel`, `ContactChannel` y reproyección al nativo), `07-devices-sesion`
> (`device_id` de instalación y Dio autenticado con `x-device-id`).

---

## 1. Introducción

La spec 03 dejó `RecordDetailScreen` como un **stub**: carga el evento por id vía
`eventByIdProvider` y muestra una lista de campos. Falta la ficha forense real
del prototipo y, sobre todo, las **dos vías de acción**:

- **Bloquear solo para mí** — añade el número a la lista negra local. La plomería
  ya existe (`classifyNumberProvider` → `numeros_listados` → exclusividad RN-05 →
  reproyección al motor), esta spec le da la UI.
- **Reportar y bloquear** — además del bloqueo local, envía un **reporte
  comunitario anónimo** al backend. Hoy **no existe** ni el cliente ni la Edge
  Function; la arquitectura sí define el contrato (`POST /v1/report`, DA-10).

**Alcance confirmado con el usuario (opción A, todo implementado de forma real):**
esta spec entrega:

1. La **ficha forense completa** (inspección del número, pestañas de vector,
   sandbox del SMS no navegable, módulo de bloqueo con categoría + nota, footer de
   privacidad), fiel al prototipo y con solo tokens de `core/theme`.
2. El **bloqueo local real** por ambas vías, heredando la exclusividad RN-05 y la
   reproyección al motor (sin reimplementar el hashing).
3. Una **feature `reports` real**: dominio + datasource **real** contra la Edge
   Function `v1-report` **y** un datasource **fake** en memoria, seleccionados por
   `AppConfig.hasSupabase` (mismo patrón que `auth`/`device`). La app funciona
   completa con el fake; al desplegar `v1-report` se activa el real sin tocar
   dominio ni UI.
4. El **código del backend** del reporte comunitario (migración de la tabla
   `reports` + Edge Function `v1-report` con normalización, HMAC con el pepper,
   allowlist de protección, dedup por `device_id` y estado `pendiente`), **escrito
   y verificable localmente**. El **despliegue al proyecto Supabase remoto queda
   fuera de alcance de la implementación** y requiere confirmación explícita del
   usuario cuando se decida (regla R-DEPLOY-01); la spec deja todo listo para ese
   deploy.

> **Fuera de alcance explícito:** la **promoción** del reporte a `blacklist`
> global por umbral (pg_cron / job de moderación) y las métricas; la **generación
> de evidencia SIC** (spec 06); la **UI de administración de listas** (spec 05);
> la reversibilidad del reporte (pregunta de negocio #2). Ver §3.

---

## 2. Requerimientos

### R1 · Cargar y mostrar la ficha forense del evento (RF-DETAIL-01/02, CA-DETAIL-01/02)
**Historia:** como usuario, al abrir el detalle veo todo el contexto del número
sospechoso: quién es, cuándo, dónde y de qué tipo de amenaza se trata.

Criterios (EARS):
1. CUANDO llego al detalle con un `id` válido, EL SISTEMA DEBERÁ cargar el evento
   vía `eventByIdProvider`/`GetEvent` (ruta deep-link-capable `/calls/:id`) sin
   depender de pasar el objeto en memoria.
2. EL SISTEMA DEBERÁ mostrar el **número** (`sender`, seleccionable), un **badge de
   nivel de peligro** derivado de `level` con etiqueta textual redundante
   (`ThreatLevel.label`, no solo color), y la marca de tiempo formateada.
3. EL SISTEMA DEBERÁ mostrar los **metadatos forenses**: fecha/hora
   (`timestamp`), **ubicación reportada** (`details?.ubicacion`), **tipo de
   actividad** (`threatTitle`), categoría (`category.label`), reputación
   (`reputationTag`) y diagnóstico (`diagnosis`).
4. EL SISTEMA DEBERÁ presentar pestañas de **vector Llamada/SMS**, con la pestaña
   inicial igual al `type` del evento (SMS → "SMS", llamada → "Llamada").

### R2 · Sandbox del payload SMS, no navegable (RF-DETAIL-03, RN-DETAIL-06, CA-DETAIL-02/03)
**Historia:** como usuario, veo el SMS neutralizado y entiendo por qué es
peligroso, sin poder tocar el enlace.

Criterios (EARS):
1. CUANDO el evento es **SMS** y tiene `quarantinedContent` (`hasQuarantine`), EL
   SISTEMA DEBERÁ mostrar el texto en un bloque **sandbox** con el enlace
   **resaltado** visualmente.
2. EL SISTEMA NO DEBERÁ hacer el enlace **navegable** (no clicable): tocarlo no
   abre nada (texto plano, sin `Linkify`).
3. EL SISTEMA DEBERÁ acompañar el sandbox con una **alerta** explicativa de
   "enlace peligroso".
4. CUANDO el evento es **llamada** (o SMS sin contenido), EL SISTEMA NO DEBERÁ
   mostrar el bloque de payload.

### R3 · Seleccionar categoría del problema (RF-DETAIL-04, RN-DETAIL-04, CA-DETAIL-10)
**Historia:** como usuario, clasifico conscientemente el tipo de problema antes de
reportar, con un catálogo estructurado.

Criterios (EARS):
1. EL SISTEMA DEBERÁ ofrecer un **selector de categoría** alineado con el catálogo
   cerrado `ThreatCategory` (RN-07), **no** cadenas sueltas de UI.
2. EL SISTEMA DEBERÁ **preseleccionar** la `category` del evento como valor
   inicial sugerido (el usuario puede cambiarla).
3. CUANDO el usuario intenta **"Reportar y bloquear"** sin una categoría
   seleccionada, EL SISTEMA DEBERÁ exigir elegir una antes de enviar
   (RN-DETAIL-04). La categoría **no** es obligatoria para "Bloquear solo para mí".

### R4 · Nota adicional opcional (RF-DETAIL-05)
**Historia:** como usuario, añado un detalle libre que ayude a entender el reporte.

Criterios (EARS):
1. EL SISTEMA DEBERÁ ofrecer un campo de **texto libre opcional** ("Detalles
   adicionales").
2. EL SISTEMA DEBERÁ permitir reportar con el campo **vacío** (opcional).
3. EL SISTEMA NO DEBERÁ incluir la nota en el payload que viaja al backend si esto
   compromete el anonimato; la nota es contexto local/moderación — ver §4 decisión
   de negocio (por defecto la nota **no** se transmite en el MVP del reporte).

### R5 · Reportar y bloquear (comunitario anónimo + bloqueo local) (RF-DETAIL-06, RN-DETAIL-01/02, CA-DETAIL-04)
**Historia:** como usuario, con una acción bloqueo el número en mi teléfono y, de
forma anónima, ayudo a proteger a otros reportándolo a la comunidad.

Criterios (EARS):
1. CUANDO toco **"Reportar y bloquear"** con una categoría seleccionada, EL
   SISTEMA DEBERÁ, en este orden: (a) **bloquear localmente** el número (lista
   negra, exclusividad RN-05, reproyección al motor) y (b) **enviar el reporte
   comunitario** al backend.
2. MIENTRAS la acción está en curso, EL SISTEMA DEBERÁ mostrar el estado
   **"Generando Prueba ZK & Inmunizando…"** (EST-DETAIL-02) y, al terminar con
   éxito, **"¡Bloqueado y Sincronizado!"** (EST-DETAIL-03).
3. EL SISTEMA DEBERÁ enviar al backend **solo**: el **número del infractor**
   (`sender`, canónico E.164, RN-04), la **categoría** y el **`device_id`
   anónimo** de instalación. EL SISTEMA NO DEBERÁ incluir identidad, contactos,
   contenido del mensaje ni datos personales del reportante (RN-DETAIL-02, RN-02,
   DA-10).
4. EL SISTEMA DEBERÁ tratar el reporte como la Edge Function `POST /v1/report`:
   el servidor normaliza a E.164, calcula el **HMAC con el pepper** y guarda el
   reporte en estado `pendiente` (no entra directo a la blacklist; DA-10).
5. CUANDO `AppConfig.hasSupabase` es falso (tests / offline), EL SISTEMA DEBERÁ
   usar el datasource **fake** y completar el flujo (bloqueo local + "reporte"
   simulado en memoria) sin romper la UI.

### R6 · Bloquear solo localmente (RF-DETAIL-07, RN-DETAIL-01, CA-DETAIL-06)
**Historia:** como usuario, bloqueo el número solo en mi teléfono, sin reportarlo
a la comunidad.

Criterios (EARS):
1. CUANDO toco **"Bloquear solo para mí"**, EL SISTEMA DEBERÁ añadir el número a
   la **lista negra local** (vía `classifyNumber`, exclusividad RN-05) **sin**
   enviar reporte comunitario.
2. CUANDO el bloqueo local se aplica, EL SISTEMA DEBERÁ mostrar la confirmación
   **"Número Silenciado Localmente"** (EST-DETAIL-04).
3. EL SISTEMA DEBERÁ reflejar el bloqueo en el **motor** (reproyección a niveles 1
   y 3 del `PrecedenceEngine`), igual que las acciones del registro.

### R7 · Salir de confianza al bloquear (RN-DETAIL-03, RN-05, CA-DETAIL-05)
**Historia:** como usuario, si un número estaba en confianza y lo bloqueo, deja de
estar en confianza automáticamente.

Criterios (EARS):
1. CUANDO bloqueo (por cualquiera de las dos vías) un número que estaba en la
   lista de **confianza**, EL SISTEMA DEBERÁ **retirarlo de confianza** de forma
   atómica (RN-05: un número nunca en ambas listas).
2. EL SISTEMA DEBERÁ reflejar el nuevo estado (BLOQUEADO) en la ficha de forma
   reactiva (vía `membershipProvider`).

### R8 · Manejo de error del reporte y reintento (RF-DETAIL-09, EST-DETAIL-05, CA-DETAIL-07)
**Historia:** como usuario, si el reporte comunitario falla, me entero y puedo
reintentar sin perder el bloqueo ni la categoría.

Criterios (EARS):
1. SI el **reporte comunitario falla** (red, servidor, 4xx/5xx), EL SISTEMA DEBERÁ
   mostrar un mensaje de **error** con acción de **reintentar** (EST-DETAIL-05).
2. EL SISTEMA DEBERÁ **conservar el bloqueo local ya aplicado** y la **categoría /
   nota** seleccionadas tras el error (no se pierden ni se revierten).
3. CUANDO el servidor responde `rechazado` con motivo `numero_protegido`
   (allowlist de protección, DA-10), EL SISTEMA DEBERÁ informar que el número está
   **protegido** y **no** tratarlo como error reintentar-able (el bloqueo local se
   mantiene).

### R9 · Estado "ya reportado" / idempotencia (RF-DETAIL-10, RN-DETAIL-05, EST-DETAIL-06, CA-DETAIL-08)
**Historia:** como usuario, si ya reporté un número, no genero un reporte
duplicado y la UI lo refleja.

Criterios (EARS):
1. EL SISTEMA DEBERÁ ser **idempotente**: reportar dos veces el mismo número desde
   el mismo dispositivo **no** crea un reporte duplicado (dedup por `device_id` +
   número en el servidor, DA-10).
2. CUANDO el número ya fue reportado por este dispositivo, EL SISTEMA DEBERÁ
   reflejar el estado **"ya reportado"** (acción de reporte informada/
   deshabilitada), sin bloquear la vía de "Bloquear solo para mí".

### R10 · Evento no disponible (RF-DETAIL-11, EST-DETAIL-07, CA-DETAIL-11)
**Historia:** como usuario, si abro un detalle cuyo evento ya no existe, veo un
estado claro en vez de datos de ejemplo.

Criterios (EARS):
1. CUANDO el `id` no resuelve a un evento (null) o la carga falla, EL SISTEMA
   DEBERÁ mostrar un estado **"Evento no disponible"** (ya presente en el stub),
   **nunca** datos mock.
2. MIENTRAS carga, EL SISTEMA DEBERÁ mostrar un indicador de carga.

### R11 · Volver al origen (RF-DETAIL-08, CA-DETAIL-09)
**Historia:** como usuario, al terminar vuelvo a la pantalla desde la que llegué.

Criterios (EARS):
1. CUANDO toco **Volver** (o el back del sistema), EL SISTEMA DEBERÁ regresar a la
   pantalla previa (Registro de eventos) usando la pila de navegación real de
   go_router.

### R12 · Reporte comunitario anónimo — backend (código, sin deploy) (DA-10, RN-02)
**Historia:** como equipo, dejamos el backend del reporte comunitario escrito y
verificable, listo para desplegar con aprobación.

Criterios (EARS):
1. EL SISTEMA DEBERÁ incluir una **migración** que cree la tabla `reports`
   (número legible del infractor, hash HMAC, categoría, `device_id` anónimo,
   estado `pendiente|promovido|rechazado`, timestamps) con **dedup** por
   (`device_id`, hash) y RLS que **no** exponga escritura al cliente (solo Edge
   Function / service role), siguiendo el estilo de `0008_devices.sql`.
2. EL SISTEMA DEBERÁ incluir la Edge Function **`v1-report`** que: exige
   dispositivo activo (`requireActiveDevice`), normaliza el número a E.164,
   calcula el **HMAC con el pepper** (RPC `get_dataset_pepper`), verifica la
   **allowlist de protección**, y hace **upsert idempotente** del reporte en
   estado `pendiente`; responde `{ estado: "pendiente" }` o
   `{ estado: "rechazado", motivo: "numero_protegido" }`, siguiendo el estilo de
   `v1-sync`/`v1-session`.
3. EL SISTEMA NO DEBERÁ ejecutar `supabase db push` ni `functions deploy` contra
   el proyecto remoto como parte de esta spec; el deploy es una acción separada
   que requiere confirmación explícita (R-DEPLOY-01).
4. EL SISTEMA DEBERÁ permitir verificar la Edge Function **localmente** (p. ej.
   `supabase functions serve` / `deno check`) sin tocar el remoto.

### R13 · Fidelidad visual y accesibilidad (RN-DETAIL, §6.8/§6.9, WCAG)
**Historia:** como usuario, la ficha es coherente con la marca y usable con
lector de pantalla / daltonismo.

Criterios (EARS):
1. EL SISTEMA DEBERÁ reproducir la jerarquía de `RecordDetailScreen.tsx`:
   indicador "Número Sospechoso", tarjeta de inspección con pestañas de vector,
   sandbox (SMS), módulo "Opciones de bloqueo" con las dos explicaciones + chips +
   nota + botones, y footer "Tu privacidad está protegida".
2. EL SISTEMA DEBERÁ usar **exclusivamente** tokens de `core/theme` (colores,
   spacing, radios, tipografía) — nada hardcodeado — y el `PrimaryButton` del
   proyecto para el botón dual (evita el override Material You).
3. EL SISTEMA NO DEBERÁ comunicar la severidad **solo por color** (etiqueta textual
   redundante del nivel).
4. EL SISTEMA DEBERÁ garantizar objetivos táctiles ≥ 48 dp y `Semantics` en
   pestañas, chips y botones de acción.

---

## 3. Fuera de alcance (esta spec)

- **Promoción a blacklist global por umbral** (pg_cron / job de moderación que
  cuenta reportes independientes y hace `bump` de `dataset_version`): pertenece a
  la operación del backend; esta spec deja el reporte en `pendiente` y el contrato
  listo. [DA-10]
- **Despliegue remoto** de la migración `reports` y de `v1-report`: acción
  separada que requiere confirmación explícita del usuario (R-DEPLOY-01). El código
  queda escrito y verificable localmente.
- **Generación / exportación de evidencia SIC**: spec `06-canales-denuncia`
  (el detalle no dispara SIC; eso vive en el registro/canales).
- **UI de administración de listas** (ver/editar confianza y negra, importación):
  spec `05-listas-y-configuracion`. Aquí solo se usan las acciones de clasificación
  ya existentes.
- **Reversibilidad del reporte / del bloqueo** (pregunta de negocio #2) y **acuse
  de comunidad** ("tu reporte ayudó a N"): fuera de alcance; se documentan.
- **Métricas `v1-metrics`**: no relacionadas con el reporte de bloqueo.

---

## 4. Decisiones de negocio tomadas en esta spec (resuelven preguntas abiertas)

Las preguntas abiertas del documento de negocio se resuelven así (revisables):

1. **"Prueba ZK" (pregunta #1).** En el MVP, el artefacto que se envía es el
   **mínimo dato necesario**: `{ numero, categoria, device_id_anon }`. El servidor
   deriva el **hash HMAC** del número con el pepper (misma función que el dataset),
   guarda el número legible **solo** para moderación/auditoría del infractor, y el
   reporte es **anónimo respecto al reportante** (no viaja `user_id`, contactos,
   contenido ni la nota). La etiqueta "Generando Prueba ZK" es el **texto de UI**
   del estado de envío (marketing), no un ZK-proof criptográfico en el MVP; el
   endurecimiento criptográfico queda como pendiente.
2. **Categoría obligatoria vs. por defecto (pregunta #4).** Se **preselecciona** la
   categoría del evento pero se **exige confirmación consciente** para reportar
   (RN-DETAIL-04): la acción "Reportar y bloquear" valida que haya categoría.
3. **Nota adicional.** Opcional y, por defecto, **no se transmite** al backend en
   el MVP (minimización de datos / anonimato); queda como contexto local. Revisable
   si moderación la necesita.
4. **Reversibilidad y acuse de comunidad (preguntas #2, #3):** fuera de alcance
   (§3), documentadas.

---

## 5. Trazabilidad (negocio → requisitos de esta spec)

| Negocio | Aquí |
|---|---|
| RF-DETAIL-01/02 (metadatos + vector) | R1 |
| RF-DETAIL-03, RN-DETAIL-06 (sandbox no navegable) | R2 |
| RF-DETAIL-04, RN-DETAIL-04 (categoría) | R3 |
| RF-DETAIL-05 (nota opcional) | R4 |
| RF-DETAIL-06, RN-DETAIL-01/02 (reportar+bloquear anónimo) | R5, R12 |
| RF-DETAIL-07, RN-DETAIL-01 (bloquear local) | R6 |
| RN-DETAIL-03, RN-05 (salir de confianza) | R7 |
| RF-DETAIL-09 (error + reintento) | R8 |
| RF-DETAIL-10, RN-DETAIL-05 (ya reportado / idempotencia) | R9 |
| RF-DETAIL-11 (evento no disponible) | R10 |
| RF-DETAIL-08 (volver) | R11 |
| DA-10, RN-02 (contrato backend anónimo) | R12 |
| RN-DETAIL (fidelidad + accesibilidad) | R13 |
