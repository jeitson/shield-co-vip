# Spec · 05 Motor de bloqueo — Requerimientos

> Motor de bloqueo real: capa nativa Android (`CallScreeningService` + roles) +
> inspección de SMS no-destructiva + el **motor de precedencia de 5 niveles**
> (Dart) que decide permitir/bloquear cada contacto entrante.
>
> Fuente de arquitectura: [`04-app-flutter`](../../../03-architecture/04-app-flutter.md) §04.5/§04.6,
> [`03-datos-y-sincronizacion`](../../../03-architecture/03-datos-y-sincronizacion.md) §03.5 (precedencia),
> [`02-seguridad`](../../../03-architecture/02-seguridad-y-criptografia.md) §02.2 (HMAC/pepper), §00.6 (permisos).
> Depende de: `03-persistencia-local` (listas + `activeHashes`) y `04-dataset-sync`
> (pepper en keystore).

Esta spec hace **real** RF-SHIELD-04 (aplicar la configuración del escudo al
motor que realmente filtra). Dispositivo de prueba: **Moto g04s, Android 14 (API 34)**.

---

## 1. Introducción

El prototipo solo cambiaba la UI; no filtraba nada. Producción exige un motor
real (`04-app-flutter` §04.5):

- **Interceptación de llamadas** vía `CallScreeningService` + rol
  `ROLE_CALL_SCREENING` (Android). Decide permitir/rechazar/silenciar según el
  motor de precedencia.
- **Inspección de SMS no-destructiva**: la app **no** reemplaza la app de SMS
  por defecto (decisión del usuario). Con permiso `RECEIVE_SMS` + un
  `BroadcastReceiver`, inspecciona remitente y detecta **links/dominios**
  sospechosos; **detecta y alerta**, no borra el SMS (borrar exigiría ser app por
  defecto). 
- **Motor de precedencia de 5 niveles** (Dart puro, testeable): el corazón de la
  decisión (`03-datos` §03.5).
- **Permisos con priming y degradación honesta** (§00.6): la app nunca finge
  proteger si una capa está inactiva.

### Alcance (confirmado con el usuario)
- ✅ Interceptación de **llamadas** completa.
- ✅ SMS: **solo inspección** de remitente + links/dominios (sin ser app por
  defecto, sin borrar).
- ❌ No se implementa app de SMS por defecto.

---

## 2. Requerimientos — Motor de precedencia (Dart)

### R1 · Jerarquía de precedencia de 5 niveles
**Historia:** como motor, decido permitir/bloquear cada contacto evaluando reglas
en orden estricto, ganando la primera que coincide (`03-datos` §03.5).

Criterios (EARS):
1. CUANDO llega un contacto, EL SISTEMA DEBERÁ calcular `HMAC-SHA256(pepper, E164)`
   del número con el pepper del keystore (`04-dataset-sync`).
2. EL SISTEMA DEBERÁ evaluar en este orden y detenerse en la primera coincidencia:
   1. Lista **blanca local** → PERMITIR (soberanía del usuario).
   2. **Allowlist global** → PERMITIR (entidad protegida).
   3. Lista **negra local** → BLOQUEAR.
   4. Lista **negra global** (dataset `phone_hashes`) → BLOQUEAR.
   5. **Motor de capas** del escudo (extorsión/callcenter/ley) → decide según
      categoría/nivel de la firma y las capas activas (RN-06, RN-07).
3. CUANDO ninguna regla aplica, EL SISTEMA DEBERÁ PERMITIR por defecto (no romper
   llamadas legítimas desconocidas).
4. CUANDO la firma coincide en el dataset global pero su **capa responsable está
   desactivada** (RN-SHIELD-05), EL SISTEMA DEBERÁ dejar pasar esa categoría.

### R2 · Relación capa↔categoría (RN-07)
Criterios:
1. EL SISTEMA DEBERÁ mapear cada categoría de amenaza a su capa responsable:
   extorsión/phishing → `extorsion`; call center/fantasma → `callcenter`;
   Ley 2300/comercial → `ley`.
2. CUANDO la capa responsable está activa, EL SISTEMA DEBERÁ bloquear la amenaza;
   si está inactiva, dejarla pasar (coherente con el estado agregado RN-03).

### R3 · Normalización E.164 (RN-04)
Criterios:
1. EL SISTEMA DEBERÁ normalizar el número entrante a E.164 (`+57` + 10 dígitos CO)
   antes de hashear, idéntico al servidor (para que los HMAC coincidan).
