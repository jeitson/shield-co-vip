# 05 · Listas locales y configuración avanzada

**Pantalla:** `PANT-ADVANCED` (Configuración avanzada)
**Depende de:** 00-fundamentos (RN-04 formato, RN-05 exclusividad, RN-08 franja Ley 2300), 02-escudo
**Componente del prototipo:** `AdvancedScreen.tsx`

Centro de control del motor: reglas horarias de la Ley 2300, auditoría de la bóveda de hashes y gestión de las listas de confianza y negra. Estas listas son el mismo dominio que manipulan el Registro (03) y el Detalle (04); aquí se gestionan de forma directa.

---

## PANT-ADVANCED · Propósito
Dar al usuario avanzado control fino sobre reglas, listas e integridad del motor local.

## Elementos de UI [PROTOTIPO]
- **Switch "Modo Marco Móvil"** → es andamiaje del prototipo (meta-control), **no es funcionalidad de producto**. Se elimina en Flutter (ver 08 y nota más abajo).
- **Reglas Ley 2300:** franjas horarias (L-V, Sáb, Dom/festivos) + 2 switches:
  - Bloqueo estricto fin de semana / festivos.
  - Silenciar "llamadas fantasma" (discadores que cuelgan antes de 3s).
- **Auditoría de integridad ZK:** botón con estados checking → verified ("14.892 Hashes Íntegros").
- **Gestor Lista de Confianza:** input + "Añadir" + chips con eliminar; contador.
- **Gestor Lista Negra:** input + "Bloquear" + chips con eliminar; contador.
- **Acceso rápido al Simulador.**

> El "Modo Marco Móvil" NO se especifica como funcionalidad de negocio. Es parte del chrome del prototipo (ver 08-navegacion-y-shell). Se documenta aquí solo para dejar explícito que debe retirarse.

---

## Requisitos funcionales

### Listas de confianza y negra
- **RF-ADV-01 — Añadir a confianza.** Agregar un número a la lista de confianza desde el input. [PROTOTIPO]
- **RF-ADV-02 — Añadir a lista negra.** Agregar un número a la lista negra desde el input. [PROTOTIPO]
- **RF-ADV-03 — Eliminar de una lista.** Quitar un número de confianza o de lista negra. [PROTOTIPO]
- **RF-ADV-04 — Ver contadores.** Mostrar cuántos números hay en cada lista. [PROTOTIPO]
- **RF-ADV-05 — Validar y normalizar el número.** Al añadir, validar que sea un número telefónico válido y normalizarlo a formato canónico (**RN-04**). **[PROPUESTO]** (hoy acepta cualquier texto).
- **RF-ADV-06 — Evitar duplicados.** No permitir el mismo número dos veces en una lista (tras normalizar). [PROTOTIPO parcial: compara string exacto] · **[PROPUESTO]**: deduplicar por forma canónica.
- **RF-ADV-07 — Exclusividad entre listas.** Añadir a una lista retira de la otra (**RN-05**). **[PROPUESTO]** en esta pantalla (hoy el prototipo aplica exclusividad desde eventos, pero el alta manual aquí NO la aplica — inconsistencia a corregir).
- **RF-ADV-08 — Estado vacío de lista.** Mostrar un mensaje cuando una lista no tiene números. **[PROPUESTO]** (ausente).

### Reglas Ley 2300
- **RF-ADV-09 — Ver franjas horarias.** Mostrar las franjas legales (hereda **RN-08**). [PROTOTIPO] (estáticas).
- **RF-ADV-10 — Bloqueo estricto fin de semana/festivos.** Switch que endurece el bloqueo en domingos y festivos. [PROTOTIPO] (solo estado local) · **[PROPUESTO]** debe afectar el motor y persistir.
- **RF-ADV-11 — Silenciar llamadas fantasma.** Switch que silencia discadores que cuelgan antes de 3s. [PROTOTIPO] (solo estado local) · **[PROPUESTO]** debe afectar el motor y persistir.
- **RF-ADV-12 — Editar franjas.** Permitir ajustar las franjas o excepciones. **[PROPUESTO]** (hoy son texto fijo) — confirmar si el usuario puede editarlas o son normativas inmutables.

### Auditoría de integridad
- **RF-ADV-13 — Auditar integridad ZK.** Botón que verifica la integridad de la bóveda local de hashes y muestra el resultado. [SIMULADO] (1.5s, número fijo) · **[PROPUESTO]** verificación criptográfica real.
- **RF-ADV-14 — Resultado de integridad comprometida.** Si la verificación falla, informar y ofrecer acción (re-sincronizar/reparar). **[PROPUESTO]** (ausente).

