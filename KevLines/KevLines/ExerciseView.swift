import SwiftUI

struct ExerciseView: View {
    @StateObject private var poseAnalyzer = PoseAnalyzer()
    @State private var isRecording = false
    @State private var selectedExercise: ExerciseType = .pushup
    @State private var showingExercisePicker = false
    @State private var showingWorkoutSummary = false
    @State private var workoutStartTime: Date?
    @State private var cameraPermissionGranted = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera view with overlay
                if cameraPermissionGranted {
                    CameraView(poseAnalyzer: poseAnalyzer, isRecording: $isRecording)
                        .edgesIgnoringSafeArea(.all)
                    
                    CameraOverlayView(poseAnalyzer: poseAnalyzer)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    // Camera permission request view
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("KevLines needs camera access to analyze your workout form and provide real-time feedback.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Grant Camera Access") {
                            requestCameraPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding()
                }
                
                // Top controls
                VStack {
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
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        if isRecording {
                            Button(action: stopWorkout) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: startWorkout) {
                                Image(systemName: "record.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Bottom controls
                VStack {
                    Spacer()
                    
                    if isRecording {
                        HStack(spacing: 20) {
                            Button(action: resetWorkout) {
                                VStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2)
                                    Text("Reset")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                            }
                            
                            Spacer()
                            
                            Button(action: pauseWorkout) {
                                VStack {
                                    Image(systemName: "pause.fill")
                                        .font(.title2)
                                    Text("Pause")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("KevLines")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkCameraPermission()
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(selectedExercise: $selectedExercise)
            }
            .sheet(isPresented: $showingWorkoutSummary) {
                WorkoutSummaryView(
                    exerciseType: selectedExercise.rawValue,
                    repCount: poseAnalyzer.repCount,
                    formScore: poseAnalyzer.formScore,
                    duration: workoutStartTime.map { Date().timeIntervalSince($0) } ?? 0
                )
            }
        }
    }
    
    private func checkCameraPermission() {
        // Simplified for now - always grant permission
        cameraPermissionGranted = true
    }
    
    private func requestCameraPermission() {
        // Simplified for now - always grant permission
        cameraPermissionGranted = true
    }
    
    private func startWorkout() {
        isRecording = true
        workoutStartTime = Date()
        poseAnalyzer.setExerciseType(selectedExercise)
        poseAnalyzer.resetAnalysis()
    }
    
    private func stopWorkout() {
        isRecording = false
        showingWorkoutSummary = true
    }
    
    private func pauseWorkout() {
        isRecording = false
    }
    
    private func resetWorkout() {
        poseAnalyzer.resetAnalysis()
        workoutStartTime = Date()
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

#Preview {
    ExerciseView()
}
