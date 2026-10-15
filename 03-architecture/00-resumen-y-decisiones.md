# 00 · Resumen ejecutivo y registro de decisiones (ADR)

## 00.1 Resumen ejecutivo

Cifrado Cero se compone de **una app Flutter (Android-first)** que hace el filtrado real de llamadas/SMS **en el dispositivo y offline**, y un **backend sobre Supabase** que distribuye la inteligencia de bloqueo (hashes), gestiona cuentas y dispositivos, recibe reportes comunitarios y recolecta métricas anónimas agregadas.

El sistema está gobernado por una promesa de marca que es, a la vez, una restricción de arquitectura: **Zero-Knowledge respecto al historial y contenido de terceros**. Nada de lo que llama o escribe al usuario sale del teléfono. Lo que sí vive en el servidor es la cuenta del usuario (incluido su propio número), los hashes de la lista global, los reportes (con número legible del infractor) y métricas agregadas sin identidad.

### Pilares

1. **Matching local offline.** El dispositivo descarga una lista de hashes y evalúa cada llamada/SMS entrante localmente, en milisegundos, sin consultar al servidor. Esto preserva la privacidad y funciona sin conexión.
2. **Criptografía con pepper.** Los números se representan como `HMAC-SHA-256(pepper, número)`. El pepper es secreto, vive en el servidor y se entrega al dispositivo tras autenticarse, custodiado en el keystore del SO. Esto hace que los hashes **no sean reversibles** por fuerza bruta aunque se filtre la base de datos.
3. **Base local cifrada.** La SQLite del dispositivo usa SQLCipher con una llave aleatoria de 256 bits en el keystore, independiente de la contraseña del usuario.
4. **Soberanía del usuario.** Las listas blanca y negra locales del usuario mandan sobre la inteligencia global y nunca se sincronizan al servidor.
5. **Comunidad con integridad.** Los reportes no entran directo al blacklist global: pasan por un umbral de reputación y una allowlist de protección que evita el envenenamiento de la lista.

---

## 00.2 Principios rectores

- **Privacidad por diseño (RN-01).** Si un dato de terceros puede quedarse en el dispositivo, se queda. Solo sale lo mínimo, agregado o explícitamente consentido.
- **Fallar hacia la privacidad.** Ante la duda de diseño, se elige la opción que menos datos expone.
- **Separación de la capa nativa.** Todo lo específico de plataforma (interceptación) se aísla tras una interfaz Dart; el núcleo es agnóstico.
- **Versionar todo.** API, dataset de hashes, pepper, migraciones de DB y releases llevan versión explícita.
- **Configurable sin desplegar.** Umbrales, ventanas y constantes viven en configuración de servidor, no en código.

---

## 00.3 Registro de decisiones de arquitectura (ADR)

Decisiones acordadas y su justificación. `[DN-xx]` = decisión de negocio previa; `[DA-xx]` = decisión de arquitectura.

### DA-01 · Métricas en dos planos (personal local + agregada anónima)
- **Decisión:** las estadísticas personales ("tu tiempo ahorrado") se calculan y viven **en el dispositivo** (Plano B). Las métricas poblacionales (bloqueos/día plataforma) se envían **agregadas, anónimas y opt-in** (Plano A), sin número, sin contenido, sin `user_id`, sin `device_id`.
- **Porqué:** responde las preguntas de negocio sin romper RN-01. Cumple Habeas Data (Ley 1581 CO) y buenas prácticas tipo GDPR.
- **Ver:** [05 · Backend, API y métricas](./05-backend-api-metricas.md).

### DA-02 · Registro de dispositivos por cuenta con `device_id` propio
- **Decisión:** cada cuenta puede tener varios dispositivos. El `device_id` es un **UUID de instalación propio** (generado al primer arranque, en secure storage), **no** un identificador de hardware (IMEI/Android ID). Se asocian metadatos: marca, modelo, SO + versión, idioma/zona horaria.
- **Porqué:** permite gestión de sesiones y la regla de exclusividad por número, sin usar PII de hardware restringida por el SO.

