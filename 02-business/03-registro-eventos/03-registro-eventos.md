# 03 · Registro de eventos interceptados

**Pantalla:** `PANT-CALLS` (Llamadas / Registro criptográfico)
**Depende de:** 00-fundamentos (entidad EventoInterceptado, RN-05 exclusividad, RN-07 categorías), 02-escudo
**Componente del prototipo:** `CallsScreen.tsx`

Timeline de eventos interceptados (llamadas y SMS). Permite buscar, filtrar, marcar confianza/lista negra, exportar evidencia SIC y abrir el detalle de un evento (04).

---

## PANT-CALLS · Propósito
Dar al usuario un historial legible y accionable de todo lo que el escudo neutralizó, con herramientas rápidas para clasificar cada número.

## Elementos de UI [PROTOTIPO]
- **3 micro-tarjetas de telemetría:** intercepciones de hoy, tiempo ahorrado, críticas. (Hoy con valores fijos 48 / 36m / 7.)
- **Buscador** por texto libre.
- **Chips de filtro:** Todos (con conteo), Llamadas, SMS, Alto, Medio, Bajo.
- **Encabezado "Registro Criptográfico"** + indicador "Motor Local v4.1".
- **Lista de tarjetas de evento** con glow de severidad, icono por tipo/nivel, badges (nivel, CONFIABLE, BLOQUEADO), banner de diagnóstico, preview de SMS en cuarentena y barra de acciones rápidas.
- **Banner de privacidad** "Aislamiento Criptográfico Local".
- **Toast** de feedback efímero al clasificar un número.

---

## Requisitos funcionales

- **RF-CALLS-01 — Listar eventos.** Mostrar los eventos interceptados ordenados cronológicamente (más reciente primero). [PROTOTIPO] (lista) · **[PROPUESTO]** el orden real por fecha requiere `timestamp` como fecha (RN-04/dominio).
- **RF-CALLS-02 — Buscar.** Filtrar por texto que coincida con número, título de amenaza, etiqueta de reputación, diagnóstico o contenido en cuarentena. Insensible a mayúsculas. [PROTOTIPO]
- **RF-CALLS-03 — Filtrar por chip.** Por tipo (Llamadas/SMS) y por severidad (Alto/Medio/Bajo). "Todos" quita el filtro. [PROTOTIPO]
- **RF-CALLS-04 — Combinar búsqueda + filtro.** Buscador y chip se aplican simultáneamente (AND). [PROTOTIPO]
- **RF-CALLS-05 — Marcar/desmarcar lista negra.** Acción rápida por evento; aplica **RN-05** (exclusividad). Muestra toast de confirmación. [PROTOTIPO]
- **RF-CALLS-06 — Marcar/desmarcar confianza.** Acción rápida por evento; aplica **RN-05**. Muestra toast. [PROTOTIPO]
- **RF-CALLS-07 — Exportar evidencia SIC.** Disponible solo en eventos de categoría "Violación franja Ley 2300" (ver **RN-07** y **RN-CALLS-02**); abre el flujo de evidencia SIC. [PROTOTIPO]
- **RF-CALLS-08 — Abrir detalle.** "Ver detalles" / menú del evento navega a `PANT-DETAIL` (04) con el evento seleccionado. [PROTOTIPO]
- **RF-CALLS-09 — Estado vacío por filtro.** Si ningún evento cumple el criterio, mostrar mensaje "No hay eventos con este criterio". [PROTOTIPO]
- **RF-CALLS-10 — Telemetría real.** Las 3 micro-tarjetas deben calcularse de los eventos reales, no ser fijas. **[PROPUESTO]** (hoy hardcodeadas).
- **RF-CALLS-11 — Carga asíncrona.** Mostrar skeleton/spinner mientras se cargan los eventos; manejar error de carga con reintento. **[PROPUESTO]** (hoy data síncrona).
- **RF-CALLS-12 — Estado vacío inicial.** Para un usuario nuevo con 0 eventos, mostrar un estado vacío de bienvenida distinto del "vacío por filtro". **[PROPUESTO]**
- **RF-CALLS-13 — Paginación / carga incremental.** Para historiales largos, paginar o cargar bajo scroll. **[PROPUESTO]**

---

## Reglas de negocio

