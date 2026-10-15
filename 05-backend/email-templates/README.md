# Plantillas de correo (Supabase Auth)

Plantillas de los correos transaccionales de autenticación, con la marca
Cifrado Cero en es-CO. **No se despliegan desde código**: se pegan a mano en el
panel de Supabase (Supabase gestiona las plantillas por proyecto, no por CLI).

> Confirmación de correo **obligatoria** (R7, `01-autenticacion`): sin confirmar
> el correo no se puede iniciar sesión.

---

## Archivos

| Archivo | Plantilla de Supabase | Estado |
|---------|-----------------------|:---:|
| `confirm-signup.html` | **Confirm signup** | lista para pegar |

(Se irán agregando `reset-password.html`, `magic-link.html`, etc. cuando se activen.)

---

## Cómo pegarla en el panel (paso a paso)

1. Entra al Dashboard de Supabase del proyecto `shield_co`.
2. Menú lateral: **Authentication**.
3. Submenú: **Emails** (en algunas versiones aparece como **Email Templates**).
4. Selecciona la pestaña **Confirm signup**.
5. **Subject (asunto):** pega exactamente:
   ```
   Confirma tu cuenta · Cifrado Cero
   ```
6. **Message body:** cambia el editor a modo **HTML** (o "Source") y pega el
   contenido completo de `confirm-signup.html`.
7. **Guardar** (botón *Save*).
8. Prueba: registra una cuenta desde la app y revisa el correo que llega.

### Variables que puedes usar (las rellena Supabase)

| Variable | Qué es |
|----------|--------|
| `{{ .ConfirmationURL }}` | Enlace de confirmación (ya usado en el botón). |
| `{{ .SiteURL }}` | URL del sitio configurada en Auth → URL Configuration. |
| `{{ .Email }}` | Correo del destinatario. |
| `{{ .Token }}` / `{{ .TokenHash }}` | Código/hash OTP (por si se usa confirmación por código). |

### Antes de probar: revisa la URL de redirección

En **Authentication → URL Configuration**:
- **Site URL:** la URL base a la que vuelve el enlace de confirmación.
- **Redirect URLs:** añade el esquema de la app para deep link si se usa
  (p. ej. `io.supabase.cifradocero://login-callback`, ya previsto en
  `config.toml`). Para el MVP, basta con que el enlace confirme la cuenta;
  tras confirmar, el usuario vuelve a la app y hace login.

---

## Recomendación para producción: SMTP propio

El correo compartido de Supabase tiene **límites bajos de envío** (unos pocos por
hora) y cae con facilidad en spam. Para producción, configura **SMTP propio** en
**Project Settings → Auth → SMTP Settings** con un proveedor como Resend,
SendGrid, Amazon SES o Postmark. Esto mejora entregabilidad y quita los límites.

> Las credenciales SMTP son **secretas**: van en el panel/entorno, nunca en el
> repo.
