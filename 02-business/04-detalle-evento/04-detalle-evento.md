# 04 · Detalle de evento (análisis forense y bloqueo)

**Pantalla:** `PANT-DETAIL` (Detalle de registro)
**Depende de:** 00-fundamentos (EventoInterceptado, RN-02 reporte anónimo, RN-05 exclusividad), 03-registro (origen del evento), 05-listas (modifica listas)
**Componente del prototipo:** `RecordDetailScreen.tsx`

Ficha forense de un evento concreto. Permite inspeccionar los metadatos, revisar el payload del SMS en un sandbox, y decidir cómo responder: **reportar + bloquear** (comunitario) o **bloquear solo localmente**.

---

## PANT-DETAIL · Propósito
Dar al usuario el contexto completo de un número sospechoso y dos vías de acción claras, con el mensaje de privacidad siempre presente.

## Elementos de UI [PROTOTIPO]
- **Tarjeta de inspección del número:** número, badge de peligro, pestañas vector (Llamada / SMS).
- **Metadatos forenses:** fecha y hora, ubicación reportada, tipo de actividad.
- **Sandbox del payload SMS:** texto del mensaje con el enlace peligroso resaltado + alerta de "enlace peligroso". (Solo relevante en SMS.)
- **Módulo de opciones de bloqueo:**
  - Explicación de las dos opciones (bloquear en tu teléfono / ayudar a proteger a otros).
  - Selector de **categoría del problema** (chips).
  - Campo de **detalles adicionales (opcional)**.
  - Botón primario **"Reportar y bloquear"** (estados idle → generando → éxito).
  - Botón secundario **"Bloquear solo para mí"**.
- **Nota de privacidad** (reporte 100% anónimo).

### Categorías del selector [PROTOTIPO]
Extorsión o amenaza · Estafa por mensaje (Link) · Call center molesto · Llamada silenciosa.
> **[PROPUESTO]** Alinear este selector con el catálogo cerrado de **RN-07** (fundamentos) para que la categoría sea un dato estructurado reutilizable (clasificación, elegibilidad SIC, reputación comunitaria).

---

## Requisitos funcionales

- **RF-DETAIL-01 — Mostrar metadatos del evento.** Número, fecha/hora, ubicación, tipo de actividad y nivel de peligro del evento recibido. [PROTOTIPO]
- **RF-DETAIL-02 — Alternar vector Llamada/SMS.** Pestañas para ver el detalle según el vector. La pestaña inicial corresponde al tipo del evento. [PROTOTIPO]
- **RF-DETAIL-03 — Sandbox del SMS.** Mostrar el contenido del SMS resaltando el enlace peligroso, sin que el enlace sea clicable. [PROTOTIPO]
- **RF-DETAIL-04 — Seleccionar categoría.** El usuario elige la categoría del problema antes de reportar. [PROTOTIPO]
- **RF-DETAIL-05 — Añadir nota opcional.** Campo de texto libre con detalles adicionales. [PROTOTIPO]
- **RF-DETAIL-06 — Reportar y bloquear.** Bloquea el número localmente **y** lo reporta a la comunidad de forma anónima a través del **backend**. Muestra estados "Generando Prueba ZK…" → "¡Bloqueado y Sincronizado!". El bloqueo local es [PROTOTIPO]; el envío del reporte al servicio comunitario es **[DECIDIDO · DN-01]** (hay backend; el prototipo lo simula). Contrato de API en la arquitectura.
- **RF-DETAIL-07 — Bloquear solo localmente.** Añade el número a la lista negra del dispositivo sin reportarlo a la comunidad. Muestra confirmación "Número Silenciado Localmente". [PROTOTIPO]
- **RF-DETAIL-08 — Volver al registro.** Regresar a la pantalla previa (Registro de eventos). [PROTOTIPO] (hoy siempre vuelve a `calls`; **[PROPUESTO]** usar pila de navegación real, ver 08).
- **RF-DETAIL-09 — Manejo de error de reporte.** Si el reporte comunitario falla, informar y permitir reintento sin perder la clasificación. **[PROPUESTO]** (ausente).
- **RF-DETAIL-10 — Estado "ya reportado".** Si el número ya fue reportado antes, reflejarlo (no duplicar reporte). **[PROPUESTO]**
- **RF-DETAIL-11 — Evento no encontrado.** Si se abre el detalle sin un evento válido (p. ej. desde una notificación cuyo evento ya no existe), mostrar un estado de "evento no disponible". **[PROPUESTO]** (hoy el prototipo cae a datos mock por defecto).

---

## Reglas de negocio