- **RN-CALLS-01 · Severidad gobierna la presentación.** El color del glow, icono, badge y acentos se derivan de `nivel` (ALTO rojo / MEDIO ámbar / BAJO verde). **[PROPUESTO]**: añadir indicador no-cromático (texto/forma) por accesibilidad.
- **RN-CALLS-02 · Elegibilidad de exportación SIC.** El botón "Exportar SIC" aparece solo cuando la categoría del evento es "Violación franja Ley 2300". **[PROPUESTO]** reemplaza la regla frágil del prototipo (buscar la palabra "Ley" en el título).
- **RN-CALLS-03 · Exclusividad al clasificar.** Marcar confianza quita de lista negra y viceversa (hereda **RN-05**). El cambio se refleja de inmediato en los badges del evento y en las listas de 05. [PROTOTIPO]
- **RN-CALLS-04 · Preview de cuarentena solo en SMS.** El contenido neutralizado se muestra solo si el evento es SMS y tiene `contenidoCuarentena`. El contenido se muestra en un "sandbox" (no accionable, enlaces no clicables). [PROTOTIPO]
- **RN-CALLS-05 · El conteo de "Todos" refleja el total sin filtrar.** El chip "Todos (N)" muestra el total de eventos del historial. [PROTOTIPO]
- **RN-CALLS-06 · Toast efímero.** La confirmación de clasificación desaparece sola (~2.5s). [PROTOTIPO]

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-CALLS-01 | Con datos | Lista de eventos filtrable. | [PROTOTIPO] |
| EST-CALLS-02 | Vacío por filtro | Búsqueda/chip sin resultados → mensaje de "sin eventos con este criterio". | [PROTOTIPO] |
| EST-CALLS-03 | Vacío inicial | Usuario sin ningún evento → bienvenida/onboarding. | [PROPUESTO] |
| EST-CALLS-04 | Cargando | Skeleton/spinner mientras llega la data. | [PROPUESTO] |
| EST-CALLS-05 | Error de carga | Fallo al cargar → mensaje + reintentar. | [PROPUESTO] |
| EST-CALLS-06 | Feedback (toast) | Confirmación efímera de una acción. | [PROTOTIPO] |

---

## Criterios de aceptación

- **CA-CALLS-01.** Dado el historial con eventos, cuando abro la pantalla, entonces veo las tarjetas ordenadas de más reciente a más antigua. **[PROPUESTO: requiere fecha real]**
- **CA-CALLS-02.** Dado que escribo un número parcial en el buscador, cuando hay coincidencias, entonces la lista se reduce a los eventos cuyo número, título, etiqueta, diagnóstico o contenido contienen el texto.
- **CA-CALLS-03.** Dado que selecciono el chip "SMS", cuando se aplica, entonces solo veo eventos de tipo SMS.
- **CA-CALLS-04.** Dado que selecciono el chip "Alto", cuando se aplica, entonces solo veo eventos de nivel ALTO.
- **CA-CALLS-05.** Dado un filtro activo y un término de búsqueda, cuando ambos aplican, entonces la lista cumple las dos condiciones simultáneamente.
- **CA-CALLS-06.** Dado un filtro/búsqueda sin coincidencias, cuando no hay resultados, entonces veo "No hay eventos con este criterio".
- **CA-CALLS-07.** Dado un evento no bloqueado, cuando toco "Lista Negra", entonces el evento muestra el badge BLOQUEADO, el número entra a la lista negra, sale de confianza si estaba, y veo un toast de confirmación.
- **CA-CALLS-08.** Dado un evento marcado confiable, cuando toco "De confianza" de nuevo, entonces se desmarca y el número sale de la lista de confianza.
- **CA-CALLS-09.** Dado un evento de categoría "Violación franja Ley 2300", cuando veo sus acciones, entonces aparece el botón "Exportar SIC"; para cualquier otra categoría, no aparece.
- **CA-CALLS-10.** Dado que toco "Ver detalles" en un evento, entonces navego al detalle con ese evento cargado.
- **CA-CALLS-11.** Dado un evento SMS con contenido en cuarentena, cuando veo su tarjeta, entonces veo el texto neutralizado en un sandbox sin enlaces activos; para llamadas no se muestra ese bloque.
- **CA-CALLS-12.** Dado que soy un usuario nuevo sin eventos, cuando abro la pantalla, entonces veo un estado vacío de bienvenida (no el de "sin resultados por filtro"). **[PROPUESTO]**
- **CA-CALLS-13.** Dado que la carga falla, cuando termina con error, entonces veo un mensaje y un botón de reintentar. **[PROPUESTO]**

---

## Preguntas abiertas de negocio

1. **Telemetría:** ¿cómo se definen "intercepciones de hoy", "tiempo ahorrado" y "críticas"? ¿Ventana temporal, fórmula del tiempo ahorrado?
2. **Retención del historial:** ¿cuántos eventos/por cuánto tiempo se guardan localmente? ¿Hay purga automática?
3. **Acciones sobre eventos ya clasificados:** ¿se puede "deshacer" un reporte comunitario, o solo la clasificación local?
4. **Orden y agrupación:** ¿agrupar por día ("Hoy", "Ayer")? El prototipo usa texto libre en la fecha.
