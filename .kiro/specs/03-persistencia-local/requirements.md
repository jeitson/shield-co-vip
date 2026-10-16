# Spec · 03 Persistencia local cifrada — Requerimientos

> Base de datos local **cifrada** del dispositivo (`core/db` + `core/secure`) y
> la **DEK** que la abre. Infra transversal que habilita la persistencia real de
> varias features (config del escudo, dataset de hashes, listas, eventos,
> métricas locales).
>
> Fuente de arquitectura: [`03-architecture/04-app-flutter`](../../../03-architecture/04-app-flutter.md) §04.4,
> [`03-architecture/02-seguridad-y-criptografia`](../../../03-architecture/02-seguridad-y-criptografia.md) §02.3 (DA-07, DA-14).
> Modelo de dominio: [`02-business/00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md) §00.4 (persistencia transversal).

Esta spec **no** implementa ninguna pantalla. Entrega la capa de persistencia
sobre la que se construyen las specs `04-dataset-sync`, `05-motor-bloqueo` y
`06-escudo-dashboard`.

---

## 1. Introducción

El prototipo mantenía todo en memoria y lo perdía al recargar (`00-fundamentos` §00.4).
Producción exige persistencia local **cifrada en reposo** con estas propiedades
(`02-seguridad` §02.3):

- **drift** sobre **SQLCipher / SQLite con cifrado AES-256** (ORM tipado,
  migraciones versionadas, queries reactivas).
- **DEK** (Data Encryption Key) de 256 bits, **aleatoria**, generada en el primer
  arranque y custodiada en el **keystore del SO** (Android Keystore), nunca en la
  propia base ni en `SharedPreferences` plano.
- La DEK es **independiente de la contraseña** del usuario: un reset de clave por
  email **no** debe dejar la base ilegible.
- La base **nunca** guarda material de keystore (DEK, pepper, tokens).

**Alcance de esta spec:** la infraestructura de base cifrada + DEK + el esquema
inicial estrictamente necesario para desbloquear el Dashboard: la **config del
escudo** (3 capas) y la tabla de **hashes locales** del dataset. Las demás tablas
(listas, eventos, métricas) se añaden en migraciones posteriores cuando llegue su
feature, reusando este mismo cimiento.

---

## 2. Requerimientos

### R1 · Base local cifrada operativa (drift + SQLCipher)
**Historia:** como app, necesito una base local cifrada para persistir
configuración y datos sin exponerlos en reposo.

Criterios de aceptación (EARS):
1. CUANDO la app arranca por primera vez, EL SISTEMA DEBERÁ crear el archivo de
   base **cifrado** con AES-256 y abrirlo con la DEK del keystore (DA-07).
2. CUANDO la app arranca con una base ya existente, EL SISTEMA DEBERÁ abrirla con
   la DEK almacenada sin pedir nada al usuario.
3. EL SISTEMA DEBERÁ verificar en tiempo de ejecución que la variante cifrada del
   motor está activa (p. ej. `PRAGMA cipher`), fallando de forma explícita si no
   lo está (nunca abrir en claro silenciosamente).
4. EL SISTEMA DEBERÁ exponer el acceso a la base **solo** a través de la capa
   `data` de las features (vía providers de Riverpod), nunca directamente desde
   `presentation`.

### R2 · DEK en keystore (core/secure)
**Historia:** como sistema de seguridad, custodio la clave de cifrado en hardware
para que el robo del archivo no comprometa los datos.

Criterios de aceptación (EARS):
1. CUANDO no existe DEK en el primer arranque, EL SISTEMA DEBERÁ generar una clave
   **aleatoria** de 256 bits de alta entropía y guardarla en el keystore seguro
   (Android Keystore vía `flutter_secure_storage`, DA-14).
2. CUANDO ya existe DEK, EL SISTEMA DEBERÁ reutilizarla sin regenerarla.
3. EL SISTEMA DEBERÁ mantener la DEK **independiente de la contraseña** del usuario
   (un reset de clave no la cambia ni invalida la base, `02-seguridad` §02.3).
4. EL SISTEMA NUNCA DEBERÁ escribir la DEK en la base de datos, en logs ni en
   almacenamiento plano.
5. CUANDO el dispositivo se revoca o se cierra sesión con borrado de material,
   EL SISTEMA DEBERÁ poder eliminar la DEK (lo que vuelve ilegible la base), sin
   que esto rompa el arranque (se regenera base vacía).

### R3 · Esquema inicial y migraciones versionadas
**Historia:** como base de datos, evoluciono mi esquema de forma segura entre
versiones de la app.

Criterios de aceptación (EARS):
1. EL SISTEMA DEBERÁ definir `schemaVersion` y un flujo de migración versionado
   (drift `MigrationStrategy`), partiendo de la versión 1.
2. EL SISTEMA DEBERÁ crear en la v1 las tablas **`shield_config`** (3 capas +
   metadatos) y **`phone_hashes`** local (hash + categoría + nivel + versiones de
   dataset), según el esquema de `03-datos-y-sincronizacion` §03.1/§03.3.
3. CUANDO se agregue una tabla nueva en una feature posterior, EL SISTEMA DEBERÁ
   permitir añadirla por migración incremental sin recrear la base.
4. EL SISTEMA DEBERÁ garantizar fila única de `shield_config` por defecto con las
   **3 capas activas** (RN-SHIELD-04 / `ConfigEscudo` defecto `true`).

### R4 · Acceso tipado y reactivo
**Historia:** como capa de datos, quiero leer/escribir con tipos seguros y
observar cambios en vivo.

Criterios de aceptación (EARS):
1. EL SISTEMA DEBERÁ exponer DAOs tipados para `shield_config` y `phone_hashes`.
2. EL SISTEMA DEBERÁ ofrecer un **stream** de la config del escudo para que la UI
   reaccione a cambios (patrón `AsyncValue`, `04-app-flutter` §04.3).
3. EL SISTEMA DEBERÁ ofrecer un conteo (`COUNT`) eficiente de `phone_hashes` para
   el contador del Dashboard (RF-SHIELD-06), sin cargar todas las filas.
4. EL SISTEMA DEBERÁ permitir cargar los hashes activos como un `Set` en memoria
   para el matching O(1) del motor (`04-app-flutter` §04.4).

### R5 · Aislamiento y arranque
**Historia:** como app, quiero que la base esté lista antes de que las features la
usen, sin bloquear el hilo de UI.

Criterios de aceptación (EARS):
1. EL SISTEMA DEBERÁ abrir la base en background (p. ej. `NativeDatabase.createInBackground`)
   para no bloquear el arranque.
2. EL SISTEMA DEBERÁ inicializar la base en el `bootstrap` o de forma perezosa vía
   provider, de modo que `restoreSession` y las features la encuentren disponible.
3. EL SISTEMA DEBERÁ cerrar correctamente la base al disponerse (tests y hot-restart
   no deben filtrar conexiones).

---

## 3. Fuera de alcance (esta spec)

- Tablas de **listas** (blanca/negra), **eventos** y **métricas**: se añaden por
  migración cuando lleguen sus features (`05-listas`, `03/04-eventos`, `metrics`).
- **Pepper** y la lógica de **HMAC/matching**: pertenecen a `04-dataset-sync` y
  `05-motor-bloqueo` (el pepper va al keystore, no a la base; aquí solo se deja el
  gancho en `core/secure`).
- **Delta sync** y endpoints `/v1/sync`: spec `04-dataset-sync`.
- **Certificate pinning** (DA-14): hardening transversal sobre el `ApiClient`.
- Backup/restore entre dispositivos: por diseño, los datos locales no se
  restauran desde el servidor (`02-seguridad` §02.3).
