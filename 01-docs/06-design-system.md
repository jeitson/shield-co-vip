# 6. Design System

Tokens y patrones visuales extraídos directamente del código (`index.html`, `src/index.css` y las clases Tailwind usadas en los componentes). Dado que el objetivo es portar a Flutter, cada sección incluye una lectura orientada a `ThemeData`.

---

## 6.1 Fundamentos

- **Tema:** oscuro, único (el `<html>` fuerza `class="dark"`). No hay tema claro.
- **Idioma:** español (`lang="es"`), Colombia.
- **Densidad:** compacta, tipada "táctica/forense". Tamaños de fuente pequeños (10–17px predominan), bordes sutiles translúcidos, mucho uso de mono-espaciada para datos.
- **Forma general:** móvil-first dentro de un marco de 420px máx.

---

## 6.2 Color

Paleta extraída de los valores hex literales usados en el código.

### Superficies / fondos
| Token | Hex | Uso |
|-------|-----|-----|
| `bg/root` | `#0a0e15` | Fondo app más oscuro, inputs |
| `bg/surface` | `#0f131b` | Fondo del "dispositivo" / body |
| `bg/surface-1` | `#181c23` | Tarjetas |
| `bg/surface-2` | `#1c2027` | Tarjetas elevadas / filas |
| `bg/surface-3` | `#262a32` | Chips, botones secundarios |
| `bg/surface-4` | `#31353d` | Pistas de switch, divisores sólidos |
| `border/subtle` | `#3b494c` | Bordes (casi siempre con alpha `/20`–`/40`) |

### Acento / marca
| Token | Hex | Uso |
|-------|-----|-----|
| `accent/cyan` | `#00e5ff` | Acción primaria, foco, enlaces, activo |
| `accent/cyan-hover` | `#9cf0ff` | Hover de botón primario |
| `accent/cyan-2` | `#00daf3` | Estado intermedio (loading) |
| `accent/cyan-ink` | `#00363d` | Texto sobre fondo cyan |
| `accent/mint` | `#c3f5ff` | Marca / avatar / texto suave de acento |

### Semánticos
| Token | Hex | Significado |
|-------|-----|-------------|
| `success` | `#7dffa2` | Protegido / confiable / activo (nivel BAJO) |
| `success-strong` | `#05e777` | Éxito confirmado |
| `success-ink` | `#003918` | Texto sobre verde |
| `warning` | `#f59e0b` | Protección parcial / nivel MEDIO |
| `warning-amber` | `amber-400` (`#fbbf24`) | Variante de medio (Tailwind) |
| `danger` | `#ffb4ab` | Riesgo / nivel ALTO (texto e iconos) |
| `danger-strong` | `#93000a` | Fondo rojo profundo (lista negra, GAULA) |
| `danger-700` | `#b91c1c` / `#ba1a1a` | Hover de botón de peligro |
| `danger-600` | `#dc2626` | Botón "Reportar" en simulador |

### Texto
| Token | Hex | Uso |
|-------|-----|-----|
| `text/primary` | `#dfe2ed` | Texto principal |
| `text/secondary` | `#bac9cc` | Texto secundario / descripciones |
| `text/muted` | `#849396` | Texto terciario / placeholders / labels |

> **Mapeo de severidad (importante y recurrente):** `ALTO → #ffb4ab` (rojo), `MEDIO → #f59e0b/amber-400`, `BAJO → #7dffa2` (verde). Este trío gobierna glows, badges, iconos y bordes en `calls`, `shield`, `detail`, `simulator`.

> ⚠️ **Accesibilidad:** la severidad se comunica mayormente por color. Añadir texto/forma redundante para daltonismo. Varios textos secundarios sobre fondos oscuros rozan el mínimo de contraste; verificar WCAG AA en el port.

---

## 6.3 Tipografía

Definida en `index.css` como variables y cargada desde Google Fonts.

| Rol | Familia | Variable CSS / clase | Uso |
|-----|---------|----------------------|-----|
| Headline | **Space Grotesk** | `--font-headline` / `.font-headline` | Títulos, valores de métrica, botones |
| Body | **Hanken Grotesk** | `--font-body` / `.font-body` | Texto corrido, descripciones |
| Mono | **JetBrains Mono** | `--font-mono` / `.font-mono` | Números, labels en mayúsculas, datos técnicos, badges |

**Escala observada (px):** 9, 10, 11, 12, 13, 14, 15, 16, 17, 20, 22, 24, 38 (reloj del simulador). Pesos: `font-medium`, `font-semibold`, `font-bold`. Tracking frecuente: `tracking-wide`, `tracking-wider`, `tracking-tight` y mayúsculas (`uppercase`) en labels mono.

---

## 6.4 Iconografía

- **Material Symbols Outlined** (CDN). Configurada en `index.css` con `font-feature-settings: 'liga'`.
- Variación de relleno vía estilo inline `fontVariationSettings: "'FILL' 1"` (ítem activo de BottomNav, algunos iconos de énfasis).
- Iconos recurrentes: `shield`, `lock`, `verified_user`, `warning`, `policy`, `gavel`, `block`, `call`, `sms`, `phone_disabled`, `sync`, `fingerprint`, `local_police`.
- **No usa** `lucide-react` (declarado pero inactivo).

