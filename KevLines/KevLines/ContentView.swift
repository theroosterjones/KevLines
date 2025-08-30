import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExerciseView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Workout")
                }
            
            WorkoutHistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
}
