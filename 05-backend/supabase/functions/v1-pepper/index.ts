// v1-pepper — Entrega el pepper del dataset al dispositivo autenticado [DA-05].
//
// Requiere una sesión válida de Supabase Auth (header Authorization: Bearer
// <access_token>). Lee el pepper de Vault con el service role (nunca expuesto al
// cliente) y devuelve { pepper, pepper_version } sobre TLS. Sin sesión → 401.
//
// [B1] Aún no verifica "dispositivo activo"; eso lo añade la spec `devices`.
// Ref: 03-architecture/05-backend-api-metricas.md §05.2; 02-seguridad §02.2.

import { requireActiveDevice } from "../_shared/device.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-app-version, x-device-id",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Exige sesión Auth + dispositivo ACTIVO (DA-02/03/04).
  const ctx = await requireActiveDevice(req, corsHeaders);
  if (ctx instanceof Response) return ctx;
  const { admin } = ctx;

  const { data, error } = await admin.rpc("get_dataset_pepper");
  const row = Array.isArray(data) ? data[0] : data;
  if (error || !row?.pepper) {
    return json({ error: "pepper_unavailable" }, 500);
  }

  return json({
    pepper: row.pepper,
    pepper_version: row.pepper_version ?? 1,
  }, 200);
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
