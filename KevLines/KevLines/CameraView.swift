import SwiftUI

struct CameraView: UIViewRepresentable {
    @ObservedObject var poseAnalyzer: PoseAnalyzer
    @Binding var isRecording: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
    }
}

struct CameraOverlayView: View {
    @ObservedObject var poseAnalyzer: PoseAnalyzer
    
    var body: some View {
        ZStack {
            // Simple overlay without camera functionality
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
