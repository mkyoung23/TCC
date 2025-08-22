import Foundation
import SwiftUI

class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()
    
    @Published var currentError: AppError?
    @Published var showError = false
    
    private init() {}
    
    func handleError(_ error: Error, context: String = "") {
        let appError = AppError.from(error, context: context)
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.showError = true
            
            // Log error for debugging
            print("🔥 Error in \(context): \(appError.localizedDescription)")
            print("   Details: \(appError.debugDescription)")
        }
    }
    
    func handleError(_ appError: AppError) {
        DispatchQueue.main.async {
            self.currentError = appError
            self.showError = true
            
            // Log error for debugging
            print("🔥 App Error: \(appError.localizedDescription)")
            print("   Details: \(appError.debugDescription)")
        }
    }
    
    func dismissError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.showError = false
        }
    }
}

enum AppError: LocalizedError, CustomDebugStringConvertible {
    case authentication(String)
    case network(String)
    case storage(String)
    case validation(String)
    case unknown(String)
    case permission(String)
    case videoProcessing(String)
    
    var errorDescription: String? {
        switch self {
        case .authentication(let message):
            return "Authentication Error: \(message)"
        case .network(let message):
            return "Network Error: \(message)"
        case .storage(let message):
            return "Storage Error: \(message)"
        case .validation(let message):
            return "Validation Error: \(message)"
        case .permission(let message):
            return "Permission Error: \(message)"
        case .videoProcessing(let message):
            return "Video Processing Error: \(message)"
        case .unknown(let message):
            return "Unexpected Error: \(message)"
        }
    }
    
    var debugDescription: String {
        switch self {
        case .authentication(let message):
            return "AUTH_ERROR: \(message)"
        case .network(let message):
            return "NETWORK_ERROR: \(message)"
        case .storage(let message):
            return "STORAGE_ERROR: \(message)"
        case .validation(let message):
            return "VALIDATION_ERROR: \(message)"
        case .permission(let message):
            return "PERMISSION_ERROR: \(message)"
        case .videoProcessing(let message):
            return "VIDEO_ERROR: \(message)"
        case .unknown(let message):
            return "UNKNOWN_ERROR: \(message)"
        }
    }
    
    var recoveryMessage: String {
        switch self {
        case .authentication(_):
            return "Please try signing in again"
        case .network(_):
            return "Check your internet connection and try again"
        case .storage(_):
            return "Check your device storage and try again"
        case .validation(_):
            return "Please check your input and try again"
        case .permission(_):
            return "Please grant the necessary permissions in Settings"
        case .videoProcessing(_):
            return "Try recording a new video"
        case .unknown(_):
            return "Please try again or contact support"
        }
    }
    
    static func from(_ error: Error, context: String = "") -> AppError {
        let message = error.localizedDescription
        
        if let nsError = error as NSError? {
            switch nsError.domain {
            case "FIRAuthErrorDomain":
                return .authentication(message)
            case "FIRStorageErrorDomain":
                return .storage(message)
            case NSURLErrorDomain:
                return .network(message)
            default:
                return .unknown("\(context.isEmpty ? "" : "[\(context)] ")\(message)")
            }
        }
        
        return .unknown("\(context.isEmpty ? "" : "[\(context)] ")\(message)")
    }
}

// SwiftUI modifier for centralized error handling
struct ErrorHandler: ViewModifier {
    @StateObject private var errorService = ErrorHandlingService.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorService.showError) {
                Button("OK") {
                    errorService.dismissError()
                }
            } message: {
                if let error = errorService.currentError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error.localizedDescription)
                        Text(error.recoveryMessage)
                            .font(.caption)
                    }
                }
            }
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(ErrorHandler())
    }
}