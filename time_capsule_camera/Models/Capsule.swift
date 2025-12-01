import Foundation
import FirebaseFirestoreSwift

struct Capsule: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var creatorId: String
    var unlockDate: Date
    var memberIds: [String] // List of User IDs who can see this
    var isSealed: Bool = true
    
    // For the UI
    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: unlockDate, relativeTo: Date())
    }
}

struct CapsuleVideo: Identifiable, Codable {
    @DocumentID var id: String?
    var uploaderId: String
    var videoUrl: String
    var timestamp: Date
}
