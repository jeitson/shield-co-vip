# 02 · Escudo / Dashboard

**Pantalla:** `PANT-SHIELD` (Escudo / Dashboard) — pantalla principal tras iniciar sesión
**Depende de:** 00-fundamentos (RN-03 estado agregado, ConfigEscudo, RN-07 capas↔categorías), 01-autenticación
**Componente del prototipo:** `ShieldScreen.tsx`

Es el panel principal y el **destino por defecto una vez el usuario inició sesión**. Muestra el estado global del blindaje y permite activar/desactivar las tres capas de protección. El estado de las capas que aquí se controla es consumido por el Registro de eventos (03), el Simulador (07) y el Header global (08).

> **[DECIDIDO · DN-02]** El Dashboard **no es la pantalla de arranque de la app**; es la pantalla a la que se llega tras autenticarse. El acceso directo del prototipo (abrir en `shield` sin sesión) queda sustituido por el flujo con login obligatorio (ver 01 y 08). Esta pantalla solo es accesible con sesión activa.

---

## PANT-SHIELD · Propósito
Dar al usuario, de un vistazo, el nivel de protección actual y control inmediato sobre las tres capas, con mensajes claros de las consecuencias de desactivar cada una.

## Elementos de UI [PROTOTIPO]
- **Barra de estado "Filtro Zero-Knowledge"** con indicador de color y contador `N / 3 ACTIVOS`.
- **Hero con escudo dinámico** (color + mensaje según estado total/parcial/riesgo) y anillos animados.
- **3 tarjetas-módulo** con switch táctil:
  - Llamadas extorsivas (`extorsion`, etiqueta "Crítico").
  - Call center molestos (`callcenter`, etiqueta "Spam").
  - Ley dejen de fregar (`ley`, etiqueta "Legal").
  - Cada una muestra un **panel de advertencia** cuando se desactiva.
- **2 métricas:** contador de hashes de la lista local + botón de **sincronización manual**.
- **Tarjeta de acceso rápido al Simulador** (botón "Probar").

---

## Requisitos funcionales

- **RF-SHIELD-01 — Ver estado agregado.** Mostrar el estado global (Total/Parcial/Riesgo) derivado de las capas activas, según **RN-03**. Afecta color del indicador, icono, escudo del hero y textos. [PROTOTIPO]
- **RF-SHIELD-02 — Alternar capa.** El usuario activa/desactiva cada capa de forma independiente mediante su switch. [PROTOTIPO]
- **RF-SHIELD-03 — Advertencia por capa desactivada.** Al desactivar una capa, mostrar el panel de consecuencia correspondiente (texto específico por capa). [PROTOTIPO]
- **RF-SHIELD-04 — Aplicar la configuración al motor.** El estado de cada capa debe realmente activar/desactivar el filtrado correspondiente. **[PROPUESTO]** (hoy el toggle solo cambia la UI; no hay motor real — depende de permisos del SO, ver 00.6).
- **RF-SHIELD-05 — Persistir la configuración.** La configuración sobrevive al cierre/reinicio de la app. **[PROPUESTO]** (hoy se pierde al recargar).
- **RF-SHIELD-06 — Contador de lista local (hashes).** Mostrar cuántas firmas tiene la lista local. [SIMULADO] (hoy valor fijo 14.892 que crece con `Math.random`). **[PROPUESTO]**: debe reflejar el tamaño real del dataset local.
- **RF-SHIELD-07 — Sincronización manual del dataset.** Botón que descarga/actualiza las firmas locales y actualiza fecha de última sincronización. [SIMULADO] (hoy `setTimeout` 1.2s + incremento aleatorio). **[PROPUESTO]**: descarga real con versión de dataset, manejo de error de red y timestamp real.
- **RF-SHIELD-08 — Acceso al Simulador.** El botón "Probar" navega al Simulador (07). [PROTOTIPO]

---

## Reglas de negocio