> Para Flutter: Material Symbols no es idéntico a `Icons` de Material. Empaquetar la fuente variable de Material Symbols como asset o mapear a los iconos equivalentes.

---

## 6.5 Forma, espaciado y elevación

| Token | Valor | Uso |
|-------|-------|-----|
| Radio chips/badges | `rounded` / `rounded-md` / `rounded-full` | Píldoras, switches |
| Radio tarjetas | `rounded-xl` (12px) | Mayoría de tarjetas |
| Radio tarjetas grandes | `rounded-2xl` (16px) | Tarjetas destacadas, modal |
| Radio del "dispositivo" | `rounded-[40px]` | Marco emulador |
| Padding tarjeta | `p-3` / `p-4` | Interior de tarjetas |
| Gap de columnas | `gap-2` / `gap-3` / `gap-4` | Separación vertical de secciones |
| Sombra | `shadow-sm` → `shadow-2xl` | Elevación por jerarquía |
| Glow | `shadow-[0_0_10px_<color>]`, `blur-2xl/3xl` | Resplandor semántico (severidad/estado) |
| Blur de fondo | `backdrop-blur-xl` | Headers, nav, modal |

Bordes casi siempre translúcidos: `border-[#3b494c]/20` a `/60`, o color semántico con alpha (`border-[#ffb4ab]/30`).

---

## 6.6 Animaciones

Definidas en `index.css` y vía utilidades Tailwind:

| Nombre | Fuente | Uso |
|--------|--------|-----|
| `radar-ping` / `.animate-radar` | `index.css` (keyframes) | Anillo radar del escudo |
| `animate-ping` | Tailwind | Anillos pulsantes, indicadores |
| `animate-pulse` | Tailwind | Puntos de estado "vivo" |
| `animate-spin` | Tailwind | Spinners de loading |
| `animate-bounce` | Tailwind | Toast de `calls` |
| `animate-fadeIn` / `animate-slideDown` | *referenciadas pero no definidas en `index.css`* | Entradas de pantalla/notificación |

> ⚠️ `animate-fadeIn` y `animate-slideDown` se usan en casi todas las pantallas pero **no están definidas** en `index.css` ni como utilidades de Tailwind v4 por defecto. Probablemente no animan hoy (clase inexistente). Definirlas o eliminarlas.

> Nota: la librería `motion` está instalada pero no se usa; las animaciones son CSS puro.

---

## 6.7 Componentes de estilo (referencia rápida de clases)

**Botón primario**
```
bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d] font-headline font-bold
rounded-xl active:scale-[0.98] transition-all
```

**Botón secundario**
```
bg-[#262a32] hover:bg-[#31353d] text-[#dfe2ed] rounded-xl border border-[#3b494c]/40
```

**Botón de peligro**
```
bg-[#93000a] hover:bg-[#ba1a1a] text-white rounded-xl
```

**Input**
```
bg-[#0a0e15] border border-[#3b494c]/30 rounded-xl text-[#dfe2ed]
placeholder:text-[#849396]/60 focus:outline-none focus:border-[#00e5ff]
```

**Switch (encendido / apagado)**
```
on:  bg-[#7dffa2]   ·   off: bg-[#31353d]   ·   thumb: bg-[#0a0e15]
```

**Badge de nivel**
```
ALTO:  bg-[#93000a]/30 text-[#ffb4ab]
MEDIO: bg-amber-400/10 text-amber-400
BAJO:  bg-[#7dffa2]/15 text-[#7dffa2]
```

---

## 6.8 Guía de port a Flutter (ThemeData)

```dart
// Colores base
const bgRoot      = Color(0xFF0A0E15);
const bgSurface   = Color(0xFF0F131B);
const surface1    = Color(0xFF181C23);
const surface2    = Color(0xFF1C2027);
const accentCyan  = Color(0xFF00E5FF);
const success     = Color(0xFF7DFFA2);
const warning     = Color(0xFFF59E0B);
const danger      = Color(0xFFFFB4AB);
const textPrimary = Color(0xFFDFE2ED);
const textSecondary = Color(0xFFBAC9CC);
const textMuted   = Color(0xFF849396);
```

- `ThemeData.brightness = Brightness.dark`.
- Tres `TextTheme` por familia: Space Grotesk (display/title), Hanken Grotesk (body), JetBrains Mono (label/data) — vía `google_fonts` o assets locales.
- Radios: `BorderRadius.circular(12)` tarjetas, `16` destacadas, `999` píldoras.
- Definir un `enum ThreatLevel` con su color asociado para no repetir el ternario de severidad.
- Reemplazar el "chrome" de emulador por el shell real de la app.
- Empaquetar Material Symbols y las fuentes como assets (no CDN) para funcionar offline.

---

## 6.9 Inconsistencias detectadas (a resolver en el sistema)

1. `amber-400` (Tailwind) y `#f59e0b` se usan indistintamente para "MEDIO". Unificar a un solo token.
2. Switch con dos tamaños/implementaciones (`ShieldScreen` vs `AdvancedScreen`), uno sin accesibilidad.
3. `animate-fadeIn` / `animate-slideDown` referenciadas sin definición.
4. Lógica/plantilla de evidencia SIC duplicada con textos distintos.
5. Dependencia de iconos y tipografías remotas (riesgo offline).
6. Severidad comunicada solo por color (riesgo de accesibilidad).
