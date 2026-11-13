import { createClient } from "npm:@supabase/supabase-js@2";
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const j = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });
const slug = (n: string) =>
  n.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().trim().replace(/[^a-z0-9]+/g, ".").replace(/^\.|\.$/g, "");
const PAD = "-pk";
const EMAIL_DOMAIN = "@medeko.local";

// Prvé spustenie: vytvorí PRVÉHO dispečera. Funguje LEN keď v tabuľke users
// ešte nie je žiadny dispečer. Po vytvorení účtu ďalšie volania odmietne.
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const url = Deno.env.get("SUPABASE_URL")!, svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, svc, { auth: { persistSession: false } });
    const b = await req.json().catch(() => ({}));
    const name = String(b.name || "").trim(), pw = String(b.password || "");
    if (!name || pw.length < 3) return j({ error: "Meno a heslo (min. 3 znaky) sú povinné" }, 400);

    const { count, error: ce } = await admin.from("users").select("id", { count: "exact", head: true }).eq("role", "dispecer");
    if (ce) return j({ error: ce.message }, 500);
    if ((count || 0) > 0) return j({ error: "Dispečerský účet už existuje. Prihláste sa, alebo požiadajte dispečera o účet." }, 403);

    const email = slug(name) + EMAIL_DOMAIN;
    const { data, error } = await admin.auth.admin.createUser({
      email, password: pw + PAD, email_confirm: true, user_metadata: { name, role: "dispecer" },
    });
    if (error) return j({ error: error.message }, 400);
    const { error: e2 } = await admin.from("users").insert({ id: data.user.id, name, role: "dispecer", email });
    if (e2) { await admin.auth.admin.deleteUser(data.user.id); return j({ error: e2.message }, 400); }
    return j({ ok: true, id: data.user.id, email, name });
  } catch (e) { return j({ error: String(e) }, 500); }
});
