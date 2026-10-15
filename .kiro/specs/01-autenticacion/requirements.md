# Spec · 01 Autenticación — Requerimientos

> Flujo de pantallas **login** y **register** de Cifrado Cero.
> Fuente de negocio: [`02-business/01-autenticacion`](../../../02-business/01-autenticacion/01-autenticacion.md) y [`00-fundamentos`](../../../02-business/00-fundamentos/00-modelo-dominio.md).
> Arquitectura: [`03-architecture`](../../../03-architecture/) (DA-04, DA-07, DA-11, DA-13, DA-14).
> Referencia visual: `app_desing/src/components/screens/LoginScreen.tsx` y `RegisterScreen.tsx` + [design system](../../../01-docs/06-design-system.md).

Esta spec es la primera de una serie; cada flujo de pantallas vivirá en su propia carpeta `.kiro/specs/NN-<nombre>/` espejando la numeración de `02-business/`.

---

## 1. Introducción

La autenticación es la puerta de entrada obligatoria de la app (**DN-02**: no hay modo invitado). Debe:

- Permitir **iniciar sesión** con identificador/correo + clave maestra, con gate de consentimiento.
- Permitir **crear cuenta** (nombre, apellido, correo, contraseña ≥ 8, celular CO +57 fijo), con gate de consentimiento.
- Mantener la **sesión persistente** de forma segura entre reinicios (**RF-LOGIN-07**, DA-04).
- Modelar explícitamente los cuatro estados de operación asíncrona: cargando / éxito / error / vacío (`00-fundamentos` §00.5).
- Eliminar la deuda del prototipo: nada de credenciales pre-rellenadas (**RN-LOGIN-02**), nada de éxito simulado.

**Alcance MVP:** validación por email (DA-04). **OTP de celular queda fuera del MVP** (diseñado, no implementado) — el prefijo +57 es fijo pero no se verifica por SMS en esta fase.

---

## 2. Requerimientos

### R1 · Iniciar sesión con credenciales
**Historia:** como usuario registrado, quiero acceder con mi identificador/correo y clave para recuperar mi configuración y listas.

Criterios de aceptación (EARS):
1. CUANDO el usuario abre la app sin sesión, EL SISTEMA DEBERÁ mostrar la pantalla de login como arranque (DN-02).
2. CUANDO el usuario escribe en el campo de clave y pulsa el icono de visibilidad, EL SISTEMA DEBERÁ alternar entre texto plano y oculto (RF-LOGIN-02 / CA-LOGIN-04).
3. MIENTRAS alguno de los dos checkboxes de consentimiento esté sin marcar, EL SISTEMA DEBERÁ mantener deshabilitado el botón "Iniciar Sesión" (RN-LOGIN-01 / CA-LOGIN-01).
4. CUANDO el usuario envía con ambos consentimientos y credenciales válidas, EL SISTEMA DEBERÁ mostrar el estado "Descifrando Enclave…", autenticar contra el backend y navegar al Dashboard (RF-LOGIN-04 / CA-LOGIN-02).
5. SI las credenciales son inválidas o la cuenta no existe/está bloqueada, EL SISTEMA DEBERÁ mostrar un mensaje de error comprensible y mantener los campos editables sin navegar (RF-LOGIN-06 / CA-LOGIN-03).
6. SI no hay conexión, EL SISTEMA DEBERÁ mostrar un error de red con opción de reintentar (CA-LOGIN-06).
7. CUANDO el usuario pulsa "Regístrate", EL SISTEMA DEBERÁ navegar a la pantalla de registro (CA-LOGIN-05).
8. CUANDO el usuario pulsa "¿Olvidaste tu clave?", EL SISTEMA DEBERÁ iniciar el flujo de recuperación estándar por email (DA-04 / `02-seguridad` §02.4). *(En esta fase: informar que la recuperación es por email; el envío real se cablea cuando el backend esté disponible.)*

### R2 · Crear cuenta
**Historia:** como persona nueva, quiero registrar una cuenta para empezar a usar el blindaje.

Criterios de aceptación (EARS):
1. CUANDO algún campo obligatorio está vacío, EL SISTEMA DEBERÁ bloquear el envío y señalar el campo faltante (CA-REG-01).
2. CUANDO la contraseña tiene menos de 8 caracteres, EL SISTEMA DEBERÁ mostrar el aviso de longitud mínima y no enviar (RN-REG-02 / CA-REG-02).
3. CUANDO el correo tiene formato inválido, EL SISTEMA DEBERÁ mostrar un error de formato (RF-REG-05 / CA-REG-04).
4. CUANDO el celular no es un móvil CO válido (10 dígitos iniciando en 3), EL SISTEMA DEBERÁ mostrar un error de formato (RN-REG-04).
5. MIENTRAS alguno de los dos checkboxes esté sin marcar, EL SISTEMA DEBERÁ mantener deshabilitado "Crear cuenta" (RN-REG-03 / CA-REG-03).
6. EL SISTEMA DEBERÁ mostrar el prefijo **+57 fijo y no editable** (RF-REG-02 / CA-REG-07).
7. CUANDO el registro es válido, EL SISTEMA DEBERÁ mostrar "Blindando Identidad…", luego "Identidad Generada", crear la cuenta en el backend y, dado que la confirmación de correo es obligatoria (R7), mostrar el aviso de "revisa tu correo" y redirigir al login (RF-REG-08 / CA-REG-06, ajustado por R7).
8. SI el correo o celular ya existen, EL SISTEMA DEBERÁ mostrar "ya existe una cuenta" sin crear duplicado (RF-REG-07 / CA-REG-05).
9. CUANDO el usuario pulsa "Inicia sesión", EL SISTEMA DEBERÁ navegar a la pantalla de login.

