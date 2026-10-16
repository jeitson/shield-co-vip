// v1-report — Reporte comunitario anónimo [DA-10] (spec 04).
//
// POST /v1/report  { numero, categoria, device_id_anon? }
//   → 200 { estado: "pendiente" }        aceptado, en moderación
//   → 200 { estado: "ya_reportado" }     dedup: este device ya lo reportó
//   → 200 { estado: "rechazado", motivo: "numero_protegido" }
//   → 400 { error: "numero_invalido" | "categoria_invalida" }
//   → 401/403 (sin sesión / dispositivo no activo)  vía requireActiveDevice
//
// GET  /v1/report?numero=...   consulta si ESTE device ya reportó el número
//   → 200 { reportado: true|false, protegido: bool }
//   → 400 { error: "numero_invalido" }
//   (fuente de verdad del estado "ya reportado" para la UI del detalle, R9.)
//
// Anónimo respecto al reportante (RN-02): NO viaja user_id ni contenido. El
// `device_id_anon` del cuerpo se IGNORA en favor del `x-device-id` validado por
// requireActiveDevice (evita spoofing y mantiene honesta la dedup del umbral).
// El servidor normaliza a E.164, hashea con el pepper (mismo algoritmo que
// v1-sync/el seed) y guarda el número legible del INFRACTOR para moderación.
//
// Ref: 03-architecture/05-backend-api-metricas.md §05.2; 03-datos §03.6.

import { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { requireActiveDevice } from "../_shared/device.ts";

/// Cliente admin (service role) que devuelve `requireActiveDevice`.
type Admin = SupabaseClient;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-app-version, x-device-id",
};

// Catálogo cerrado RN-07 (labels estables; iguales a ThreatCategory.label y al
// seed del dataset). Un reporte con categoría fuera de esta lista se rechaza 400.
const CATEGORIAS = new Set<string>([
  "Extorsión / amenaza",
  "Phishing / vishing (suplantación)",
  "Call center / discador robótico",
  "Llamada fantasma / silenciosa",
  "Violación franja Ley 2300",
  "Comercial sin riesgo",
]);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST" && req.method !== "GET") {
    return json({ error: "method_not_allowed" }, 405);
  }

  // Exige sesión Auth + dispositivo ACTIVO (DA-02/03/04).
  const ctx = await requireActiveDevice(req, corsHeaders);
  if (ctx instanceof Response) return ctx;
  const { admin, deviceId } = ctx;

  return req.method === "GET"
    ? await handleQuery(req, admin, deviceId)
    : await handleReport(req, admin, deviceId);
});

/// GET: ¿este device ya reportó el número? (fuente de verdad para la UI, R9.)
async function handleQuery(
  req: Request,
  admin: Admin,
  deviceId: string,
): Promise<Response> {
  const url = new URL(req.url);
  const e164 = normalizeE164(url.searchParams.get("numero") ?? "");
  if (!e164) return json({ error: "numero_invalido" }, 400);

  const protegido = await isProtected(admin, e164);

  const hashInfo = await resolveHash(admin, e164);
  if (hashInfo instanceof Response) return hashInfo;

  const { data: existing } = await admin
    .from("reports")
    .select("id")
    .eq("device_id_anon", deviceId)
    .eq("hash", hashInfo.hash)
    .eq("pepper_version", hashInfo.pepperVersion)
    .maybeSingle();

  return json({ reportado: existing != null, protegido }, 200);
}

/// POST: ingesta del reporte con dedup idempotente.
async function handleReport(
  req: Request,
  admin: Admin,
  deviceId: string,
): Promise<Response> {
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "numero_invalido" }, 400);
  }

  const e164 = normalizeE164(String(body.numero ?? ""));
  if (!e164) return json({ error: "numero_invalido" }, 400);

  const categoria = String(body.categoria ?? "");
  if (!CATEGORIAS.has(categoria)) {
    return json({ error: "categoria_invalida" }, 400);
  }

  // 1) Allowlist de protección (anti-envenenamiento).
  if (await isProtected(admin, e164)) {
    return json({ estado: "rechazado", motivo: "numero_protegido" }, 200);
  }

  // 2) Pepper vigente + HMAC (mismo algoritmo que v1-sync / el seed).
  const hashInfo = await resolveHash(admin, e164);
  if (hashInfo instanceof Response) return hashInfo;

  // 3) Upsert idempotente: dedup por (device_id_anon, hash, pepper_version).
  //    `ignoreDuplicates` → si ya existe, no inserta y `data` llega vacío.
  const { data: inserted, error: insErr } = await admin
    .from("reports")
    .upsert(
      {
        hash: hashInfo.hash,
        numero_legible: e164,
        categoria,
        device_id_anon: deviceId,
        pepper_version: hashInfo.pepperVersion,
        estado: "pendiente",
      },
      { onConflict: "device_id_anon,hash,pepper_version", ignoreDuplicates: true },
    )
    .select("id");

  if (insErr) return json({ error: "report_failed" }, 500);

  const estado = (inserted && inserted.length === 0)
    ? "ya_reportado"
    : "pendiente";
  return json({ estado }, 200);
}

/// ¿El número está en la allowlist de protección?
async function isProtected(admin: Admin, e164: string): Promise<boolean> {
  const { data } = await admin
    .from("protected_numbers")
    .select("numero_e164")
    .eq("numero_e164", e164)
    .maybeSingle();
  return data != null;
}

/// Resuelve el HMAC del número con el pepper vigente, o una Response de error.
async function resolveHash(
  admin: Admin,
  e164: string,
): Promise<{ hash: string; pepperVersion: number } | Response> {
  const { data: pepperData, error: pepperErr } = await admin.rpc(
    "get_dataset_pepper",
  );
  const raw = Array.isArray(pepperData) ? pepperData[0] : pepperData;
  const pepperRow = raw as { pepper?: string; pepper_version?: number } | null;
  if (pepperErr || !pepperRow?.pepper) {
    return json({ error: "pepper_unavailable" }, 500);
  }
  const pepperVersion: number = pepperRow.pepper_version ?? 1;
  const hash = await hmacSha256Hex(e164, pepperRow.pepper);
  return { hash, pepperVersion };
}

/// Normaliza un número a E.164 colombiano (RN-04).
/// - Conserva un `+` inicial y dígitos.
/// - Un móvil CO de 10 dígitos (3XXXXXXXXX) recibe el prefijo +57.
/// - Si ya trae `+57…` o es un código corto, se respeta.
/// Devuelve `null` si no quedan dígitos.
export function normalizeE164(raw: string): string | null {
  const trimmed = raw.trim();
  if (trimmed === "") return null;

  const hasPlus = trimmed.startsWith("+");
  const digits = trimmed.replace(/[^0-9]/g, "");
  if (digits === "") return null;

  if (hasPlus) return `+${digits}`;
  // Móvil CO de 10 dígitos sin prefijo → anteponer 57.
  if (digits.length === 10 && digits.startsWith("3")) return `+57${digits}`;
  // Ya viene con indicativo 57XXXXXXXXXX.
  if (digits.startsWith("57")) return `+${digits}`;
  // Código corto u otro remitente: se conserva con `+` para forma canónica.
  return `+${digits}`;
}

/// HMAC-SHA256 en hex (equivalente a pgcrypto `encode(hmac(msg, key,'sha256'),'hex')`).
export async function hmacSha256Hex(message: string, key: string): Promise<string> {
  const enc = new TextEncoder();
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    enc.encode(key),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", cryptoKey, enc.encode(message));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