2. Los códigos cortos SMS se tratan aparte (sin normalización E.164).

---

## 3. Requerimientos — Capa nativa (Android)

### R4 · Interceptación de llamadas (CallScreeningService)
**Historia:** como app con el rol concedido, intercepto llamadas y las bloqueo
según el motor.

Criterios (EARS):
1. CUANDO el usuario tiene concedido `ROLE_CALL_SCREENING` y entra una llamada,
   EL SISTEMA DEBERÁ recibirla en el `CallScreeningService`, consultar al motor
   (vía platform channel) y responder permitir o **rechazar+silenciar**.
2. CUANDO el motor decide BLOQUEAR, EL SISTEMA DEBERÁ rechazar la llamada sin
   timbrar y (si hay permiso de notificaciones) emitir la alerta de interceptación.
3. CUANDO el rol **no** está concedido, EL SISTEMA DEBERÁ marcar la capa de
   llamadas como inactiva (degradación honesta, §00.6) y no fingir protección.
4. EL SISTEMA DEBERÁ responder en el tiempo que exige el SO (la respuesta de
   screening debe ser rápida; el matching local es O(1) con el `Set`).

### R5 · Inspección de SMS no-destructiva
**Historia:** como app con permiso de lectura de SMS, detecto remitentes y links
peligrosos y alerto, sin reemplazar la mensajería.

Criterios (EARS):
1. CUANDO llega un SMS y hay permiso `RECEIVE_SMS`, EL SISTEMA DEBERÁ leer
   remitente y cuerpo en un `BroadcastReceiver`, evaluar el remitente con el motor
   y extraer URLs para verificar dominios.
2. CUANDO el remitente o un dominio del cuerpo coincide con una firma peligrosa,
   EL SISTEMA DEBERÁ registrar el evento y (con permiso) **alertar**; NO borra ni
   bloquea el SMS (no es app por defecto).
3. EL SISTEMA DEBERÁ funcionar sin ser la app de SMS por defecto (solo
   `RECEIVE_SMS`), y degradar si el permiso se niega.

### R6 · Permisos, priming y estado (BlockingEngine)
**Historia:** como usuario, entiendo por qué se piden los roles y veo con
transparencia qué protección está activa.

Criterios (EARS):
1. EL SISTEMA DEBERÁ exponer una implementación real de `BlockingEngine`
   (`core/platform`) que solicite roles/permisos, informe su estado y reciba
   contactos entrantes.
2. EL SISTEMA DEBERÁ mostrar una pantalla de **priming** explicando cada rol
   antes de lanzar el diálogo del SO (`RoleManager`), §04.5.
3. CUANDO un rol se niega, EL SISTEMA DEBERÁ reflejar la capa como inactiva y
   ofrecer reintento / enlace a ajustes del SO.
4. CUANDO el usuario revoca un rol desde ajustes, EL SISTEMA DEBERÁ detectarlo al
   reanudar la app y actualizar el estado del escudo.

### R7 · Aplicar la configuración del escudo al motor (RF-SHIELD-04)
**Historia:** como usuario, cuando activo/desactivo una capa, el filtrado real
cambia en consecuencia.

Criterios (EARS):
1. CUANDO cambia `ShieldConfig` (una capa), EL SISTEMA DEBERÁ reflejarlo en el
   motor de precedencia inmediatamente (sin reiniciar la app).
2. EL SISTEMA DEBERÁ leer la config vigente (`ShieldConfigDao`) en cada decisión,
   de modo que el toggle tenga efecto real sobre el filtrado.

---

## 4. Verificación

- **Motor de precedencia (Dart):** pruebas unitarias exhaustivas de los 5 niveles
  y del mapeo capa↔categoría (todos los caminos de `03-datos` §03.5).
- **Compilación nativa:** `flutter build apk` (debug) compila con el servicio,
  el receiver, los permisos del manifest y el platform channel.
- **Dispositivo (Moto g04s, API 34):** instalar, conceder el rol de call
  screening, verificar que una llamada de un número en lista negra local se
  rechaza y que la UI refleja el estado de permisos.

---

## 5. Fuera de alcance (esta spec)

- App de **SMS por defecto** / borrado de SMS (decisión del usuario).
- iOS (Call Directory / Message Filter): fase futura.
- Allowlist global y domain_hashes **matching**: la estructura existe; el motor
  deja los ganchos de nivel 2 y de dominios, con matching activable cuando el
  dataset incluya esas secciones (`03-datos` §03.3).
- Registro/exclusividad de **dispositivo** (DA-03): spec `devices` (B2).
