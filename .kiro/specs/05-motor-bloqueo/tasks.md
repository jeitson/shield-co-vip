# Spec · 05 Motor de bloqueo — Plan de implementación

> Motor de precedencia (Dart) + capa nativa Android (llamadas) + inspección SMS +
> proyección del índice al nativo. Hace real RF-SHIELD-04. Device de prueba:
> Moto g04s, Android 14 (API 34).

## 1. Motor de precedencia (Dart, `features/engine/domain`)
- [x] 1.1 Entidades: `IncomingContact`, `BlockDecision` (allow/block + nivel + razón),
  `ThreatCategory` + mapa categoría→capa (RN-07).
- [x] 1.2 `NumberNormalizer` (E.164 CO, códigos cortos aparte; RN-04).
- [x] 1.3 `PrecedenceEngine`: 5 niveles (`03-datos` §03.5), default allow,
  capa desactivada deja pasar (RN-SHIELD-05).
- _Req: R1, R2, R3_

## 2. Hashing y proyección (Dart, `features/engine/data`)
- [x] 2.1 `HmacHasher` (HMAC-SHA256(pepper, E164) hex) — **verificado idéntico al
  servidor** con vector real (test `hmac_hasher_test.dart`).
- [x] 2.2 `NativeSnapshotWriter`: serializa {negraGlobal, blancaLocal, negraLocal,
  allowlist, config, layerByHash} y lo envía por MethodChannel `cifradocero/engine`
  (+ `setPepper`/`clearPepper`).
- [x] 2.3 `engine_providers.dart`: `engineIndexProvider` (observa config + dataset)
  y `engineProjectionProvider` que reproyecta el snapshot al nativo.
- _Req: R1, R7_

## 3. Capa nativa Android — puente y matcher
- [x] 3.1 `BlockingEngineChannel.kt`: writeSnapshot, setPepper, clearPepper,
  requestCallScreeningRole, permissionStatus. Registrado en `MainActivity` (+ onActivityResult).
- [x] 3.2 `SnapshotStore.kt` (archivo privado) + `PepperStore.kt`
  (EncryptedSharedPreferences, master key en Keystore) + `Hmac.kt` + `NumberNormalizer.kt`.
- [x] 3.3 `PrecedenceMatcher.kt` (misma precedencia de 5 niveles, nativa, O(1)).
- _Req: R4, R6, R7_

## 4. Capa nativa Android — llamadas y SMS
- [x] 4.1 `CallScreeningServiceImpl.kt` + manifest (BIND_SCREENING_SERVICE +
  intent-filter telecom). Decide con snapshot+pepper y responde reject+silence/allow.
- [x] 4.2 `SmsReceiver.kt` (SMS_RECEIVED, RECEIVE_SMS): inspecciona remitente +
  extrae dominios de URLs; detecta y registra, no borra (no es app por defecto).
- [x] 4.3 Permisos en manifest (READ_PHONE_STATE/RECEIVE_SMS/POST_NOTIFICATIONS;
  sin Contactos, RN-01).
- _Req: R4, R5_

## 5. BlockingEngine real (Dart, `core/platform`)
- [x] 5.1 `BlockingEngineAndroid implements BlockingEngine` sobre el channel +
  `BlockingEngineNoop` (no-Android) + `createBlockingEngine()`.
- [~] 5.2 Flujo de **priming** de permisos: el canal expone requestRole +
  permissionStatus (degradación honesta). La **pantalla** de priming se integra con
  la UI en el onboarding/Dashboard (spec D) para no duplicar navegación aquí.
- _Req: R6_

## 6. Verificación
- [x] 6.1 Tests Dart exhaustivos: PrecedenceEngine (12 tests: 5 niveles, precedencia,
  categoría→capa, capa off deja pasar RN-SHIELD-05, default allow), NumberNormalizer
  (8), HmacHasher (2, **vector real contra el backend**), NativeSnapshotWriter (2).
- [x] 6.2 `flutter analyze` + `dart format` limpios; suite completa **87 tests OK**.
- [x] 6.3 `flutter build apk --debug --flavor dev` compila con servicio+receiver+
  androidx.security (APK generado).
- [~] 6.4 **Dispositivo (Moto g04s, API 34)**: APK instalado y lanzado sin crashes;
  el SO reconoce `CallScreeningServiceImpl` (BIND_SCREENING_SERVICE + acción
  telecom) y `SmsReceiver` (SMS_RECEIVED); permisos declarados correctamente.
  **PENDIENTE (requiere acción física del usuario):** conceder el rol de call
  screening desde la UI de priming y realizar una **llamada real** desde un número
  en negra local para confirmar el rechazo. No es automatizable desde este entorno
  (no se pueden originar llamadas). La lógica de decisión está verificada por el
  vector HMAC real + los tests de precedencia (nativo = Dart).
- _Req: todos_

---

## Nota para spec D (dashboard)
- RF-SHIELD-04 queda cableado: el toggle del escudo reproyecta el snapshot y el
  motor nativo filtra en consecuencia.
- El estado de permisos del `BlockingEngine` alimentará la degradación honesta del
  estado agregado (RN-03) en el Dashboard.
