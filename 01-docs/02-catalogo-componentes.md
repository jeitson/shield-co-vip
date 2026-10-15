# 2. Catálogo de componentes

El prototipo tiene pocos componentes reutilizables formales. La mayor parte de la UI se compone con elementos inline (botones, switches, tarjetas) repetidos en cada pantalla con clases Tailwind. Esta tabla separa **componentes React reales** de **patrones de UI recurrentes** que, al portar a Flutter, deberían extraerse como widgets.

## 2.1 Componentes React (archivos)

| Componente | Archivo | Reutilizable | Props |
|------------|---------|:---:|-------|
| `App` | `App.tsx` | Raíz | — (contiene todo el estado global) |
| `Header` | `components/Header.tsx` | ✅ | `activeScreen`, `onNavigate`, `onBack?`, `activeCount` |
| `BottomNav` | `components/BottomNav.tsx` | ✅ | `activeScreen`, `onNavigate` |
| `ShieldScreen` | `components/screens/ShieldScreen.tsx` | Pantalla | `config`, `onToggle`, `onNavigateToSimulator` |
| `CallsScreen` | `components/screens/CallsScreen.tsx` | Pantalla | `events`, `onSelectEvent`, `onToggleTrust`, `onToggleBlacklist`, `onExportSicReport` |
| `RecordDetailScreen` | `components/screens/RecordDetailScreen.tsx` | Pantalla | `event?`, `onBack`, `onBlockAndReport`, `onBlockLocal` |
| `ReportChannelsScreen` | `components/screens/ReportChannelsScreen.tsx` | Pantalla | — |
| `LiveSimulatorScreen` | `components/screens/LiveSimulatorScreen.tsx` | Pantalla | — |
| `LoginScreen` | `components/screens/LoginScreen.tsx` | Pantalla | `onSuccess`, `onGoToRegister` |
| `RegisterScreen` | `components/screens/RegisterScreen.tsx` | Pantalla | `onSuccess`, `onGoToLogin` |
| `AdvancedScreen` | `components/screens/AdvancedScreen.tsx` | Pantalla | 9 props (ver inventario de pantallas) |

### `Header` — 3 variantes internas

Renderiza condicionalmente según `activeScreen`:

1. **Detalle** (`detail`): botón "Volver" + título "Detalle De Registro" + avatar.
2. **Auth** (`login` / `register`): botón "Volver al Escudo" + indicador "ENCLAVE SEGURO".
3. **Estándar** (resto): indicador de estado (verde/ámbar/rojo según `activeCount`), título "Shield Dashboard", botón simulador + avatar.

El avatar navega a `login`. El indicador de color refleja: 3 activos = verde "Blindaje Activo", 1-2 = ámbar "Blindaje Parcial", 0 = rojo "Blindaje Desactivado".

### `BottomNav`

4 ítems: Escudo (`shield`), Llamadas (`call`), Denunciar (`report`), Avanzados (`tune`). **Retorna `null`** (se oculta) en `login`, `register` y `detail`. El ítem activo cambia a cyan, rellena el icono (`FILL 1`) y muestra un punto indicador. `simulator` no tiene ítem propio en la barra.

---

## 2.2 Patrones de UI recurrentes (candidatos a widgets Flutter)

Estos no son componentes en el código, pero se repiten y deberían extraerse. Para cada uno se indica dónde aparece.

### Switch táctil (toggle)
- **Variante A (grande, 48px):** `ShieldScreen` — pista redondeada, `role="switch"`, `aria-checked`, verde al activar. 3 instancias.
- **Variante B (pequeña, 40px):** `AdvancedScreen` — mismo patrón visual, sin `role`/`aria`. 2 instancias.
- ⚠️ Inconsistencia de accesibilidad: la variante B no expone semántica de switch.

### Tarjeta de métrica / telemetría
- `CallsScreen` (3 micro-tarjetas bento), `ShieldScreen` (hashes + sync). Fondo `#181c23`, borde sutil, label mono en mayúsculas + valor grande headline.

### Chip de filtro
- `CallsScreen` (Todos/Llamadas/SMS/Alto/Medio/Bajo). Píldora redondeada, activo en cyan o color de severidad.

### Tarjeta de evento interceptado
- `CallsScreen` (lista). Glow lateral de severidad, icono por tipo/nivel, badges (nivel, CONFIABLE, BLOQUEADO), banner de diagnóstico, preview de cuarentena, barra de acciones.

### Pestañas segmentadas (segmented control)
- `ReportChannelsScreen` (GAULA/SIC), `LiveSimulatorScreen` (Llamada/SMS), `RecordDetailScreen` (vector Llamada/SMS). Mismo patrón: contenedor con 2 botones, activo resaltado.

### Botón primario de acción con estados
- Patrón idle → loading (spinner) → success. Aparece en `RecordDetailScreen`, `LoginScreen`, `RegisterScreen`. Cambia color (cyan → cian intermedio → verde) y texto/icono.

### Banner de advertencia / consecuencia
- `ShieldScreen` (al desactivar cada capa), `RecordDetailScreen` (enlace peligroso). Fondo tintado por severidad, icono + título + descripción.

### Campo de entrada (input)
- Patrón: contenedor redondeado `#0a0e15`, icono prefijo, foco con borde cyan. Usado en login, register, advanced, calls (buscador), detail (nota).

### Toast / feedback efímero
- `CallsScreen` (`toastMessage`), `LiveSimulatorScreen` (`toastFeedback`). Auto-descartado por `setTimeout`. No hay un componente Toast compartido.

### Modal
- Único modal real: **Export SIC** en `App.tsx` (overlay full-screen con backdrop blur). `ReportChannelsScreen` y `LiveSimulatorScreen` usan "pseudo-modales" inline (no overlays).

### Empty state
- Solo existe uno: `CallsScreen` cuando el filtro no arroja resultados. **No hay empty state** en listas de `advanced`.

---

## 2.3 Modelo de datos / tipos (`src/types/index.ts`)

| Tipo | Definición | Uso |
|------|-----------|-----|
| `ThreatLevel` | `'ALTO' \| 'MEDIO' \| 'BAJO'` | Severidad del evento |
| `EventType` | `'call' \| 'sms'` | Tipo de interceptación |
| `InterceptedEvent` | objeto (ver abajo) | Entidad central de la app |
| `ShieldConfig` | `{ extorsion, callcenter, ley: boolean }` | Capas de protección |
| `ActiveScreen` | union de 8 strings | Pantalla activa |

**`InterceptedEvent`:**
```ts
{
  id: string;
  sender: string;
  type: EventType;
  level: ThreatLevel;
  timestamp: string;        // texto libre: "Hoy, 14:25" — no es Date
  threatTitle: string;
  reputationTag: string;
  diagnosis: string;
  quarantinedContent?: string;
  isTrusted?: boolean;
  isBlacklisted?: boolean;
  details?: { location?, duration?, carrier?, attempts? };
}
```

**Observaciones para producción:**
- `timestamp` es string libre, no `DateTime`. Impide ordenar/filtrar por fecha real.
- No hay tipo para `User`, `Session`, `SicReport`, `Rule` ni respuestas de API.
- `details.attempts` es numérico pero no se muestra en ninguna pantalla.