- **RN-SHIELD-01 · Estado agregado.** Hereda **RN-03** de fundamentos (3→Total, 1-2→Parcial, 0→Riesgo). Es la fuente de verdad del color/estado en toda la app.
- **RN-SHIELD-02 · Capa extorsión = crítica.** La capa `extorsion` protege contra la amenaza de mayor gravedad; su advertencia al desactivar es de nivel ALTO (rojo). Las capas `callcenter` y `ley` muestran advertencia de nivel MEDIO (ámbar). [PROTOTIPO]
- **RN-SHIELD-03 · Independencia de capas.** Las capas se activan/desactivan de forma independiente; no hay dependencias entre ellas. [PROTOTIPO]
- **RN-SHIELD-04 · Defecto = todo activo.** Una instalación nueva arranca con las 3 capas activas (máxima protección por defecto). [PROTOTIPO]
- **RN-SHIELD-05 · Relación capa↔categoría.** Cada capa gobierna un conjunto de categorías de amenaza (ver **RN-07**). Desactivar una capa deja pasar su categoría asociada. **[PROPUESTO]** (define el efecto real del toggle).

### Textos de advertencia por capa [PROTOTIPO]
| Capa | Título advertencia | Consecuencia (resumen) |
|------|--------------------|------------------------|
| `extorsion` | "Advertencia de riesgo alto" | Exposición a llamadas de cárceles, números de extorsión y fraude telefónico. |
| `callcenter` | "Advertencia de exposición" | Entran llamadas automatizadas spam y "llamadas fantasma". |
| `ley` | "Invasión horaria habilitada" | Bancos/comercios podrán llamar fuera de horario legal, fines de semana o festivos. |

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-SHIELD-01 | Total (3/3) | Verde; "Protección Total Activa"; escudo con check. | [PROTOTIPO] |
| EST-SHIELD-02 | Parcial (1–2/3) | Ámbar; "Protección Parcial"; brechas abiertas. | [PROTOTIPO] |
| EST-SHIELD-03 | Riesgo (0/3) | Rojo; "Protección Desactivada - En Riesgo"; escudo con alerta. | [PROTOTIPO] |
| EST-SHIELD-04 | Sincronizando | Botón de sync muestra spinner "Verificando firmas…". | [PROTOTIPO] |
| EST-SHIELD-05 | Error de sincronización | Mensaje de fallo (red/servidor) con opción de reintentar. | [PROPUESTO] (ausente hoy) |

---

## Criterios de aceptación

- **CA-SHIELD-01.** Dado que las 3 capas están activas, cuando abro el Dashboard, entonces veo estado verde "Protección Total Activa" y el contador "3 / 3 ACTIVOS".
- **CA-SHIELD-02.** Dado que desactivo una de tres capas, cuando queda 2/3 activas, entonces el estado pasa a ámbar "Protección Parcial" y se muestra el panel de advertencia de la capa desactivada.
- **CA-SHIELD-03.** Dado que desactivo las 3 capas, cuando quedan 0/3, entonces el estado pasa a rojo "Protección Desactivada - En Riesgo".
- **CA-SHIELD-04.** Dado que reactivo una capa, cuando vuelve a estar activa, entonces su panel de advertencia desaparece y el estado agregado se recalcula.
- **CA-SHIELD-05.** Dado que cambié la configuración de capas, cuando cierro y reabro la app, entonces la configuración se conserva. **[PROPUESTO]**
- **CA-SHIELD-06.** Dado que toco "sincronizar", cuando la operación está en curso, entonces veo "Verificando firmas…" y, al terminar con éxito, la fecha de última sincronización se actualiza al momento real.
- **CA-SHIELD-07.** Dado que la sincronización falla por red, cuando termina, entonces veo un mensaje de error y puedo reintentar; la fecha previa no se altera. **[PROPUESTO]**
- **CA-SHIELD-08.** Dado que toco "Probar", entonces navego al Simulador.
- **CA-SHIELD-09.** Dado que desactivo la capa `extorsion`, cuando se muestra su advertencia, entonces el panel es de severidad ALTA (rojo), diferenciándose de las advertencias de `callcenter`/`ley` (ámbar).

---

## Preguntas abiertas de negocio

1. **Efecto real del toggle:** ¿desactivar una capa deja pasar *todas* sus categorías o permite un control más fino (p. ej. solo nivel BAJO)?
2. **Origen del dataset de firmas:** ¿servidor propio? ¿frecuencia de actualización? ¿tamaño inicial? El "14.892" es ilustrativo.
3. **Métrica de "hashes":** ¿se muestra al usuario el conteo real de firmas descargadas, o un número agregado de "amenazas conocidas"?
4. **¿Sincronización automática?** Hoy solo es manual. ¿Debe sincronizar en segundo plano con cierta periodicidad?
