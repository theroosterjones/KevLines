import Foundation
import UIKit

// MARK: - API Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let results: T?
    let error: String?
    let output_file: String?
    let message: String?
}

struct UploadResponse: Codable {
    let success: Bool
    let filename: String
    let message: String
}

struct AnalysisResponse: Codable {
    let success: Bool
    let results: AnalysisResults?
    let output_file: String
}

struct AnalysisResults: Codable {
    let message: String?
    let output_file: String?
    let rep_count: Int?
    let form_score: Int?
    let feedback: [String]?
}

struct StatusResponse: Codable {
    let status: String
    let version: String
    let supported_exercises: [String]
    let timestamp: String
}

// MARK: - API Service
class APIService: ObservableObject {
    static let shared = APIService()
    
    // Configuration
    private let baseURL = "http://10.0.10.231:3000"  // Your computer's IP address for iPhone testing
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Network Configuration
    func updateServerURL(with ipAddress: String) {
        // This method can be called to update the server URL dynamically
        // For now, we'll use the hardcoded IP address
        print("🌐 Server URL configured for: \(baseURL)")
    }
    
    // MARK: - API Status Check
    func checkBackendStatus() async throws -> StatusResponse {
        guard let url = URL(string: "\(baseURL)/api/status") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
        print("✅ Backend status: \(statusResponse.status)")
        print("✅ Supported exercises: \(statusResponse.supported_exercises)")
        
        return statusResponse
    }
    
    // MARK: - Video Upload
    func uploadVideo(_ videoURL: URL) async throws -> UploadResponse {
        guard let url = URL(string: "\(baseURL)/upload") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = try createMultipartBody(videoURL: videoURL, boundary: boundary)
        request.httpBody = httpBody
        
        print("📤 Uploading video: \(videoURL.lastPathComponent)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        if httpResponse.statusCode == 200 {
            let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
            print("✅ Video uploaded successfully: \(uploadResponse.filename)")
            return uploadResponse
        } else {
            let errorResponse = try JSONDecoder().decode(APIResponse<String>.self, from: data)
            throw APIError.uploadFailed(errorResponse.error ?? "Unknown error")
        }
    }
    
    // MARK: - Video Analysis
    func analyzeVideo(filename: String, exerciseType: String, side: String = "left") async throws -> AnalysisResponse {
        guard let url = URL(string: "\(baseURL)/analyze") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "filename": filename,
            "exercise_type": exerciseType,
            "side": side
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔍 Analyzing video: \(filename) for exercise: \(exerciseType), side: \(side)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        if httpResponse.statusCode == 200 {
            let analysisResponse = try JSONDecoder().decode(AnalysisResponse.self, from: data)
            print("✅ Video analysis completed: \(analysisResponse.output_file)")
            return analysisResponse
        } else {
            let errorResponse = try JSONDecoder().decode(APIResponse<String>.self, from: data)
            throw APIError.analysisFailed(errorResponse.error ?? "Unknown error")
        }
    }
    
    // MARK: - Download Analyzed Video
    func downloadAnalyzedVideo(filename: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/download/\(filename)") else {
            throw APIError.invalidURL
        }
        
        print("📥 Downloading analyzed video: \(filename)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.downloadFailed
        }
        
        // Save to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: tempURL)
        
        print("✅ Analyzed video downloaded: \(tempURL.path)")
        return tempURL
    }
    
    // MARK: - Helper Methods
    private func createMultipartBody(videoURL: URL, boundary: String) throws -> Data {
        var body = Data()
        
        // Add file data
        let videoData = try Data(contentsOf: videoURL)
        let filename = videoURL.lastPathComponent
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        
        // Determine correct content type based on file extension
        let contentType: String
        if filename.lowercased().hasSuffix(".mov") {
            contentType = "video/quicktime"
        } else if filename.lowercased().hasSuffix(".mp4") {
            contentType = "video/mp4"
        } else {
            contentType = "video/mp4" // Default fallback
        }
        
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case uploadFailed(String)
    case analysisFailed(String)
    case downloadFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error occurred"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .analysisFailed(let message):
            return "Analysis failed: \(message)"
        case .downloadFailed:
            return "Download failed"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Exercise Type Extension
extension ExerciseType {
    var apiString: String {
        switch self {
        case .pushup:
            return "pushup"
        case .squat:
            return "squat"
        case .row:
            return "row"
        case .hacksquat:
            return "hacksquat"
        case .backsquat:
            return "backsquat"
        }
    }
}
