import Foundation
import SwiftUI

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
}

class PoseAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var currentAnalysis: PoseAnalysis?
    @Published var repCount = 0
    @Published var formScore: Float = 85.0
    @Published var feedback: [String] = ["Ready to start!"]
    
    private var exerciseType: ExerciseType = .pushup
    
    init() {
        // Initialize with default values
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
    }
    
    func analyzeFrame(_ pixelBuffer: Any) {
        // Do nothing for now - will be implemented later
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
