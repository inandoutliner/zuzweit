// Zu zweit: Speichert einen Ort aus dem iPhone-Kurzbefehl.
// Aufruf per einfachem GET (der Kurzbefehl braucht keine Header):
//   https://<projekt>.supabase.co/functions/v1/zuzweit-ort?k=<Listen-Code>&ich=a&t=<URL-codierter geteilter Text>
// In Supabase anlegen: Edge Functions → Deploy a new function → Via Editor → Name "zuzweit-ort",
// diesen Code einfügen, Deploy; danach in den Einstellungen der Funktion "Verify JWT" ausschalten.
Deno.serve(async (req) => {
  const u = new URL(req.url);
  const k = u.searchParams.get("k") ?? "";
  const ich = u.searchParams.get("ich") === "b" ? "b" : "a";
  const t = u.searchParams.get("t") ?? "";
  const n = u.searchParams.get("n");
  const key = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  let msg = "Zu zweit: Fehler";
  try {
    const r = await fetch(Deno.env.get("SUPABASE_URL") + "/rest/v1/rpc/zz_ort_aus_google", {
      method: "POST",
      headers: { "Content-Type": "application/json", apikey: key, Authorization: "Bearer " + key },
      body: JSON.stringify({ p_text: `k=${k}&ich=${ich} ${t}`, p_notiz: n }),
    });
    const body = await r.text();
    try { const j = JSON.parse(body); msg = typeof j === "string" ? j : "Zu zweit: " + (j.message ?? body); } catch { msg = body; }
  } catch (e) {
    msg = "Zu zweit: " + String(e);
  }
  return new Response(msg, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
});