### Otros
- **RF-ADV-15 — Acceso al Simulador.** Botón "Abrir Simulador" navega a 07. [PROTOTIPO]

---

## Reglas de negocio

- **RN-ADV-01 · Normalización canónica.** Todo número ingresado manualmente se normaliza a **RN-04** antes de guardarse/comparar. **[PROPUESTO]**
- **RN-ADV-02 · Exclusividad.** Un número no puede estar en ambas listas (hereda **RN-05**). **[PROPUESTO]** aplicarlo también en el alta manual.
- **RN-ADV-03 · Franja legal.** Las franjas mostradas corresponden a **RN-08**. Si la ley cambia, se actualizan en un solo lugar (fundamentos).
- **RN-ADV-04 · Llamada fantasma = cuelgue < 3s.** Definición operativa de "llamada fantasma": discador que termina la llamada antes de 3 segundos. [PROTOTIPO] (texto) · **[PROPUESTO]** como umbral configurable del motor.
- **RN-ADV-05 · Persistencia de reglas.** Los switches de reglas y las listas persisten entre sesiones (hereda persistencia de fundamentos). **[PROPUESTO]**
- **RN-ADV-06 · Festivos.** El bloqueo de "domingos y festivos" requiere un calendario de festivos colombianos (fuente a definir, ver 00.3 RN-08).

---

## Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-ADV-01 | Listas con items | Chips de números con botón de eliminar. | [PROTOTIPO] |
| EST-ADV-02 | Lista vacía | Mensaje de "aún no has añadido números". | [PROPUESTO] |
| EST-ADV-03 | Auditando | Botón "Verificando firmas locales…" con spinner. | [PROTOTIPO] |
| EST-ADV-04 | Integridad verificada | "N Hashes Íntegros y Verificados" (se auto-oculta tras ~3.5s). | [PROTOTIPO] |
| EST-ADV-05 | Integridad comprometida | Alerta de bóveda alterada + acción de reparación. | [PROPUESTO] |
| EST-ADV-06 | Error de entrada | Número inválido al añadir. | [PROPUESTO] |

---

## Criterios de aceptación

- **CA-ADV-01.** Dado el input de confianza con un número válido, cuando toco "Añadir", entonces el número aparece como chip en la lista de confianza, el contador aumenta y el input se limpia.
- **CA-ADV-02.** Dado un chip en una lista, cuando toco su botón de eliminar, entonces el número desaparece y el contador disminuye.
- **CA-ADV-03.** Dado que añado a lista negra un número que ya está en confianza, cuando se agrega, entonces sale de confianza automáticamente (exclusividad). **[PROPUESTO]**
- **CA-ADV-04.** Dado que ingreso un valor no numérico/ inválido, cuando toco "Añadir", entonces veo un error y el número no se agrega. **[PROPUESTO]**
- **CA-ADV-05.** Dado que ingreso un número ya presente (en su forma canónica), cuando intento añadirlo, entonces no se duplica. **[PROPUESTO]**
- **CA-ADV-06.** Dado que una lista queda sin números, cuando se vacía, entonces veo un estado vacío explicativo. **[PROPUESTO]**
- **CA-ADV-07.** Dado que toco "Auditar Integridad", cuando la verificación corre, entonces veo "Verificando firmas locales…" y al terminar el resultado de integridad.
- **CA-ADV-08.** Dado que la integridad resulta comprometida, cuando termina la auditoría, entonces veo una alerta y una acción para re-sincronizar/reparar. **[PROPUESTO]**
- **CA-ADV-09.** Dado que activo "bloqueo estricto fin de semana", cuando lo guardo, entonces la preferencia persiste al reabrir la app y afecta el filtrado. **[PROPUESTO]**
- **CA-ADV-10.** Dado que toco "Abrir Simulador", entonces navego al Simulador.

---

## Preguntas abiertas de negocio

1. **¿Las franjas Ley 2300 son editables por el usuario** o son normativas fijas? (Afecta RF-ADV-12.)
2. **Umbral de "llamada fantasma":** ¿fijo en 3s o configurable?
3. **Fuente de festivos:** calendario empaquetado vs. servicio actualizable.
4. **¿Qué significa "auditar integridad"** para el usuario? Definir qué comunica y qué acción habilita ante un fallo.
5. **Importación masiva de listas:** ¿se permite importar números desde un archivo o pegar varios a la vez?
