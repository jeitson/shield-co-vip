# 06 · Canales de denuncia (GAULA y SIC)

**Pantalla:** `PANT-REPORT` (Canales de denuncia)
**Depende de:** 00-fundamentos, 03-registro (la evidencia SIC se construye desde un evento)
**Componentes del prototipo:** `ReportChannelsScreen.tsx` + modal de exportación SIC en `App.tsx`

Orientación legal al usuario. Dos vías, en dos pestañas:
- **GAULA (Línea 165):** extorsión, secuestro, amenazas telefónicas.
- **SIC (Ley 2300):** acoso comercial / cobranzas fuera de horario.

---

## PANT-REPORT · Propósito
Guiar al usuario para que actúe ante las autoridades competentes, con un acceso directo de emergencia (GAULA) y una guía práctica para radicar quejas ante la SIC.

## Elementos de UI [PROTOTIPO]
- Encabezado "Canales de Denuncia" + nota empática.
- **Pestañas segmentadas:** "Línea GAULA (165)" / "Reporte SIC".
- **Pestaña GAULA:** botón grande "Llamar al GAULA (Línea 165)" (`tel:165`) + recomendaciones inmediatas (mantener la calma, colgar, guardar el registro).
- **Pestaña SIC:** contexto (la SIC no tiene API directa), guía de 4 pasos, botón "Abrir portal oficial de la SIC" y botón "Copiar datos de evidencia rápida".
- **Pie de confianza** ("Cifrado Cero te acompaña").

### Modal de exportación de evidencia SIC [PROTOTIPO]
Se abre desde el Registro (03) al tocar "Exportar SIC" sobre un evento Ley 2300. Compone un resumen con metadatos del evento (número infractor, fecha, causal, diagnóstico, hash de integridad) y permite copiarlo o ir al portal SIC.

---

## Requisitos funcionales

- **RF-REP-01 — Cambiar de pestaña.** Alternar entre GAULA y SIC. [PROTOTIPO]
- **RF-REP-02 — Llamar al GAULA 165.** Iniciar una llamada al 165 vía el marcador del sistema. [PROTOTIPO] (hoy intercepta el tap y muestra un pseudo-modal "Marcando…"; en producción debe abrir el dialer real).
- **RF-REP-03 — Mostrar recomendaciones GAULA.** Lista de pasos a seguir ante extorsión/amenaza. [PROTOTIPO]
- **RF-REP-04 — Abrir portal SIC.** Enlace externo al portal oficial de la Superintendencia de Industria y Comercio. [PROTOTIPO]
- **RF-REP-05 — Guía de 4 pasos SIC.** Explicar cómo radicar la queja. [PROTOTIPO]
- **RF-REP-06 — Copiar evidencia (genérica).** Copiar al portapapeles una plantilla de evidencia. [PROTOTIPO] (texto genérico, sin datos de un evento específico).
- **RF-REP-07 — Exportar evidencia de un evento (modal).** Desde el Registro, generar y copiar la evidencia con los metadatos reales del evento. [PROTOTIPO] / [SIMULADO] (el hash es `Math.random`).
- **RF-REP-08 — Manejo de fallo del portapapeles.** Informar si no se pudo copiar. **[PROPUESTO]** (hoy marca "copiado" aunque falle).
- **RF-REP-09 — Manejo sin conexión / sin dialer.** Si no hay red para abrir el portal o el dispositivo no puede llamar, informar y ofrecer alternativa (mostrar el número, copiar el enlace). **[PROPUESTO]**
- **RF-REP-10 — Unificar generación de evidencia.** La evidencia SIC debe generarse en un solo lugar con un único formato. **[PROPUESTO]** (hoy hay dos lógicas: el modal de `App.tsx` y el botón de esta pantalla, con textos distintos — deuda a eliminar).

---

## Reglas de negocio

