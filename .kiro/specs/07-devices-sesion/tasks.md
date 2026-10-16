# Spec · 07 Dispositivos y sesión — Plan de implementación

> Subsistema `devices` (Fase 2): tabla + RLS + `v1-session` (register/activate/
> refresh), `device_id` de instalación, registro post-login con diálogo de
> exclusividad, refresh con wipe, y endurecimiento de `v1-sync`/`v1-pepper`.

## 1. Backend — esquema
- [x] 1.1 `0008_devices.sql`: tabla `devices` (id=device_id, profile_id FK, metadatos,
  estado, numero_protegido, last_synced_version, last_seen_at) + índice de exclusividad
  (activo por numero_protegido) + RLS (select propio; escritura solo Edge).
- [x] 1.2 Copia con timestamp `20260101000008_devices.sql` en `05-backend/supabase/migrations/`.
- _Req: R1_

## 2. Backend — Edge Function v1-session
- [x] 2.1 `v1-session/index.ts`: valida JWT; acción `register` (upsert + cálculo de
  exclusividad → activo | pendiente_confirmacion), `activate` (revoca otros + activa
  este), `refresh` (activo → OK + last_seen_at; revocado → 401).
- _Req: R2, R3, R4_

## 3. Backend — endurecer v1-sync / v1-pepper
- [x] 3.1 Helper compartido `_shared/device.ts` `requireActiveDevice(req)` (lee
  `x-device-id` + valida fila activa). Aplicado en `v1-sync` y `v1-pepper` → 403 si no activo.
- _Req: R5_

## 4. Despliegue backend (DESPLEGADO con aprobación explícita del usuario)
- [x] 4.1 `supabase db push` de 0008 (crea tabla `devices` + RLS). Aditivo, reversible.
- [x] 4.2 `supabase functions deploy v1-session v1-sync v1-pepper` (las dos últimas,
  re-deploy con el chequeo de device). **Nota:** tras desplegarlas, el sync exige
  dispositivo activo; sin registrar el device la app no sincroniza (por eso v1-session
  se desplegó junto).
- [x] 4.3 Verificado e2e: flujo A/B/activate/refresh/revocado + sync denegado si inactivo.
  En dispositivo real `v1-session` responde `{"estado":"activo"}` y `v1-sync` 200.
- _Req: R1–R5_. **Desplegado con "por favor haz el despliegue en supabase" (R-DEPLOY-01).**

## 5. App — device_id + metadatos
- [x] 5.1 `DeviceIdStore` (UUID v4 de instalación en secure storage).
- [x] 5.2 `device_info_plus` + `uuid` (deps) + `DeviceInfoLoader`/`DeviceInfo`.
- _Req: R6_

## 6. App — repositorio de sesión de dispositivo
- [x] 6.1 `SessionRemoteDataSource` (register/activate/refresh vía ApiClient autenticado).
- [x] 6.2 `DeviceRepository` + `DeviceRepositoryImpl` (register/confirmExclusivity/refresh;
  401 → revocado).
- [x] 6.3 `SessionWiper` (borra pepper + DEK + dataset) reutilizable.
- _Req: R7, R8_

## 7. App — enganche en el flujo
- [x] 7.1 Registro automático tras login en `ShieldScreen` (register con celular del
  perfil) + `ExclusivityDialog` si pendiente → activate.
- [x] 7.2 Refresh al entrar; en `device_revocado` → `SessionWiper.wipe()` + logout
  (guard vuelve a login).
- [x] 7.3 `SupabaseAuthInterceptor` añade `x-device-id` (sync/pepper/session, incl. background).
- _Req: R7, R8, R9_

## 8. Verificación
- [x] 8.1 Tests: `DeviceIdStore` (crea/reusa/únicos), `DeviceRepositoryImpl`
  (register activo/pendiente, refresh activo/revocado/red), `SessionWiper` (borra
  pepper+DEK+dataset). 8 tests nuevos.
- [x] 8.2 `flutter analyze` + `dart format` limpios; suite completa **113 tests OK**.
- [x] 8.3 `flutter build apk --debug --flavor dev` compila OK; instalado y verificado
  en Moto g04s con backend desplegado: tras login real, el registro post-login llama
  a `v1-session` y obtiene `{"estado":"activo"}`; `v1-sync` responde 200 con el
  dataset (300 hashes) y `x-device-id` presente en las cabeceras. El Dashboard
  renderiza completo (ver spec 06, tarea 5.3).
- _Req: todos_
