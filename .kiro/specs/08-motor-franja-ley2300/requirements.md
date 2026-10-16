# Spec · 08 Motor de franja Ley 2300 + integridad — Requerimientos

> Lleva al **motor** las reglas que la spec 05 dejó decididas pero fuera de su
> alcance (configuración vs. evaluación): la **evaluación en tiempo de contacto**
> de la franja horaria legal (RN-08), el **calendario de festivos** calculado
> offline, y la **verificación real de integridad** del dataset local. Las
> franjas son normativas y fijas (DN-05); el bloqueo es siempre offline (DN-06).
>
> Fuente de negocio: [`00-fundamentos` RN-07/RN-08](../../../02-business/00-fundamentos/00-modelo-dominio.md)
> (DN-05 franjas fijas, DN-06 festivos calculados + override `app_params`),
> [`05-listas-y-configuracion`](../../../02-business/05-listas-y-configuracion/05-listas-y-configuracion.md)
> (DN-07 fantasma = categoría, DN-08 auditoría real).
> Arquitectura: jerarquía de precedencia [`03-datos §03.5`](../../../03-architecture/03-datos-y-sincronizacion.md)
> (nivel 5 "motor de capas"), verificación de integridad del dataset
> [`02-seguridad §02.6`](../../../03-architecture/02-seguridad-y-criptografia.md).
> Depende de: `05-motor-bloqueo` (`PrecedenceEngine`, `EngineIndex`,
> `ThreatCategory`, `IncomingContact`, proyección al nativo), `04-dataset-sync`
> (checksum del último sync válido, `IntegrityFailure`), `05-listas-configuracion`
> (fuente única `core/legal/ley2300_hours.dart`).

---

## 1. Introducción

Hoy el `PrecedenceEngine` resuelve la Ley 2300 **solo por hash + capa**: un
contacto llega ya categorizado como `ley2300`/`comercial` desde el dataset
comunitario, y la capa `ley` decide si se bloquea. **No** se evalúa la **hora**
ni el **día** del contacto: el `IncomingContact` ni siquiera lleva timestamp.

Esta spec cierra esa brecha. Un contacto **comercial** (categoría `comercial` o
`ley2300`) debe bloquearse **cuando ocurre fuera de la franja legal** (RN-08),
aunque no esté en ninguna lista negra: ese es el sentido de la Ley 2300. Para
ello:

1. El contacto que evalúa el motor lleva **marca de tiempo** (hora local CO).
2. El motor tiene un **calendario de festivos** colombianos **calculado**
   (determinista, offline), con override opcional por `app_params` (DN-06).
3. Una **regla de franja** en el motor decide, para contactos comerciales, si la
   hora/día caen fuera de la franja permitida → bloqueo.
4. La **verificación de integridad** del dataset local se hace de verdad
   (checksum vs. último sync válido), reemplazando la simulación del prototipo.

**Fuera de alcance:** cambiar el modelo de categorías (RN-07 ya está), la UI de
configuración (la tarjeta de solo lectura ya está en spec 05), métricas, SIC.
"Llamada fantasma" **no** se mide por duración (DN-07): sigue siendo una
categoría del dataset gobernada por la capa `callcenter`.

---

## 2. Requerimientos

### R1 · El contacto evaluado lleva hora local (DN-05/DN-06)
**Historia:** como motor, necesito saber cuándo ocurre el contacto para aplicar la
franja horaria.

Criterios (EARS):
1. EL SISTEMA DEBERÁ extender `IncomingContact` (o el valor que evalúa el motor)
   con la **marca de tiempo** del contacto en **hora local de Colombia**
   (America/Bogota, sin DST).
2. CUANDO la plataforma nativa entrega la llamada/SMS, EL SISTEMA DEBERÁ poblar esa
   marca de tiempo con el instante real del contacto.
3. SI la marca de tiempo no está disponible, EL SISTEMA DEBERÁ usar "ahora" como
   defecto seguro (no debe romper la evaluación).

### R2 · Calendario de festivos colombianos calculado y offline (DN-06)
**Historia:** como motor, sé qué días son festivos en Colombia sin depender de la red.

