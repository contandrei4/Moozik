# Deploy pe Hugging Face Spaces (Docker)

Rezultatul: un API public la
`https://<user>-moozik-backend.hf.space` pe care aplicația Android îl folosește.

## 1. Cont + Space

1. Cont gratuit pe <https://huggingface.co/join> (fără card).
2. <https://huggingface.co/new-space>:
   - **Owner**: contul tău
   - **Space name**: `moozik-backend`
   - **License**: la alegere (ex. `mit`)
   - **SDK**: **Docker** → *Blank*
   - **Hardware**: `CPU basic` (gratuit, 16 GB RAM)
   - **Visibility**: Public (Private merge doar cu token în app — vezi §4)
3. **Create Space**.

## 2. Urcă codul

Conținutul folderului `backend/` din acest repo devine **rădăcina** Space-ului
(Dockerfile, `app/`, `requirements.txt`, `README.md` cu frontmatter).

```bash
# în folderul backend/
cd backend

git init
git remote add space https://huggingface.co/spaces/<user>/moozik-backend
git add Dockerfile app requirements.txt README.md .gitignore DEPLOY.md
git commit -m "Moozik backend"
git branch -M main
git push space main
```

La push îți cere user + **token** (nu parola): generează unul cu rol *write* la
<https://huggingface.co/settings/tokens>.

> Alternativ, fără git: în pagina Space → **Files** → *Add file* → urci manual
> `Dockerfile`, `requirements.txt`, `README.md` și folderul `app/`.

## 3. Așteaptă build-ul

Tab-ul **Logs** din Space arată build-ul Docker (~5–10 min prima dată — compilează
`madmom` din git). Când apare `Uvicorn running on http://0.0.0.0:7860`, e gata.

Testează:

```bash
curl https://<user>-moozik-backend.hf.space/health
# {"status":"ok","tempo_engine":"madmom"}
```

Documentația interactivă: `https://<user>-moozik-backend.hf.space/docs`

## 4. Conectează aplicația Android

În app → **Settings** → *URL backend*:

```
https://<user>-moozik-backend.hf.space
```

→ **Test conexiune** trebuie să devină „Conectat ✓ (motor tempo: madmom)".

E HTTPS, deci nu mai e nevoie de `usesCleartextTraffic`. Poți schimba și
valoarea implicită din [`app/build.gradle.kts`](../app/build.gradle.kts)
(`DEFAULT_BACKEND_URL`).

### Space privat (opțional)

Un Space public înseamnă că oricine îți poate apela API-ul. Dacă îl faci Private:
- adaugă în `app/main.py` o verificare de header `Authorization: Bearer <token>`
- trimite din Android același token (Retrofit interceptor)

Spune-mi dacă vrei să adaug asta.

## YouTube: „Sign in to confirm you're not a bot"

Pe IP de datacenter (Railway/Render/etc.) YouTube cere adesea autentificare.
Fix: cookies dintr-un cont Google.

1. Într-un browser, loghează-te pe **un cont Google de rezervă** (nu principalul —
   cookies-urile ajung pe server).
2. Instalează extensia **„Get cookies.txt LOCALLY"** (Chrome/Firefox).
3. Deschide `youtube.com`, click pe extensie → **Export** → obții un fișier
   `cookies.txt` (format Netscape).
4. Deschide fișierul, copiază **tot** conținutul.
5. Railway → serviciu → **Variables** → adaugă:
   - `MOOZIK_YTDLP_COOKIES_CONTENT` = (lipești tot textul din `cookies.txt`)
6. Railway redeployează singur. Gata.

> Cookies-urile expiră în ~2–4 săptămâni și când YouTube te dezautentifică.
> Când YouTube reîncepe să dea eroarea, repeți pașii 3–5 cu un export nou.
> Alternativ, `MOOZIK_YTDLP_PROXY` = un proxy rezidențial (contra cost).

## Note

- **Sleep**: Space-urile gratuite adorm după ~48h de inactivitate; prima cerere
  după aceea le trezește (câteva secunde). Nu adorm la fiecare 15 min ca Render.
- **yt-dlp / YouTube**: IP-urile Hugging Face pot fi uneori limitate de YouTube
  (`HTTP 403`). Dacă se întâmplă, setează în Space → *Settings* → *Variables* o
  variabilă `MOOZIK_YTDLP_PROXY`.
- **Limite**: `MOOZIK_MAX_DURATION_SEC` (720s implicit), `MOOZIK_MAX_UPLOAD_MB`
  (30 implicit) — se pot seta ca *Variables* în Space.