### R7 · Confirmación de correo obligatoria (DECISIÓN CONFIRMADA)
**Historia:** como producto, exijo que el correo esté verificado antes de permitir el acceso, para garantizar que la cuenta pertenece a un correo real y controlado por el usuario.

> **[DECIDIDO]** La verificación de correo es **obligatoria**: ninguna cuenta puede iniciar sesión sin haber confirmado su correo. Esto corrige el estado abierto previo (`RN-LOGIN-02`/config) y queda como regla firme de negocio. La confirmación se mantiene **activada** en el proyecto Supabase (Authentication → Providers → Email → "Confirm email").

Reglas de negocio:
- **RN-LOGIN-04 · Verificación obligatoria.** El acceso requiere correo confirmado. Un intento de login con cuenta no confirmada **no** abre sesión.
- **RN-REG-05 · Alta en dos pasos.** El registro crea la cuenta pero **no** abre sesión; deja la cuenta en estado "pendiente de confirmación" hasta que el usuario use el enlace del correo.

Criterios de aceptación (EARS):
1. CUANDO el usuario completa un registro válido, EL SISTEMA DEBERÁ crear la cuenta, mostrar un aviso de éxito ("te enviamos un correo para confirmar") y redirigir al login **sin** abrir sesión.
2. CUANDO el usuario intenta iniciar sesión con una cuenta **no confirmada**, EL SISTEMA DEBERÁ bloquear el acceso y mostrar un mensaje claro indicando que debe confirmar su correo, ofreciendo **reenviar** el correo de confirmación.
3. CUANDO el usuario solicita reenviar la confirmación, EL SISTEMA DEBERÁ pedir/usar su correo y disparar el reenvío, mostrando un aviso neutro de "si la cuenta existe y está sin confirmar, enviamos el enlace".
4. CUANDO el usuario confirma su correo (enlace) e inicia sesión, EL SISTEMA DEBERÁ permitir el acceso normal y navegar al Dashboard.
5. EL SISTEMA DEBERÁ usar una plantilla de correo con la marca Cifrado Cero en es-CO (configurada en el panel de Supabase).

### R3 · Sesión persistente y guard de navegación
**Historia:** como usuario autenticado, quiero no re-teclear mi clave en cada arranque, y que las pantallas internas estén protegidas.

Criterios de aceptación (EARS):
1. CUANDO el login/registro es exitoso, EL SISTEMA DEBERÁ guardar los tokens de sesión en almacenamiento seguro (RF-LOGIN-07 / DA-14).
2. CUANDO la app arranca con una sesión válida almacenada, EL SISTEMA DEBERÁ restaurarla y abrir directamente el Dashboard sin pedir credenciales.
3. MIENTRAS el estado de sesión aún no se resuelve (lectura de secure storage), EL SISTEMA DEBERÁ mostrar un estado de carga neutro sin parpadeo hacia login.
4. SI no hay sesión, EL SISTEMA DEBERÁ redirigir cualquier ruta interna a login (guard, DN-02).
5. CUANDO el usuario cierra sesión, EL SISTEMA DEBERÁ borrar el material de sesión y volver a login.

### R4 · Fidelidad visual y accesibilidad
**Historia:** como usuario, quiero una experiencia visual coherente con la identidad "táctica/forense" de la marca.

Criterios de aceptación (EARS):
1. EL SISTEMA DEBERÁ usar exclusivamente los tokens de `core/theme` (colores, tipografía, radios, espaciado); nada hardcodeado (design system §6.8).
2. EL SISTEMA DEBERÁ reproducir la jerarquía visual del prototipo: marca + icono, campos con icono-afijo, checkboxes de consentimiento, botón primario cyan y enlace de cambio login↔registro.
3. EL SISTEMA DEBERÁ garantizar objetivos táctiles ≥ 48dp, labels asociados a cada campo y mensajes de error legibles por lectores de pantalla (no comunicar estado solo por color, §6.9).
4. EL SISTEMA DEBERÁ mostrar el banner "Garantía Absoluta" (no se accede a agenda/contactos) en registro (RN-01).

---

## 3. Fuera de alcance (esta spec)

- **OTP de celular** (RF-REG-06): diferido, DA-04 / memory bank §2.
- **Recuperación de clave real** por email: la UI inicia el flujo; el envío real depende del backend Supabase (se integra cuando exista el entorno).
- **Registro de dispositivo y exclusividad por número** (DA-03): pertenece al onboarding post-login (flujo `08-navegacion` / shield), no a estas dos pantallas. Esta spec deja el `AuthRepository` preparado para encadenarlo.
- **Certificate pinning** (DA-14): se añade sobre `ApiClient` en una tarea de hardening transversal.
