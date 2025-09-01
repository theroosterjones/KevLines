import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewRepresentable {
    @ObservedObject var poseAnalyzer: PoseAnalyzer
    @Binding var isRecording: Bool
    @Binding var recordedVideoURL: URL?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Check if running in simulator
        #if targetEnvironment(simulator)
        // Simulator: Show enhanced mock camera view
        let mockView = createEnhancedMockCameraView()
        view.addSubview(mockView)
        mockView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mockView.topAnchor.constraint(equalTo: view.topAnchor),
            mockView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mockView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mockView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        #else
        // Real device: Set up actual camera
        let previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Store reference to preview layer
        context.coordinator.previewLayer = previewLayer
        
        // Set up camera session
        context.coordinator.setupCamera()
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        #if !targetEnvironment(simulator)
        // Update preview layer frame when view size changes
        context.coordinator.previewLayer?.frame = uiView.bounds
        
        // Update recording state and setup camera when needed
        let wasRecording = context.coordinator.isRecording
        context.coordinator.isRecording = isRecording
        
        // Setup camera when recording starts
        if !wasRecording && isRecording {
            context.coordinator.startRecording()
        } else if wasRecording && !isRecording {
            context.coordinator.stopRecording()
        }
        #else
        // Simulator: Update mock recording state
        context.coordinator.updateSimulatorRecording(isRecording)
        #endif
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Enhanced Mock Camera View for Simulator
    private func createEnhancedMockCameraView() -> UIView {
        let mockView = UIView()
        mockView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // Add camera frame overlay
        let frameView = UIView()
        frameView.backgroundColor = .clear
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 2.0
        frameView.layer.cornerRadius = 8.0
        mockView.addSubview(frameView)
        
        frameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: mockView.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: mockView.centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: mockView.widthAnchor, multiplier: 0.8),
            frameView.heightAnchor.constraint(equalTo: mockView.heightAnchor, multiplier: 0.6)
        ])
        
        // Add simulator indicator
        let indicatorLabel = UILabel()
        indicatorLabel.text = "📱 Camera Simulator"
        indicatorLabel.textColor = .white
        indicatorLabel.textAlignment = .center
        indicatorLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        mockView.addSubview(indicatorLabel)
        
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorLabel.centerXAnchor.constraint(equalTo: mockView.centerXAnchor),
            indicatorLabel.topAnchor.constraint(equalTo: mockView.topAnchor, constant: 50)
        ])
        
        // Add mock camera feed simulation
        let mockCameraFeed = UIView()
        mockCameraFeed.backgroundColor = UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        mockCameraFeed.layer.cornerRadius = 8.0
        mockView.addSubview(mockCameraFeed)
        
        mockCameraFeed.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mockCameraFeed.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            mockCameraFeed.centerYAnchor.constraint(equalTo: frameView.centerYAnchor),
            mockCameraFeed.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.9),
            mockCameraFeed.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.9)
        ])
        
        // Add mock pose detection visualization
        let poseIndicator = UIView()
        poseIndicator.backgroundColor = UIColor.green.withAlphaComponent(0.6)
        poseIndicator.layer.cornerRadius = 20
        mockView.addSubview(poseIndicator)
        
        poseIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            poseIndicator.centerXAnchor.constraint(equalTo: mockCameraFeed.centerXAnchor),
            poseIndicator.centerYAnchor.constraint(equalTo: mockCameraFeed.centerYAnchor),
            poseIndicator.widthAnchor.constraint(equalToConstant: 40),
            poseIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add instruction text
        let instructionLabel = UILabel()
        instructionLabel.text = "Use a physical device to test real camera functionality"
        instructionLabel.textColor = .lightGray
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.numberOfLines = 0
        mockView.addSubview(instructionLabel)
        
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: mockView.centerXAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: mockView.bottomAnchor, constant: -50),
            instructionLabel.leadingAnchor.constraint(equalTo: mockView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: mockView.trailingAnchor, constant: -20)
        ])
        
        return mockView
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
        let parent: CameraView
        var previewLayer: AVCaptureVideoPreviewLayer?
        var captureSession: AVCaptureSession?
        var movieOutput: AVCaptureMovieFileOutput?
        var isRecording = false
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func setupCamera() {
            #if targetEnvironment(simulator)
            // Skip camera setup in simulator
            return
            #else
            let session = AVCaptureSession()
            session.sessionPreset = .high
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Failed to get camera device")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                // Add audio input for video recording
                if let audioDevice = AVCaptureDevice.default(for: .audio) {
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    if session.canAddInput(audioInput) {
                        session.addInput(audioInput)
                    }
                }
                
                // Add video data output for pose analysis
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
                videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                
                if session.canAddOutput(videoOutput) {
                    session.addOutput(videoOutput)
                }
                
                // Add movie file output for video recording
                let movieOutput = AVCaptureMovieFileOutput()
                if session.canAddOutput(movieOutput) {
                    session.addOutput(movieOutput)
                    self.movieOutput = movieOutput
                }
                
                self.captureSession = session
                
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
                
                print("Camera setup completed successfully")
            } catch {
                print("Failed to setup camera: \(error)")
            }
            #endif
        }
        
        func startRecording() {
            #if targetEnvironment(simulator)
            // Simulate recording in simulator
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.parent.isRecording = false
                // Create a mock video URL for simulator
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let mockVideoURL = documentsPath.appendingPathComponent("mock_video.mov")
                self.parent.recordedVideoURL = mockVideoURL
            }
            return
            #else
            guard let movieOutput = movieOutput, !isRecording else { return }
            
            // Create unique filename for the video
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let videoName = "kevlines_\(Date().timeIntervalSince1970).mov"
            let videoURL = documentsPath.appendingPathComponent(videoName)
            
            // Start recording
            movieOutput.startRecording(to: videoURL, recordingDelegate: self)
            isRecording = true
            print("Started recording to: \(videoURL)")
            #endif
        }
        
        func stopRecording() {
            #if targetEnvironment(simulator)
            return
            #else
            guard let movieOutput = movieOutput, isRecording else { return }
            
            movieOutput.stopRecording()
            isRecording = false
            print("Stopped recording")
            #endif
        }
        
        func updateSimulatorRecording(_ recording: Bool) {
            #if targetEnvironment(simulator)
            if recording && !isRecording {
                // Start simulated recording
                isRecording = true
                print("Simulator: Started mock recording")
                
                // Simulate recording completion after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.parent.isRecording = false
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let mockVideoURL = documentsPath.appendingPathComponent("simulator_mock_video.mov")
                    self.parent.recordedVideoURL = mockVideoURL
                    print("Simulator: Mock recording completed")
                }
            }
            #endif
        }
        
        // MARK: - AVCaptureFileOutputRecordingDelegate
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            DispatchQueue.main.async {
                if let error = error {
                    print("Recording error: \(error)")
                    self.parent.isRecording = false
                } else {
                    print("Recording completed successfully: \(outputFileURL)")
                    self.parent.recordedVideoURL = outputFileURL
                    self.parent.isRecording = false
                }
            }
        }
        
        // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            #if !targetEnvironment(simulator)
            // Analyze frame for pose detection
            parent.poseAnalyzer.analyzeFrame(sampleBuffer)
            #endif
        }
    }
}

struct CameraOverlayView: View {
    @ObservedObject var poseAnalyzer: PoseAnalyzer
    @Binding var isRecording: Bool
    
    var body: some View {
        ZStack {
            // Recording indicator at top
            if isRecording {
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .opacity(0.8)
                        
                        Text("REC")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding(.top, 60)
            }
            
            // Stats overlay
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Form Score: \(Int(poseAnalyzer.formScore))%")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        
                        Text("Reps: \(poseAnalyzer.repCount)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            // Feedback display
            if !poseAnalyzer.feedback.isEmpty {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(poseAnalyzer.feedback, id: \.self) { feedback in
                            Text(feedback)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}
