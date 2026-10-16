# Spec · 05 Motor de bloqueo — Diseño

> Motor de precedencia (Dart) + capa nativa Android (Kotlin) + inspección de SMS.
> Alineado a `04-app-flutter` §04.5, `03-datos` §03.5, `02-seguridad` §02.2.

---

## 1. Reto arquitectónico y decisión clave

`CallScreeningService` lo invoca el SO **en su propio proceso**, con una ventana
de tiempo muy corta para responder y **sin garantía de que el motor Dart/Flutter
esté vivo**. Llamar a Dart por platform channel desde el servicio es frágil
(arrancar el engine por cada llamada es lento y poco fiable).

**Decisión:** el matching en caliente para llamadas se hace **nativo**, contra un
**índice local que Dart mantiene actualizado**:

- El dominio Dart es la **fuente de verdad** del motor de precedencia y de las
  reglas. Tras cada sync o cambio de config/listas, Dart **proyecta** a un store
  nativo-legible un snapshot mínimo:
  - El `Set` de hashes activos de la **negra global** (del dataset).
  - Las listas **blanca** y **negra local** (hashes).
  - La **config del escudo** (3 capas) y el mapa categoría→capa de los hashes
    bloqueables (para respetar RN-SHIELD-05 nativamente).
  - El **pepper** (ya está en keystore; el nativo lo lee de ahí para hashear el
    entrante con el mismo algoritmo).
- El `CallScreeningService` (Kotlin) hashea el número entrante, aplica la misma
  precedencia de 5 niveles sobre ese snapshot y decide. Es O(1) con `HashSet`.

> Así la decisión es **instantánea y fiable** sin depender del engine Dart, y la
> lógica sigue siendo "real" (idéntica precedencia, mismos datos). El motor Dart
> queda como fuente de verdad + usado para SMS (que sí tolera arrancar lógica) y
> para pruebas unitarias exhaustivas.

El **snapshot** se escribe en un almacenamiento compartido rápido: un archivo
JSON en el directorio de la app (o `SharedPreferences` cifrado). No contiene
números legibles, solo hashes (coherente con RN-01). El pepper no se duplica: se
lee del keystore.

---

## 2. Motor de precedencia (Dart) — `features/engine`

```
features/engine/
├── domain/
│   ├── entities/
│   │   ├── incoming_contact.dart     # número, tipo (call/sms), cuerpo (sms)
│   │   ├── block_decision.dart       # allow | block (+ razón/nivel)
│   │   └── threat_category.dart      # catálogo RN-07 + mapa categoría→capa
│   ├── precedence_engine.dart        # los 5 niveles (lógica pura)
│   └── number_normalizer.dart        # E.164 (RN-04)
├── data/
│   ├── hmac_hasher.dart              # HMAC-SHA256(pepper, E164) (crypto)
│   └── native_snapshot_writer.dart   # proyecta el índice al store nativo
└── presentation/
    └── engine_providers.dart         # compone pepper + DAOs + proyección
```

### `PrecedenceEngine`

Función pura: dado un contacto, el pepper, las listas y la config, devuelve
`BlockDecision`. Implementa los 5 niveles de `03-datos` §03.5 y el mapeo
categoría→capa de RN-07. Totalmente testeable sin plataforma.

### Normalización y hash

- `NumberNormalizer`: a E.164 CO; códigos cortos aparte (RN-04).
- `HmacHasher`: `HMAC-SHA256(pepper, numeroE164)` en hex, idéntico al servidor y
  al seed (verificado end-to-end en la spec 04).

### Proyección al snapshot nativo

`NativeSnapshotWriter` serializa `{ negraGlobal:Set, blancaLocal:Set,
negraLocal:Set, config:{...}, categoriaPorHash?:{...} }` y lo entrega al nativo
por un `MethodChannel` (`engine/snapshot`) que lo persiste. Se reproyecta tras:
sync (altas/bajas), cambios de listas, y cambios de config del escudo.

---

## 3. Capa nativa Android (Kotlin)

```
android/app/src/main/kotlin/com/cifradocero/shield_app/
├── MainActivity.kt                 # + MethodChannels (roles, snapshot, estado)
├── engine/
│   ├── BlockingEngineChannel.kt    # puente MethodChannel (requestRole, status, snapshot)
│   ├── SnapshotStore.kt            # persiste/lee el snapshot (archivo privado)
│   ├── PrecedenceMatcher.kt        # misma precedencia de 5 niveles, nativa
│   └── Hmac.kt                     # HMAC-SHA256 con el pepper del keystore
├── call/
│   └── CallScreeningServiceImpl.kt # intercepta llamadas, decide, responde
└── sms/
    └── SmsReceiver.kt              # BroadcastReceiver RECEIVE_SMS (inspección)
```

