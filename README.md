# KevLines - AI-Powered Fitness Form Analysis

A comprehensive fitness analysis platform with **Python backend** for sophisticated video analysis and **iOS app** for user interface and video capture.

## 🎯 Current Status & Architecture

**KevLines** is transitioning to a **hybrid architecture** that leverages the best of both platforms:

### 🐍 Python Backend (Primary Analysis Engine)
- **Sophisticated exercise analyzers** with MediaPipe integration
- **Working analyzers**: Hack Squat, Row, Lat Pulldown (archived: Pushup analyzers)
- **Advanced pose detection** and form analysis
- **Video processing** with detailed feedback overlays
- **Flask web API** for iOS app integration

### 📱 iOS App (User Interface)
- **Video capture and upload** to Python backend
- **Results display** and workout tracking
- **User-friendly interface** for exercise selection
- **Download processed videos** with pose analysis overlays

## 🏗️ Current Architecture

```
iOS App → Upload Video → Python Backend → Process with MediaPipe → Return Processed Video → iOS App → Save to Device
```

### ✅ What's Currently Working
- **Python analyzers**: Hack squat, row, and lat pulldown analysis with high accuracy
- **Flask web API**: Video upload, processing, and download endpoints
- **iOS app foundation**: Basic UI and video handling structure
- **Video processing pipeline**: Upload → Analyze → Download workflow

### 🔄 Current Limitations
- **iOS app uses simulated analysis** (not connected to Python backend yet)
- **Pushup analyzers archived** (didn't work as intended)
- **No real-time connection** between iOS and Python backend

## 🏗️ Project Structure

```
KevLines/
├── app.py                           # Flask web API (Python backend)
├── hacksquat_analyzer.py           # Working hack squat analyzer
├── row_analyzer.py                 # Working row analyzer  
├── pose_analyzer.py                # Working lat pulldown analyzer
├── archive/pushup_analyzers/       # Archived pushup analyzers
├── KevLines/                       # iOS App
│   ├── KevLinesApp.swift           # App entry point
│   ├── ContentView.swift           # Main navigation
│   ├── ExerciseView.swift          # Workout interface
│   ├── PoseAnalyzer.swift          # Pose analysis logic (simulated)
│   ├── CameraView.swift            # Camera interface
│   ├── WorkoutHistoryView.swift    # Workout tracking
│   └── SettingsView.swift          # App settings
├── templates/                      # Web interface templates
├── uploads/                        # Video upload storage
├── outputs/                        # Processed video output
├── requirements.txt                # Python dependencies
└── IOS_DEPLOYMENT_GUIDE.md        # iOS deployment guide
```

## 🚀 Quick Start

### Python Backend (Primary)
1. **Install dependencies**: `pip install -r requirements.txt`
2. **Run the Flask API**: `python app.py`
3. **Access web interface**: `http://localhost:3000`
4. **Test with working exercises**: Hack squat, row, lat pulldown

### iOS App (Development)
1. **Open Xcode** and load `KevLines.xcodeproj`
2. **Select your development team** in project settings
3. **Build and run** on iOS Simulator or device
4. **Note**: Currently uses simulated analysis (backend integration in progress)

## 🎯 Development Roadmap

### Phase 1: Hybrid Architecture (Current Focus)
- **Connect iOS app to Python backend** via REST API
- **Implement video upload/download** pipeline
- **Test full workflow** with working exercises
- **Deploy Python backend** to cloud server

### Phase 2: Scale to 100s of Exercises
- **Add new exercise analyzers** to Python backend
- **Implement exercise recognition** algorithms
- **Build comprehensive exercise database**
- **Optimize video processing** for mobile uploads

### Phase 3: Machine Learning Integration
- **Collect user feedback** and form ratings
- **Train ML models** on exercise form data
- **Implement personalized coaching** algorithms
- **Add predictive analytics** for progress tracking

### Phase 4: Advanced Features
- **Real-time coaching** during workouts
- **Social features** and community challenges
- **Integration with fitness trackers**
- **Professional trainer tools**

## 🛠️ Technical Stack

### Python Backend (Primary Analysis Engine)
- **Python 3.8+** with Flask web framework
- **MediaPipe** for advanced pose detection
- **OpenCV** for video processing and analysis
- **MoviePy** for video manipulation
- **NumPy** for mathematical calculations
- **REST API** for iOS app integration

### iOS App (User Interface)
- **Xcode 15.0+** with iOS 17.0+ deployment target
- **SwiftUI** for modern, responsive UI
- **AVFoundation** for video capture and playback
- **Vision framework** for basic pose detection (future)
- **URLSession** for backend communication

### Future ML Stack
- **PyTorch/TensorFlow** for model training
- **MLflow** for model management
- **PostgreSQL** for user data and feedback
- **Cloud storage** for video datasets

## 📱 Installation

### Python Backend (Primary)
```bash
# Clone the repository
git clone https://github.com/yourusername/kevlines.git
cd kevlines

# Install dependencies
pip install -r requirements.txt

# Run the Flask API
python app.py

# Access web interface at http://localhost:3000
```

### iOS App (Development)
```bash
# Open in Xcode
open KevLines/KevLines.xcodeproj

# Follow IOS_DEPLOYMENT_GUIDE.md for setup
# Note: Currently uses simulated analysis
```

## 🎯 Current Goals

1. **Connect iOS app to Python backend** for real video analysis
2. **Deploy Python backend to cloud server** for production use
3. **Scale to support 100s of exercises** with centralized processing
4. **Integrate machine learning** for personalized coaching
5. **Build comprehensive fitness analysis platform**

## 🤝 Contributing

This project is in active development. The focus is on:
- Connecting iOS app to Python backend
- Adding new exercise analyzers
- Improving analysis accuracy
- Building ML capabilities

## 📄 License

This project is licensed under the MIT License.

---

**KevLines** - Building the future of AI-powered fitness analysis! 🏋️‍♂️ 