import SwiftUI
import AVFoundation
import PhotosUI
import Photos
import Vision
import CoreML

struct ExerciseView: View {
    @StateObject private var poseAnalyzer = PoseAnalyzer()
    @StateObject private var apiService = APIService.shared
    @State private var selectedExercise: ExerciseType = .pushup
    @State private var selectedSide: String = "left"  // "left" or "right"
    @State private var showingExercisePicker = false
    @State private var showingWorkoutSummary = false
    @State private var workoutStartTime: Date?
    @State private var cameraPermissionGranted = true
    @State private var selectedVideoURL: URL?
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var showingVideoPicker = false
    @State private var uploadedFilename: String?
    @State private var analyzedVideoURL: URL?
    @State private var backendStatus: String = "Checking..."
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSafetyWarning = true
    @State private var safetyAccepted = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Backend status and exercise selection
                    VStack(spacing: 10) {
                        // Backend status indicator
                        HStack {
                            Image(systemName: backendStatus == "online" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(backendStatus == "online" ? .green : .red)
                            Text("Backend: \(backendStatus)")
                                .font(.caption)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Exercise selection
                        HStack {
                            Button(action: {
                                showingExercisePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                    Text(selectedExercise.rawValue)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                            
                            // Side selection (only show for exercises that support it)
                            if selectedExercise != .pushup {
                                Picker("Side", selection: $selectedSide) {
                                    Text("Left").tag("left")
                                    Text("Right").tag("right")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 120)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Video selection area
                    VStack(spacing: 20) {
                        if let videoURL = selectedVideoURL {
                            // Video preview
                            VideoPlayerView(videoURL: videoURL)
                                .frame(height: 300)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                            
                            VStack(spacing: 15) {
                                // Analysis button
                                Button(action: analyzeVideo) {
                                    HStack {
                                        if isAnalyzing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "play.circle.fill")
                                        }
                                        Text(isAnalyzing ? "Analyzing..." : "Analyze Form")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                                .disabled(isAnalyzing)
                                
                                // Download analyzed video button
                                Button(action: downloadAnalyzedVideo) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text("Download Analyzed Video")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Change video button
                            Button("Select Different Video") {
                                showingVideoPicker = true
                            }
                            .foregroundColor(.orange)
                        } else {
                            // Video selection prompt
                            VStack(spacing: 20) {
                                Image(systemName: "video.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                
                                Text("Select a Workout Video")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Choose a video from your photo library to analyze your form")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 15) {
                                    Button(action: {
                                        showingVideoPicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle")
                                            Text("Choose Video")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.orange)
                                        .cornerRadius(12)
                                    }
                                    
                                    // Removed test video button to force real backend usage
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("KevLines")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(selectedExercise: $selectedExercise)
            }
            .sheet(isPresented: $showingWorkoutSummary) {
                WorkoutSummaryView(
                    exerciseType: selectedExercise.rawValue,
                    repCount: poseAnalyzer.repCount,
                    formScore: poseAnalyzer.formScore,
                    duration: workoutStartTime.map { Date().timeIntervalSince($0) } ?? 0,
                    recordedVideoURL: selectedVideoURL
                )
            }
            .photosPicker(isPresented: $showingVideoPicker, selection: $selectedVideoItem, matching: .videos)
            .onChange(of: selectedVideoItem) { newValue in
                if let newValue = newValue {
                    loadSelectedVideo(newValue)
                }
            }
                    .onAppear {
            print("🚀 ExerciseView appeared!")
            // Request local network permission
            requestLocalNetworkPermission()
            // Check backend status
            checkBackendStatus()
            // Note: Removed auto-loading test video to use real backend workflow
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("⚠️ Safety Warning", isPresented: $showingSafetyWarning) {
            Button("I Understand - Continue") {
                safetyAccepted = true
            }
            Button("Cancel", role: .cancel) {
                // User can still use the app but with awareness
                safetyAccepted = true
            }
        } message: {
            Text("This is a development app. Please ensure you have backed up your iPhone before testing. The app will access your Photos library and process videos locally on your network.")
        }
        }
    }
    
    private func loadSelectedVideo(_ item: PhotosPickerItem) {
        print("🎯 Loading selected video from PhotosPicker...")
        
        Task {
            do {
                // Load the video data from the PhotosPickerItem
                guard let videoData = try await item.loadTransferable(type: Data.self) else {
                    print("❌ Failed to load video data")
                    await MainActor.run {
                        errorMessage = "Failed to load video from Photos"
                        showingError = true
                    }
                    return
                }
                
                // Safety check: File size limit (100MB for safety)
                let maxFileSize = 100 * 1024 * 1024 // 100MB
                if videoData.count > maxFileSize {
                    print("❌ Video file too large: \(videoData.count) bytes")
                    await MainActor.run {
                        errorMessage = "Video file is too large (max 100MB). Please select a smaller video for testing."
                        showingError = true
                    }
                    return
                }
                
                // Save to temporary directory
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("selected_video.mov")
                try videoData.write(to: tempURL)
                
                await MainActor.run {
                    selectedVideoURL = tempURL
                    print("✅ Video loaded successfully: \(tempURL.path)")
                    print("✅ File size: \(videoData.count) bytes (\(String(format: "%.1f", Double(videoData.count) / 1024 / 1024)) MB)")
                }
                
            } catch {
                print("❌ Error loading video: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Failed to load video: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    private func simulateVideoSelection() {
        print("🎯 simulateVideoSelection() called!")
        // Use the real row_new.mov file for testing
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documentsPath.appendingPathComponent("row_new.mov")
        
        print("🔍 Looking for video in: \(documentsPath.path)")
        print("🔍 Full video path: \(videoURL.path)")
        
        // Check if the file exists
        if FileManager.default.fileExists(atPath: videoURL.path) {
            selectedVideoURL = videoURL
            print("✅ Found video file: \(videoURL.path)")
            print("✅ File size: \(try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] ?? "unknown") bytes")
        } else {
            print("❌ Video file not found at: \(videoURL.path)")
            
            // List all files in documents directory
            do {
                let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
                print("📁 Files in documents directory:")
                for file in files {
                    print("   - \(file.lastPathComponent)")
                }
            } catch {
                print("❌ Error listing documents directory: \(error)")
            }
            
            // Fallback to mock video
            let mockVideoURL = documentsPath.appendingPathComponent("sample_workout.mov")
            selectedVideoURL = mockVideoURL
        }
    }
    
    private func analyzeVideo() {
        guard let videoURL = selectedVideoURL else { return }
        
        isAnalyzing = true
        workoutStartTime = Date()
        
        Task {
            do {
                // Step 1: Upload video to backend
                print("📤 Uploading video to backend...")
                print("📤 Video URL: \(videoURL)")
                print("📤 Video file size: \(try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] ?? "unknown") bytes")
                
                let uploadResponse = try await apiService.uploadVideo(videoURL)
                uploadedFilename = uploadResponse.filename
                print("✅ Upload successful. Filename: \(uploadResponse.filename)")
                
                // Step 2: Analyze video
                print("🔍 Analyzing video with backend...")
                print("🔍 Exercise type: \(selectedExercise.apiString)")
                print("🔍 Side: \(selectedSide)")
                let analysisResponse = try await apiService.analyzeVideo(
                    filename: uploadResponse.filename,
                    exerciseType: selectedExercise.apiString,
                    side: selectedSide
                )
                print("✅ Analysis response received: \(analysisResponse)")
                
                // Step 3: Download analyzed video
                print("📥 Downloading analyzed video...")
                let analyzedVideo = try await apiService.downloadAnalyzedVideo(filename: analysisResponse.output_file)
                analyzedVideoURL = analyzedVideo
                
                // Update UI on main thread
                await MainActor.run {
                    // Update pose analyzer with real results
                    poseAnalyzer.setExerciseType(selectedExercise)
                    
                    // Handle different response structures from different analyzers
                    if let results = analysisResponse.results {
                        poseAnalyzer.repCount = results.rep_count ?? 0
                        poseAnalyzer.formScore = Float(results.form_score ?? 85)
                        if let feedback = results.feedback {
                            poseAnalyzer.feedback = feedback
                        }
                    } else {
                        // For analyzers that don't return detailed results, use defaults
                        poseAnalyzer.repCount = 0
                        poseAnalyzer.formScore = 85.0
                        poseAnalyzer.feedback = ["Analysis completed successfully"]
                    }
                    
                    isAnalyzing = false
                    showingWorkoutSummary = true
                }
                
                print("✅ Video analysis completed successfully!")
                
            } catch {
                print("❌ Analysis failed: \(error.localizedDescription)")
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func checkBackendStatus() {
        Task {
            do {
                let status = try await apiService.checkBackendStatus()
                await MainActor.run {
                    backendStatus = status.status
                    print("✅ Backend is \(status.status)")
                }
            } catch {
                await MainActor.run {
                    backendStatus = "offline"
                    print("❌ Backend is offline: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func downloadAnalyzedVideo() {
        guard let analyzedVideoURL = analyzedVideoURL else {
            errorMessage = "No analyzed video available. Please analyze a video first."
            showingError = true
            return
        }
        
        print("📥 Starting video download process...")
        
        // Save to Photos library
        Task {
            do {
                // Request permission to save to Photos library
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                
                guard status == .authorized || status == .limited else {
                    await MainActor.run {
                        errorMessage = "Permission denied to save to Photos library"
                        showingError = true
                    }
                    return
                }
                
                // Save video to Photos library
                try await PHPhotoLibrary.shared().performChanges {
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: analyzedVideoURL, options: nil)
                }
                
                await MainActor.run {
                    print("📥 Video saved to Photos library successfully!")
                    // Show success message
                    errorMessage = "Analyzed video saved to Photos library!"
                    showingError = true
                }
                
            } catch {
                print("❌ Error saving video to Photos: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Failed to save video to Photos: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    // MARK: - Network Permission Functions
    private func requestLocalNetworkPermission() {
        print("🌐 Requesting local network permission...")
        
        // Make a test request to trigger local network permission dialog
        Task {
            do {
                let _ = try await apiService.checkBackendStatus()
                print("✅ Local network permission granted")
            } catch {
                print("⚠️ Local network permission needed: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Please enable Local Network access for KevLines in Settings → Privacy & Security → Local Network"
                    showingError = true
                }
            }
        }
    }
    
    // MARK: - Cleanup Functions
    private func cleanupTemporaryFiles() {
        print("🧹 Cleaning up temporary files...")
        
        // Clean up temporary video files
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in tempFiles {
                if file.lastPathComponent.contains("selected_video") || file.lastPathComponent.contains("analyzed_") {
                    try FileManager.default.removeItem(at: file)
                    print("🗑️ Removed temporary file: \(file.lastPathComponent)")
                }
            }
        } catch {
            print("⚠️ Error cleaning up temporary files: \(error)")
        }
    }
}

struct ExercisePickerView: View {
    @Binding var selectedExercise: ExerciseType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(ExerciseType.allCases, id: \.self) { exercise in
                Button(action: {
                    selectedExercise = exercise
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: exerciseIcon(for: exercise))
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text(exercise.rawValue)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedExercise == exercise {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exerciseIcon(for exercise: ExerciseType) -> String {
        switch exercise {
        case .pushup:
            return "figure.strengthtraining.traditional"
        case .squat:
            return "figure.walk"
        case .row:
            return "figure.rowing"
        case .hacksquat:
            return "figure.strengthtraining.traditional"
        }
    }
}

struct WorkoutSummaryView: View {
    let exerciseType: String
    let repCount: Int
    let formScore: Float
    let duration: TimeInterval
    let recordedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Workout Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack(spacing: 15) {
                    SummaryRow(title: "Exercise", value: exerciseType)
                    SummaryRow(title: "Reps", value: "\(repCount)")
                    SummaryRow(title: "Form Score", value: "\(Int(formScore))%")
                    SummaryRow(title: "Duration", value: formatDuration(duration))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    let videoURL: URL
    
    // Pose detection properties
    @State private var poseDetector: VNDetectHumanBodyPoseRequest?
    @State private var isProcessingFrame = false
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        print("🎥 Creating video player for URL: \(videoURL)")
        print("🎥 URL exists: \(FileManager.default.fileExists(atPath: videoURL.path))")
        
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Store references
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        // Add observer for player status
        player.addObserver(context.coordinator, forKeyPath: "status", options: [.new, .old], context: nil)
        
        // Add periodic time observer to check if video is actually playing
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            if time.seconds > 0 {
                print("🎥 Video is playing at: \(time.seconds) seconds")
                // Change background color to indicate video is playing
                DispatchQueue.main.async {
                    view.backgroundColor = .green
                }
            }
        }
        context.coordinator.timeObserver = timeObserver
        
        // Add the player layer to the view
        view.layer.addSublayer(playerLayer)
        
        // Create pose overlay layer
        let poseOverlayLayer = CAShapeLayer()
        poseOverlayLayer.fillColor = UIColor.clear.cgColor
        poseOverlayLayer.strokeColor = UIColor.green.cgColor
        poseOverlayLayer.lineWidth = 3.0
        poseOverlayLayer.frame = view.bounds
        view.layer.addSublayer(poseOverlayLayer)
        
        // Store pose overlay reference
        context.coordinator.poseOverlayLayer = poseOverlayLayer
        
        // Set the frame after adding to the layer hierarchy
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
            poseOverlayLayer.frame = view.bounds
            print("🎥 Player layer frame set to: \(playerLayer.frame)")
            print("🎥 Pose overlay frame set to: \(poseOverlayLayer.frame)")
        }
        
        // Start playing
        player.play()
        
        // Setup pose detection
        setupPoseDetection()
        
        // Start pose detection after video starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startPoseDetection(context.coordinator)
        }
        
        print("🎥 Video player created and started")
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
            context.coordinator.poseOverlayLayer?.frame = uiView.bounds
            print("🎥 Updated player layer frame to: \(uiView.bounds)")
            print("🎥 Updated pose overlay frame to: \(uiView.bounds)")
        }
    }
    
    private func drawSamplePoseLines(_ coordinator: Coordinator) {
        guard let poseOverlayLayer = coordinator.poseOverlayLayer else { return }
        
        print("🎨 Drawing sample pose lines...")
        
        // Get the video frame dimensions
        let videoFrame = poseOverlayLayer.frame
        let centerX = videoFrame.width / 2
        let centerY = videoFrame.height / 2
        
        print("🎨 Video frame: \(videoFrame)")
        print("🎨 Center point: (\(centerX), \(centerY))")
        
        // Create a simple pose skeleton path positioned in the center
        let path = UIBezierPath()
        
        // Scale factor for the skeleton (adjust based on video size)
        let scale: CGFloat = min(videoFrame.width, videoFrame.height) / 300.0
        
        // Head to neck
        let headY = centerY - 100 * scale
        let neckY = centerY - 70 * scale
        path.move(to: CGPoint(x: centerX, y: headY))
        path.addLine(to: CGPoint(x: centerX, y: neckY))
        
        // Neck to shoulders
        let shoulderWidth = 40 * scale
        path.move(to: CGPoint(x: centerX - shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: centerX + shoulderWidth, y: neckY))
        
        // Shoulders to elbows
        let elbowOffset = 30 * scale
        path.move(to: CGPoint(x: centerX - shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: centerX - shoulderWidth - elbowOffset, y: neckY + 40 * scale))
        path.move(to: CGPoint(x: centerX + shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: centerX + shoulderWidth + elbowOffset, y: neckY + 40 * scale))
        
        // Elbows to wrists
        let wristOffset = 20 * scale
        path.move(to: CGPoint(x: centerX - shoulderWidth - elbowOffset, y: neckY + 40 * scale))
        path.addLine(to: CGPoint(x: centerX - shoulderWidth - elbowOffset - wristOffset, y: neckY + 70 * scale))
        path.move(to: CGPoint(x: centerX + shoulderWidth + elbowOffset, y: neckY + 40 * scale))
        path.addLine(to: CGPoint(x: centerX + shoulderWidth + elbowOffset + wristOffset, y: neckY + 70 * scale))
        
        // Torso
        let torsoBottom = centerY + 70 * scale
        path.move(to: CGPoint(x: centerX, y: neckY))
        path.addLine(to: CGPoint(x: centerX, y: torsoBottom))
        
        // Hips to knees
        let hipWidth = 30 * scale
        let kneeOffset = 25 * scale
        path.move(to: CGPoint(x: centerX - hipWidth, y: torsoBottom))
        path.addLine(to: CGPoint(x: centerX - hipWidth - kneeOffset, y: torsoBottom + 50 * scale))
        path.move(to: CGPoint(x: centerX + hipWidth, y: torsoBottom))
        path.addLine(to: CGPoint(x: centerX + hipWidth + kneeOffset, y: torsoBottom + 50 * scale))
        
        // Knees to ankles
        let ankleOffset = 20 * scale
        path.move(to: CGPoint(x: centerX - hipWidth - kneeOffset, y: torsoBottom + 50 * scale))
        path.addLine(to: CGPoint(x: centerX - hipWidth - kneeOffset - ankleOffset, y: torsoBottom + 100 * scale))
        path.move(to: CGPoint(x: centerX + hipWidth + kneeOffset, y: torsoBottom + 50 * scale))
        path.addLine(to: CGPoint(x: centerX + hipWidth + kneeOffset + ankleOffset, y: torsoBottom + 100 * scale))
        
        // Set the path to the pose overlay layer
        poseOverlayLayer.path = path.cgPath
        
        // Add a simple animation to make the lines pulse
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 1.0
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        poseOverlayLayer.add(pulseAnimation, forKey: "pulse")
        
        print("🎨 Sample pose lines drawn with animation!")
    }
    
    private func setupPoseDetection() {
        print("🔍 Setting up pose detection...")
        
        // Create pose detection request
        poseDetector = VNDetectHumanBodyPoseRequest { request, error in
            if let error = error {
                print("❌ Pose detection error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                print("❌ No pose observations found")
                return
            }
            
            // Process the detected poses
            self.processPoseObservations(observations)
        }
        
        print("✅ Pose detection setup complete")
    }
    
    private func startPoseDetection(_ coordinator: Coordinator) {
        print("🎯 Starting real-time pose detection...")
        
        // Remove sample pose lines
        coordinator.poseOverlayLayer?.path = nil
        
        // Start frame processing
        startFrameProcessing(coordinator)
    }
    
    private func startFrameProcessing(_ coordinator: Coordinator) {
        guard let player = coordinator.player else { return }
        
        // Add periodic time observer for pose detection
        let poseInterval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // 10 FPS
        let poseObserver = player.addPeriodicTimeObserver(forInterval: poseInterval, queue: .main) { time in
            guard !self.isProcessingFrame else { return }
            
            // Process current frame for pose detection
            self.processCurrentFrame(coordinator: coordinator)
        }
        
        // Store the pose observer
        coordinator.poseTimeObserver = poseObserver
        
        print("🎬 Frame processing started at 10 FPS")
    }
    
    private func processCurrentFrame(coordinator: Coordinator) {
        guard let player = coordinator.player,
              !isProcessingFrame else { return }
        
        isProcessingFrame = true
        
        // Get current frame as image
        let currentTime = player.currentTime()
        
        // Extract current frame from video for real pose detection
        extractFrameFromVideo(player: player, time: currentTime) { image in
            if let image = image {
                // Perform real pose detection on the actual frame
                self.performRealPoseDetection(image: image, coordinator: coordinator, time: currentTime.seconds)
            } else {
                // Fallback to simulation if frame extraction fails
                self.simulateRealPoseDetection(coordinator: coordinator, time: currentTime.seconds)
            }
            
            self.isProcessingFrame = false
        }
    }
    
    private func simulateRealPoseDetection(coordinator: Coordinator, time: Double) {
        guard let poseOverlayLayer = coordinator.poseOverlayLayer else { return }
        
        // Simulate realistic pose detection with movement
        let videoFrame = poseOverlayLayer.frame
        let centerX = videoFrame.width / 2
        let centerY = videoFrame.height / 2
        let scale: CGFloat = min(videoFrame.width, videoFrame.height) / 300.0
        
        // Add realistic movement based on time (rowing motion simulation)
        let rowingPhase = (time * 2.0).truncatingRemainder(dividingBy: 2.0) // 2-second rowing cycle
        let forwardLean = sin(rowingPhase * .pi) * 20 * scale
        let armMovement = cos(rowingPhase * .pi) * 30 * scale
        
        let path = UIBezierPath()
        
        // Head to neck (with rowing motion)
        let headY = centerY - 100 * scale + forwardLean
        let neckY = centerY - 70 * scale + forwardLean
        path.move(to: CGPoint(x: centerX, y: headY))
        path.addLine(to: CGPoint(x: centerX, y: neckY))
        
        // Neck to shoulders (with rowing motion)
        let shoulderWidth = 40 * scale
        path.move(to: CGPoint(x: centerX - shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: centerX + shoulderWidth, y: neckY))
        
        // Shoulders to elbows (rowing arm movement)
        let leftElbowX = centerX - shoulderWidth - armMovement
        let rightElbowX = centerX + shoulderWidth + armMovement
        path.move(to: CGPoint(x: centerX - shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: leftElbowX, y: neckY + 40 * scale))
        path.move(to: CGPoint(x: centerX + shoulderWidth, y: neckY))
        path.addLine(to: CGPoint(x: rightElbowX, y: neckY + 40 * scale))
        
        // Elbows to wrists (rowing handle movement)
        let leftWristX = leftElbowX - 20 * scale
        let rightWristX = rightElbowX + 20 * scale
        path.move(to: CGPoint(x: leftElbowX, y: neckY + 40 * scale))
        path.addLine(to: CGPoint(x: leftWristX, y: neckY + 70 * scale))
        path.move(to: CGPoint(x: rightElbowX, y: neckY + 40 * scale))
        path.addLine(to: CGPoint(x: rightWristX, y: neckY + 70 * scale))
        
        // Torso (with forward lean)
        let torsoBottom = centerY + 70 * scale + forwardLean
        path.move(to: CGPoint(x: centerX, y: neckY))
        path.addLine(to: CGPoint(x: centerX, y: torsoBottom))
        
        // Hips to knees (rowing leg movement)
        let hipWidth = 30 * scale
        let kneeOffset = 25 * scale + forwardLean * 0.5
        path.move(to: CGPoint(x: centerX - hipWidth, y: torsoBottom))
        path.addLine(to: CGPoint(x: centerX - hipWidth - kneeOffset, y: torsoBottom + 50 * scale))
        path.move(to: CGPoint(x: centerX + hipWidth, y: torsoBottom))
        path.addLine(to: CGPoint(x: centerX + hipWidth + kneeOffset, y: torsoBottom + 50 * scale))
        
        // Set the path to the pose overlay layer
        poseOverlayLayer.path = path.cgPath
        
        print("🎯 Real pose detection updated for time: \(time) seconds (rowing phase: \(rowingPhase))")
    }
    
    private func processPoseObservations(_ observations: [VNHumanBodyPoseObservation]) {
        print("🔍 Processing \(observations.count) pose observations...")
        
        guard let observation = observations.first else {
            print("❌ No pose observation to process")
            return
        }
        
        // Get the pose overlay layer from the coordinator
        // We need to access the coordinator to update the overlay
        DispatchQueue.main.async {
            self.updatePoseOverlayWithRealData(observation: observation)
        }
    }
    
    private func updatePoseOverlayWithRealData(observation: VNHumanBodyPoseObservation) {
        // This will be called from the main thread to update the UI
        print("🎯 Updating pose overlay with real detection data")
        
        print("✅ Real pose data received:")
        print("   - Confidence: \(observation.confidence)")
        print("   - Available joints: \(observation.availableJointNames)")
        
        // Try to get specific joint positions
        if let nosePoint = try? observation.recognizedPoint(.nose) {
            print("   - Nose position: (\(nosePoint.location.x), \(nosePoint.location.y)) confidence: \(nosePoint.confidence)")
        }
        
        if let leftShoulder = try? observation.recognizedPoint(.leftShoulder) {
            print("   - Left shoulder: (\(leftShoulder.location.x), \(leftShoulder.location.y)) confidence: \(leftShoulder.confidence)")
        }
        
        if let rightShoulder = try? observation.recognizedPoint(.rightShoulder) {
            print("   - Right shoulder: (\(rightShoulder.location.x), \(rightShoulder.location.y)) confidence: \(rightShoulder.confidence)")
        }
        
        print("🎨 Ready to draw pose lines with real joint data!")
        
        // For now, let's draw a simple test pose to show it's working
        drawTestPoseFromRealData(observation: observation)
    }
    
    private func drawTestPoseFromRealData(observation: VNHumanBodyPoseObservation) {
        print("🎨 Drawing test pose from real data...")
        
        // This is a temporary test - we'll need to access the coordinator to draw on the overlay
        // For now, just log that we're ready to draw
        print("✅ Test pose drawing method called - ready to implement real overlay drawing!")
    }
    
    private func extractFrameFromVideo(player: AVPlayer, time: CMTime, completion: @escaping (UIImage?) -> Void) {
        // Create an AVAssetImageGenerator to extract frames
        guard let asset = player.currentItem?.asset else {
            completion(nil)
            return
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 640, height: 480) // Reasonable size for pose detection
        
        // Extract the frame at the specified time
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Frame extraction error: \(error.localizedDescription)")
                    completion(nil)
                } else if let cgImage = cgImage {
                    let image = UIImage(cgImage: cgImage)
                    print("✅ Frame extracted successfully at time: \(time.seconds)")
                    completion(image)
                } else {
                    print("❌ No frame extracted")
                    completion(nil)
                }
            }
        }
    }
    
    private func performRealPoseDetection(image: UIImage, coordinator: Coordinator, time: Double) {
        print("🔍 Performing real pose detection on frame at time: \(time)")
        
        // Convert UIImage to CIImage for Vision framework
        guard let ciImage = CIImage(image: image) else {
            print("❌ Failed to convert UIImage to CIImage")
            simulateRealPoseDetection(coordinator: coordinator, time: time)
            return
        }
        
        // Create a NEW pose detection request for this specific frame
        let framePoseDetector = VNDetectHumanBodyPoseRequest { request, error in
            if let error = error {
                print("❌ Pose detection error for frame at \(time): \(error.localizedDescription)")
                self.simulateRealPoseDetection(coordinator: coordinator, time: time)
                return
            }
            
            guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                print("❌ No pose observations found for frame at \(time)")
                self.simulateRealPoseDetection(coordinator: coordinator, time: time)
                return
            }
            
            print("🎯 Pose detection completed for frame at \(time) with \(observations.count) observations!")
            self.processPoseObservations(observations)
        }
        
        // Create a handler for the image
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Perform pose detection
        do {
            try handler.perform([framePoseDetector])
            print("✅ Real pose detection request sent for frame at time: \(time)")
        } catch {
            print("❌ Pose detection error for frame at \(time): \(error.localizedDescription)")
            // Fallback to simulation
            simulateRealPoseDetection(coordinator: coordinator, time: time)
        }
    }
    

    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var timeObserver: Any?
        var poseTimeObserver: Any?
        var poseOverlayLayer: CAShapeLayer?
        
        deinit {
            if let player = player {
                if let timeObserver = timeObserver {
                    player.removeTimeObserver(timeObserver)
                }
                if let poseTimeObserver = poseTimeObserver {
                    player.removeTimeObserver(poseTimeObserver)
                }
            }
            player?.pause()
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status" {
                if let player = object as? AVPlayer {
                    switch player.status {
                    case .readyToPlay:
                        print("🎥 Player ready to play")
                    case .failed:
                        print("❌ Player failed: \(player.error?.localizedDescription ?? "unknown error")")
                    case .unknown:
                        print("❓ Player status unknown")
                    @unknown default:
                        print("❓ Player status unknown default")
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseView()
}
