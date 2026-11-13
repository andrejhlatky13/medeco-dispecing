# MEDEKO – Dispečing  
## Návod na skúšobnú prevádzku

Tento dokument patrí k čistej kópii dispečerskej aplikácie pripravenej pre firmu **MEDEKO CAST s.r.o.**, Orlové 255, 017 01 Považská Bystrica. Aplikácia je určená na **skúšobné obdobie**. Ceny v nej nie sú. Údaje sa zdieľajú v reálnom čase medzi počítačom dispečera a telefónmi vodičov.

Oficiálny názov firmy je **MEDEKO** (nie „Medeco“). Logo a farby (biela a červená) sú prevzaté z oficiálnej stránky [www.medeko.sk](https://www.medeko.sk/).

---

## 1. Čo aplikácia robí

Dispečer na počítači pripraví **zadávací lístok** na konkrétny deň (aj dopredu): ŠPZ vozidla, meno vodiča a až 5 úloh. Každá úloha má text, hmotnosť, poznámky, čísla kontajnerov a čas od–do.

Vodič v telefóne vidí **len svoje** lístky a úlohy. Môže úlohu začať a ukončiť, dopísať údaje, poslať poznámku, fotku, hlasovú správu a polohu GPS. Keď dispečer pridá úlohu, vodičovi príde upozornenie (ak si ho povolil).

Ďalšie možnosti: tlač lístka (aj s fotkami), archív a export podľa vodiča, kôš s obnovením zmazaného lístka, denník zmien, mapa polohy vodičov.

Slovo v aplikácii je vždy **vodič**, nie šofér.

---

## 2. Odkaz na skúšobnú aplikáciu

**Adresa:** https://andrejhlatky13.github.io/medeco-dispecing/

Táto adresa je verejná, ale bez účtu sa k údajom nikto nedostane. Heslá sa na prihlasovacej obrazovke **nezobrazujú**.

### Dôležité – čo treba spraviť úplne ako prvé

Aplikácia (webová stránka) je pripravená. **Databázu** (bezplatný server Supabase) sa nepodarilo založiť automaticky k existujúcemu účtu – prístupový kľúč nemá právo vytvárať nový projekt. Preto treba databázu založiť ručne. Bez tohto kroku aplikácia vypíše: „Databáza ešte nie je pripojená.“

Presný postup je v **kapitole 8**. Keď bude databáza pripojená, na obrazovke sa objaví **Prvé spustenie**.

---

## 3. Ako otvoriť aplikáciu a dať ju na plochu

### Na počítači (dispečer)

1. Otvorte prehliadač **Google Chrome** (alebo Edge).
2. Do adresného riadka zadajte odkaz z kapitoly 2.
3. Môžete si stránku pripnúť, alebo v Chrome zvoliť ponuku (tri bodky) → **Uložiť a zdieľať** → **Vytvoriť odkaz** / **Nainštalovať aplikáciu**.

### Na telefóne s Androidom (vodič) – Chrome

1. Otvorte odkaz **v prehliadači Chrome** (nie v Facebooku, Messengeri ani WhatsAppe – tam to nemusí ponúknuť inštaláciu).
2. Ťuknite na **tri bodky** vpravo hore.
3. Zvoľte **Pridať na plochu** alebo **Inštalovať aplikáciu**.
4. Potvrďte. Na ploche sa objaví ikona MEDEKO. Ďalej otvárajte aplikáciu z tejto ikony.

### Na iPhone (Safari)

1. Otvorte odkaz v **Safari**.
2. Ťuknite na tlačidlo **Zdieľať** (štvorček so šípkou).
3. Zvoľte **Pridať na plochu**, zadajte názov (napr. MEDEKO) a potvrďte.

Ak ste aplikáciu otvárali už skôr, po aktualizácii obnovte stránku (potiahnite dolu, alebo zatvorte a otvorte znova).

---

## 4. Prvé spustenie – účet dispečera

Keď je databáza pripojená a ešte v nej nie je žiadny používateľ, aplikácia ukáže obrazovku:

**„Prvé spustenie – vytvoriť dispečerský účet“**

1. Zadajte **meno a priezvisko** dispečera (takto sa bude ukazovať v aplikácii).
2. Zadajte **heslo** (najmenej 3 znaky) a to isté heslo znova. Oko vedľa poľa heslo na chvíľu ukáže, čo píšete.
3. Ťuknite na **Vytvoriť účet dispečera**.

Účet sa vytvorí a dispečer sa hneď prihlási. Tento krok funguje **len raz** – keď už dispečer existuje, druhý sa takto založiť nedá. Ďalších ľudí pridáva prihlásený dispečer.

Heslo si dobre zapamätajte alebo uložte na bezpečné miesto. Na prihlasovacej obrazovke sa heslá nikdy nevypisujú.

---

## 5. Ako pridať vodičov

1. Vpravo hore ťuknite na **Vodiči**.
2. Do riadka zadajte **meno a priezvisko** a **heslo** (najmenej 3 znaky). ŠPZ sa tu nezadáva – vodiči menia vozidlá, ŠPZ sa píše na každý lístok zvlášť.
3. Ťuknite na **+ Pridať vodiča**.
4. Heslo povedzte vodičovi osobne (nie cez verejný chat). Vodič sa prihlasuje **svojím menom** a týmto heslom.

Heslo vodiča môžete neskôr zmeniť tlačidlom **Zmeniť heslo**, meno tlačidlom **Premenovať**.

Na prihlasovacej obrazovke sa nový vodič objaví hneď v zozname. Ak má niekto aplikáciu už otvorenú, nech stránku obnoví.

---

## 6. Denná práca dispečera

- **Dátum** hore meníte šípkami, alebo výberom dňa. Lístky môžete pripraviť aj na budúce dni.
- **+ Nový lístok** – najprv musí existovať aspoň jeden vodič. Lístok vyplníte: ŠPZ, vodič, text úloh, prípadne poznámky.
- Dátum lístka sa priamo needituje (aby sa lístok „nestratil“ na inom dni). Na iný deň ho dáte tlačidlom **Presunúť…**.
- **Tlačiť lístok** vytlačí len lístok, nie celú obrazovku. Môžete zvoliť aj tlač s fotkami, alebo všetky lístky daného dňa.
- **Denný prehľad** – súhrn za deň, export CSV, tlač.
- **Archív / export** – obdobie, export podľa vodiča. Navrhnutá lehota: údaje 24 mesiacov, fotky 12 mesiacov; automatické mazanie je predvolene vypnuté.
- **Kôš** – zmazaný lístok sa dá **Obnoviť**.
- **Pokyny** na spodku lístka sú zatiaľ všeobecné. Môžete ich zmeniť tlačidlom **Upraviť pokyny** (každý riadok jeden pokyn).
- Na mape je posledná známa poloha vodičov, ktorí ju odoslali.

---

## 7. Denná práca vodiča

1. Otvorte aplikáciu z ikony na ploche.
2. Prihláste sa **svojím menom** (môžete ťuknúť na meno v zozname) a **heslom**, ktoré vám dal dispečer. Oko vedľa hesla ho na chvíľu ukáže.
3. Uvidíte svoj lístok na zvolený deň (šípkami viete listovať, ale nové úlohy čakajú zvyčajne dnes).
4. Pri úlohe ťuknite **Začať** (zapíše sa čas od a stav „Prebieha“).
5. Doplňte potrebné údaje – hmotnosť, čísla kontajnerov, poznámky.
6. Môžete **pridať fotku**, **hlasovú správu**, **poznámku pre dispečera** alebo **zdieľať polohu**.
7. Keď je úloha dokončená, ťuknite **Hotovo** (zapíše sa čas do).

Ak vám príde nové upozornenie, aplikácia môže pípnuť a prečítať správu. Povolenie na upozornenia sa pýta len raz.

---

## 8. Ako pripojiť bezplatnú databázu (Supabase)

Tento krok spraví niekto, kto vie založiť účet na internete (dispečer, IT, alebo kto aplikáciu odovzdáva). Trvá to približne 10–15 minút. Všetko je v bezplatnom pláne.

### 8.1 Založenie projektu

1. Otvorte [https://supabase.com](https://supabase.com) a vytvorte si účet (ideálne na firemnom e-maile MEDEKO, napr. cez „Sign up with Google“ alebo e-mail).
2. Kliknite **New project**.
3. Názov projektu: `medeco-dispecing`.
4. Vyberte región **Frankfurt (eu-central-1)** alebo **Ireland (eu-west-1)**.
5. Zadajte silné heslo databázy a **uložte si ho** na bezpečné miesto (do aplikácie sa nedáva, budete ho potrebovať pri správe projektu).
6. Plán **Free**. Počkajte, kým sa projekt vytvorí (cca 1–2 minúty, stav „Active“).

### 8.2 SQL schéma

1. Vľavo zvoľte **SQL Editor** → **New query**.
2. Otvorte súbor `setup/schema.sql` (je v prílohe a v ZIP) a **celý** ho vložte do editora.
3. Kliknite **Run**. Nemalo by to ohlásiť chybu.

Tým sa vytvoria tabuľky, práva (vodič vidí len svoje údaje), kôš, denník zmien, úložisko fotiek a funkcie `login_roster` a `keepalive`.

### 8.3 Edge Functions (dve funkcie)

Tieto dve funkcie slúžia na bezpečné zakladanie účtov. Súborom sú:

- `setup/fn/bootstrap/index.ts` – **prvé spustenie**, vytvorí jediného dispečera, a to **len keď ešte žiadny dispečer nie je**.
- `setup/fn/admin-users/index.ts` – **pridávanie a úprava vodičov**, len pre prihláseného dispečera.

Nasadenie v konzole Supabase:

1. Vľavo **Edge Functions**.
2. **Create function**, názov presne `bootstrap`. Do editora vložte obsah `setup/fn/bootstrap/index.ts`. Pri tejto funkcii treba **vypnúť overovanie JWT** (`verify_jwt = false`), inak prvé spustenie nebude dostupné pred prihlásením. V novšom rozhraní je to voľba „Enforce JWT“ / „Verify JWT“ – vypnite ju **len** pri `bootstrap`.
3. **Create function**, názov presne `admin-users`. Vložte `setup/fn/admin-users/index.ts`. JWT overovanie **nechajte zapnuté**.

Ak používate nástroj `supabase` v príkazovom riadku, v priečinku `setup` je pripravený skript `provision.sh` (a konfigurácia `setup/supabase/`). Skript má poistku, aby sa nespustil proti inému, už existujúcemu projektu, ktorý k tejto aplikácii nepatrí.

### 8.4 Verejný kľúč do aplikácie

1. V Supabase: **Project Settings** → **API Keys**.
2. Skopírujte **Project URL** (vyzerá ako `https://xxxxxxxx.supabase.co`) a **anon** / **publishable** kľúč.  
   **Service role kľúč nikdy nedávajte do aplikácie ani do e-mailu** – má plný prístup k údajom.
3. V súbore `index.html` nájdite riadok, ktorý začína `const SB_URL=` a doplňte:

```javascript
const SB_URL='https://VÁŠ_REF.supabase.co',SB_KEY='VÁŠ_ANON_KĽÚČ';
```

4. Súbor `index.html` uložte a znova nahrajte na GitHub (kapitola 10), alebo ho zatiaľ otvárajte ako súbor pri testovaní.
5. Odporúčané: v **Authentication** → **Providers** → **Email** vypnite **Allow new users to sign up** (používateľov zakladá len aplikácia, nie verejný formulár).
6. V **Authentication** → **URL Configuration** môžete ako Site URL dať adresu aplikácie z kapitoly 2.

Po obnovení stránky sa objaví **Prvé spustenie** (kapitola 4).

---

## 9. Bezplatný plán – na čo si dať pozor

- **Uspanie po nečinnosti.** Bezplatný projekt Supabase sa po približne **jednom týždni bez použitia** uspí. Prihlásenie potom zlyhá, alebo aplikácia napíše, že server je nedostupný. V konzole Supabase projekt obnovíte tlačidlom **Restore**. Aby sa to nedealo, aplikáciu aspoň raz za pár dní otvorte, alebo nastavte denné „zobudenie“ (funkcia `keepalive` v schéme; vzor je v súbore `setup/keepalive.yml.example` – GitHub Actions raz denne zavolá túto funkciu verejným kľúčom, ktorý je v aplikácii aj tak verejný).
- **Úložisko.** Fotky a hlasové správy idú do priečinka `media`. Bezplatný plán má obmedzenú kapacitu (rádovo v jednotkách GB; aktuálny limit je v cenníku Supabase). Archív v aplikácii navrhuje fotky držať 12 mesiacov, údaje 24 mesiacov. Automatické mazanie je vypnuté, kým ho nezapnete a nespustíte úlohu na strane servera.
- **Dva bezplatné projekty.** Na jednom účte Supabase býva počet bezplatných projektov obmedzený. Ak založenie nového projektu zlyhá, použite iný účet (ideálne firemný účet MEDEKO) alebo zvoľte platený plán.
- **Zálohy.** Pri skúšobnej prevádzke si dôležité dni môžete exportovať z Archívu (CSV). Pred ostrým nasadením si dohodnite pravidelné zálohy.

---

## 10. Ako si aplikáciu prevziať na vlastné účty

Skúšobná kópia môže bežať na účtoch, ktoré ju pripravili. Na trvalú prevádzku je lepšie, aby ju MEDEKO malo na **vlastnom GitHub účte** a **vlastnom Supabase**. Údaje zo skúšobnej databázy sa automaticky nepresunú – po prevzatí začnete s čistou databázou (alebo si dáta exportujete).

### 10.1 Vlastný GitHub a stránka

1. Založte si účet na [github.com](https://github.com).
2. Vytvorte **nový verejný repozitár**, napr. `medeco-dispecing`. (Verejný je potrebný pre bezplatné GitHub Pages.)
3. Nahrajte doň: `index.html`, `manifest.json`, `logo.svg`, ikony (`icon-192.png`, `icon-512.png`, `icon-maskable-192.png`, `icon-maskable-512.png`, `apple-touch-icon.png`), prípadne tento návod. Súbor `.nojekyll` (prázdny) nechajte, aby GitHub Pages súbory nemodifikoval.
4. V nastaveniach repozitára: **Pages** → Source **Deploy from a branch** → vetva `main`, priečinok `/ (root)`.
5. Po minúte bude adresa: `https://VÁŠ_ÚČET.github.io/medeco-dispecing/`.
6. Túto adresu dajte vodičom. Starú skúšobnú adresu potom môžete prestať používať.

Do GitHubu **nikdy** nedávajte service role kľúč, heslo databázy ani osobný token Supabase.

### 10.2 Vlastný Supabase

Postup je rovnaký ako v kapitole 8, len na účte MEDEKO. Po nasadení schémy a funkcií upravte v `index.html` hodnoty `SB_URL` a `SB_KEY` na **nový** projekt a súbor znova nahrajte na GitHub.

Ak chcete preniesť skúšobné údaje, v starej konzole Supabase použite export (Table Editor / `pg_dump`) a do novej ich importujte. Heslá používateľov sú v Auth, nie v tabuľke `users` – pri prenose je najčistejšie založiť účty znova (dispečer cez prvé spustenie, vodiči cez „Pridať vodiča“) a lístky preniesť osobitne. Ak potrebujete pomoc s prenosom, ozvite sa.

### 10.3 Heslá – technická poznámka

Supabase vyžaduje heslo dlhé aspoň 6 znakov. Aby mohol dispečer zadať aj kratšie heslo (od 3 znakov), aplikácia aj serverové funkcie na konci hesla **pridajú skrytú príponu** `-pk`. Používateľ ju **nepíše** a **nevidí**. Pri prihlásení, pri prvom spustení aj pri pridávaní vodiča sa prípona doplní sama.

Syntetický e-mail účtu má tvar `meno.priezvisko@medeko.local` (len vnútorne, pošta naň nechodí).

Ak by ste príponu menili, treba ju zmeniť na **rovnakom mieste** v `index.html` (prihlásenie a prvé spustenie) aj v oboch Edge Functions (`const PAD = "-pk"`). Inak sa nikto neprihlási.

---

## 11. Rýchly prehľad súborov

| Súbor | Význam |
|---|---|
| `index.html` | Celá aplikácia (jeden súbor) |
| `manifest.json`, ikony, `logo.svg` | Ikona na ploche a vzhľad |
| `setup/schema.sql` | Databáza – spustiť v SQL Editor |
| `setup/fn/bootstrap/index.ts` | Prvé spustenie (dispečer) |
| `setup/fn/admin-users/index.ts` | Pridávanie vodičov |
| `setup/provision.sh` | Voliteľné automatické nasadenie (pre IT) |
| `NAVOD-MEDECO.md` / `.pdf` | Tento návod |

Žiadny z týchto súborov neobsahuje tajné kľúče ani heslá.

---

*MEDEKO – Dispečing, skúšobná verzia. Pripravené november 2026.*
