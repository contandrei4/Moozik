---
title: Moozik Backend
emoji: 🎵
colorFrom: indigo
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# Moozik Backend — API REST de analiză audio

FastAPI + librosa + madmom + yt-dlp. Fără AI generativ — totul e DSP determinist.

> Frontmatter-ul de mai sus e pentru Hugging Face Spaces (SDK Docker). Vezi
> [`DEPLOY.md`](DEPLOY.md) pentru pașii de publicare.

## Rute

| Metodă | Rută | Body | Răspuns |
|---|---|---|---|
| `GET`  | `/health` | — | `{"status":"ok","tempo_engine":"madmom\|librosa"}` |
| `POST` | `/analyze/file` | `multipart/form-data`, câmp `file` (`.mp3/.wav/.flac/.m4a/.ogg`) | `AnalysisResult` |
| `POST` | `/analyze/youtube` | `{"url": "https://youtu.be/..."}` | `AnalysisResult` |

Documentație interactivă: `http://localhost:8000/docs`.

### Forma `AnalysisResult`

```jsonc
{
  "source":        {"type": "file", "title": "…", "duration_sec": 213.4},
  "bpm":           {"value": 128.0, "confidence": 0.82, "candidates": [64.0, 256.0]},
  "time_signature":{"value": "4/4", "beats_per_bar": 4, "confidence": 0.7},
  "key":           {"tonic": "A", "scale": "minor", "camelot": "8A",
                    "confidence": 0.7, "alt": {"tonic": "C", "scale": "major"}},
  "structure":     [{"label": "Intro", "start_sec": 0.0, "end_sec": 15.2}, …],
  "waveform":      {"points": 400, "peaks": [0.0, 0.13, …]},
  "engine":        "madmom"
}
```

## Rulare locală (Windows)

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install "numpy==1.26.4" "Cython==0.29.37"
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> **Nevoie de `ffmpeg` în PATH** pentru decodare MP3 și pentru `yt-dlp`.
> Windows: `winget install Gyan.FFmpeg` sau `choco install ffmpeg`.

> **`madmom`** se compilează doar pe **Python 3.10** (nu are wheel-uri pt 3.12+).
> Dacă instalarea eșuează, backend-ul funcționează la fel folosind `librosa`
> pentru BPM/metrică (vezi `tempo_engine` în `/health`).

### Docker (recomandat pentru madmom)

```bash
cd backend
docker build -t moozik-backend .
docker run --rm -p 8000:8000 moozik-backend
```

## Configurare (variabile de mediu, prefix `MOOZIK_`)

Vezi `.env.example`. Cele mai utile: `MOOZIK_MAX_DURATION_SEC`,
`MOOZIK_MAX_UPLOAD_MB`, `MOOZIK_WAVEFORM_POINTS`, `MOOZIK_TMP_DIR`,
`MOOZIK_YTDLP_PROXY`.

## Acces de pe Android

| Client | URL backend |
|---|---|
| Emulator Android Studio | `http://10.0.2.2:8000` |
| Telefon fizic (aceeași rețea Wi-Fi) | `http://<IP-LAN-al-PC-ului>:8000` |

## Teste

```bash
pip install pytest
pytest
```

Testele folosesc semnale sintetice (click track 120 BPM, acord C major) și
verifică inclusiv că **niciun fișier temporar nu rămâne pe disc** după procesare.

## Deploy (de decis ulterior)

Imaginea Docker rulează oriunde. Note:
- **Render / Fly.io / Railway**: folosește `Dockerfile`-ul. Setează variabilele
  `MOOZIK_*`. Atenție la limitele de RAM (madmom + librosa ~1 GB pentru piese lungi).
- **YouTube**: unele platforme de hosting au IP-uri blocate de YouTube; setează
  `MOOZIK_YTDLP_PROXY` dacă apar erori `HTTP 403`.
