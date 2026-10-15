# 00 · Fundamentos — Modelo de dominio y reglas transversales

Define el vocabulario, las entidades y las reglas de negocio que aplican a **toda** la aplicación. El resto de documentos se apoya en esto y no vuelve a repetir estas definiciones.

---

## 00.1 Propuesta de valor

Cifrado Cero es un **filtro telefónico local** que intercepta y neutraliza llamadas y SMS maliciosos dirigidos a usuarios en Colombia:

- Extorsión (incluida la carcelaria).
- Phishing / vishing (suplantación bancaria por SMS o voz).
- Call centers molestos y discadores robóticos.
- Violaciones a la Ley 2300 de 2023 ("Dejen de Fregar"): contacto comercial fuera de la franja horaria legal.

Dos promesas de marca sostienen el producto y son **reglas de negocio**, no solo copy:

- **Privacidad "Zero-Knowledge" (RN-01):** ningún dato personal, agenda de contactos ni contenido sale del dispositivo sin consentimiento explícito. Los números peligrosos se guardan como **hashes** locales, no en texto plano.
- **Protección comunitaria (RN-02):** el usuario puede reportar un número de forma **anónima** para proteger a otros; el reporte nunca revela su identidad ni sus contactos.

> **[DECIDIDO · DN-01]** La "protección comunitaria" se implementa contra un **backend propio** (confirmado). El servicio recibe el reporte del número infractor de forma anónima. Para que sea compatible con "zero-knowledge", lo que se envía debe ser el hash del número y la categoría, nunca datos del denunciante. El **contrato de API concreto se define en el documento de arquitectura del sistema**; esta especificación solo fija el comportamiento funcional esperado.

---

## 00.2 Entidades del dominio

### EventoInterceptado

Representa una llamada o SMS que el motor interceptó.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|:---:|-------------|
| `id` | string | ✅ | Identificador único del evento. |
| `remitente` (`sender`) | string | ✅ | Número telefónico o código corto que originó el contacto. |
| `tipo` (`type`) | `llamada` \| `sms` | ✅ | Vector del evento. |
| `nivel` (`level`) | `ALTO` \| `MEDIO` \| `BAJO` | ✅ | Severidad de la amenaza. |
| `marcaTiempo` (`timestamp`) | fecha-hora | ✅ | Momento del evento. **[PROPUESTO]** debe ser fecha ISO 8601 real, no texto libre. |
| `tituloAmenaza` (`threatTitle`) | string | ✅ | Clasificación legible: "Extorsión Carcelaria", "Phishing Bancario SMS", etc. |
| `categoria` | enum | ✅ | **[PROPUESTO]** campo estructurado de categoría (ver RN-07). Sustituye la dependencia de texto. |
| `etiquetaReputacion` (`reputationTag`) | string | ✅ | Origen/razón de la detección: "VoIP no registrado", "Ley 2300 Aplicada". |
| `diagnostico` (`diagnosis`) | string | ✅ | Explicación de por qué se interceptó. |
| `contenidoCuarentena` (`quarantinedContent`) | string | ❌ | Texto del SMS aislado (solo para `sms`). |
| `esConfiable` (`isTrusted`) | bool | ❌ | El usuario marcó el número como de confianza. |
| `enListaNegra` (`isBlacklisted`) | bool | ❌ | El usuario bloqueó el número. |
| `detalles` (`details`) | objeto | ❌ | Metadatos forenses: `ubicacion`, `duracion`, `operador`, `intentos`. |

### ConfigEscudo

Las tres capas de protección activables.

| Campo | Tipo | Defecto | Descripción |
|-------|------|:---:|-------------|
| `extorsion` | bool | `true` | Capa anti-extorsión (crítica). |
| `callcenter` | bool | `true` | Capa anti call center / spam. |
| `ley` | bool | `true` | Capa de cumplimiento Ley 2300. |

### NumeroListado

Número en una lista local del usuario.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `numero` | string | Número en formato canónico (ver RN-04). |
| `lista` | `confianza` \| `negra` | A qué lista pertenece. |
| `origen` | enum | **[PROPUESTO]** cómo entró: manual, desde evento, desde simulador. |

### Usuario / Sesión

> **[DECIDIDO · DN-02]** El login es obligatorio, por lo que `Usuario` y `Sesión` son entidades de primer orden (no opcionales). El prototipo solo tiene campos de formulario; el modelo definitivo (incluido el esquema de sesión/token) se detalla con el backend en la arquitectura. Modelo funcional mínimo:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | string | Identificador de la cuenta. |
| `correo` | string | Correo de acceso. |
| `nombre`, `apellido` | string | Datos de perfil. |
| `celular` | string | Celular con prefijo +57 (ver 01-autenticación). |
| `terminosAceptados` | bool | Consentimiento de T&C. |
| `privacidadAceptada` | bool | Consentimiento de política de privacidad. |

---

## 00.3 Reglas de negocio transversales

### RN-01 · Privacidad Zero-Knowledge
Ningún registro, número, contenido de mensaje ni dato de contacto puede salir del dispositivo salvo:
- Un reporte comunitario explícito (y aun así, solo el hash del número infractor, nunca datos del usuario).
- Lo que el usuario copie o exporte manualmente (evidencia SIC).

### RN-02 · Reporte comunitario anónimo
Reportar un número a la comunidad nunca transmite la identidad del denunciante ni su agenda.

### RN-03 · Estado agregado del escudo
El estado global se deriva del número de capas activas (`N` de 3):