- **RN-REP-01 · GAULA es prioridad de emergencia.** La pestaña GAULA se presenta primero por tratarse de vida e integridad (extorsión, amenazas). [PROTOTIPO]
- **RN-REP-02 · La SIC no tiene integración directa.** No existe API pública para radicar automáticamente; el flujo es guía + enlace + evidencia copiable. [PROTOTIPO] (confirmado en el copy del propio prototipo).
- **RN-REP-03 · Evidencia SIC solo para eventos Ley 2300.** La exportación de evidencia desde un evento aplica a eventos de categoría "Violación franja Ley 2300" (coherente con **RN-CALLS-02**). [PROTOTIPO]
- **RN-REP-04 · Contenido de la evidencia SIC.** La evidencia incluye: número infractor, fecha y hora, causal (violación franja Ley 2300), diagnóstico, identificador del registro local y una firma/hash de integridad. **[PROPUESTO]**: la firma debe ser una prueba de integridad real, no un valor aleatorio.
- **RN-REP-05 · Privacidad en la evidencia.** La evidencia la controla y comparte el usuario manualmente; nada se envía automáticamente (coherente con **RN-01**). [PROTOTIPO]
- **RN-REP-06 · Marcar 165 no interrumpe la protección.** Llamar al GAULA es una acción saliente del usuario y no altera la configuración del escudo. [PROTOTIPO]

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-REP-01 | Pestaña GAULA | Botón de llamada + recomendaciones. | [PROTOTIPO] |
| EST-REP-02 | Pestaña SIC | Guía de pasos + acciones. | [PROTOTIPO] |
| EST-REP-03 | Confirmación de llamada | Aviso "Marcando al 165…". | [PROTOTIPO] (pseudo-modal; en prod. lo gestiona el dialer) |
| EST-REP-04 | Copiado | Feedback "¡Copiado!" temporal. | [PROTOTIPO] |
| EST-REP-05 | Fallo al copiar | Mensaje de error de portapapeles. | [PROPUESTO] |
| EST-REP-06 | Modal evidencia SIC | Overlay con resumen del evento + copiar / ir a SIC. | [PROTOTIPO] |

---

## Criterios de aceptación

- **CA-REP-01.** Dado que estoy en la pantalla, cuando alterno entre pestañas, entonces veo el contenido correspondiente a GAULA o SIC.
- **CA-REP-02.** Dado que toco "Llamar al GAULA (Línea 165)", cuando el dispositivo puede llamar, entonces se abre el marcador con el 165 cargado.
- **CA-REP-03.** Dado que el dispositivo no puede iniciar la llamada, cuando toco llamar, entonces veo el número para marcarlo manualmente. **[PROPUESTO]**
- **CA-REP-04.** Dado que toco "Abrir portal oficial de la SIC", cuando hay conexión, entonces se abre el portal en el navegador externo.
- **CA-REP-05.** Dado que toco "Copiar evidencia" y el portapapeles funciona, cuando se copia, entonces veo confirmación de copiado.
- **CA-REP-06.** Dado que el portapapeles falla, cuando intento copiar, entonces veo un error (no una falsa confirmación). **[PROPUESTO]**
- **CA-REP-07.** Dado un evento de categoría Ley 2300, cuando toco "Exportar SIC" en el Registro, entonces se abre el modal con los metadatos reales de ese evento.
- **CA-REP-08.** Dado el modal de evidencia, cuando copio, entonces el texto copiado contiene número infractor, fecha/hora, causal, diagnóstico, id de registro y una firma de integridad **real**. **[PROPUESTO: firma real]**
- **CA-REP-09.** Dado el modal de evidencia, cuando toco "Ir a la SIC", entonces se abre el portal oficial.

---

## Preguntas abiertas de negocio

1. **Firma de integridad de la evidencia:** ¿qué algoritmo/forma tiene y cómo puede un tercero (SIC) verificarla? Hoy es un valor aleatorio.
2. **Unificación del formato de evidencia:** definir el único formato oficial (campos, orden, idioma) y de dónde se obtienen los datos.
3. **Festivos y horario** para clasificar automáticamente un evento como "fuera de franja" (depende de RN-08 y del calendario de festivos).
4. **Enlace SIC vigente:** confirmar la URL oficial de radicación de quejas y mantenerla configurable.
5. **Otros canales:** ¿se contempla la línea de la Policía (123) u otras entidades, o solo GAULA + SIC?