### DA-03 · Exclusividad de protección por número (una sesión activa por número)
- **Decisión:** una cuenta puede tener múltiples dispositivos (visible/auditado, **RN-DEV-01**), pero el **número protegido solo puede estar activo en un dispositivo a la vez** (**RN-DEV-02**). Activar el mismo número en otro dispositivo advierte al usuario y, al confirmar, revoca el anterior, que queda desprotegido.
- **Porqué:** modelo de "licencia de protección" anclada al número; evita clonación silenciosa de la protección.

### DA-04 · Sesión de dispositivo de 12 horas como mecanismo de revocación
- **Decisión:** el access token vive 12h. El refresh verifica contra la tabla de dispositivos si el `device_id` sigue autorizado; si fue revocado, la renovación falla y el dispositivo cae a "desprotegido" y borra material sensible. Ventana máxima de doble protección: 12h. Sin push.
- **Porqué:** cumple el requisito de "ir al menos una vez al día", simplifica la arquitectura (no requiere push) y da una revocación acotada y predecible.
- **Nota:** OTP de celular queda **sugerido / fase futura**; el registro MVP valida solo email.

### DA-05 · Hashing con HMAC-SHA-256 + pepper (Opción B)
- **Decisión:** `hash = HMAC-SHA-256(key = PEPPER, msg = número_E164)`. El pepper vive en Supabase Vault, se entrega al dispositivo tras login y se guarda en keystore (Android Keystore / iOS Keychain), **nunca** en la SQLite. El matching es local.
- **Porqué:** los móviles CO son ~10^9 combinaciones; un hash plano es reversible por fuerza bruta. El pepper hace los hashes inútiles para quien no lo tenga (p. ej. si se filtra la DB de Supabase o el archivo SQLite).
- **Derivados:** el pepper es rotable (`pepper_version`); rotarlo fuerza full-resync. Los códigos cortos SMS se hashean con el mismo HMAC sin normalización E.164.

### DA-06 · Dataset de bloqueo con secciones versionadas
- **Decisión MVP:** `phone_hashes` (números E.164 + códigos cortos SMS). **Diseñado pero diferido:** `domain_hashes` (URLs maliciosas en SMS). **Fase futura:** reglas de contenido difuso.
- **Porqué:** el matching por hash exacto solo sirve para valores estables (números, dominios), no para texto libre.

### DA-07 · SQLite local cifrada con SQLCipher y DEK en keystore
- **Decisión:** `drift` + SQLCipher con DEK aleatoria de 256 bits en keystore, **independiente de la contraseña**. Recuperación de clave estándar por email (Supabase); perder la contraseña **no** pierde datos locales; perder/desinstalar el dispositivo sí.
- **Porqué:** evita que un reset de contraseña deje los datos locales ilegibles; mantiene ZK respecto a terceros sin forzar seed phrase (fricción de UX).

### DA-08 · Delta sync versionado por secuencia
- **Decisión:** el servidor mantiene `dataset_version` incremental; cada hash tiene `added_at_version` y `removed_at_version` (soft delete). El móvil guarda `last_synced_version` y pide cambios desde ahí. Fallback a **full resync** si cambió `pepper_version` o el gap es grande. Volumen esperado: **miles** de hashes.
- **Porqué:** idempotente, no depende de relojes sincronizados, barato para el volumen esperado.
- **Transporte/activación:** tarea en background diaria (WorkManager Android / BGTaskScheduler iOS a futuro) + **sync oportunista** al abrir la app y al recuperar conexión.

### DA-09 · Jerarquía de precedencia de 5 niveles
- **Decisión (mayor a menor prioridad):**
  1. **Lista blanca local del usuario** → siempre pasa.
  2. **Allowlist global gestionada** (gobierno / empresas / seguridad interna) → siempre pasa.
  3. **Lista negra local del usuario** → se bloquea.
  4. **Lista negra global** (hashes comunitarios) → se bloquea.
  5. **Motor de capas** (extorsión / callcenter / ley 2300).
