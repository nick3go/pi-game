# π lab

Minimalistična spletna aplikacija za učenje in vadbo decimalk števila π.

## Funkcije

- Vaja se konča ob prvi napačni decimalki; izpiše napačno in pričakovano številko.
- Prikaz trenutnega rezultata in možnost takojšnjega ponovnega poskusa.
- Učenje številk po skupinah po 3, 5 ali 10; prikaz do 500 decimalk.
- Gostujoča uporaba brez profila ali profil z enim alfanumeričnim vzdevkom.
- Osebni rekord se shrani v Supabase in se posodobi samo navzgor.
- Prilagojeno mobilnim telefonom; brez namestitve ali knjižnic.

## Zagon

1. V svojem **obstoječem** Supabase projektu odpri **SQL Editor**.
2. Izvedi **celotno** datoteko [setup.sql](./setup.sql). Skripta ustvarja samo shemo `pi_private`, tabelo profilov in tri javne RPC funkcije z imeni `pi_...`; shem drugih aplikacij ne spreminja.
3. V GitHubu pod **Settings → Pages** omogoči **Deploy from a branch**, izberi `main` in `/ (root)`.
4. Odpri spletno stran. Vadba deluje tudi brez Supabase, za profil in rekord pa mora biti SQL že izveden.

Javni Supabase URL in publishable ključ sta v `index.html` (podatki iz že javno objavljene konfiguracije drugih projektov). **Service-role ali skrivnih ključev nikoli ne vstavljaj v brskalniško kodo.**

## Kako deluje

Prve 1.500 decimalk se izračuna v brskalniku (Machinova formula z `BigInt`); prvih 30 se preveri z znano referenco. Prva številka, ki jo vneseš, je **1** (prva decimalka števila 3,14159…).

## Varnost in omejitve

**Vzdevek ni varna prijava.** Kdor pozna vzdevek, lahko uporablja isti profil in posodablja njegov rekord. Rezultat se izračuna v brskalniku, zato ga lahko tehnično podtakne vsak z dostopom do API-ja. Rekordi so primerni za sproščeno igro, ne za varno tekmovanje. Za preverjeno avtentikacijo je potreben Supabase Auth in preverjanje poskusov na strežniku.

Če profil ne deluje, preveri, ali je bil SQL izveden v pravilnem projektu ter ali so funkcije na voljo v shemi `public`. Podatkov v drugih aplikacijah ni treba spreminjati.
