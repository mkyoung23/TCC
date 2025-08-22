import Foundation
import FirebaseFirestore

struct Clip: Identifiable {
    let id: String
    let uploaderId: String
    let uploaderName: String
    let storagePath: String
    let createdAt: Date // Original creation timestamp
    let uploadedAt: Date // When uploaded to Firebase
    var url: URL?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.uploaderId = data["uploaderId"] as? String ?? ""
        self.uploaderName = data["uploaderName"] as? String ?? ""
        self.storagePath = data["storagePath"] as? String ?? ""
        
        // Use original creation timestamp if available, otherwise use uploaded timestamp
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        // Track when video was uploaded to Firebase
        if let timestamp = data["uploadedAt"] as? Timestamp {
            self.uploadedAt = timestamp.dateValue()
        } else {
            self.uploadedAt = Date()
        }
        
        self.url = nil
    }
}
