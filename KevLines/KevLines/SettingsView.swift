import SwiftUI

struct SettingsView: View {
    @State private var userName = ""
    @State private var workoutGoal = "General Fitness"
    @State private var useMetricUnits = true
    @State private var formScoreThreshold: Float = 70.0
    @State private var autoSaveWorkouts = true
    @State private var hapticFeedback = true
    @State private var soundFeedback = true
    @State private var cameraQuality = "High"
    
    let workoutGoals = ["General Fitness", "Strength Training", "Weight Loss", "Muscle Building", "Endurance", "Flexibility"]
    let cameraQualities = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $userName)
                    
                    Picker("Workout Goal", selection: $workoutGoal) {
                        ForEach(workoutGoals, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                }
                
                Section("Workout Settings") {
                    Toggle("Use Metric Units", isOn: $useMetricUnits)
                    
                    VStack(alignment: .leading) {
                        Text("Form Score Threshold: \(Int(formScoreThreshold))%")
                        Slider(value: $formScoreThreshold, in: 50...95, step: 5)
                    }
                    
                    Toggle("Auto-save Workouts", isOn: $autoSaveWorkouts)
                }
                
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    Toggle("Sound Feedback", isOn: $soundFeedback)
                }
                
                Section("Camera") {
                    Picker("Camera Quality", selection: $cameraQuality) {
                        ForEach(cameraQualities, id: \.self) { quality in
                            Text(quality)
                        }
                    }
                }
                
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 Beta")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Support") {
                    Button("Help & Tutorial") {
                        // TODO: Show help/tutorial
                    }
                    
                    Button("Report Bug") {
                        // TODO: Open bug report form
                    }
                    
                    Button("Feature Request") {
                        // TODO: Open feature request form
                    }
                }
                
                Section("Data") {
                    Button("Export Workout Data") {
                        // TODO: Export functionality
                    }
                    
                    Button("Clear All Data") {
                        // TODO: Clear data with confirmation
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
