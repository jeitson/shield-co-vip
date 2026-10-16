// _shared/device.ts — helpers compartidos por las Edge Functions para exigir
// que el request venga de un dispositivo ACTIVO del usuario (DA-02/03/04).
//
// `v1-sync` y `v1-pepper` lo usan para no entregar dataset/pepper a dispositivos
// revocados o no registrados (endurecimiento de la decisión B1).

import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

export interface DeviceContext {
  profileId: string;
  deviceId: string;
  admin: SupabaseClient;
}

/** Respuesta de error homogénea. */
export function jsonError(
  status: number,
  error: string,
  corsHeaders: Record<string, string>,
): Response {
  return new Response(JSON.stringify({ error }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/**
 * Valida la sesión Auth y que el dispositivo (`x-device-id`) exista y esté
 * `activo` para ese usuario. Devuelve el contexto o una `Response` de error.
 */
export async function requireActiveDevice(
  req: Request,
  corsHeaders: Record<string, string>,
): Promise<DeviceContext | Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return jsonError(401, "unauthorized", corsHeaders);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) {
    return jsonError(401, "unauthorized", corsHeaders);
  }
  const profileId = userData.user.id;

  const deviceId = req.headers.get("x-device-id");
  if (!deviceId) return jsonError(400, "device_id_required", corsHeaders);

  const admin = createClient(supabaseUrl, serviceKey);
  const { data: device } = await admin
    .from("devices")
    .select("estado")
    .eq("id", deviceId)
    .eq("profile_id", profileId)
    .maybeSingle();

  if (!device) return jsonError(403, "device_no_registrado", corsHeaders);
  if (device.estado !== "activo") {
    return jsonError(403, "device_inactivo", corsHeaders);
  }

  return { profileId, deviceId, admin };
}
