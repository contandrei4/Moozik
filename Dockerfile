# Python 3.11 — librosa + ffmpeg. Fără madmom (prea greu pt hosting mic;
# vezi nota de mai jos dacă ai un plan cu >= 2 GB RAM).
FROM python:3.11-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 appuser
USER appuser
ENV PATH="/home/appuser/.local/bin:$PATH"
WORKDIR /home/appuser/app

COPY --chown=appuser requirements.txt .
RUN pip install --no-cache-dir --user "numpy==1.26.4" \
    && pip install --no-cache-dir --user -r requirements.txt

COPY --chown=appuser app ./app

# Railway/Render injectează $PORT; local implicit 8000.
ENV PORT=8000
EXPOSE 8000
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]

# --- madmom (BPM/downbeat mai precis) — OPȚIONAL, doar cu >= 2 GB RAM ---
# Adaugă `git build-essential` la apt-get, apoi:
#   RUN pip install --no-cache-dir --user "Cython==0.29.37" \
#       && pip install --no-cache-dir --user "git+https://github.com/CPJKU/madmom.git@main"
# și setează variabila de mediu MOOZIK_USE_MADMOM=true.
