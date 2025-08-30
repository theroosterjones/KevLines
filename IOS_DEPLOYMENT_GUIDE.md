# 🚀 KevLines iOS Beta Deployment Guide

This guide will walk you through getting the KevLines beta version running on your iOS device.

## 📋 Prerequisites

### 1. Install Xcode
- **Download Xcode** from the Mac App Store (15GB download)
- **Launch Xcode** once after installation to accept licenses
- **Install iOS Simulator** when prompted

### 2. Apple Developer Account Setup
You have two options:

#### Option A: Free Apple Developer Account (Recommended for Beta)
- Go to [developer.apple.com](https://developer.apple.com)
- Sign in with your Apple ID
- Accept the free developer agreement
- **Limitation**: Apps expire after 7 days and need to be reinstalled

#### Option B: Paid Developer Account ($99/year)
- Required for App Store distribution
- Apps can be installed for 1 year
- Access to TestFlight for beta distribution

## 🔧 Setup Steps

### Step 1: Configure Xcode Command Line Tools
After installing Xcode, run:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Step 2: Open Project in Xcode
```bash
open KevLines.xcodeproj
```

### Step 3: Configure Signing & Capabilities

1. **Select the KevLines project** in the navigator
2. **Select the KevLines target**
3. **Go to "Signing & Capabilities" tab**
4. **Configure your team**:
   - Select your Apple Developer account
   - Bundle Identifier: `com.kevlines.app` (or change to something unique)
   - Team: Your development team

### Step 4: Configure Device Deployment

1. **Connect your iPhone** via USB
2. **Trust the computer** on your iPhone if prompted
3. **In Xcode**:
   - Select your device from the device dropdown
   - If your device doesn't appear, click "Window" → "Devices and Simulators"
   - Make sure your device is trusted

### Step 5: Build and Deploy

#### Method A: Using Xcode (Recommended)
1. **Select your device** in the device dropdown
2. **Press Cmd+R** to build and run
3. **Trust the developer** on your iPhone when prompted
4. **Grant camera permissions** when the app requests them

#### Method B: Using Build Script
```bash
# Update the build script with your team ID
# Edit build_ios.sh and add your TEAM_ID

# Build for device
./build_ios.sh device

# Create archive for distribution
./build_ios.sh archive

# Export IPA
./build_ios.sh export
```

## 📱 Testing the App

### First Launch
1. **Open KevLines** on your device
2. **Grant camera permissions** when prompted
3. **Navigate through the tabs**:
   - **Workout**: Main exercise interface
   - **History**: Past workouts (empty initially)
   - **Settings**: App configuration

### Testing Features
1. **Camera Access**: The app should request camera permissions
2. **Exercise Selection**: Tap the exercise type to change
3. **Recording**: Tap the red record button to start
4. **Pose Detection**: Position yourself in frame to test pose detection

## 🔍 Troubleshooting

### Common Issues

#### "No provisioning profiles found"
- **Solution**: Make sure you're signed in to Xcode with your Apple ID
- **Solution**: Select your development team in project settings

#### "App installation failed"
- **Solution**: Trust the developer in Settings → General → VPN & Device Management
- **Solution**: Delete the app and reinstall

#### "Camera access denied"
- **Solution**: Go to Settings → Privacy & Security → Camera → KevLines → Allow

#### "Build failed"
- **Solution**: Check that all Swift files are included in the project
- **Solution**: Clean build folder (Product → Clean Build Folder)

### Device-Specific Issues

#### iPhone Not Appearing
1. **Check USB connection**
2. **Trust the computer** on your iPhone
3. **Restart Xcode**
4. **Check device management** in Xcode (Window → Devices and Simulators)

#### App Crashes on Launch
1. **Check console logs** in Xcode
2. **Verify camera permissions**
3. **Test on simulator first**

## 📊 Beta Testing Features

### Current Features
- ✅ **Real-time pose detection** using Vision framework
- ✅ **Exercise selection** (Push-up, Squat, Row, Hack Squat)
- ✅ **Form scoring** and feedback
- ✅ **Rep counting** (basic implementation)
- ✅ **Workout history** tracking
- ✅ **Settings configuration**

### Known Limitations
- 🔄 **Rep counting** needs refinement
- 🔄 **Form scoring** algorithms need tuning
- 🔄 **Exercise-specific feedback** needs enhancement
- 🔄 **Data persistence** needs implementation

## 🚀 Next Steps for Production

### Short Term (1-2 weeks)
1. **Fix rep counting logic**
2. **Improve form scoring algorithms**
3. **Add data persistence** for workout history
4. **Enhance UI/UX** based on beta feedback

### Medium Term (1-2 months)
1. **Add more exercise types**
2. **Implement social features**
3. **Add progress analytics**
4. **Optimize performance**

### Long Term (3+ months)
1. **App Store submission**
2. **Apple Watch companion app**
3. **Cloud sync** for workout data
4. **AI-powered coaching**

## 📞 Support

### Getting Help
- **Check console logs** in Xcode for error details
- **Test on simulator** first to isolate device issues
- **Verify permissions** are granted correctly

### Reporting Issues
- **Document the issue** with screenshots/videos
- **Include device model** and iOS version
- **Describe steps to reproduce**

---

**Happy Testing! 🏋️‍♂️**

The KevLines beta is now ready for testing on your iOS device. Start with basic functionality and gradually test more advanced features as you become familiar with the app.
