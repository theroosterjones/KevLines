# KevLines - AI-Powered Fitness Form Analysis

A comprehensive fitness analysis platform with both **Python backend** for video analysis and **iOS app** for real-time pose detection and form feedback.

## 🚀 Beta Version 1.0 Released!

**KevLines Beta 1.0** is now available with a working iOS app that provides:
- ✅ **Three-tab interface**: Workout, History, Settings
- ✅ **Exercise selection**: Push-up, Squat, Row, Hack Squat
- ✅ **Basic form scoring**: Real-time form quality assessment
- ✅ **Workout tracking**: Save and view workout history
- ✅ **Settings configuration**: Customize app preferences
- ✅ **Stable build**: No crashes, ready for testing

### 📱 iOS App Features (Beta 1.0)
- **Real-time interface** with SwiftUI
- **Exercise selection** and workout management
- **Form scoring system** (basic implementation)
- **Workout history** tracking
- **Settings and preferences**
- **Camera-ready architecture** (camera functionality to be added in future updates)

### 🐍 Python Backend Features
- **Video upload and analysis** via web interface
- **Multiple exercise analyzers**: Push-ups, Squats, Rows, Hack Squats
- **YOLO-based pose detection** for enhanced accuracy
- **Form scoring and feedback** generation
- **Video processing** with MediaPipe integration

## 🏗️ Project Structure

```
KevLines/
├── app.py                    # Flask web application
├── KevLines/                 # iOS App
│   ├── KevLinesApp.swift     # App entry point
│   ├── ContentView.swift     # Main navigation
│   ├── ExerciseView.swift    # Workout interface
│   ├── PoseAnalyzer.swift    # Pose analysis logic
│   ├── CameraView.swift      # Camera interface
│   ├── WorkoutHistoryView.swift # Workout tracking
│   └── SettingsView.swift    # App settings
├── templates/                # Web interface templates
├── uploads/                  # Video upload storage
├── outputs/                  # Processed video output
├── requirements.txt          # Python dependencies
├── build_ios.sh             # iOS build script
├── setup_ios.sh             # iOS setup script
└── IOS_DEPLOYMENT_GUIDE.md  # iOS deployment guide
```

## 🚀 Quick Start

### iOS App (Beta 1.0)
1. **Open Xcode** and load `KevLines.xcodeproj`
2. **Select your development team** in project settings
3. **Build and run** on iOS Simulator or device
4. **Test the three-tab interface**: Workout, History, Settings

### Python Backend
1. **Install dependencies**: `pip install -r requirements.txt`
2. **Run the Flask app**: `python app.py`
3. **Access web interface**: `http://localhost:3000`
4. **Upload workout videos** for analysis

## 📋 Beta 1.0 Release Notes

### ✅ What's Working
- **iOS app launches** without crashes
- **All UI navigation** works smoothly
- **Exercise selection** and workout interface
- **Settings configuration** and preferences
- **Workout history** tracking system
- **Basic form scoring** display

### 🔄 Known Limitations (Beta 1.0)
- **Camera functionality** temporarily disabled (to be added in future updates)
- **Real pose detection** using mock data for now
- **Form scoring** uses basic algorithms
- **No data persistence** between app launches

### 🎯 Next Steps for Beta 2.0
- **Add camera functionality** back with proper error handling
- **Implement real pose detection** using Vision framework
- **Add data persistence** for workout history
- **Enhance form scoring** algorithms
- **Add more exercise types**

## 🛠️ Development

### iOS Development
- **Xcode 15.0+** required
- **iOS 17.0+** deployment target
- **SwiftUI** for modern UI
- **Vision framework** for pose detection (planned)

### Python Backend
- **Python 3.8+** required
- **Flask** web framework
- **MediaPipe** for pose detection
- **OpenCV** for video processing
- **YOLO** for enhanced pose detection

## 📱 Installation

### iOS App
```bash
# Clone the repository
git clone https://github.com/yourusername/kevlines.git
cd kevlines

# Open in Xcode
open KevLines/KevLines.xcodeproj

# Follow IOS_DEPLOYMENT_GUIDE.md for setup
```

### Python Backend
```bash
# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

## 🤝 Contributing

This is a beta release. Please report any issues or suggestions for improvement.

## 📄 License

This project is licensed under the MIT License.

---

**KevLines Beta 1.0** - Transform your workouts with AI-powered form analysis! 🏋️‍♂️ 