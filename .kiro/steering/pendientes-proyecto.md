---
inclusion: always
---

# Memory Bank — Pendientes del proyecto Cifrado Cero

Registro vivo de pendientes, decisiones diferidas y trabajo fuera del alcance actual (MVP). Mantener actualizado conforme se cierren o aparezcan pendientes. La arquitectura detallada vive en `03-architecture/`.

> **Convención:** marcar `[ ]` pendiente, `[x]` hecho. Referenciar la decisión relacionada con `[DA-xx]` / `[DN-xx]` cuando aplique.

---

## 1. Plataforma iOS (fase futura)

- [ ] Implementar `BlockingEngine` para iOS con **Call Directory Extension** (lista precargada de números a bloquear/identificar). [DA-12]
- [ ] Implementar **Message Filter Extension** (IdentityLookup) para SMS de remitentes desconocidos. [DA-12]
- [ ] Diseñar el **empuje de la lista de hashes** a las extensiones iOS (límites de tamaño de Call Directory). [DA-12]
- [ ] Preparar diagrama de onboarding de permisos/extensiones iOS (equivalente al de Android en `04-app-flutter.md` §04.5). **Explícitamente pospuesto a pedido del usuario.**
- [ ] `BGTaskScheduler` para el sync en background en iOS (con sus límites). [DA-08]
- [ ] Flavor/target iOS en el proyecto Flutter.
- [ ] Comunicar en UI la **ausencia de paridad de interceptación** iOS vs Android (modo "proveedor de listas").

## 2. Autenticación y cuenta

- [ ] **OTP de verificación de celular** en registro (diseñado, no implementado en MVP). Definir proveedor SMS (Twilio u otro) y costo. [DA-04]
- [ ] Confirmar **política de contraseñas** (hoy solo longitud ≥ 8; evaluar robustez: mayúscula/número/símbolo + 2FA opcional). Pregunta abierta de `01-autenticacion.md`.
- [ ] Confirmar **alcance geográfico** (hoy +57 fijo; ¿multi-país a futuro?). RN-REG-01.

## 3. Dataset de bloqueo

- [ ] Activar **`domain_hashes`**: extracción de URL/dominio en SMS + matching. Estructura ya diseñada; activación diferida. [DA-06]
- [ ] **Reglas de contenido difuso** (`content_rules`): keywords/patrones locales. Fase futura. [DA-06]

## 4. Seguridad (hardening diferido)

- [ ] **Detección de root/jailbreak** (modelo "detectar y advertir"). Fuera del MVP. [DA-14]
- [ ] **Play Integrity attestation** (app/dispositivo genuino). Fuera del MVP. [DA-14]
- [ ] Documento de **modelo de amenazas formal (STRIDE)** — propuesto, aún no elaborado.
- [ ] Definir **procedimiento operativo de rotación de pepper** (hoy diseñado a nivel de versión; falta runbook). [DA-05]

## 5. Métricas (fase 2)

- [ ] Salud comunitaria detallada (reportes/día, % promovidos). [DA-01]
- [ ] Cobertura global vs. local. [DA-01]
- [ ] % escudo total/parcial/desactivado (usa RN-03). [DA-01]
- [ ] Opt-in rate de telemetría. [DA-01]
- [ ] **Falsos positivos** como contador agregado anónimo (opt-in, nunca el número). [DA-01]

## 6. Backend y operación

- [ ] **Segundo entorno** (dev/staging + prod) con proyectos Supabase y peppers separados + flavors. Hoy un solo entorno. [DA-15]
- [ ] **CI/CD** completo (build Flutter por flavor, deploy de Edge Functions y migraciones, gate de compatibilidad de API). [DA-16]
- [ ] Confirmar **política de deprecación de versiones de API** (hoy sugerida: últimas 2 minor). [DA-15]
- [ ] Definir **calendario de festivos colombianos** para la Ley 2300 (fuente local empaquetada y/o actualizable). Pregunta abierta de `00-modelo-dominio.md` RN-08.

## 7. Fuera de alcance (otros proyectos)

- [ ] **Administración web** de organizaciones/allowlists (carga CSV/manual) — proyecto separado. [DA-10]
- [ ] **Billing** automático para exclusiones comerciales pagadas — proyecto separado. [DA-10]

---

## Pendientes recién añadidos (bandeja de entrada)

> Mover a la categoría correspondiente al procesarlos.

- [ ] (nada pendiente de clasificar)
