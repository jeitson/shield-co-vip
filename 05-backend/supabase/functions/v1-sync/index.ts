// v1-sync — Delta sync versionado del dataset de hashes [DA-08].
//
// GET /v1/sync?since={N}&pepper_version={P}
// Requiere sesión válida de Supabase Auth. Responde las novedades desde la
// versión `since` del cliente:
//   { current_version, pepper_version, altas:{phone_hashes}, bajas:{phone_hashes},
//     checksum, full }
// - full = true cuando since<=0, el gap supera `sync_full_gap`, o el
//   pepper_version del cliente difiere del vigente (fuerza reconstrucción).
// - checksum = sha256 del cuerpo canónico, para que el cliente verifique
//   integridad antes de aplicar (02-seguridad §02.6).
// Idempotente: el mismo `since` devuelve el mismo resultado.
//
// [B1] Aún no verifica "dispositivo activo"; eso lo añade la spec `devices`.
// Ref: 03-architecture/05-backend-api-metricas.md §05.2; 03-datos §03.4.

import { requireActiveDevice } from "../_shared/device.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-app-version, x-device-id",
};

interface HashRow {
  hash: string;
  categoria: string;
  nivel: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Exige sesión Auth + dispositivo ACTIVO (DA-02/03/04).
  const ctx = await requireActiveDevice(req, corsHeaders);
  if (ctx instanceof Response) return ctx;
  const admin = ctx.admin;

  const url = new URL(req.url);
  const since = parseInt(url.searchParams.get("since") ?? "0", 10) || 0;
  const clientPepper = url.searchParams.has("pepper_version")
    ? parseInt(url.searchParams.get("pepper_version")!, 10)
    : null;

  // Estado global del dataset.
  const { data: dv, error: dvErr } = await admin
    .from("dataset_version")
    .select("current_version, pepper_version")
    .eq("id", 1)
    .maybeSingle();
  if (dvErr || !dv) {
    return json({ error: "dataset_unavailable" }, 500);
  }
  const currentVersion: number = dv.current_version;
  const pepperVersion: number = dv.pepper_version;

  // Umbral de full resync (app_params).
  const { data: gapParam } = await admin
    .from("app_params")
    .select("valor")
    .eq("clave", "sync_full_gap")
    .maybeSingle();
  const fullGap = parseInt(gapParam?.valor ?? "500", 10) || 500;

  const pepperChanged = clientPepper !== null && clientPepper !== pepperVersion;
  const full = since <= 0 || currentVersion - since > fullGap || pepperChanged;

  let altas: HashRow[] = [];
  let bajas: string[] = [];

  if (full) {
    // Dataset activo completo.
    const { data } = await admin
      .from("phone_hashes")
      .select("hash, categoria, nivel")
      .is("removed_at_version", null)
      .eq("pepper_version", pepperVersion);
    altas = (data ?? []) as HashRow[];
  } else {
    // Altas: entraron después de `since` y siguen activas.
    const { data: altasData } = await admin
      .from("phone_hashes")
      .select("hash, categoria, nivel")
      .gt("added_at_version", since)
      .is("removed_at_version", null)
      .eq("pepper_version", pepperVersion);
    altas = (altasData ?? []) as HashRow[];

    // Bajas: se marcaron removidas después de `since`.
    const { data: bajasData } = await admin
      .from("phone_hashes")
      .select("hash")
      .gt("removed_at_version", since)
      .eq("pepper_version", pepperVersion);
    bajas = (bajasData ?? []).map((r: { hash: string }) => r.hash);
  }

  const payload = {
    current_version: currentVersion,
    pepper_version: pepperVersion,
    altas: { phone_hashes: altas },
    bajas: { phone_hashes: bajas },
    full,
  };

  const checksum = await sha256Hex(canonical(payload));

  return json({ ...payload, checksum }, 200);
});

/// Serialización canónica estable del payload (sin el checksum) para que el
/// cliente recompute el mismo sha256. El orden de claves es fijo.
function canonical(p: {
  current_version: number;
  pepper_version: number;
  altas: { phone_hashes: HashRow[] };
  bajas: { phone_hashes: string[] };
  full: boolean;
}): string {
  const altas = p.altas.phone_hashes
    .map((h) => `${h.hash}:${h.categoria}:${h.nivel}`)
    .sort()
    .join(",");
  const bajas = [...p.bajas.phone_hashes].sort().join(",");
  return [
    p.current_version,
    p.pepper_version,
    p.full ? "1" : "0",
    altas,
    bajas,
  ].join("|");
}

async function sha256Hex(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  const hex = Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return `sha256:${hex}`;
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
