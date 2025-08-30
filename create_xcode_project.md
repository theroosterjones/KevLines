# 🔧 Creating a New Xcode Project for KevLines

Since the previous Xcode project got corrupted, we need to create a new one. Here's how to do it:

## Step 1: Create New Xcode Project

1. **Open Xcode**
2. **Choose "Create a new Xcode project"**
3. **Select "iOS" → "App"**
4. **Configure the project:**
   - **Product Name**: `KevLines`
   - **Team**: Your development team
   - **Organization Identifier**: `com.kevlines` (or your own)
   - **Bundle Identifier**: `com.kevlines.app`
   - **Language**: `Swift`
   - **Interface**: `SwiftUI`
   - **Life Cycle**: `SwiftUI App`
   - **Use Core Data**: `No`
   - **Include Tests**: `No`

5. **Save the project** in the `/Users/kevinjones/Documents/KevLines` directory
6. **Replace the existing files** when prompted

## Step 2: Add Required Files

After creating the project, you'll need to add the existing Swift files:

1. **Delete the default files** that Xcode created:
   - Delete the default `ContentView.swift` (we have our own)
   - Keep `KevLinesApp.swift` but replace its contents

2. **Add our existing files**:
   - Right-click on the KevLines folder in Xcode
   - Choose "Add Files to 'KevLines'"
   - Select all these files from the KevLines directory:
     - `KevLinesApp.swift`
     - `ContentView.swift`
     - `PoseAnalyzer.swift`
     - `CameraView.swift`
     - `ExerciseView.swift`
     - `WorkoutHistoryView.swift`
     - `SettingsView.swift`

## Step 3: Configure Project Settings

1. **Select the KevLines project** in the navigator
2. **Select the KevLines target**
3. **Go to "Signing & Capabilities"**:
   - Select your development team
   - Bundle Identifier: `com.kevlines.app`

4. **Go to "Info" tab** and add these keys:
   - `NSCameraUsageDescription`: `KevLines needs camera access to analyze your workout form and provide real-time feedback.`
   - `NSMicrophoneUsageDescription`: `KevLines may use microphone access for audio feedback during workouts.`

## Step 4: Build and Test

1. **Select iOS Simulator** as the target device
2. **Press Cmd+R** to build and run
3. **Test the app** in the simulator first

## Alternative: Use the Setup Script

If you prefer, you can run the setup script after creating the project:

```bash
./setup_ios.sh
```

This will help configure the project settings automatically.

## Troubleshooting

### If you get build errors:
1. **Clean the build folder**: Product → Clean Build Folder
2. **Check that all files are added** to the project
3. **Verify the bundle identifier** is correct
4. **Make sure your development team** is selected

### If the app crashes:
1. **Check the console** for error messages
2. **Verify camera permissions** are configured
3. **Test on simulator first** before trying on device

---

**Once you've created the new project, you should be able to build and run the app successfully!**
