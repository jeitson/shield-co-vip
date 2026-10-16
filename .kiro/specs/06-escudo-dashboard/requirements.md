# Spec · 06 Escudo / Dashboard — Requerimientos

> Pantalla principal tras login (`PANT-SHIELD`): estado agregado del blindaje,
> control de las 3 capas, contador de la lista local, sincronización y acceso al
> simulador. Integra, 100% real, las specs A (persistencia), B (dataset/sync) y
> C (motor de bloqueo).
>
> Fuente de negocio: [`02-business/02-escudo-dashboard`](../../../02-business/02-escudo-dashboard/02-escudo-dashboard.md)
> y [`00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md) (RN-03, RN-07).
> Referencia visual: `app_desing/src/components/screens/ShieldScreen.tsx` + [design system](../../../01-docs/06-design-system.md).
> Depende de: `03-persistencia-local`, `04-dataset-sync`, `05-motor-bloqueo`.

---

## 1. Introducción

El Dashboard es el **destino por defecto tras iniciar sesión** (DN-02). Muestra el
estado global del blindaje y permite activar/desactivar las 3 capas, cuyo estado
consumen Registro de eventos (03), Simulador (07) y Header (08).

Esta spec reemplaza el `PlaceholderScreen` actual del `ShieldScreen` por la
pantalla real, cableada a datos reales: la config persiste cifrada (A), el
contador refleja el dataset local sincronizado (B), y el toggle aplica al motor
que realmente filtra (C).

---

## 2. Requerimientos

### R1 · Estado agregado del escudo (RF-SHIELD-01, RN-03)
**Historia:** como usuario, veo de un vistazo mi nivel de protección.

Criterios (EARS):
1. CUANDO las 3 capas están activas, EL SISTEMA DEBERÁ mostrar estado **Total**
   (verde), "Protección Total Activa" y el contador "3 / 3 ACTIVOS" (CA-SHIELD-01).
2. CUANDO hay 1–2 capas activas, EL SISTEMA DEBERÁ mostrar estado **Parcial**
   (ámbar) "Protección Parcial" (CA-SHIELD-02).
3. CUANDO hay 0 capas activas, EL SISTEMA DEBERÁ mostrar estado **Riesgo** (rojo)
   "Protección Desactivada - En Riesgo" (CA-SHIELD-03).
4. EL SISTEMA DEBERÁ derivar color, icono, escudo del hero y textos de RN-03,
   usando exclusivamente los tokens de `core/theme`.

### R2 · Alternar capas (RF-SHIELD-02, RN-SHIELD-03)
**Historia:** como usuario, activo/desactivo cada capa de forma independiente.

Criterios (EARS):
1. CUANDO el usuario pulsa el switch de una capa, EL SISTEMA DEBERÁ alternar su
   estado de forma independiente (sin dependencias entre capas).
2. CUANDO cambia una capa, EL SISTEMA DEBERÁ **persistir** la config en la base
   cifrada (A, RF-SHIELD-05) y recalcular el estado agregado (CA-SHIELD-04).
3. CUANDO cambia una capa, EL SISTEMA DEBERÁ reproyectar el snapshot al motor
   (C) para que el filtrado real cambie (RF-SHIELD-04).

### R3 · Advertencias por capa desactivada (RF-SHIELD-03, RN-SHIELD-02)
**Historia:** como usuario, entiendo la consecuencia de desactivar una capa.

Criterios (EARS):
1. CUANDO se desactiva `extorsion`, EL SISTEMA DEBERÁ mostrar un panel de
   advertencia de **severidad ALTA** (rojo) con el texto de consecuencia
   (CA-SHIELD-09).
2. CUANDO se desactiva `callcenter` o `ley`, EL SISTEMA DEBERÁ mostrar un panel
   de **severidad MEDIA** (ámbar) con su texto.
3. CUANDO se reactiva una capa, EL SISTEMA DEBERÁ ocultar su panel (CA-SHIELD-04).
4. EL SISTEMA DEBERÁ usar los textos de advertencia del documento de negocio
   (tabla "Textos de advertencia por capa").

### R4 · Contador de la lista local (RF-SHIELD-06)
**Historia:** como usuario, veo cuántas firmas tiene mi lista local.

Criterios (EARS):
1. EL SISTEMA DEBERÁ mostrar el **conteo real** de firmas activas
   (`datasetCountProvider`, de B), no un número fijo.
2. CUANDO el dataset se sincroniza, EL SISTEMA DEBERÁ actualizar el contador de
   forma reactiva.
3. CUANDO el conteo es 0 (sin sincronizar aún), EL SISTEMA DEBERÁ mostrarlo con
   claridad (estado vacío, no un número inventado).

### R5 · Sincronización manual y estados (RF-SHIELD-07, EST-SHIELD-04/05)
**Historia:** como usuario, puedo forzar la actualización de firmas y ver su estado.

Criterios (EARS):
1. CUANDO el usuario pulsa "sincronizar", EL SISTEMA DEBERÁ iniciar el sync (B) y
   mostrar "Verificando firmas…" con spinner (EST-SHIELD-04, CA-SHIELD-06).
2. CUANDO el sync termina con éxito, EL SISTEMA DEBERÁ mostrar la **fecha real**
   de última sincronización (es-CO) y el contador actualizado.
3. CUANDO el sync falla (red/servidor/integridad), EL SISTEMA DEBERÁ mostrar un
   mensaje de error y permitir reintento, **sin** alterar la fecha previa
   (EST-SHIELD-05, CA-SHIELD-07).
4. MIENTRAS hay un sync en curso, EL SISTEMA DEBERÁ evitar lanzar otro (de-dup, B).

### R6 · Acceso al Simulador (RF-SHIELD-08)
Criterios:
1. CUANDO el usuario pulsa "Probar", EL SISTEMA DEBERÁ navegar al Simulador
   (`AppRoutes.simulatorPath`) (CA-SHIELD-08).

### R7 · Permisos del motor y degradación honesta (§00.6, C)
**Historia:** como usuario, la app me dice con transparencia qué protección está
realmente activa y me ayuda a conceder permisos.

Criterios (EARS):
1. CUANDO falta el rol de call screening, EL SISTEMA DEBERÁ indicarlo y ofrecer
   un **priming**/acción para concederlo (`BlockingEngine.requestPermissions`).
2. EL SISTEMA DEBERÁ reflejar el estado de permisos (llamadas/SMS/notificaciones)
   sin fingir protección cuando una capa del SO está inactiva.
3. CUANDO el usuario vuelve a la pantalla, EL SISTEMA DEBERÁ refrescar el estado
   de permisos (p. ej. si concedió/revocó desde ajustes).

### R8 · Fidelidad visual y accesibilidad (R4 del doc, §6.9)
Criterios:
1. EL SISTEMA DEBERÁ reproducir la jerarquía de `ShieldScreen.tsx`: barra de
   estado, hero con escudo dinámico + anillos, 3 tarjetas-módulo con switch, 2
   métricas (lista local + sync), tarjeta de acceso al simulador.
2. EL SISTEMA DEBERÁ usar exclusivamente tokens de `core/theme` (nada hardcodeado).
3. EL SISTEMA DEBERÁ garantizar objetivos táctiles ≥ 48dp, switches con semántica
   accesible, y **no** comunicar estado solo por color (texto/forma redundante).

---

## 3. Fuera de alcance (esta spec)

- Verificación de **interceptación real** en dispositivo (acción física del
  usuario; cubierto por la spec C).
- Listas blanca/negra **locales** (feature `lists`): el motor las soporta, pero su
  gestión UI es otra spec. Aquí el contador es del dataset global.
- Registro de eventos interceptados (feature `events`).
- Sincronización automática/oportunista: ya vive en B (triggers); el Dashboard
  solo añade el disparo **manual**.
