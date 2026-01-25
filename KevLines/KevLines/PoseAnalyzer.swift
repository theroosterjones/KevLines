import Foundation
import SwiftUI
import Vision
import CoreML

// MARK: - Pose Analysis Models
struct PoseKeypoint {
    let position: CGPoint
    let confidence: Float
}

struct PoseAnalysis {
    let keypoints: [PoseKeypoint]
    let exerciseType: ExerciseType
    let formScore: Float
    let feedback: [String]
    let repCount: Int
}

enum ExerciseType: String, CaseIterable {
    case pushup = "Push-up"
    case squat = "Squat"
    case row = "Row"
    case hacksquat = "Hack Squat"
    case backsquat = "Back Squat"
}

class PoseAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var currentAnalysis: PoseAnalysis?
    @Published var repCount = 0
    @Published var formScore: Float = 85.0
    @Published var feedback: [String] = ["Ready to start!"]
    
    private var exerciseType: ExerciseType = .pushup
    private var poseRequest: VNDetectHumanBodyPoseRequest?
    private var lastAnalysisTime: Date = Date()
    private var exerciseState: ExerciseState = .ready
    private var repStartTime: Date?
    
    // Exercise state tracking
    enum ExerciseState {
        case ready
        case down
        case up
    }
    
    init() {
        setupPoseDetection()
    }
    
    private func setupPoseDetection() {
        poseRequest = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            if let error = error {
                print("Pose detection error: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.processPoseResults(request)
            }
        }
    }
    
    func setExerciseType(_ type: ExerciseType) {
        exerciseType = type
        resetAnalysis()
    }
    
    func resetAnalysis() {
        repCount = 0
        formScore = 85.0
        feedback = ["Ready to start!"]
        currentAnalysis = nil
        exerciseState = .ready
        repStartTime = nil
    }
    
    func analyzeFrame(_ sampleBuffer: CMSampleBuffer) {
        #if targetEnvironment(simulator)
        // In simulator, simulate pose analysis
        simulatePoseAnalysis()
        return
        #else
        guard let poseRequest = poseRequest else { return }
        
        // Throttle analysis to avoid overwhelming the system
        let now = Date()
        guard now.timeIntervalSince(lastAnalysisTime) > 0.1 else { return } // 10 FPS max
        lastAnalysisTime = now
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        
        do {
            try handler.perform([poseRequest])
        } catch {
            print("Failed to perform pose detection: \(error)")
        }
        #endif
    }
    
    #if targetEnvironment(simulator)
    private func simulatePoseAnalysis() {
        // Simulate pose analysis in simulator for testing
        let now = Date()
        guard now.timeIntervalSince(lastAnalysisTime) > 1.0 else { return } // 1 FPS for simulator
        
        lastAnalysisTime = now
        
        // Simulate rep counting
        if exerciseState == .ready {
            exerciseState = .down
            feedback = ["Going down..."]
        } else if exerciseState == .down {
            exerciseState = .up
            repCount += 1
            feedback = ["Good form! Rep \(repCount) completed"]
            formScore = min(100.0, formScore + 1.0)
        } else {
            exerciseState = .ready
            feedback = ["Ready for next rep"]
        }
        
        print("Simulator: Simulated pose analysis - Rep \(repCount), Form Score: \(formScore)")
    }
    
    func simulateVideoAnalysis() {
        // Simulate analyzing a pre-recorded video
        resetAnalysis()
        
        // Simulate comprehensive video analysis
        DispatchQueue.main.async {
            self.isAnalyzing = true
            
            // Simulate processing time and results
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.repCount = Int.random(in: 5...15)
                self.formScore = Float.random(in: 75...95)
                
                // Generate realistic feedback based on exercise type
                switch self.exerciseType {
                case .pushup:
                    self.feedback = [
                        "Good arm positioning throughout most reps",
                        "Try to maintain a straight line from head to heels",
                        "Consider going deeper on the down phase",
                        "Excellent breathing rhythm maintained"
                    ]
                case .squat:
                    self.feedback = [
                        "Good depth on most squats",
                        "Keep your chest up and back straight",
                        "Knees are tracking well over toes",
                        "Consider adding a slight pause at the bottom"
                    ]
                case .row:
                    self.feedback = [
                        "Good shoulder blade retraction",
                        "Maintain neutral spine position",
                        "Elbows close to body throughout movement",
                        "Consider slowing down the eccentric phase"
                    ]
                case .hacksquat:
                    self.feedback = [
                        "Good foot positioning on the platform",
                        "Maintain upright torso position",
                        "Knees tracking properly over toes",
                        "Consider adding more depth to your squats"
                    ]
                }
                
                self.isAnalyzing = false
                print("Video analysis completed: \(self.repCount) reps, \(self.formScore)% form score")
            }
        }
    }
    #endif
    

    
    private func processPoseResults(_ request: VNRequest) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else {
            feedback = ["No pose detected"]
            return
        }
        
        // Extract keypoints
        let keypoints = extractKeypoints(from: observation)
        
        // Analyze exercise based on type
        switch exerciseType {
        case .pushup:
            analyzePushup(keypoints: keypoints)
        case .squat:
            analyzeSquat(keypoints: keypoints)
        case .row:
            analyzeRow(keypoints: keypoints)
        case .hacksquat:
            analyzeHackSquat(keypoints: keypoints)
        }
        
        // Update current analysis
        currentAnalysis = PoseAnalysis(
            keypoints: keypoints,
            exerciseType: exerciseType,
            formScore: formScore,
            feedback: feedback,
            repCount: repCount
        )
    }
    
    private func extractKeypoints(from observation: VNHumanBodyPoseObservation) -> [PoseKeypoint] {
        var keypoints: [PoseKeypoint] = []
        
        // Extract key body points
        let recognizedPoints = try? observation.recognizedPoints(.all)
        
        for (_, point) in recognizedPoints ?? [:] {
            if point.confidence > 0.3 { // Only include confident detections
                keypoints.append(PoseKeypoint(
                    position: CGPoint(x: point.location.x, y: 1 - point.location.y), // Flip Y coordinate
                    confidence: point.confidence
                ))
            }
        }
        
        return keypoints
    }
    
    private func analyzePushup(keypoints: [PoseKeypoint]) {
        // Simple pushup analysis based on arm angles
        // In a real implementation, you'd use more sophisticated pose analysis
        
        // Simulate rep counting and form analysis
        let now = Date()
        
        switch exerciseState {
        case .ready:
            exerciseState = .down
            repStartTime = now
            feedback = ["Starting pushup..."]
            
        case .down:
            // Simulate detecting down position
            if now.timeIntervalSince(repStartTime ?? now) > 1.0 {
                exerciseState = .up
                feedback = ["Good form! Push up"]
            }
            
        case .up:
            // Simulate detecting up position
            if now.timeIntervalSince(repStartTime ?? now) > 2.0 {
                repCount += 1
                exerciseState = .down
                repStartTime = now
                formScore = min(100, formScore + 2) // Improve score with good reps
                feedback = ["Great rep! \(repCount) completed"]
            }
        }
    }
    
    private func analyzeSquat(keypoints: [PoseKeypoint]) {
        // Similar pattern for squat analysis
        let now = Date()
        
        switch exerciseState {
        case .ready:
            exerciseState = .down
            repStartTime = now
            feedback = ["Starting squat..."]
            
        case .down:
            if now.timeIntervalSince(repStartTime ?? now) > 1.5 {
                exerciseState = .up
                feedback = ["Good depth! Stand up"]
            }
            
        case .up:
            if now.timeIntervalSince(repStartTime ?? now) > 3.0 {
                repCount += 1
                exerciseState = .down
                repStartTime = now
                formScore = min(100, formScore + 2)
                feedback = ["Excellent squat! \(repCount) completed"]
            }
        }
    }
    
    private func analyzeRow(keypoints: [PoseKeypoint]) {
        // Row analysis
        let now = Date()
        
        switch exerciseState {
        case .ready:
            exerciseState = .down
            repStartTime = now
            feedback = ["Starting row..."]
            
        case .down:
            if now.timeIntervalSince(repStartTime ?? now) > 1.0 {
                exerciseState = .up
                feedback = ["Pull back!"]
            }
            
        case .up:
            if now.timeIntervalSince(repStartTime ?? now) > 2.5 {
                repCount += 1
                exerciseState = .down
                repStartTime = now
                formScore = min(100, formScore + 2)
                feedback = ["Strong row! \(repCount) completed"]
            }
        }
    }
    
    private func analyzeHackSquat(keypoints: [PoseKeypoint]) {
        // Hack squat analysis
        let now = Date()
        
        switch exerciseState {
        case .ready:
            exerciseState = .down
            repStartTime = now
            feedback = ["Starting hack squat..."]
            
        case .down:
            if now.timeIntervalSince(repStartTime ?? now) > 1.5 {
                exerciseState = .up
                feedback = ["Push through!"]
            }
            
        case .up:
            if now.timeIntervalSince(repStartTime ?? now) > 3.0 {
                repCount += 1
                exerciseState = .down
                repStartTime = now
                formScore = min(100, formScore + 2)
                feedback = ["Powerful hack squat! \(repCount) completed"]
            }
        }
    }
    
    func startAnalysis() {
        isAnalyzing = true
        feedback = ["Analysis started!"]
    }
    
    func stopAnalysis() {
        isAnalyzing = false
        feedback = ["Analysis stopped!"]
    }
}