Criterios (EARS):
1. EL SISTEMA DEBERÁ calcular el conjunto de **festivos colombianos** de un año de
   forma **determinista y offline** (festivos fijos + movibles de la **Ley
   Emiliani**, que se trasladan al lunes siguiente, + los derivados de la **Pascua**
   mediante el algoritmo de cómputo).
2. EL SISTEMA DEBERÁ exponer una consulta `esFestivo(fecha)` pura y testeable.
3. EL SISTEMA DEBERÁ admitir un **override opcional desde `app_params`** (fechas
   adicionales declaradas por decreto o exenciones). SI el override está ausente o
   no se pudo leer, EL SISTEMA DEBERÁ usar solo el cálculo local (el bloqueo nunca
   depende de la red, DN-06).

### R3 · Regla de franja Ley 2300 en el motor (RN-08)
**Historia:** como usuario, un contacto comercial fuera del horario legal se
bloquea aunque no esté en ninguna lista.

Criterios (EARS):
1. CUANDO un contacto es de categoría **comercial**/`ley2300` y la capa `ley` está
   **activa**, EL SISTEMA DEBERÁ bloquearlo **si** su hora local cae **fuera** de
   la franja permitida (RN-08): L-V 07:00–19:00, Sáb 08:00–15:00, Dom/festivos
   bloqueo total.
2. CUANDO el mismo contacto cae **dentro** de la franja, EL SISTEMA DEBERÁ
   **permitirlo** (contacto comercial legal).
3. CUANDO la capa `ley` está **desactivada**, EL SISTEMA NO DEBERÁ aplicar la regla
   de franja (coherente con RN-SHIELD-05: capa off deja pasar).
4. ESTA regla DEBERÁ integrarse en el nivel 5 del `PrecedenceEngine` **sin** alterar
   la precedencia de los niveles 1–4 (listas locales y dataset mandan primero).
5. EL SISTEMA DEBERÁ reutilizar la **fuente única** de franjas
   `core/legal/ley2300_hours.dart` (la misma que muestra la spec 05).

### R4 · Paridad nativa de la regla de franja
**Historia:** como motor que corre sin FlutterEngine vivo, aplico la franja también
en el proceso nativo que filtra la llamada.

Criterios (EARS):
1. EL SISTEMA DEBERÁ proyectar al **snapshot nativo** la información necesaria para
   que el `CallScreeningService` aplique la franja (franjas fijas + festivos del
   periodo vigente), de modo que el bloqueo ocurra **antes de timbrar** (DN-07,
   mismo principio que call center).
2. EL SISTEMA DEBERÁ mantener la decisión Dart y la nativa **coherentes** para el
   mismo contacto/hora.

### R5 · Verificación real de integridad del dataset local (DN-08)
**Historia:** como usuario avanzado, cuando "audito integridad" se comprueba de
verdad que mi bóveda de hashes no fue alterada.

Criterios (EARS):
1. CUANDO se ejecuta la verificación, EL SISTEMA DEBERÁ recomputar el **checksum**
   del dataset local y compararlo con el **valor del último sync válido**
   (`02-seguridad §02.6`), **sin** simulaciones ni números fijos.
2. CUANDO el checksum **coincide**, EL SISTEMA DEBERÁ reportar el **conteo real**
   de hashes íntegros.
3. CUANDO **no coincide**, EL SISTEMA DEBERÁ reportar **integridad comprometida** y
   ofrecer **re-sincronizar/reparar** (reutiliza el flujo de sync + `IntegrityFailure`).
4. LA verificación DEBERÁ poder ejecutarse **offline** (no re-descarga; compara
   contra el checksum ya guardado).

---

## 3. No objetivos / decisiones heredadas

- **Llamada fantasma por duración:** descartado (DN-07). Es categoría del dataset,
  no una medición en tiempo real.
- **Edición de franjas / switches de "bloqueo estricto":** descartado (DN-05). La
  franja es fija; la capa `ley` se togglea desde el Dashboard.
- **Importación masiva de listas:** fuera de alcance de la app (DN-09, portal externo).
- **ZK-proof criptográfico completo:** la "auditoría" de esta spec es verificación
  por checksum (real y barata); la prueba ZK formal sigue en el hardening diferido.
