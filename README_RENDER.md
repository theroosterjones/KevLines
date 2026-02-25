# KevLines Flask Backend Deployment (Render)

This guide deploys your existing `app.py` Flask backend to Render with HTTPS and production settings.

## Included files

- `app.py` (your existing backend, with env-based production config)
- `requirements.txt` (runtime dependencies, including `gunicorn`)
- `render.yaml` (Blueprint config for Render Web Service)
- `Procfile` (alternative start command definition)

## What changed for production

- Uses Gunicorn instead of Flask dev server.
- Adds request and resource timeouts in Gunicorn.
- Adds env-configurable upload size in `app.py` via:
  - `MAX_CONTENT_LENGTH_MB` (default `500`)
- Adds env-configurable storage root in `app.py` via:
  - `APP_STORAGE_ROOT` (default current directory)

## 1) Deploy with Render Blueprint (recommended)

1. Push this repo to GitHub/GitLab.
2. In Render: **New +** -> **Blueprint**.
3. Select this repo. Render detects `render.yaml`.
4. Confirm service settings and create.
5. Wait for build/deploy to finish.

Render automatically provides HTTPS at:
- `https://<your-service-name>.onrender.com`

## 2) Manual Render Web Service setup (if not using Blueprint)

1. In Render: **New +** -> **Web Service**
2. Connect this repo.
3. Configure:
   - **Runtime**: Python
   - **Build Command**:
     - `pip install --upgrade pip && pip install -r requirements.txt`
   - **Start Command**:
     - `gunicorn app:app --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 300 --graceful-timeout 60 --keep-alive 5`
4. Add environment variables (below).
5. Deploy.

## Environment variables

Required:
- `PORT` (provided by Render automatically)

Recommended:
- `FLASK_ENV=production`
- `PYTHONUNBUFFERED=1`
- `MAX_CONTENT_LENGTH_MB=500`
- `APP_STORAGE_ROOT=.` (or a mounted path if you add persistent disk storage)

Optional:
- `PYTHON_VERSION=3.11.9` (via Render setting or `render.yaml`)

## Test the deployed backend

Assume base URL:
- `BASE_URL=https://<your-service-name>.onrender.com`

Health check:
- `GET $BASE_URL/api/status`

Quick terminal test:

```bash
curl -s https://<your-service-name>.onrender.com/api/status
```

You should get JSON with `status: "online"`.

Upload test:

```bash
curl -X POST \
  -F "file=@/absolute/path/to/video.mov" \
  https://<your-service-name>.onrender.com/upload
```

Analyze test:

```bash
curl -X POST https://<your-service-name>.onrender.com/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "filename": "20260101_120000_video.mov",
    "exercise_type": "row",
    "side": "left"
  }'
```

## iOS app config for Render

In `APIService.swift`, point `baseURL` to your Render HTTPS URL:

- `https://<your-service-name>.onrender.com`

Do not use `http://` for production on iPhone.

## Large video upload guidance (production)

1. **Request timeout**
   - Gunicorn `--timeout 300` is already set.
   - Increase for longer analyses if needed.

2. **Upload size limits**
   - Flask limit is controlled by `MAX_CONTENT_LENGTH_MB`.
   - Keep this aligned with client-side limits.

3. **Cold starts**
   - Render services can cold-start on inactivity.
   - Consider Starter/Standard plan and health pings.

4. **CPU-heavy analysis**
   - MediaPipe/OpenCV analysis is CPU-intensive.
   - Start with `--workers 1` to avoid OOM, then tune.

5. **Storage considerations**
   - Local disk is ephemeral unless using persistent disk.
   - For durable file retention, move uploads/outputs to object storage (S3/R2/GCS).

6. **Async processing (recommended at scale)**
   - For long jobs, offload analysis to a queue worker (RQ/Celery) and return job IDs.
   - Poll job status from iOS instead of keeping one long HTTP request open.

## Notes about system packages

- Your analyzers can call `ffmpeg` via subprocess for post-processing.
- If Render environment lacks `ffmpeg`, your code currently falls back and still returns output.
- If strict ffmpeg output is required, use a Docker deployment that installs ffmpeg explicitly.
