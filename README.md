# Moozik

Aplicație Android de **analiză audio deterministă** (fără AI generativ): încarci o
piesă și primești **BPM, cheia muzicală, metrica și structura** (Intro / Strofă /
Refren / Punte / Outro), extrase direct din semnal prin procesare de semnal (DSP).

## Componente

| Folder     | Ce este                              | Stack |
|------------|--------------------------------------|-------|
| `app/`     | Client Android nativ                 | Kotlin, Jetpack Compose, Media3, Retrofit |
| `backend/` | API REST care face toată analiza DSP | Python, FastAPI, librosa, SciPy, scikit-learn |

Cele două componente sunt decuplate și comunică prin JSON peste HTTPS. Backend-ul
e stateless — fiecare cerere e independentă, fișierul temporar se șterge imediat.

## Funcționalități

- Analiză: **BPM** (+ candidați half/double), **cheie** + gamă alternativă + cod
  Camelot, **metrică** (3/4 vs 4/4), **structură** (segmentare Laplaciană McFee-Ellis)
- **Waveform interactiv** — benzi colorate pe secțiuni, tap = redare de la acel moment
- **Istoric local** — ultimele analize, redeschidere instantă fără backend
- **Comparație** — două piese una lângă alta (BPM, cheie, compatibilitate de mixaj)
- **Export** JSON

## Rulare

### Backend
```bash
cd backend
python -m venv .venv && .venv\Scripts\activate
pip install -r requirements-local.txt      # varianta fără madmom (Python 3.11/3.12)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Pentru deploy: `backend/Dockerfile` (rulează pe Railway, Render, orice hosting Docker).

### Android
Deschide folderul rădăcină în Android Studio → Run. În ecranul **Settings**
setează URL-ul backend-ului (implicit `http://10.0.2.2:8000` pentru emulator).

## Algoritmi

| Metrică | Metodă |
|---|---|
| BPM | onset strength → `librosa.beat.beat_track` (autocorelație) |
| Cheie | chromagram CENS → corelație cu profilele Temperley (Kostka-Payne) |
| Metrică | grupare bătăi în 3 vs 4, accent maxim pe primul timp |
| Structură | recurrence + sequence matrix → Laplacian → clustering spectral (K-Means) |

## Limitări

- Fără ML antrenat: precizie mai mică pe metal / jazz / experimental
- Structura e aproximativă când strofa și refrenul au aceeași armonie
- Import YouTube dezactivat (platforma blochează extragerea audio de pe servere)
