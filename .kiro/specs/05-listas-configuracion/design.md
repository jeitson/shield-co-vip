# Spec · 05 Listas locales y configuración avanzada — Diseño

> Diseño técnico de la administración directa de listas en `AdvancedScreen`
> (PANT-ADVANCED). **No se crea feature nueva ni se toca dominio/datos**: toda la
> plomería (`lists`) ya existe desde la spec 03. Esta spec es esencialmente
> **presentación** que consume providers existentes, más una pequeña capa de
> estado de UI por formulario de alta.
> Clean Architecture por features (DA-13), Riverpod, tokens de `core/theme`.
> Regla de dependencia: `presentation → domain ← data` (aquí solo tocamos
> `presentation`).

---

## 1. Panorama

Se **expande una pantalla existente** (`features/settings/presentation/advanced_screen.dart`)
y se añaden widgets de presentación. El resto es reutilización pura:

```
features/
├── settings/
│   └── presentation/
│       ├── advanced_screen.dart              # (expandir) + sección de listas, + simulador
│       ├── controllers/
│       │   └── list_admin_controller.dart    # NEW estado de alta por lista (error/dup/idle)
│       ├── state/
│       │   └── list_admin_state.dart          # NEW AddPhase { idle, invalid, duplicate }
│       └── widgets/
│           ├── list_manager_card.dart         # NEW tarjeta de una lista (input + chips + contador + vacío)
│           └── number_chip.dart               # NEW chip de número con eliminar
│
└── lists/   ← SIN CAMBIOS (reutilizado)
    ├── domain/{canonical_number, classify_number, entities, repositories}
    └── presentation/lists_providers.dart
        · classifyNumberProvider  (set/unset con exclusividad RN-05, normaliza RN-04)
        · confianzaNumbersProvider / negraNumbersProvider  (Set<String> reactivos)
        · membershipProvider  (no se usa aquí; es para el timeline)
```

No hay cambios en `core/db`, en el motor, ni en el backend. El flujo de datos es:

```
AdvancedScreen
  └─ ListManagerCard(kind: confianza)  ← watch confianzaNumbersProvider
  └─ ListManagerCard(kind: negra)      ← watch negraNumbersProvider
        · input + botón → listAdminController.add(raw, kind)
              → canonicalizeNumber(raw)         (RN-04)
              → null? → state = invalid (R3)
              → ya presente en esa lista? → state = duplicate (R4)
              → classifyNumber(raw, kind, origin: manual)   (RN-05 atómica)
        · chip X → classifyNumber(numero, null)             (baja, R6)
```

Como `classifyNumber` ya persiste en `numeros_listados` y los providers son
streams sobre el DAO, **toda la UI es reactiva sin estado local de la lista**: el
único estado de UI es el resultado del último intento de alta (para pintar el
error/duplicado), encapsulado en un controller pequeño por lista.

---

## 2. Estado de UI del alta (`ListAdminController`)

Se modela por **lista** (family por `ListKind`) porque cada tarjeta tiene su
propio input y su propio feedback.

```dart
enum AddPhase { idle, invalid, duplicate }

class ListAdminState {
  const ListAdminState({this.phase = AddPhase.idle});
  final AddPhase phase;
  bool get hasError => phase != AddPhase.idle;
  String? get message => switch (phase) {
    AddPhase.idle => null,
    AddPhase.invalid => 'Número inválido. Revisa el formato.',
    AddPhase.duplicate => 'Ese número ya está en la lista.',
  };
}
```

`ListAdminController` (StateNotifier, family por `ListKind`):

- `Future<void> add(String raw)`:
  1. `canonical = canonicalizeNumber(raw)` → si `null` ⇒ `phase = invalid`, return.
  2. Leer el `Set` actual de **esa** lista (`ref.read(confianza/negra NumbersProvider.future)`);
     si `canonical` ya está ⇒ `phase = duplicate`, return.
  3. `await classifyNumber(raw, kind, origin: ListOrigin.manual)`; en `Ok` ⇒
     `phase = idle` (la UI limpia el input; el stream pinta el chip). En `Err` ⇒
     mantener un mensaje de error genérico (reutiliza `invalid` como "no se pudo").
- `void clearError()`: vuelve a `idle` cuando el usuario edita el input.

> La **duplicación** se chequea contra la forma canónica (R4) usando el mismo
> `Set` reactivo que pinta los chips, de modo que no hay desalineación. La
> **exclusividad** (R5) no requiere lógica aquí: `classifyNumber` con la misma PK
> `numero` ya mueve el número entre listas atómicamente; el `Set` de la lista de
> origen se actualiza solo.

---

## 3. Widgets

### 3.1 `ListManagerCard`
Tarjeta de una lista. Props: `kind` (`ListKind`), `title`, `addLabel`,
`accentColor` (cyan para confianza, danger para negra).

