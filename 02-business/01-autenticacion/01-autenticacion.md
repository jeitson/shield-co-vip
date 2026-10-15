# 01 · Autenticación — Acceso seguro y registro

**Pantallas:** `PANT-LOGIN` (Acceso seguro) y `PANT-REGISTER` (Crear cuenta)
**Depende de:** 00-fundamentos (RN-01 privacidad, modelo Usuario/Sesión)
**Componente del prototipo:** `LoginScreen.tsx`, `RegisterScreen.tsx`

> **[DECIDIDO · DN-02]** El **login es obligatorio**. La aplicación arranca en `login`; no existe modo invitado ni uso anónimo. Para usar cualquier pantalla interna (Dashboard, Registro, etc.) se requiere una sesión activa (guard de autenticación, ver 08-navegación). Esto corrige el comportamiento del prototipo, que abría directamente en el Dashboard sin sesión.
>
> **[DECIDIDO · DN-01]** La autenticación y el registro operan contra un **backend propio**; el contrato de API se define en la arquitectura del sistema.

---

## PANT-LOGIN · Acceso seguro

### Propósito
Permitir que un usuario registrado acceda a su cuenta y recupere la configuración/listas asociadas.

### Elementos de UI [PROTOTIPO]
- Marca "Cifrado Cero • Enclave Seguro" con icono.
- Campo **Identificador o Correo**.
- Campo **Clave Maestra** con botón de mostrar/ocultar.
- Enlace **"¿Olvidaste tu clave?"**.
- Checkbox **Acepto los Términos y Condiciones**.
- Checkbox **Entiendo que no se accede a mi agenda ni datos personales**.
- Botón **Iniciar Sesión**.
- Enlace **Regístrate**.

### Requisitos funcionales

- **RF-LOGIN-01 — Ingreso de credenciales.** El usuario ingresa identificador/correo y clave. [PROTOTIPO]
- **RF-LOGIN-02 — Mostrar/ocultar clave.** Alterna la visibilidad del campo de clave. [PROTOTIPO]
- **RF-LOGIN-03 — Gate de consentimiento.** El botón de ingreso no procede si no están marcados ambos checkboxes. [PROTOTIPO]
- **RF-LOGIN-04 — Autenticación real.** Validar credenciales contra el backend y abrir sesión. **[DECIDIDO · DN-01]** (hay backend; el prototipo simula éxito en ~1s sin validar y trae credenciales pre-rellenadas: ese comportamiento simulado debe eliminarse).
- **RF-LOGIN-07 — Sesión persistente.** Tras un login exitoso, mantener la sesión (token) de forma segura entre reinicios de la app, hasta su expiración o cierre de sesión. **[DECIDIDO · DN-02]** (detalle de token/expiración en arquitectura).
- **RF-LOGIN-05 — Recuperación de clave.** Flujo real de recuperación acorde a arquitectura zero-knowledge. **[PROPUESTO]** (hoy es un `alert` que explica que se requiere llave de respaldo local).
- **RF-LOGIN-06 — Manejo de errores.** Mostrar mensajes claros ante credenciales inválidas, cuenta inexistente/bloqueada o fallo de red. **[PROPUESTO]**

### Reglas de negocio

- **RN-LOGIN-01 · Consentimiento obligatorio.** No se permite iniciar sesión sin aceptar T&C y la nota de privacidad. [PROTOTIPO]
- **RN-LOGIN-02 · No pre-rellenar credenciales.** En producción los campos inician vacíos; está prohibido incluir credenciales de ejemplo embebidas. **[PROPUESTO]** (corrige deuda del prototipo).
- **RN-LOGIN-03 · Zero-Knowledge en recuperación.** Si la arquitectura es realmente ZK, el proveedor no puede restablecer la clave por sí mismo; se requiere la llave de respaldo del usuario. Negocio debe confirmar el modelo. **[PROPUESTO]**

### Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-LOGIN-01 | Inicial | Pantalla de arranque de la app (DN-02). Formulario vacío; botón habilitado solo si consentimientos marcados. | [PROPUESTO] (hoy pre-rellenado y no es la pantalla de arranque) |
| EST-LOGIN-02 | Enviando | Botón muestra spinner y texto "Descifrando Enclave…"; campos bloqueados. | [PROTOTIPO] |
| EST-LOGIN-03 | Éxito | Sesión abierta; navega al Dashboard. | [PROTOTIPO] |
| EST-LOGIN-04 | Error | Mensaje de error, campos editables, sin navegar. | [PROPUESTO] |

### Criterios de aceptación

- **CA-LOGIN-01.** Dado que **no** he marcado ambos checkboxes, cuando toco "Iniciar Sesión", entonces no ocurre nada (no se envía).
- **CA-LOGIN-02.** Dado que marqué ambos checkboxes e ingresé credenciales válidas, cuando toco "Iniciar Sesión", entonces veo el estado "Descifrando Enclave…" y luego accedo al Dashboard. **[PROPUESTO: validar contra backend]**
- **CA-LOGIN-03.** Dado que ingresé credenciales inválidas, cuando envío, entonces veo un mensaje de error comprensible y permanezco en la pantalla con los campos editables. **[PROPUESTO]**
- **CA-LOGIN-04.** Dado que toco el icono de visibilidad, cuando el campo estaba oculto, entonces la clave se muestra en texto, y viceversa.
- **CA-LOGIN-05.** Dado que toco "Regístrate", entonces navego a la pantalla de registro.
- **CA-LOGIN-06.** Dado que no hay conexión, cuando intento ingresar, entonces veo un error de red con opción de reintentar. **[PROPUESTO]**

