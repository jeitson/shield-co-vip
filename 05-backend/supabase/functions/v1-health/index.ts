// v1-health — Health-check de la API versionada.
//
// No contiene lógica de negocio ni toca el pepper. Existe para fijar el patrón
// de Edge Functions versionadas por carpeta (`/vN`, DA-15) y validar el
// toolchain de despliegue (`supabase functions deploy v1-health`). Las
// funciones sensibles (v1-pepper, v1-sync, v1-session, v1-report, v1-metrics)
// se añaden en fases posteriores.

Deno.serve((_req: Request) => {
  const body = {
    service: "cifrado-cero",
    api_version: "v1",
    status: "ok",
    time: new Date().toISOString(),
  };
  return new Response(JSON.stringify(body), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
});