Composición:
- Encabezado: título + **contador** (`Set.length`), de `confianza/negraNumbersProvider`.
- Fila de alta: `TextField` (teclado `phone`) + `PrimaryButton` (`core/widgets`).
  El error del `ListAdminController` se pinta bajo el input (texto `danger`).
- Cuerpo:
  - Si el `Set` está **vacío** ⇒ `_EmptyState` (icono + texto, R7).
  - Si no ⇒ `Wrap` de `NumberChip` (uno por número, orden estable por
    `numero`).

Todo observado con `ref.watch(provider)` sobre `AsyncValue<Set<String>>`; usa el
`AsyncValueView`/`valueOrNull` ya presente en `core/widgets` para los estados de
carga/error, coherente con el resto de pantallas.

### 3.2 `NumberChip`
`Chip` con el `numero` canónico y `onDeleted` → `classifyNumber(numero, null)`
(R6). Estética del design system (superficie, borde sutil, color de acento según
lista).

### 3.3 `ListsScreen` (pantalla propia de listas)
Pantalla con `Scaffold` + `AppBar` (back nativo), ruta `/advanced/lists` sobre el
navegador raíz (como el detalle y el simulador). Contiene las **dos**
`ListManagerCard` (confianza + negra) juntas, porque comparten la exclusividad
RN-05. Toda la lógica es reutilizada; la pantalla solo compone.

### 3.4 Integración en `AdvancedScreen` (menú de secciones, R8b)
Avanzados es un **menú**, no un formulario:
1. **PROTECCIÓN** (tarjeta única con filas):
   - "Listas locales" → `context.pushNamed(listsName)`; subtítulo con el conteo
     (`N en confianza · M bloqueados`) observando `confianza/negraNumbersProvider`.
   - "Horario legal (Ley 2300)" → `ExpansionTile` (acordeón) con
     `Law2300HoursCard(embedded: true)` (R11, solo lectura).
   - "Abrir Simulador" → `context.pushNamed(simulatorName)` (R8).
2. **CUENTA** → logout (sin cambios).
3. **DESARROLLO** (solo dev) → sembrador de eventos (sin cambios).

`Law2300HoursCard` gana un flag `embedded` para no dibujar su propia
superficie/borde cuando vive dentro del acordeón (evita tarjetas anidadas). Un
helper `_Card` unifica el contenedor de las secciones.

Se **elimina** el `_SectionHint` placeholder de listas (R9.2). No se introduce
"Modo Marco Móvil" (R10).

---

## 4. Normalización, deduplicación y exclusividad (reutilización)

| Preocupación | Dónde vive (ya existe) | Rol de esta spec |
|---|---|---|
| Normalización RN-04 | `canonicalizeNumber` + `ColombianPhone` VO | invocar antes de dup-check |
| Exclusividad RN-05 | `ClassifyNumber`→DAO (PK `numero`, transacción) | invocar con `origin: manual` |
| Deduplicación canónica | `Set<String>` del provider (números ya canónicos) | `contains(canonical)` |
| Reproyección al motor | `engineIndexProvider`/proyección existente | ninguno (automático) |

No se reimplementa ninguna de estas; la spec solo las orquesta desde la UI.

---

## 5. Theming y accesibilidad

- Solo tokens de `core/theme` (`AppColors`, `AppDimens`), como el resto de la app.
- Contadores y errores con **texto redundante** (no solo color): el error se
  comunica con mensaje textual, no solo con borde rojo.
- Chips con `tooltip`/`semanticLabel` de "Eliminar <número> de la lista".
- `TextField` con `textInputAction: done` y envío también por teclado.

---

## 6. Pruebas

- **Controller** (`ListAdminController`): entrada inválida → `invalid`; duplicado
  (misma forma canónica con formato distinto, p. ej. `300 123 4567` vs
  `+573001234567`) → `duplicate`; alta válida → `idle` y `classifyNumber` llamado
  con `origin.manual`.
- **Widget** (`ListManagerCard`): lista vacía muestra estado vacío; con items
  muestra N chips y contador N; tocar la X dispara la baja; error visible bajo el
  input.
- **Exclusividad** (integración ligera con repo real sobre base en memoria /
  fake DAO si está disponible): alta en negra de un número presente en confianza
  lo retira de confianza (un solo registro, RN-05). Si montar la base cifrada en
  test es costoso, cubrir la exclusividad vía test del repo ya existente y limitar
  el widget test al comportamiento de UI.
- Verificar `flutter analyze` limpio y la suite completa verde.

---

## 7. Fuera de alcance (coherencia con requirements §3)

Ley 2300 (franjas/switches), auditoría ZK e importación masiva **no** se diseñan
aquí. Si se retoman, serán tarjetas adicionales en esta misma pantalla, con su
propia persistencia (`shield_config` o una tabla de reglas) y, para Ley 2300, un
proveedor de calendario de festivos (fuente a decidir, PN#3).