---

## PANT-REGISTER · Crear cuenta

### Propósito
Registrar un nuevo usuario para empezar a usar el blindaje.

### Elementos de UI [PROTOTIPO]
- Banner "Garantía Absoluta": la app no recolecta agenda ni contactos.
- Campos: **Nombre***, **Apellido***, **Correo Electrónico***, **Contraseña*** (mín. 8), **Número Celular*** con prefijo **+57 bloqueado**.
- Mostrar/ocultar contraseña.
- Checkbox **Términos y Condiciones + Política de Cero Registros** (obligatorio).
- Checkbox **no accederá a mi agenda ni contactos** (obligatorio).
- Botón **Crear cuenta**.
- Enlace **Inicia sesión**.

### Requisitos funcionales

- **RF-REG-01 — Captura de datos.** Nombre, apellido, correo, contraseña y celular. [PROTOTIPO]
- **RF-REG-02 — Prefijo fijo +57.** El indicativo de país está bloqueado en +57 (Colombia) y no es editable. [PROTOTIPO]
- **RF-REG-03 — Longitud mínima de contraseña.** Mínimo 8 caracteres. [PROTOTIPO] (vía `minLength`).
- **RF-REG-04 — Gate de consentimiento.** No se envía sin ambos checkboxes. [PROTOTIPO]
- **RF-REG-05 — Validación de formato.** Validar correo bien formado y celular de 10 dígitos (móvil Colombia). **[PROPUESTO]** (hoy solo `type=email` básico).
- **RF-REG-06 — Verificación de celular (OTP).** Confirmar el celular por código. **[PROPUESTO]** (hoy el prefijo se marca "verificado" sin verificar).
- **RF-REG-07 — Unicidad.** Rechazar correo o celular ya registrados con mensaje claro. **[PROPUESTO]**
- **RF-REG-08 — Creación real de cuenta.** Persistir la cuenta en backend y abrir sesión. **[DECIDIDO · DN-01]** (hay backend; el prototipo solo simula 1.2s + 1.2s).

### Reglas de negocio

- **RN-REG-01 · Colombia-only (prefijo).** El registro asume usuarios colombianos: prefijo +57 fijo. Si el producto se abre a otros países, esta regla cambia. [PROTOTIPO] — confirmar alcance.
- **RN-REG-02 · Contraseña ≥ 8 caracteres.** [PROTOTIPO]. **[PROPUESTO]** reforzar con política de robustez (mayúscula/número/símbolo) — confirmar.
- **RN-REG-03 · Consentimientos obligatorios.** Ambos checkboxes son requisito legal de alta. [PROTOTIPO]
- **RN-REG-04 · Celular formato móvil CO.** 10 dígitos iniciando en 3. **[PROPUESTO]**

### Estados

| ID | Estado | Descripción | Madurez |
|----|--------|-------------|:---:|
| EST-REG-01 | Inicial | Formulario vacío; botón "Crear cuenta". | [PROTOTIPO] |
| EST-REG-02 | Enviando | Botón "Blindando Identidad…" con spinner. | [PROTOTIPO] |
| EST-REG-03 | Hecho | Botón "Identidad Generada" (verde); navega al Dashboard tras breve pausa. | [PROTOTIPO] |
| EST-REG-04 | Error de validación | Marca el campo inválido con mensaje. | [PROPUESTO] |
| EST-REG-05 | Error de servidor | Correo/celular duplicado o fallo de red. | [PROPUESTO] |

### Criterios de aceptación

- **CA-REG-01.** Dado un formulario con algún campo obligatorio vacío, cuando toco "Crear cuenta", entonces el envío se bloquea y se señala el campo faltante.
- **CA-REG-02.** Dado que la contraseña tiene menos de 8 caracteres, cuando intento enviar, entonces veo el aviso de longitud mínima y no se envía.
- **CA-REG-03.** Dado que no marqué ambos checkboxes, cuando toco "Crear cuenta", entonces no se envía.
- **CA-REG-04.** Dado un correo con formato inválido, cuando envío, entonces veo un error de formato. **[PROPUESTO]**
- **CA-REG-05.** Dado un correo o celular ya registrado, cuando envío, entonces veo "ya existe una cuenta" sin crear duplicado. **[PROPUESTO]**
- **CA-REG-06.** Dado un registro válido, cuando envío, entonces veo "Blindando Identidad…", luego "Identidad Generada", y finalmente accedo al Dashboard. **[PROPUESTO: tras OTP y creación real]**
- **CA-REG-07.** Dado el campo de celular, cuando intento cambiar el prefijo, entonces no es posible (fijo en +57).

---

## 01.6 Decisiones confirmadas y preguntas abiertas

**Confirmado:**
- **DN-02 · Login obligatorio.** La app exige cuenta; sin modo invitado. Arranque en `login` + guard de autenticación (ver 08).
- **DN-01 · Backend.** Login, registro y recuperación operan contra el backend; contrato en arquitectura.

**Preguntas abiertas:**
1. **Modelo de recuperación de clave** bajo zero-knowledge: ¿llave de respaldo local? ¿frase semilla? ¿qué pasa si el usuario la pierde?
2. **Verificación OTP** del celular: ¿SMS propio, proveedor externo? Costo e impacto en el flujo.
3. **Alcance geográfico:** ¿solo Colombia (+57 fijo) o multi-país?
4. **Política de contraseñas:** ¿solo longitud o robustez completa + 2FA opcional?
