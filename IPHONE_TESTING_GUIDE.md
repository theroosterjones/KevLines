# iPhone Testing Guide for KevLines

## Overview
This guide will help you test the KevLines app on a physical iPhone device with video upload, processing, and download functionality.

## Prerequisites
- Physical iPhone device (not simulator)
- Computer running the Python backend
- Both devices on the same WiFi network
- Xcode installed on your Mac

## Setup Steps

### 1. Network Configuration

#### Get Your Computer's IP Address
```bash
# Run the setup script
./setup_iphone_testing.sh
```

#### Update iOS App Configuration
1. Open `KevLines/KevLines/APIService.swift`
2. Update the `baseURL` to your computer's IP address:
   ```swift
   private let baseURL = "http://YOUR_IP_ADDRESS:3000"
   ```

### 2. Backend Setup

#### Start the Python Backend
```bash
# In the KevLines directory
python app.py
```

The backend should start on `http://0.0.0.0:3000` and be accessible from your iPhone.

### 3. iOS App Configuration

#### Required Permissions
The app needs the following permissions (already configured):
- Camera access
- Photos library access
- Network access

#### Build and Deploy
1. Open `KevLines.xcodeproj` in Xcode
2. Connect your iPhone via USB
3. Select your iPhone as the target device
4. Build and run the app

### 4. Testing Workflow

#### Video Upload Test
1. Open the KevLines app on your iPhone
2. Tap "Choose Video" to select a video from your Photos library
3. The app should load the video and show a preview
4. Select an exercise type (pushup, squat, row, hacksquat)

#### Video Analysis Test
1. Tap "Analyze Form" button
2. The app will:
   - Upload the video to the Python backend
   - Process the video with pose analysis
   - Download the analyzed video back to the iPhone
3. Monitor the progress indicators

#### Video Download Test
1. After analysis completes, tap "Download Analyzed Video"
2. The app will save the processed video to your Photos library
3. Check your Photos app to confirm the video was saved

## Troubleshooting

### Connection Issues
- **Backend not reachable**: Check that both devices are on the same WiFi network
- **Firewall blocking**: Ensure port 3000 is not blocked by firewall
- **VPN interference**: Try disabling VPN if connected

### Video Upload Issues
- **Permission denied**: Check Photos library permissions in iOS Settings
- **File too large**: The backend supports up to 500MB files
- **Unsupported format**: Supported formats: mp4, avi, mov, mkv, wmv, flv, webm

### Analysis Issues
- **Backend error**: Check Python backend logs for error messages
- **Processing timeout**: Large videos may take longer to process
- **Memory issues**: Close other apps to free up memory

## Network Configuration Details

### Backend Configuration
The Python backend is configured to:
- Accept connections from any IP address (`0.0.0.0:3000`)
- Handle CORS requests from iOS app
- Support large file uploads (up to 500MB)
- Process videos with pose analysis

### iOS App Configuration
The iOS app is configured to:
- Connect to the backend via HTTP
- Handle video upload/download
- Save processed videos to Photos library
- Show progress indicators during processing

## Testing Checklist

- [ ] Backend running and accessible from iPhone
- [ ] Video selection from Photos library works
- [ ] Video upload to backend succeeds
- [ ] Video analysis completes successfully
- [ ] Analyzed video downloads to iPhone
- [ ] Video saves to Photos library
- [ ] Error handling works for various failure scenarios

## Performance Notes

- Video processing time depends on video length and complexity
- Large videos (>100MB) may take several minutes to process
- The app shows progress indicators during processing
- Network speed affects upload/download times

## Security Considerations

- The backend runs on your local network only
- No data is sent to external servers
- Videos are processed locally on your computer
- All communication is over your local WiFi network