| Capas activas | Estado | Color semántico | Texto |
|:---:|--------|-----------------|-------|
| 3 | Total | verde (`#7dffa2`) | "Protección Total Activa" / "Blindaje Activo" |
| 1–2 | Parcial | ámbar (`#f59e0b`) | "Protección Parcial" / "Blindaje Parcial" |
| 0 | Riesgo | rojo (`#ffb4ab`) | "Protección Desactivada - En Riesgo" / "Blindaje Desactivado" |

Esta regla gobierna el indicador del Header, la barra de estado del Dashboard y el escudo del hero. **[PROTOTIPO]**

### RN-04 · Formato canónico de número
> **[PROPUESTO]** Todo número se normaliza a **E.164** (`+57` + 10 dígitos para móviles Colombia) antes de guardarse, compararse o deduplicarse. Los códigos cortos de SMS (p. ej. `890123`) se tratan como una categoría aparte y no se normalizan.
>
> Motivo: el prototipo compara strings exactos, por lo que `+57 300 123 4567` y `3001234567` se consideran distintos. Esto rompe la deduplicación y la exclusividad de listas.

### RN-05 · Exclusividad de listas
Un número **no puede** estar simultáneamente en la lista de confianza y en la lista negra. Marcarlo en una lo retira automáticamente de la otra. **[PROTOTIPO]**

### RN-06 · Precedencia de listas sobre el motor
> **[PROPUESTO]** Orden de evaluación para un contacto entrante:
> 1. Si el número está en **lista de confianza** → siempre pasa, sin importar las capas del escudo.
> 2. Si el número está en **lista negra** → siempre se bloquea.
> 3. En otro caso → aplican las capas activas del escudo y las reglas del motor.

### RN-07 · Categorías de amenaza
Catálogo cerrado de categorías (reemplaza la detección por texto del prototipo, que es frágil):

| Categoría | Nivel típico | Capa responsable |
|-----------|:---:|------------------|
| Extorsión / amenaza | ALTO | `extorsion` |
| Phishing / vishing (suplantación) | ALTO–MEDIO | `extorsion` |
| Call center / discador robótico | MEDIO | `callcenter` |
| Llamada fantasma / silenciosa | MEDIO–BAJO | `callcenter` |
| Violación franja Ley 2300 | BAJO | `ley` |
| Comercial sin riesgo | BAJO | `ley` / comunitario |

> **[PROPUESTO]** El prototipo decide si un evento es "SIC-exportable" buscando la palabra "Ley" en el título (RN frágil). La regla correcta: un evento es exportable a SIC si su `categoria == "Violación franja Ley 2300"`.

### RN-08 · Franja horaria legal (Ley 2300 de 2023)
Horario en que **sí** se permite contacto comercial/cobranza:

| Día | Franja permitida |
|-----|------------------|
| Lunes a viernes | 07:00 – 19:00 |
| Sábados | 08:00 – 15:00 |
| Domingos y festivos | Bloqueo total (24h) |

Fuera de esas franjas, la capa `ley` bloquea el contacto comercial. **[PROTOTIPO]** (como texto). El motor que la aplica es **[PROPUESTO]**.

> Pregunta abierta: el calendario de **festivos colombianos** debe venir de una fuente mantenida (local empaquetada y/o actualizable). Definir.

### RN-09 · Idioma y localización
La app es **español (Colombia)**. Fechas, horas y textos en es-CO. **[PROTOTIPO]**

---

## 00.4 Persistencia (transversal)

> **[PROPUESTO]** El prototipo mantiene todo en memoria y lo pierde al recargar. Producción debe persistir localmente:
> - `ConfigEscudo` (3 capas) y switches de reglas avanzadas.
> - Listas de confianza y negra.
> - Historial de eventos interceptados.
> - Sesión/credenciales (en almacenamiento seguro).
>
> Mecanismo sugerido para Flutter: almacenamiento seguro para credenciales/token + base local (SQLite/Isar) para eventos y listas.
>
> **[DECIDIDO · DN-01]** Existe backend. El reparto entre lo que vive **solo en el dispositivo** (coherente con RN-01) y lo que se **respalda/sincroniza en el servidor** (p. ej. cuenta, preferencias, firmas) se define en la arquitectura del sistema. Como principio funcional: el historial de eventos y las listas son, por defecto, locales; cualquier sincronización entre dispositivos debe preservar la privacidad (RN-01).

---

## 00.5 Estados genéricos de operación asíncrona

> **[PROPUESTO]** Toda operación que hoy el prototipo finge con `setTimeout` debe modelar cuatro estados: `cargando`, `éxito`, `error`, `vacío`. Cada documento especifica cuáles aplican. El prototipo solo implementa `cargando → éxito`; **error** y **vacío real** están ausentes y se definen aquí como obligatorios en producción.

---

## 00.6 Permisos del sistema (transversal y crítico)

La interceptación real depende de permisos del SO que el prototipo **no solicita**. **[PROPUESTO]** para producción:

| Permiso | Para qué | Si se niega |
|---------|----------|-------------|
| Rol de filtrado de llamadas (CallScreening Android / CallKit iOS) | Interceptar/rechazar llamadas | Degradar: avisar que la protección de llamadas está inactiva. |
| Rol de filtrado de SMS | Filtrar SMS | Degradar: protección SMS inactiva. |
| Notificaciones | Mostrar la alerta heads-up de interceptación | Interceptar en silencio sin notificar. |
| Teléfono (iniciar llamada) | Llamar al GAULA 165 | Mostrar el número para marcar manualmente. |
| Contactos | **No se solicita a propósito** (promesa de marca RN-01) | N/A |

Flujos de permiso **[PROPUESTO]** y obligatorios: solicitud en onboarding, pantalla de "permiso denegado" con enlace a ajustes del sistema, degradación funcional y re-solicitud.
