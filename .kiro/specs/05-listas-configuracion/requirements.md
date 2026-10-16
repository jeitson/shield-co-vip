# Spec · 05 Listas locales y configuración avanzada — Requerimientos

> Pantalla `PANT-ADVANCED` (`AdvancedScreen`): **centro de control del usuario
> avanzado**. En esta spec entrega su primera funcionalidad real: la **gestión
> directa de las listas locales de confianza y negra** (alta/baja manual con
> normalización, deduplicación y exclusividad), más el **acceso al Simulador** y
> la retirada del andamiaje del prototipo ("Modo Marco Móvil"). Las **reglas
> Ley 2300** y la **auditoría de integridad ZK** quedan documentadas como
> diferidas (dependen de decisiones de negocio y de hardening aún no resueltos).
>
> Fuente de negocio:
> [`02-business/05-listas-y-configuracion`](../../../02-business/05-listas-y-configuracion/05-listas-y-configuracion.md)
> y [`00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md)
> (RN-04 formato canónico, RN-05 exclusividad, RN-08 franja Ley 2300).
> Arquitectura: Clean Architecture por features (DA-13), Riverpod, base cifrada
> (drift/SQLCipher), tokens de `core/theme`.
> Referencia visual: `app_desing/.../AdvancedScreen.tsx` +
> [design system](../../../01-docs/06-design-system.md).
> Depende de: `03-registro-eventos` (feature `lists` ya cableada:
> `ClassifyNumber`/exclusividad RN-05, `canonicalizeNumber` RN-04,
> `confianzaNumbersProvider`/`negraNumbersProvider`/`membershipProvider`,
> reproyección al motor), `05-motor-bloqueo` (niveles 1 y 3 del
> `PrecedenceEngine`), `01-autenticacion` (logout ya presente en la pantalla).

---

## 1. Introducción

La feature 03 dejó una **feature `lists` completa a nivel de dominio y datos**
(entidad `ListedNumber`, enums `ListKind`/`ListOrigin`, `canonicalizeNumber`,
`ClassifyNumber` con exclusividad atómica RN-05, repositorio sobre
`numeros_listados` y los providers reactivos que alimentan el motor). Lo que
**falta** es la **UI de administración directa** de esas listas: hoy
`AdvancedScreen` es un stub que solo expone el logout (DN-02) y un sembrador de
eventos de desarrollo, con una nota de que "las listas llegarán en su propio
flujo". Esta spec construye ese flujo.

El documento de negocio marca la mayoría de requisitos de esta pantalla como
`[PROPUESTO]` precisamente porque el prototipo React es estático (acepta
cualquier texto, no deduplica por forma canónica, no aplica exclusividad en el
alta manual, no tiene estado vacío). Esta spec los convierte en comportamiento
real **reutilizando** la plomería de `lists` sin reimplementar el hashing ni la
exclusividad.

**Alcance confirmado con el usuario (opción A):**

1. **Gestión real de listas de confianza y negra** desde `AdvancedScreen`:
   añadir con normalización RN-04, deduplicar por forma canónica, aplicar la
   exclusividad RN-05 **también en el alta manual**, eliminar, contadores,
   estado vacío y error de entrada. Todo reactivo sobre los providers existentes.
2. **Retirar el "Modo Marco Móvil"** (andamiaje del prototipo, no es producto —
   ver 08). En Flutter no existe ese control, así que se documenta su ausencia
   deliberada; la spec solo garantiza que no se introduzca.
3. **Acceso rápido al Simulador** desde Avanzados (ruta `/simulator` ya existe).
4. Mantener el **logout** ya presente y, en flavor dev, el sembrador de eventos.

> **Fuera de alcance de esta spec (preguntas de negocio ya resueltas, ver §3):**
> - **Evaluación de la franja Ley 2300** (franja fija por ley, bloqueo offline por
>   festivos calculados). La *configuración* (mostrar franjas de solo lectura +
>   capa on/off) se cubre aquí; la *evaluación en tiempo de contacto* vive en la
>   **spec de motor** (`08-motor-franja-ley2300`). Decisiones DN-05/DN-06.
> - **"Llamada fantasma"**: no es un ajuste ni una medición en tiempo real. Es una
>   **categoría** del dataset/evento (`llamadaFantasma`, RN-07) gobernada por la
>   capa `callcenter`. Si ya está identificada, **no timbra** (mismo principio que
>   call center). No hay switch ni umbral configurable (DN-07).
> - **Auditoría de integridad**: se implementa como **verificación real** del
>   checksum del dataset local contra el último sync válido (DN-08). Vive en la
>   **spec de motor/sync**, no en la UI del prototipo. Esta spec **no** muestra la
>   auditoría simulada del prototipo.
> - **Importación masiva de listas**: **fuera de alcance** del producto app. Será
>   una funcionalidad de un **portal administrativo externo** (otro proyecto,
>   DA-10). No se implementa aquí ni en el futuro de esta app (DN-09).
> - Promoción de reportes, SIC, métricas (otras specs).

---

## 2. Requerimientos

### R1 · Ver las listas de confianza y negra (RF-ADV-04, EST-ADV-01, CA-ADV-01)
**Historia:** como usuario avanzado, veo qué números tengo en confianza y en
lista negra, con cuántos hay en cada una.

Criterios (EARS):
1. EL SISTEMA DEBERÁ mostrar **dos secciones** diferenciadas: "Lista de
   confianza" y "Lista negra", cada una con su **contador** de números.
2. EL SISTEMA DEBERÁ renderizar cada número de una lista como un **chip** con el
   número en forma canónica y un control para **eliminar**.
3. EL SISTEMA DEBERÁ observar las listas de forma **reactiva** desde
   `confianzaNumbersProvider`/`negraNumbersProvider`: cualquier cambio (alta/baja
   aquí, o clasificación desde el Registro/Detalle) se refleja sin recargar.

### R2 · Añadir un número a una lista (RF-ADV-01/02, CA-ADV-01)
**Historia:** como usuario avanzado, escribo un número y lo agrego a confianza o
a la lista negra.

Criterios (EARS):
1. CADA sección DEBERÁ tener un **input de número** y un botón de acción
   ("Añadir" para confianza, "Bloquear" para la lista negra).
2. CUANDO el número es válido y toco el botón, EL SISTEMA DEBERÁ clasificarlo vía
   `classifyNumberProvider` con **`ListOrigin.manual`** y la `ListKind`
   correspondiente.
3. CUANDO el alta tiene éxito, EL SISTEMA DEBERÁ **limpiar el input**, y el nuevo
   chip DEBERÁ aparecer y el contador aumentar (de forma reactiva, R1.3).

### R3 · Validar y normalizar el número (RF-ADV-05, RN-ADV-01, RN-04, EST-ADV-06, CA-ADV-04)
**Historia:** como usuario avanzado, si escribo algo que no es un número válido,
me entero y no se agrega basura a la lista.

Criterios (EARS):
1. AL añadir, EL SISTEMA DEBERÁ normalizar el número a su **forma canónica**
   (RN-04) con `canonicalizeNumber` (móvil CO → E.164 `+57…`; código corto
   numérico → se conserva recortado).
2. EL SISTEMA DEBERÁ **restringir el alta manual** a un **móvil CO válido**
   (10 dígitos que inician en 3, canonizado a `+57…`) o un **código corto
   numérico** (3–10 dígitos). CUALQUIER otra entrada (vacía, solo símbolos como
   `+++`, texto alfanumérico como `abc`) DEBERÁ mostrar un **error de entrada**
   (EST-ADV-06) y **no** agregar nada.
   > Decisión de la spec: aunque `canonicalizeNumber` conserva remitentes
   > **alfanuméricos** cuando llegan de eventos reales (p. ej. "BANCO"), el alta
   > **manual** se limita a números reconocibles para evitar basura en las listas
   > (CA-ADV-04). Un remitente alfanumérico sigue pudiendo entrar a una lista
   > desde el flujo de eventos/detalle, no desde este input.
3. EL SISTEMA DEBERÁ limpiar el mensaje de error cuando el usuario corrige la
   entrada o cambia de foco.

### R4 · Evitar duplicados por forma canónica (RF-ADV-06, RN-ADV-01, CA-ADV-05)
**Historia:** como usuario avanzado, no puedo meter el mismo número dos veces en
la misma lista, aunque lo escriba con formato distinto.

Criterios (EARS):
1. CUANDO intento añadir un número que **ya está en la misma lista** (comparando
   su forma canónica, no el string crudo), EL SISTEMA NO DEBERÁ duplicarlo.
2. EL SISTEMA DEBERÁ informar discretamente (mensaje neutro, p. ej. "Ese número
   ya está en la lista") y dejar la lista sin cambios.

### R5 · Exclusividad entre listas en el alta manual (RF-ADV-07, RN-ADV-02, RN-05, CA-ADV-03)
**Historia:** como usuario avanzado, si agrego a una lista un número que estaba en
la otra, se mueve — nunca queda en ambas.

Criterios (EARS):
1. CUANDO añado a la **lista negra** un número que estaba en **confianza** (o
   viceversa), EL SISTEMA DEBERÁ **retirarlo de la lista anterior** de forma
   **atómica** (RN-05), reutilizando la exclusividad ya garantizada por
   `ClassifyNumber`/el DAO (misma PK `numero`).
2. EL SISTEMA DEBERÁ reflejar el cambio en **ambos** contadores y chips de forma
   reactiva (sale de una sección, entra en la otra).
3. ESTE comportamiento DEBERÁ ser idéntico al del alta desde el Registro/Detalle
   (consistencia: la inconsistencia del prototipo, que no aplicaba exclusividad en
   el alta manual, queda corregida).

### R6 · Eliminar un número de una lista (RF-ADV-03, CA-ADV-02)
**Historia:** como usuario avanzado, quito un número de una lista cuando ya no lo
quiero ahí.

Criterios (EARS):
1. CUANDO toco el control de eliminar de un chip, EL SISTEMA DEBERÁ **desmarcar**
   el número (clasificar con `kind == null` vía `classifyNumber`), borrándolo de
   `numeros_listados`.
2. EL SISTEMA DEBERÁ hacer desaparecer el chip y **decrementar** el contador de
   forma reactiva.
3. EL SISTEMA DEBERÁ reflejar la baja en el **motor** (el número deja de estar en
   el nivel 1 o 3 del `PrecedenceEngine` en la próxima reproyección).

### R7 · Estado vacío de cada lista (RF-ADV-08, EST-ADV-02, CA-ADV-06)
**Historia:** como usuario avanzado, cuando una lista no tiene números, veo un
mensaje claro en vez de un hueco.

Criterios (EARS):
1. CUANDO una lista **no tiene números**, EL SISTEMA DEBERÁ mostrar un **estado
   vacío** explicativo en lugar de los chips (p. ej. "Aún no has añadido números
   a esta lista").
2. CUANDO se añade el primer número, EL SISTEMA DEBERÁ **sustituir** el estado
   vacío por el chip (reactivo).

### R8 · Acceso al Simulador (RF-ADV-15, CA-ADV-10)
**Historia:** como usuario avanzado, abro el Simulador desde la configuración
avanzada.

Criterios (EARS):
1. EL SISTEMA DEBERÁ ofrecer un acceso ("Abrir Simulador") que **navegue** a la
   ruta `/simulator` (ya registrada en el router).

### R8b · Navegación de Avanzados (listas en pantalla propia, horario en acordeón)
**Historia:** como usuario avanzado, accedo a cada opción de forma clara: las
listas, que manejan mucha interacción, en su propia pantalla con regreso; la
información corta (horario legal), expandible en el acto.

Criterios (EARS):
1. `AdvancedScreen` DEBERÁ presentar las opciones como un **menú de secciones**.
2. La **gestión de listas** DEBERÁ abrirse en una **pantalla propia** (`ListsScreen`,
   ruta `/advanced/lists`) con **botón de regreso** (AppBar), conteniendo ambas
   listas (confianza + negra) por la exclusividad RN-05. El acceso en Avanzados
   DEBERÁ mostrar el **conteo** actual ("N en confianza · M bloqueados").
3. El **horario legal Ley 2300** (R11) DEBERÁ mostrarse como **acordeón**
   expansible inline (solo lectura), no en pantalla aparte.
4. El **Simulador** DEBERÁ seguir abriéndose en su pantalla (R8).

### R9 · Logout y herramientas dev conservados (DN-02)
**Historia:** como usuario, sigo pudiendo cerrar sesión desde Avanzados; en dev,
sigo teniendo el sembrador de eventos.

Criterios (EARS):
1. EL SISTEMA DEBERÁ **conservar** el cierre de sesión ya existente (confirma →
   `logout()` → el guard vuelve a login) y, SOLO en flavor dev
   (`AppConfig.enableLogging`), el sembrador de eventos de prueba.
2. EL SISTEMA DEBERÁ **retirar** la nota-placeholder "_Listas locales… llegarán
   en su propio flujo_" al existir ya las listas.

### R10 · No introducir el "Modo Marco Móvil" (nota de negocio 05)
**Historia:** como equipo, dejamos explícito que el meta-control del prototipo no
es producto.

Criterios (EARS):
1. EL SISTEMA NO DEBERÁ incluir el switch "Modo Marco Móvil" ni ningún
   meta-control de prototipo en `AdvancedScreen` (es chrome del prototipo, ver
   08-navegacion-y-shell).

### R11 · Mostrar las franjas Ley 2300 en solo lectura (RF-ADV-09, RN-08, DN-05)
**Historia:** como usuario avanzado, veo el horario legal en que sí se permite el
contacto comercial, para entender qué hace la capa Ley 2300.

Criterios (EARS):
1. EL SISTEMA DEBERÁ mostrar las **tres franjas** de RN-08 (L-V 07:00–19:00, Sáb
   08:00–15:00, Dom/festivos bloqueo 24h) como información de **solo lectura**.
2. EL SISTEMA NO DEBERÁ permitir **editar** las franjas ni ofrecer switches de
   "bloqueo estricto" o "silenciar llamadas fantasma" (DN-05/DN-07): esas reglas
   las aplica el **motor**, no esta pantalla; la capa `ley` se activa/desactiva
   desde el Dashboard.
3. EL SISTEMA DEBERÁ dejar claro que el bloqueo por franja/festivos es **offline**
   y que los festivos se calculan en el dispositivo (DN-06), con una nota breve.

---

## 3. Preguntas de negocio resueltas (decisiones)

Las 5 preguntas abiertas del documento 05 quedaron resueltas con el usuario.
Resumen y a dónde va cada una:

- **PN#1 · Franjas editables → NO (DN-05).** Las franjas Ley 2300 son normativas y
  fijas; el usuario solo activa/desactiva la **capa** `ley`. RF-ADV-09 se cumple
  mostrándolas como **solo lectura**. RF-ADV-12 (editar franjas) se **descarta**.
- **PN#2 · Umbral de llamada fantasma → NO aplica (DN-07).** No hay medición en
  tiempo real ni switch. "Llamada fantasma" es una **categoría** (`llamadaFantasma`,
  RN-07) gobernada por la capa `callcenter`: si ya está identificada, **no timbra**.
  RF-ADV-11 y RN-ADV-04 se **descartan** como ajuste configurable.
- **PN#3 · Fuente de festivos → calendario calculado y empaquetado, offline, con
  override `app_params` (DN-06).** Se implementa en la **spec de motor**
  (`ColombianHolidays` en `core`). RF-ADV-10 (bloqueo estricto dom/festivos) lo
  cubre el motor, no un switch de esta pantalla.
- **PN#4 · Auditoría de integridad → verificación real por checksum (DN-08).**
  Reemplaza la simulación del prototipo por una comprobación del checksum del
  dataset local contra el último sync válido (reutiliza `IntegrityFailure` de
  `02-seguridad §02.6`). Vive en la **spec de motor/sync**. RF-ADV-13/14 se
  cumplen de verdad ahí; esta pantalla **no** muestra la auditoría simulada.
- **PN#5 · Importación masiva → fuera de alcance de la app (DN-09).** Será una
  funcionalidad del **portal administrativo externo** (otro proyecto). No se
  implementa en esta app.

> La *configuración* de la capa Ley 2300 (mostrar franjas de solo lectura y el
> toggle de capa, ya en el Dashboard) pertenece a esta pantalla. La *evaluación*
> de la franja en tiempo de contacto y la verificación de integridad son del
> **motor** → spec `08-motor-franja-ley2300` (ver tasks §6).

---

## 4. Trazabilidad con el documento de negocio

| Negocio 05 | Esta spec |
|---|---|
| RF-ADV-01/02 añadir a confianza/negra | R2 |
| RF-ADV-03 eliminar de lista | R6 |
| RF-ADV-04 contadores | R1 |
| RF-ADV-05 validar/normalizar (RN-04) | R3 |
| RF-ADV-06 evitar duplicados canónicos | R4 |
| RF-ADV-07 exclusividad en alta manual (RN-05) | R5 |
| RF-ADV-08 estado vacío | R7 |
| RF-ADV-15 acceso al Simulador | R8 |
| Nota "Modo Marco Móvil" se retira | R10 |
| RF-ADV-09 mostrar franjas Ley 2300 (solo lectura) | R11 |
| RF-ADV-10 bloqueo estricto dom/festivos | spec motor 08 (DN-06) |
| RF-ADV-11 silenciar llamadas fantasma | descartado como switch (DN-07) |
| RF-ADV-12 editar franjas | descartado (DN-05) |
| RF-ADV-13/14 auditoría integridad | verificación real → spec motor/sync (DN-08) |