- **Porqué:** el dueño del teléfono es soberano; las entidades protegidas no deben ser bloqueables por reportes maliciosos; la comunidad aporta por debajo de la decisión humana.
- **Privacidad:** las listas blanca/negra **locales nunca se sincronizan**.

### DA-10 · Reporte comunitario con moderación anti-envenenamiento
- **Decisión:** reporte → `pendiente` → al superar un **umbral configurable de N reportes independientes** (dedup por `device_id` anónimo) → `blacklist` global. **Allowlist de protección** impide que números críticos entren al blacklist. El servidor guarda el **número legible** del infractor (además del hash); el reporte es **anónimo respecto al reportante**.
- **Config:** umbral/ventanas en **tabla de parámetros** de Supabase; secretos en **Vault**.
- **Fuera de alcance:** la gestión de organizaciones/exclusiones y su carga (CSV/manual) vive en un **proyecto de administración web separado**; aquí solo se consume la sección `allowlist_hashes`.

### DA-11 · Backend: Auth + Postgres/RLS + Edge Functions + pg_cron + Vault
- **Decisión:** toda la lógica de negocio y criptográfica va por **Edge Functions (Deno/TypeScript)**. RLS protege acceso a filas (no lógica). Sin RPC de Postgres por ahora. El cliente nunca toca el pepper ni tablas sensibles directamente.
- **Porqué:** un solo paradigma (TypeScript), fácil de versionar, frontera clara para la criptografía.

### DA-12 · Alcance Android-first; iOS en modo reducido (fase futura)
- **Decisión:** el MVP es **Android** con interceptación completa (`CallScreeningService`, rol SMS). iOS queda documentado como fase posterior con capacidades reducidas (Call Directory + Message Filter, modo lista). La interceptación se aísla tras una interfaz Dart `BlockingEngine`.
- **Porqué:** iOS no permite interceptación dinámica en tiempo real; no habrá paridad real de interceptación, pero sí en todo el resto.

### DA-13 · App Flutter con Clean Architecture + Riverpod + drift
- **Decisión:** Clean Architecture por features (presentation/domain/data), estado con **Riverpod** (`AsyncValue` para cargando/éxito/error/vacío), persistencia con **drift + SQLCipher**.

### DA-14 · Hardening de cliente — nivel base
- **Decisión MVP:** certificate pinning, secretos en keystore, ofuscación (R8/ProGuard), FLAG_SECURE en pantallas sensibles, verificación de integridad del dataset (firma/checksum), TLS/HTTPS, tokens en secure storage.
- **Fuera del MVP:** detección root/jailbreak y Play Integrity attestation.
- **Efecto:** convierte F-06 (auditoría de integridad, antes simulada) en funcionalidad real.

### DA-15 · Un entorno inicial; API versionada obligatoria; monorepo
- **Decisión:** se arranca con **un entorno** (ruta a dev/prod documentada). **API versionada por carpeta** (`/v1`), con capacidad de forzar actualización de apps obsoletas. Todo en un **monorepo** (`app/`, `supabase/`, docs).

### DA-16 · Branching trunk-based + release/hotfix + SemVer
- **Decisión:** `main` troncal desplegable, `feature/*` cortas, `release/vX.Y` para estabilizar, `hotfix/*` para producción, tags SemVer `vX.Y.Z`, Conventional Commits. Sin `develop`. Las versiones de API **coexisten por carpeta en `main`** con matriz de soporte y política de deprecación.

---

## 00.4 Qué queda fuera del MVP (resumen)

- OTP de celular en registro (diseñado, no implementado).
- iOS (documentado, no construido).
- `domain_hashes` matching de URLs (estructura lista, activación diferida).
- Reglas de contenido difuso.
- Detección root/jailbreak y Play Integrity.
- Billing automático y administración web de organizaciones (proyecto separado).
- Segundo entorno (dev/prod) y CI/CD completo.
- Métricas de fase 2 (salud comunitaria detallada, falsos positivos detallados).