### Llamadas — `CallScreeningServiceImpl`

- Declarado en el manifest con `permission.BIND_SCREENING_SERVICE` y el
  intent-filter `CallScreeningService`.
- En `onScreenCall(details)`: extrae el número → `Hmac` con el pepper (keystore)
  → `PrecedenceMatcher.decide(hash, config)` sobre el snapshot → responde con
  `CallResponse` (disallow + reject + skipCallLog/skipNotification según decisión,
  o permitir).
- Rol: se solicita desde Dart vía `RoleManager.createRequestRoleIntent(ROLE_CALL_SCREENING)`
  lanzado por `BlockingEngineChannel` / la Activity.

### SMS — `SmsReceiver`

- `BroadcastReceiver` registrado para `android.provider.Telephony.SMS_RECEIVED`
  con permiso `RECEIVE_SMS` (no es app por defecto; **no** usa `SMS_DELIVER`).
- Lee `messages`, evalúa remitente con `PrecedenceMatcher` y extrae URLs del
  cuerpo para marcar dominios sospechosos. Registra el evento (y notifica si hay
  permiso). **No** aborta ni borra el SMS.

### Permisos (manifest)

- `android.permission.READ_PHONE_STATE` / rol `ROLE_CALL_SCREENING` (vía RoleManager).
- `android.permission.RECEIVE_SMS`.
- `android.permission.POST_NOTIFICATIONS` (Android 13+).
- **No** se piden Contactos (RN-01).

### `BlockingEngineChannel` (MethodChannel)

Métodos expuestos a Dart:
- `requestCallScreeningRole()` → lanza el diálogo del SO; devuelve concedido/no.
- `permissionStatus()` → `{ callScreening, sms, notifications }` (degradación).
- `writeSnapshot(json)` → persiste el snapshot que usa el matcher nativo.
- (SMS/call eventos entrantes → emiten por un `EventChannel` opcional para el
  historial de eventos, consumido por la feature `events` más adelante.)

---

## 4. `BlockingEngine` real (core/platform)

Se implementa `BlockingEngineAndroid implements BlockingEngine` (la interfaz ya
existe en `core/platform/blocking_engine.dart`) sobre `BlockingEngineChannel`:
`requestPermissions`, `permissionStatus`, `decide` y el stream `incoming`
(alimentado por el `EventChannel`). En plataformas no-Android, una implementación
no-op que reporta permisos nulos (degradación).

---

## 5. Aplicar config al motor (RF-SHIELD-04)

- `engine_providers.dart` observa `ShieldConfigDao.watchConfig()` y el conteo del
  dataset; ante cualquier cambio, reproyecta el snapshot al nativo
  (`writeSnapshot`). Así el toggle del Dashboard tiene **efecto real inmediato**
  sobre el filtrado de llamadas/SMS.
- El `PrecedenceEngine` Dart también lee la config vigente para las decisiones que
  ocurran en Dart (SMS).

---

## 6. Dependencias

- `crypto` (ya añadido en la spec 04) para el HMAC en Dart.
- Sin dependencias nuevas en Dart. En Android, solo APIs del framework
  (`android.telecom.CallScreeningService`, `android.app.role.RoleManager`,
  `javax.crypto` para el HMAC nativo).

---

## 7. Pruebas

- **Unitarias Dart (exhaustivas):** `PrecedenceEngine` — cada uno de los 5 niveles,
  precedencia (blanca local gana sobre negra global, etc.), mapeo categoría→capa,
  capa desactivada deja pasar (RN-SHIELD-05), default allow. `NumberNormalizer`,
  `HmacHasher` (vector conocido). `NativeSnapshotWriter` serializa lo esperado.
- **Compilación:** `flutter build apk --debug --flavor dev` con el servicio y el
  receiver declarados.
- **Dispositivo (Moto g04s, API 34):** conceder rol de call screening; una llamada
  de un número en negra local se rechaza; la UI muestra el estado de permisos;
  revocar el rol se refleja al reanudar.

> La paridad del matcher nativo (Kotlin) con el motor Dart se cubre con un vector
> de prueba compartido (mismos hash+config → misma decisión), verificado en el
> test Dart y comprobado manualmente en el dispositivo.