- **RN-DETAIL-01 · Dos vías de acción, ambas bloquean localmente.** "Reportar y bloquear" = bloqueo local + reporte comunitario anónimo. "Bloquear solo para mí" = solo bloqueo local. En ambos casos el número entra a la lista negra del dispositivo. [PROTOTIPO]
- **RN-DETAIL-02 · El reporte comunitario es anónimo.** Hereda **RN-02**: el reporte enviado al backend no incluye identidad ni datos personales del usuario; solo la referencia (hash) del número infractor y la categoría. **[DECIDIDO · DN-01]** el reporte viaja a un backend real; el contrato debe garantizar el anonimato en la arquitectura.
- **RN-DETAIL-03 · Bloquear implica salir de confianza.** Si el número estaba en la lista de confianza, al bloquearlo se retira de ella (hereda **RN-05**). [PROTOTIPO]
- **RN-DETAIL-04 · Categoría obligatoria para reportar.** **[PROPUESTO]** Reportar a la comunidad requiere una categoría seleccionada (hoy viene con una por defecto; conviene exigir elección consciente). La nota adicional es opcional.
- **RN-DETAIL-05 · Idempotencia del reporte.** **[PROPUESTO]** Reportar dos veces el mismo número no genera reportes duplicados en la comunidad.
- **RN-DETAIL-06 · Privacidad del payload.** El contenido del SMS se muestra en sandbox; los enlaces nunca son navegables desde la app. [PROTOTIPO]

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-DETAIL-01 | Idle | Ficha cargada, acciones disponibles. | [PROTOTIPO] |
| EST-DETAIL-02 | Generando | "Reportar y bloquear" en curso: "Generando Prueba ZK & Inmunizando…". | [PROTOTIPO] |
| EST-DETAIL-03 | Éxito | "¡Bloqueado y Sincronizado con Éxito!". | [PROTOTIPO] |
| EST-DETAIL-04 | Bloqueo local hecho | "Número Silenciado Localmente". | [PROTOTIPO] |
| EST-DETAIL-05 | Error de reporte | Falló el reporte comunitario; permite reintentar. | [PROPUESTO] |
| EST-DETAIL-06 | Ya reportado | El número ya estaba reportado; acción deshabilitada o informada. | [PROPUESTO] |
| EST-DETAIL-07 | Evento no disponible | No hay evento válido para mostrar. | [PROPUESTO] |

---

## Criterios de aceptación

- **CA-DETAIL-01.** Dado que llego al detalle desde un evento, cuando se carga, entonces veo el número, fecha/hora, ubicación, tipo de actividad y nivel de peligro de ese evento.
- **CA-DETAIL-02.** Dado un evento de tipo SMS, cuando abro el detalle, entonces la pestaña activa inicial es "SMS" y veo el payload en sandbox con el enlace resaltado; dado un evento de tipo llamada, la pestaña inicial es "Llamada".
- **CA-DETAIL-03.** Dado el sandbox del SMS, cuando toco el enlace resaltado, entonces no se abre (no es navegable).
- **CA-DETAIL-04.** Dado que selecciono una categoría y toco "Reportar y bloquear", cuando la acción está en curso, entonces veo "Generando Prueba ZK…" y, al terminar, "¡Bloqueado y Sincronizado!"; el número queda en la lista negra.
- **CA-DETAIL-05.** Dado que el número estaba en la lista de confianza, cuando lo bloqueo (por cualquiera de las dos vías), entonces sale de la lista de confianza.
- **CA-DETAIL-06.** Dado que toco "Bloquear solo para mí", cuando se aplica, entonces el botón muestra "Número Silenciado Localmente" y el número entra a la lista negra sin reportarse a la comunidad.
- **CA-DETAIL-07.** Dado que el reporte comunitario falla, cuando termina con error, entonces veo un mensaje y puedo reintentar; la clasificación local no se pierde. **[PROPUESTO]**
- **CA-DETAIL-08.** Dado un número ya reportado previamente, cuando intento reportarlo de nuevo, entonces no se crea un reporte duplicado. **[PROPUESTO]**
- **CA-DETAIL-09.** Dado que toco "Volver", entonces regreso a la pantalla desde la que llegué. **[PROPUESTO: pila real]**
- **CA-DETAIL-10.** Dado que intento reportar sin categoría seleccionada, cuando toco reportar, entonces se me pide elegir una categoría. **[PROPUESTO]**
- **CA-DETAIL-11.** Dado que se abre el detalle sin un evento válido, cuando se renderiza, entonces veo "evento no disponible" en vez de datos de ejemplo. **[PROPUESTO]**

---

## Preguntas abiertas de negocio

> Nota: con **DN-01** (backend confirmado), estas preguntas se resuelven definiendo el **contrato de la API comunitaria en la arquitectura del sistema**.

1. **"Prueba ZK":** ¿qué es exactamente lo que se genera y envía al reportar? Define el artefacto (hash del número + categoría + timestamp firmado) y qué NO se envía.
2. **Reversibilidad:** ¿puede el usuario revertir un reporte comunitario? ¿Y un bloqueo local?
3. **Confirmación de la comunidad:** ¿el usuario recibe algún acuse ("tu reporte ayudó a N personas")? ¿afecta la reputación del número?
4. **Categoría obligatoria vs. por defecto:** ¿exigir selección consciente o aceptar una por defecto?
