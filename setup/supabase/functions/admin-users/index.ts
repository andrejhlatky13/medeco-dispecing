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
// Supabase Auth vyžaduje heslo aspoň 6 znakov. Používateľ zadáva heslo bez prípony;
// aplikácia aj táto funkcia pridajú rovnakú skrytú príponu "-pk".
const PAD = "-pk";
const EMAIL_DOMAIN = "@medeko.local";
const BAN = "876000h"; // ~100 rokov = zablokované prihlásenie

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const url = Deno.env.get("SUPABASE_URL")!, svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, svc, { auth: { persistSession: false } });
    const jwt = (req.headers.get("Authorization") || "").replace("Bearer ", "");
    const { data: { user }, error: ue } = await admin.auth.getUser(jwt);
    if (ue || !user) return j({ error: "Neprihlásený" }, 401);
    const { data: me } = await admin.from("users").select("role,active").eq("id", user.id).single();
    if (me?.role !== "dispecer" || me?.active === false) return j({ error: "Len pre dispečera" }, 403);
    const b = await req.json();
    const name = String(b.name || "").trim(), spz = String(b.spz || "").trim(), pw = String(b.password || "");
    const role = b.role === "dispecer" ? "dispecer" : "vodic";

    if (b.action === "create") {
      if (!name || pw.length < 3) return j({ error: "Meno a heslo (min. 3 znaky) sú povinné" }, 400);
      const email = slug(name) + EMAIL_DOMAIN;
      // rovnaké meno už existuje?
      const { data: ex } = await admin.from("users").select("*").or(`email.eq.${email},name.eq.${JSON.stringify(name)}`);
      const old = (ex || [])[0];
      if (old) {
        if (old.active !== false) return j({ error: "Používateľ s týmto menom už existuje" }, 400);
        // predtým zmazaný používateľ – obnoviť s novým heslom (história ostáva)
        const { error } = await admin.auth.admin.updateUserById(old.id, { password: pw + PAD, ban_duration: "none" });
        if (error) return j({ error: error.message }, 400);
        const { error: e2 } = await admin.from("users").update({ active: true, role }).eq("id", old.id);
        if (e2) return j({ error: e2.message }, 400);
        return j({ ok: true, id: old.id, email: old.email, restored: true });
      }
      const { data, error } = await admin.auth.admin.createUser({
        email, password: pw + PAD, email_confirm: true, user_metadata: { name, role },
      });
      if (error) return j({ error: error.message }, 400);
      const { error: e2 } = await admin.from("users").insert({ id: data.user.id, name, role, spz, email });
      if (e2) { await admin.auth.admin.deleteUser(data.user.id); return j({ error: e2.message }, 400); }
      return j({ ok: true, id: data.user.id, email });
    }

    const { data: u } = await admin.from("users").select("*").eq("id", b.id).single();
    if (!u) return j({ error: "Používateľ neexistuje" }, 404);

    if (b.action === "update") {
      const upd: Record<string, unknown> = {}, prof: Record<string, unknown> = {};
      if (b.spz !== undefined) prof.spz = spz;
      if (name && name !== u.name) {
        const email = slug(name) + EMAIL_DOMAIN;
        const { data: ex } = await admin.from("users").select("id").or(`email.eq.${email},name.eq.${JSON.stringify(name)}`).neq("id", u.id);
        if ((ex || []).length) return j({ error: "Používateľ s týmto menom už existuje" }, 400);
        upd.email = email; upd.user_metadata = { name, role: u.role }; prof.name = name; prof.email = email;
      }
      if (pw) {
        if (pw.length < 3) return j({ error: "Heslo min. 3 znaky" }, 400);
        upd.password = pw + PAD;
      }
      if (Object.keys(upd).length) {
        const { error } = await admin.auth.admin.updateUserById(b.id, upd);
        if (error) return j({ error: error.message }, 400);
      }
      if (Object.keys(prof).length) {
        const { error: e3 } = await admin.from("users").update(prof).eq("id", b.id);
        if (e3) return j({ error: e3.message }, 400);
      }
      return j({ ok: true });
    }

    if (b.action === "deactivate") {
      if (u.id === user.id) return j({ error: "Seba samého zmazať nemôžete" }, 400);
      if (u.role === "dispecer") {
        const { count } = await admin.from("users").select("id", { count: "exact", head: true })
          .eq("role", "dispecer").neq("active", false);
        if ((count || 0) <= 1) return j({ error: "Posledného dispečera nemožno zmazať" }, 400);
      }
      const { error } = await admin.auth.admin.updateUserById(u.id, { ban_duration: BAN });
      if (error) return j({ error: error.message }, 400);
      const { error: e2 } = await admin.from("users").update({ active: false }).eq("id", u.id);
      if (e2) return j({ error: e2.message }, 400);
      await admin.from("positions").delete().eq("driver_id", u.id);
      return j({ ok: true });
    }
    return j({ error: "Neznáma akcia" }, 400);
  } catch (e) { return j({ error: String(e) }, 500); }
});
