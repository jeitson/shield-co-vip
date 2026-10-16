// Tests locales de los helpers puros de v1-report (sin red ni Supabase).
// Correr con: deno test supabase/functions/v1-report/index_test.ts
//
// NOTA: estos tests importan los helpers exportados de index.ts. Importar el
// módulo ejecuta su `Deno.serve(...)` de nivel superior, lo cual es inofensivo
// en el runtime de test (abre un listener que el proceso de test descarta).

import { assertEquals } from "jsr:@std/assert@1";
import { hmacSha256Hex, normalizeE164 } from "./index.ts";

Deno.test("normalizeE164 · móvil CO de 10 dígitos recibe +57", () => {
  assertEquals(normalizeE164("3184928810"), "+573184928810");
});

Deno.test("normalizeE164 · respeta el prefijo + y limpia separadores", () => {
  assertEquals(normalizeE164("+57 318-492-8810"), "+573184928810");
  assertEquals(normalizeE164("+57 (318) 492 8810"), "+573184928810");
});

Deno.test("normalizeE164 · indicativo 57 sin + se canoniza", () => {
  assertEquals(normalizeE164("573184928810"), "+573184928810");
});

Deno.test("normalizeE164 · código corto se conserva como forma canónica", () => {
  assertEquals(normalizeE164("890123"), "+890123");
});

Deno.test("normalizeE164 · vacío o sin dígitos → null", () => {
  assertEquals(normalizeE164("   "), null);
  assertEquals(normalizeE164("sin-digitos"), null);
});

Deno.test("hmacSha256Hex · es determinista y hex de 64 chars", async () => {
  const a = await hmacSha256Hex("+573184928810", "pepper-secreto");
  const b = await hmacSha256Hex("+573184928810", "pepper-secreto");
  assertEquals(a, b);
  assertEquals(a.length, 64);
  assertEquals(/^[0-9a-f]+$/.test(a), true);
});

Deno.test("hmacSha256Hex · vector conocido (equivale a pgcrypto hmac sha256 hex)", async () => {
  // Vector estándar HMAC-SHA256(key='key', msg='The quick brown fox jumps over the lazy dog').
  // Igual que: encode(hmac('The quick...','key','sha256'),'hex') en pgcrypto.
  const got = await hmacSha256Hex(
    "The quick brown fox jumps over the lazy dog",
    "key",
  );
  assertEquals(
    got,
    "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8",
  );
});
