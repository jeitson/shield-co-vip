// v1-session — Registro de dispositivo, exclusividad por número y refresh
// (DA-02/03/04). Un solo endpoint que enruta por `action` en el body.
//
// Requiere sesión válida de Supabase Auth. Usa service role para escribir
// `devices` (RLS bloquea escritura del cliente). Acciones:
//  - register: upsert del dispositivo + cálculo de exclusividad por número.
//      → { estado: "activo" } | { estado: "pendiente_confirmacion", warning }
//  - activate: revoca el/los otros devices con ese número y activa este.
//      → { estado: "activo", revocado: "<device_id>" | null }
//  - refresh: si el device sigue activo → OK; si revocado → 401 device_revocado.
//
// Ref: 03-architecture/05-backend-api-metricas.md §05.2; 03-datos §03.1.

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-app-version, x-device-id",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) {
    return json({ error: "unauthorized" }, 401);
  }
  const profileId = userData.user.id;

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }

  const action = body.action as string | undefined;
  const deviceId = (body.device_id as string | undefined) ??
    req.headers.get("x-device-id") ?? undefined;
  if (!deviceId) return json({ error: "device_id_required" }, 400);

  const admin = createClient(supabaseUrl, serviceKey);

  switch (action) {
    case "register":
      return await register(admin, profileId, deviceId, body);
    case "activate":
      return await activate(admin, profileId, deviceId, body);
    case "refresh":
      return await refresh(admin, profileId, deviceId);
    default:
      return json({ error: "unknown_action" }, 400);
  }
});

async function register(
  admin: ReturnType<typeof createClient>,
  profileId: string,
  deviceId: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const numero = (body.numero_protegido as string | undefined) ?? null;

  // ¿Hay OTRO dispositivo activo con el mismo número?
  let conflict = false;
  if (numero) {
    const { data: others } = await admin
      .from("devices")
      .select("id")
      .eq("numero_protegido", numero)
      .eq("estado", "activo")
      .neq("id", deviceId);
    conflict = (others?.length ?? 0) > 0;
  }

  // Upsert del dispositivo. Si hay conflicto, no se activa todavía.
  const estado = conflict ? "revocado" : "activo";
  const row = {
    id: deviceId,
    profile_id: profileId,
    marca: body.marca ?? null,
    modelo: body.modelo ?? null,
    so: body.so ?? null,
    so_version: body.so_version ?? null,
    app_version: body.app_version ?? null,
    idioma: body.idioma ?? null,
    zona_horaria: body.zona_horaria ?? null,
    numero_protegido: numero,
    estado,
    last_seen_at: new Date().toISOString(),
  };
  const { error } = await admin.from("devices").upsert(row);
  if (error) return json({ error: "register_failed", detail: error.message }, 500);

  if (conflict) {
    return json({
      estado: "pendiente_confirmacion",
      warning: "numero_protegido_en_otro_dispositivo",
    }, 200);
  }
  return json({ estado: "activo", warning: null }, 200);
}

async function activate(
  admin: ReturnType<typeof createClient>,
  profileId: string,
  deviceId: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const numero = (body.numero_protegido as string | undefined) ?? null;

  // Revocar los otros dispositivos activos con ese número (de cualquier cuenta:
  // la licencia es por número, DA-03).
  let revocado: string | null = null;
  if (numero) {
    const { data: others } = await admin
      .from("devices")
      .select("id")
      .eq("numero_protegido", numero)
      .eq("estado", "activo")
      .neq("id", deviceId);
    if (others && others.length > 0) {
      revocado = others[0].id as string;
      await admin
        .from("devices")
        .update({ estado: "revocado" })
        .eq("numero_protegido", numero)
        .eq("estado", "activo")
        .neq("id", deviceId);
    }
  }

  // Activar este dispositivo (debe pertenecer al usuario).
  const { error } = await admin
    .from("devices")
    .update({ estado: "activo", last_seen_at: new Date().toISOString() })
    .eq("id", deviceId)
    .eq("profile_id", profileId);
  if (error) return json({ error: "activate_failed", detail: error.message }, 500);

  return json({ estado: "activo", revocado }, 200);
}

async function refresh(
  admin: ReturnType<typeof createClient>,
  profileId: string,
  deviceId: string,
): Promise<Response> {
  const { data: device } = await admin
    .from("devices")
    .select("estado")
    .eq("id", deviceId)
    .eq("profile_id", profileId)
    .maybeSingle();

  if (!device) return json({ error: "device_not_found" }, 404);
  if (device.estado !== "activo") {
    return json({ error: "device_revocado" }, 401);
  }

  await admin
    .from("devices")
    .update({ last_seen_at: new Date().toISOString() })
    .eq("id", deviceId);

  return json({ estado: "activo" }, 200);
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
