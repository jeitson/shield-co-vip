# 03 · Arquitectura del sistema — Cifrado Cero

Esta carpeta define **cómo se construye** el sistema Cifrado Cero: la aplicación móvil (Flutter), el backend (Supabase), la criptografía, el modelo de datos, el flujo de sincronización, la seguridad y la operación. Se apoya en los documentos de negocio (`02-business`) y en la especificación funcional (`01-docs`), y los traduce a decisiones técnicas concretas.

> **Audiencia:** equipo de ingeniería (móvil y backend), seguridad y arquitectura. Para el **qué hace** el producto, ver `01-docs` y `02-business`. Este bloque responde el **cómo**.

---

## Índice

| Doc | Contenido |
|-----|-----------|
| [00 · Resumen y decisiones (ADR)](./00-resumen-y-decisiones.md) | Resumen ejecutivo, principios rectores y registro de todas las decisiones de arquitectura (ADR). |
| [01 · Vista de alto nivel y topología](./01-vista-alto-nivel.md) | Diagrama de contexto, componentes del sistema, responsabilidades y alcance Android-first. |
| [02 · Seguridad y criptografía](./02-seguridad-y-criptografia.md) | Modelo Zero-Knowledge, HMAC + pepper, SQLCipher, keystore, hardening del cliente, modelo de amenazas. |
| [03 · Modelo de datos y sincronización](./03-datos-y-sincronizacion.md) | Esquema Supabase, dataset de hashes, delta sync versionado, jerarquía de precedencia, reportes y allowlists. |
| [04 · Aplicación Flutter](./04-app-flutter.md) | Clean Architecture por features, Riverpod, drift + SQLCipher, `BlockingEngine`, sesión de 12h, sync en background. |
| [05 · Backend, API y métricas](./05-backend-api-metricas.md) | Edge Functions, contratos de API versionada `/v1`, métricas anónimas (Plano A/B), privacidad y opt-in. |
| [06 · Entornos, branching y versionado](./06-entornos-branching-versionado.md) | Monorepo, estrategia de ramas trunk-based, SemVer, matriz de soporte de versiones de API. |

---

## Propósito del sistema (recordatorio)

Cifrado Cero es un **filtro telefónico local "zero-knowledge"** para Colombia que intercepta y neutraliza llamadas y SMS maliciosos (extorsión, phishing/vishing, call centers, violaciones a la Ley 2300 de 2023). La inteligencia de bloqueo se distribuye como **hashes** y el matching ocurre **en el dispositivo, offline**. Ningún historial ni contenido de terceros sale del teléfono.

## Cómo leer este bloque

1. Empieza por [00 · Resumen y decisiones](./00-resumen-y-decisiones.md) para el panorama y el porqué de cada decisión.
2. Sigue por [01 · Vista de alto nivel](./01-vista-alto-nivel.md) para entender las piezas.
3. Profundiza en los documentos temáticos según tu rol.

> **Estado:** este documento consolida las decisiones de arquitectura acordadas. Las marcas `[DN-xx]` referencian decisiones de negocio previas (`02-business`); las marcas `[DA-xx]` son decisiones de arquitectura definidas aquí.
