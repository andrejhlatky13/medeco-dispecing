#!/usr/bin/env bash
# Pripojí čistú inštaláciu MEDEKO Dispečing k už založenému projektu Supabase.
# NIKDY nespúšťať proti projektu PAL-KOV (yrrjufilzsepoqoitwed).
#
# Potrebujete:
#   1. Projekt vytvorený v https://supabase.com/dashboard (Free, región eu-central-1 alebo eu-west-1)
#   2. Osobný prístupový token: https://supabase.com/dashboard/account/tokens
#      (právo čítať/zapisovať do tohto projektu)
#   3. Project ref (Settings → General → Reference ID), napr. abcdefghijklmnop
#
# Použitie:
#   export SUPABASE_ACCESS_TOKEN=sbp_...
#   export PROJECT_REF=váš_ref
#   ./setup/provision.sh
#
# Skript: spustí SQL, nasadí Edge Functions (admin-users, bootstrap),
# vypíše verejný kľúč a upraví index.html. Service role kľúč NIKDY nevypisuje do súborov aplikácie.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PALKOV_REF="yrrjufilzsepoqoitwed"
REF="${PROJECT_REF:-${1:-}}"
TOKEN="${SUPABASE_ACCESS_TOKEN:-}"

if [[ -z "$REF" || -z "$TOKEN" ]]; then
  echo "Chýba PROJECT_REF alebo SUPABASE_ACCESS_TOKEN." >&2
  echo "Pozrite komentár na začiatku tohto súboru." >&2
  exit 1
fi
if [[ "$REF" == "$PALKOV_REF" ]]; then
  echo "ODMIETNUTÉ: tento skript sa nesmie spustiť proti projektu PAL-KOV ($PALKOV_REF)." >&2
  exit 2
fi

API="https://api.supabase.com/v1"
echo "== Overujem projekt $REF =="
META=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/projects/$REF")
echo "$META" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('name','?'), d.get('status','?'), d.get('region','?'));
import sys as s
if d.get('message'): s.exit('API: '+d.get('message','chyba'))
if d.get('ref',d.get('id'))=='$PALKOV_REF': s.exit('ODMIETNUTÉ: PAL-KOV')"

echo "== Spúšťam SQL schému =="
python3 - "$ROOT/setup/schema.sql" "$TOKEN" "$REF" << 'PY'
import json,sys,urllib.request
sql=open(sys.argv[1]).read()
token,ref=sys.argv[2],sys.argv[3]
req=urllib.request.Request(
    f"https://api.supabase.com/v1/projects/{ref}/database/query",
    data=json.dumps({"query":sql}).encode(),
    headers={"Authorization":f"Bearer {token}","Content-Type":"application/json"},
    method="POST",
)
try:
    with urllib.request.urlopen(req, timeout=120) as r:
        print(r.status, r.read()[:500])
except Exception as e:
    # Management API sometimes wants the query split; print error
    if hasattr(e,'read'):
        print('ERROR', e.read().decode()[:2000], file=sys.stderr)
    raise
PY

echo "== Nasadzujem Edge Functions =="
# Copy functions into a temp supabase folder and deploy without linking PAL-KOV
TMP=$(mktemp -d)
mkdir -p "$TMP/supabase/functions"
cp -a "$ROOT/setup/supabase/functions/admin-users" "$TMP/supabase/functions/"
cp -a "$ROOT/setup/supabase/functions/bootstrap" "$TMP/supabase/functions/"
# config with verify_jwt
cat > "$TMP/supabase/config.toml" << TOML
project_id = "$REF"
[functions.admin-users]
verify_jwt = true
[functions.bootstrap]
verify_jwt = false
TOML
export SUPABASE_ACCESS_TOKEN="$TOKEN"
( cd "$TMP" && npx supabase functions deploy admin-users --project-ref "$REF" --yes )
( cd "$TMP" && npx supabase functions deploy bootstrap --project-ref "$REF" --no-verify-jwt --yes )
rm -rf "$TMP"

echo "== Čítam verejný (anon / publishable) kľúč =="
KEYS=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/projects/$REF/api-keys")
python3 - "$KEYS" "$REF" "$ROOT/index.html" << 'PY'
import json,sys,re,pathlib
keys=json.loads(sys.argv[1])
ref=sys.argv[2]
html_path=pathlib.Path(sys.argv[3])
# keys may be a list of {name, api_key} or similar
anon=None
if isinstance(keys,list):
    for k in keys:
        name=(k.get('name') or k.get('id') or k.get('type') or '').lower()
        val=k.get('api_key') or k.get('key') or k.get('secret')
        if name in ('anon','publishable','legacy_anon') and val:
            anon=val
            if name in ('anon','publishable'):
                break
elif isinstance(keys,dict):
    anon=keys.get('anon') or keys.get('publishable')
    print('keys dict keys', keys.keys())
if not anon:
    print('Nepodarilo sa nájsť verejný kľúč. Odpoveď API (bez hodnôt):')
    def redact(o):
        if isinstance(o,dict):
            return {k:('***' if 'key' in k.lower() or 'secret' in k.lower() or 'token' in k.lower() else redact(v)) for k,v in o.items()}
        if isinstance(o,list):
            return [redact(x) for x in o]
        return o
    print(json.dumps(redact(keys), indent=2)[:1500])
    sys.exit(1)
url=f"https://{ref}.supabase.co"
html=html_path.read_text()
html2=html.replace("__SB_URL__", url).replace("__SB_KEY__", anon)
# safety: never write if PAL-KOV leaked
if "yrrjufilzsepoqoitwed" in html2:
    sys.exit("ODMIETNUTÉ: v index.html by skončil odkaz na PAL-KOV")
html_path.write_text(html2)
print("index.html aktualizovaný:")
print("  SB_URL =", url)
print("  SB_KEY =", anon[:12]+"…"+" (verejný kľúč, je v aplikácii zámerne)")
print("Hotovo. Nasadíte súbory na GitHub Pages.")
PY

echo "== Odporúčané: vypnúť verejnú registráciu (signup) =="
curl -sS -X PATCH -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "$API/projects/$REF/config/auth" \
  -d '{"disable_signup":true}' | python3 -c "import sys; print(sys.stdin.read()[:300])" || true

echo "Provision dokončený."
