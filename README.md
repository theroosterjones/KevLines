# KevLines 1.x - AI-Powered Fitness Form Analysis (Cloud Architecture)

> **This project has been superseded by [KevLines 2.0](https://github.com/theroosterjones/KevLines2.0), which moves the entire processing pipeline on-device for dramatically faster performance. This repository is preserved as a reference.**

## What KevLines 1.x Does

KevLines is a fitness form analysis platform that records exercise videos and overlays biomechanical feedback (joint angles, skeleton lines, rep counts). It uses a **Python backend** running MediaPipe for pose estimation and an **iOS app** for video capture and playback.

### Supported Exercises
- Hack Squat (knee, hip, spine angles)
- Barbell Row (elbow, shoulder angles, spine line, rep counting)
- Back Squat (knee, hip angles, extended reference lines)
- Lat Pulldown (elbow, shoulder angles, forearm line)
- Squat (knee angle, rep counting)

## Architecture (1.x)

```
iPhone → Upload video (HTTPS) → Render cloud server → MediaPipe + OpenCV → Download analyzed video → iPhone
```

## Known Limitations of 1.x

These are the specific problems that led to the KevLines 2.0 rewrite:

1. **Slow round-trip processing**: Full video uploaded to cloud, processed server-side, downloaded back. A 30-second video takes 2-5 minutes end-to-end on cellular.
2. **Software-only video decode**: `cv2.VideoCapture` uses CPU-only decoding on the server. No hardware acceleration.
3. **No GPU for pose estimation**: MediaPipe runs on server CPU without GPU delegate. Every frame is CPU-bound.
4. **Codec fallback cascade**: Tries 5 codecs sequentially (`H264 → avc1 → mp4v → XVID → MJPG`) on every export because server environment codec support is unpredictable.
5. **Double encoding**: After OpenCV writes the video, a second ffmpeg pass re-encodes for color space preservation. Two full decode/encode cycles per video.
6. **Render cold starts**: The free-tier Render instance spins down after inactivity. First request can take 30-60 seconds just to wake the server before processing begins.
7. **100MB upload limit**: Large or high-resolution videos must be trimmed or compressed before upload.
8. **No real-time analysis**: Cannot process live camera feed because of network dependency.
9. **No tempo tracking**: No phase detection for eccentric/pause/concentric timing.
10. **Duplicated analyzer code**: `calculate_angle`, `extend_line_to_frame`, `smooth_landmark`, and video I/O boilerplate are copy-pasted across all 5 analyzer files.
11. **No data persistence**: Workout history is stored in `@State` and lost when the app closes.

## Project Structure

```
KevLines/
├── app.py                          # Flask backend (API server)
├── pose_analyzer.py                # Lat pulldown analyzer
├── row_analyzer.py                 # Row analyzer (with smoothing, rep counting)
├── hacksquat_analyzer.py           # Hack squat analyzer
├── backsquat_analyzer.py           # Back squat analyzer (with smoothing)
├── hacksquat_analyzer_line.py      # Hack squat variant with extended lines
├── pose_analyzer_0.5.py            # Older pose analyzer
├── requirements.txt                # Python: flask, mediapipe, opencv, numpy, moviepy
├── Procfile / render.yaml          # Render deployment config
├── Dockerfile                      # Docker config
├── KevLines/                       # Xcode iOS app
│   ├── KevLines/
│   │   ├── KevLinesApp.swift       # App entry point
│   │   ├── ContentView.swift       # Tab navigation
│   │   ├── ExerciseView.swift      # Video selection, upload, analysis flow
│   │   ├── APIService.swift        # HTTPS client for Render backend
│   │   ├── PoseAnalyzer.swift      # Vision-based pose overlay (preview only)
│   │   ├── CameraView.swift        # AVCaptureSession camera
│   │   ├── WorkoutHistoryView.swift
│   │   └── SettingsView.swift
├── archive/pushup_analyzers/       # Archived pushup analyzers (didn't work)
└── templates/                      # Web UI templates
```

## Running 1.x

### Python Backend
```bash
pip install -r requirements.txt
python app.py
# API at http://localhost:3000
```

### iOS App
```bash
open KevLines/KevLines.xcodeproj
# Build and run in Xcode (requires Render backend running)
```

## What Changed in 2.0

KevLines 2.0 is a ground-up rebuild as a **pure Swift iOS app** with **no server dependency**:

- All video processing runs locally on-device using AVFoundation hardware acceleration
- MediaPipe iOS SDK replaces the Python MediaPipe backend (same 33 landmarks)
- Overlays rendered directly onto pixel buffers via Core Graphics
- Single-pass hardware encode via AVAssetWriter (no codec hunting, no re-encoding)
- Modular analyzer architecture with shared math utilities
- Tempo tracking (eccentric/pause/concentric/pause phase detection)
- ~10-30x faster processing than 1.x

See the [KevLines 2.0 repository](https://github.com/theroosterjones/KevLines2.0) for the new architecture.

## License

MIT License
