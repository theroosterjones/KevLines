import SwiftUI

struct WorkoutRecord: Identifiable, Codable {
    let id = UUID()
    let exerciseType: String
    let repCount: Int
    let formScore: Float
    let duration: TimeInterval
    let date: Date
    let notes: String?
}

struct WorkoutHistoryView: View {
    @State private var workouts: [WorkoutRecord] = []
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationView {
            List {
                if workouts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Workouts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Complete your first workout to see it here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(workouts.sorted(by: { $0.date > $1.date })) { workout in
                        WorkoutRowView(workout: workout)
                    }
                }
            }
            .navigationTitle("Workout History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView { workout in
                    workouts.append(workout)
                }
            }
        }
    }
}

struct WorkoutRowView: View {
    let workout: WorkoutRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.exerciseType)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(workout.repCount) reps", systemImage: "repeat")
                    .font(.subheadline)
                
                Spacer()
                
                Label("\(Int(workout.formScore))% form", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline)
                
                Spacer()
                
                Label(formatDuration(workout.duration), systemImage: "clock")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (WorkoutRecord) -> Void
    
    @State private var exerciseType = "Push-up"
    @State private var repCount = 10
    @State private var formScore: Float = 85.0
    @State private var duration: TimeInterval = 300 // 5 minutes
    @State private var notes = ""
    
    let exerciseTypes = ["Push-up", "Squat", "Row", "Hack Squat"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workout Details") {
                    Picker("Exercise Type", selection: $exerciseType) {
                        ForEach(exerciseTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    Stepper("Reps: \(repCount)", value: $repCount, in: 1...100)
                    
                    VStack(alignment: .leading) {
                        Text("Form Score: \(Int(formScore))%")
                        Slider(value: $formScore, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Duration: \(formatDuration(duration))")
                        Slider(value: $duration, in: 60...3600, step: 30)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes about your workout...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let workout = WorkoutRecord(
                            exerciseType: exerciseType,
                            repCount: repCount,
                            formScore: formScore,
                            duration: duration,
                            date: Date(),
                            notes: notes.isEmpty ? nil : notes
                        )
                        onAdd(workout)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

#Preview {
    WorkoutHistoryView()
}
