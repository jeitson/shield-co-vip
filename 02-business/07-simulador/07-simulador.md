# 07 · Simulador de interceptación en vivo

**Pantalla:** `PANT-SIMULATOR` (Simulador en vivo)
**Depende de:** 00-fundamentos, 02-escudo (punto de acceso), 05-avanzados (punto de acceso)
**Componente del prototipo:** `LiveSimulatorScreen.tsx`

Pantalla **demostrativa/educativa**. Muestra cómo se vería la notificación flotante ("heads-up") de interceptación sobre la pantalla de bloqueo, para una llamada o un SMS. Es un sandbox aislado: **nada de lo que ocurre aquí modifica el estado real** de la app.

---

## PANT-SIMULATOR · Propósito
Enseñar al usuario, sin riesgo, qué verá cuando el escudo intercepte algo y qué significa cada acción (Reportar / De confianza / Descartar). Sirve de onboarding visual y de prueba de confianza.

## Elementos de UI [PROTOTIPO]
- Indicador "MODO EN VIVO · SIMULADOR".
- **Selector** Llamada bloqueada / SMS interceptado.
- **Lienzo de pantalla de bloqueo:** wallpaper, reloj (09:41) y notificación heads-up de Cifrado Cero.
- **Acciones de la notificación:** Reportar · De confianza · Descartar notificación.
- **Tarjeta educativa** "¿Qué hace cada opción?" (explica Reportar y Confianza) + nota de privacidad.

---

## Requisitos funcionales

- **RF-SIM-01 — Seleccionar escenario.** Alternar entre "Llamada bloqueada" y "SMS interceptado"; la notificación cambia su contenido. [PROTOTIPO]
- **RF-SIM-02 — Acción "Reportar" (simulada).** Muestra un toast "Contacto bloqueado y reportado de forma anónima". [PROTOTIPO] — **no** afecta listas ni comunidad reales.
- **RF-SIM-03 — Acción "De confianza" (simulada).** Toast "Número agregado a tu lista de contactos de confianza". [PROTOTIPO] — **no** afecta listas reales.
- **RF-SIM-04 — Descartar notificación.** Oculta la notificación con un toast; permite "Simular otra interceptación" para reactivarla. [PROTOTIPO]
- **RF-SIM-05 — Tarjeta educativa.** Explica el efecto real de cada acción y reafirma la privacidad. [PROTOTIPO]
- **RF-SIM-06 — Reinicio al cambiar escenario.** Al cambiar de Llamada a SMS (o viceversa) se restablece la notificación visible. [PROTOTIPO]

---

## Reglas de negocio

- **RN-SIM-01 · Sandbox sin efectos secundarios.** Ninguna acción del simulador altera `ConfigEscudo`, listas, historial ni la comunidad. Es puramente ilustrativo. [PROTOTIPO]
- **RN-SIM-02 · Coherencia con el comportamiento real.** Los textos y acciones del simulador deben describir fielmente lo que ocurre en el flujo real (Reportar = bloquea + reporta anónimo; Confianza = lista permitida local; Descartar = solo oculta). **[PROPUESTO]**: mantener este contrato sincronizado con 04 y 05 para no engañar al usuario.
- **RN-SIM-03 · Datos de ejemplo claramente ficticios.** Los números/mensajes mostrados son de ejemplo; no corresponden a eventos reales del usuario. [PROTOTIPO]
- **RN-SIM-04 · No requiere permisos.** Al ser una demo visual, no solicita permisos del sistema. La notificación real sí los requerirá (ver 00.6). [PROTOTIPO]

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-SIM-01 | Escenario llamada | Notificación de llamada bloqueada visible. | [PROTOTIPO] |
| EST-SIM-02 | Escenario SMS | Notificación de SMS interceptado (con texto de ejemplo). | [PROTOTIPO] |
| EST-SIM-03 | Notificación descartada | Se oculta; botón "Simular otra interceptación". | [PROTOTIPO] |
| EST-SIM-04 | Toast de acción | Feedback efímero (reportar/confianza/descartar). | [PROTOTIPO] |

---

## Criterios de aceptación

- **CA-SIM-01.** Dado el selector, cuando elijo "SMS interceptado", entonces la notificación muestra el escenario de SMS con un mensaje de ejemplo; al elegir "Llamada bloqueada", muestra el escenario de llamada.
- **CA-SIM-02.** Dado que toco "Reportar", cuando se ejecuta, entonces veo un toast de confirmación y **ninguna** lista/estado real cambia.
- **CA-SIM-03.** Dado que toco "De confianza", cuando se ejecuta, entonces veo un toast y ninguna lista real cambia.
- **CA-SIM-04.** Dado que toco "Descartar notificación", cuando se oculta, entonces aparece la opción "Simular otra interceptación" que la vuelve a mostrar.
- **CA-SIM-05.** Dado que cambio de escenario, cuando lo hago, entonces la notificación se restablece (deja de estar descartada).
- **CA-SIM-06.** Dado que leo la tarjeta educativa, cuando reviso las explicaciones, entonces coinciden con el comportamiento real descrito en 04 (detalle) y 05 (listas). **[PROPUESTO: mantener sincronía]**

---

## Preguntas abiertas de negocio

1. **Rol en onboarding:** ¿el simulador se muestra como paso de bienvenida tras el registro, o solo es accesible bajo demanda?
2. **Escenarios adicionales:** ¿añadir un escenario de extorsión y uno de Ley 2300 para cubrir las tres capas?
3. **¿Convertir acciones en reales?** ¿Interesa que, opcionalmente, el simulador permita "practicar" sobre un evento real, o debe permanecer 100% sandbox?
