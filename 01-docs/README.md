# Documentación — Cifrado Cero

Análisis de ingeniería inversa del prototipo de diseño **Cifrado Cero** (blindaje y protección telefónica). Esta documentación cubre lo que el código implementa hoy y, de forma explícita, lo que **no** implementa (estados ausentes, carga de datos, errores, flujos vacíos, permisos y respuestas de servidor) para quien deba portar el prototipo a producción (Flutter).

## Naturaleza del artefacto analizado

> `app_desing/` es un **prototipo visual navegable**, no una aplicación funcional. Está construido en React 19 + Vite + Tailwind CSS v4 y generado desde Google AI Studio. Toda la data es estática (mock), la navegación se resuelve por estado local (no hay router) y **no existe ninguna integración de backend real**. El objetivo del prototipo es demostrar pantallas y microinteracciones destinadas a ser portadas a Flutter.

## Índice de artefactos

| # | Artefacto | Archivo |
|---|-----------|---------|
| 1 | Inventario de pantallas | [`01-inventario-pantallas.md`](./01-inventario-pantallas.md) |
| 2 | Catálogo de componentes | [`02-catalogo-componentes.md`](./02-catalogo-componentes.md) |
| 3 | Mapa de navegación | [`03-mapa-navegacion.md`](./03-mapa-navegacion.md) |
| 4 | Especificación funcional | [`04-especificacion-funcional.md`](./04-especificacion-funcional.md) |
| 5 | Inventario de integraciones | [`05-inventario-integraciones.md`](./05-inventario-integraciones.md) |
| 6 | Design System | [`06-design-system.md`](./06-design-system.md) |

## Convenciones

A lo largo de los documentos se usan estas etiquetas:

- **✅ Implementado** — existe y funciona en el prototipo.
- **🟡 Simulado** — hay UI y feedback, pero el comportamiento es falso (`setTimeout`, `Math.random`, data estática).
- **❌ Ausente** — el estado o flujo no existe en el código y debe diseñarse para producción.

## Stack técnico (resumen)

- **Framework:** React 19 (`react`, `react-dom`)
- **Build:** Vite 8 + `@vitejs/plugin-react`
- **Estilos:** Tailwind CSS v4 (`@tailwindcss/vite`) + CSS custom en `src/index.css`
- **Iconografía:** Material Symbols Outlined (vía CDN de Google Fonts)
- **Tipografías:** Space Grotesk, Hanken Grotesk, JetBrains Mono (vía CDN)
- **Gestión de estado:** `useState` local en `App.tsx` (sin Redux/Context/router)

> Dependencias declaradas en `package.json` pero **no utilizadas** en el código: `@google/genai`, `motion`, `express`, `dotenv`, `lucide-react`. Ver detalle en el inventario de integraciones.
