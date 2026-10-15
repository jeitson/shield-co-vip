# 5. Inventario de integraciones

Catálogo de todas las conexiones del prototipo con el exterior: APIs, servicios, recursos remotos, APIs del navegador/dispositivo y dependencias. Se distingue entre lo **realmente usado** y lo **declarado pero inactivo**.

---

## 5.1 Integraciones de red / servicios externos

| Integración | Tipo | Dónde | Estado |
|-------------|------|-------|--------|
| **GAULA — `tel:165`** | Enlace telefónico | `ReportChannelsScreen` | ✅ Activo (abre dialer). Hoy intercepta el click y muestra un pseudo-modal. |
| **Portal SIC** `https://serviciosweb.sic.gov.co/reclamasindiligencia/` | Enlace externo | `ReportChannelsScreen` y modal SIC en `App.tsx` | ✅ Activo (`target=_blank`). |
| **Google Fonts (CSS)** | CDN de tipografías | `index.html` | ✅ Space Grotesk, Hanken Grotesk, JetBrains Mono. |
| **Material Symbols Outlined** | CDN de iconos | `index.html` | ✅ Toda la iconografía depende de esta fuente remota. |
| **Imágenes `lh3.googleusercontent.com`** | Recursos remotos | `LoginScreen`, `RegisterScreen`, `LiveSimulatorScreen` | ✅ Fondos/wallpaper. Son URLs de AI Studio; pueden caducar. |
| **Backend propio / API REST** | Servidor | — | ❌ No existe. |
| **Gemini API** | IA | Declarada en `metadata.json` y `.env.example` | ❌ No se invoca en el código. |

> ⚠️ **Dependencia de CDN:** iconos y tipografías se cargan desde internet. Sin conexión, la UI pierde todos los iconos (Material Symbols) y cae a fuentes del sistema. En Flutter deben empaquetarse como assets locales.

---

## 5.2 APIs del navegador / dispositivo

| API | Uso | Dónde | Estado |
|-----|-----|-------|--------|
| `navigator.clipboard.writeText` | Copiar evidencia SIC | `App.tsx` (modal), `ReportChannelsScreen` | ✅ Usada. Sin manejo robusto de fallo en el modal. |
| `window.alert` | Mensaje "olvidé mi clave" | `LoginScreen` | 🟡 Placeholder. |
| `tel:` scheme | Llamar al 165 | `ReportChannelsScreen` | ✅ |
| `Date` (reloj/sync) | Timestamps simulados | `ShieldScreen`, `ReportChannelsScreen` | 🟡 |
| `Math.random` | Hash falso / incremento de contador | `App.tsx`, `ShieldScreen` | 🟡 Simulación. |

**Ausentes y necesarias en producción:** permisos de llamada/SMS, notificaciones, almacenamiento persistente (localStorage/IndexedDB en web; SQLite/secure storage en Flutter). Ver §4.5 de la especificación funcional.

---

## 5.3 Dependencias de `package.json`

### Usadas (runtime)
| Paquete | Uso real |
|---------|----------|
| `react`, `react-dom` | Núcleo de la app. |
| `vite`, `@vitejs/plugin-react` | Build/dev server. |
| `@tailwindcss/vite`, `tailwindcss` | Estilos. |
| `autoprefixer` | PostCSS (toolchain Tailwind). |

### Declaradas pero NO usadas (deuda / ruido)
| Paquete | Observación |
|---------|-------------|
| `@google/genai` | Para Gemini. Ningún `import` en el código. Coherente con `metadata.json`, pero muerto. |
| `motion` (Framer Motion) | No se importa. Las animaciones usan CSS (`index.css`) y clases Tailwind (`animate-ping`, etc.). |
| `express` | Servidor Node. No hay `server.js` activo (el script `clean` lo borra). Residuo del scaffolding de AI Studio. |
| `dotenv` | No se importa en el cliente. |
| `lucide-react` | Librería de iconos. No se usa; los iconos son Material Symbols vía CDN. |

### DevDependencies notables
`typescript` (`^7.0.2`), `@types/*`, `esbuild`, `tsx`. El script `lint` es `tsc --noEmit` (chequeo de tipos, no linter real como ESLint).

> **Recomendación:** eliminar `@google/genai`, `motion`, `express`, `dotenv`, `lucide-react` del `package.json` o integrarlas. Reducen claridad y aumentan superficie de supply chain sin aportar.

---

## 5.4 Variables de entorno (`.env.example`)

| Variable | Propósito declarado | Uso real |
|----------|---------------------|----------|
| `GEMINI_API_KEY` | Clave Gemini (inyectada por AI Studio) | ❌ No referenciada en el código. |
| `APP_URL` | URL de hosting (self-reference, OAuth, callbacks) | ❌ No referenciada. |

Ambas son parte del andamiaje de AI Studio. No hay OAuth ni callbacks implementados.

---

## 5.5 Configuración de capacidades (`metadata.json`)

```json
{
  "requestFramePermissions": [],
  "majorCapabilities": ["MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API"]
}
```

- `requestFramePermissions: []` → el prototipo **no** solicita permisos. Incompatible con la propuesta de valor real (interceptar llamadas/SMS) — debe diseñarse al portar.
- `MAJOR_CAPABILITY_SERVER_SIDE_GEMINI_API` → declara acceso a Gemini del lado servidor, **no utilizado**.

---

## 5.6 Resumen de integraciones a construir para producción

1. **Backend de autenticación** (login, registro, OTP, recuperación, sesión).
2. **Servicio de reputación comunitaria** (reportar/consultar números).
3. **Servicio de distribución de firmas** (dataset de hashes + sync incremental).
4. **Integración nativa de interceptación** (CallScreening/CallKit, SMS filter) — es el núcleo técnico real, hoy inexistente.
5. **Notificaciones push** (para la heads-up que el simulador emula).
6. **Persistencia local** (listas, config, historial).
7. **Empaquetado local de iconos y fuentes** (quitar dependencia de CDN).
