import Foundation
import FirebaseFirestore

struct Clip: Identifiable {
    let id: String
    let uploaderId: String
    let uploaderName: String
    let storagePath: String
    let createdAt: Date
    var url: URL?
    let videoId: String
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.uploaderId = data["uploaderId"] as? String ?? ""
        self.uploaderName = data["uploaderName"] as? String ?? ""
        self.storagePath = data["storagePath"] as? String ?? ""
        self.videoId = data["videoId"] as? String ?? id
        
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        self.url = nil
    }
    
    // Helper computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var uploaderInitials: String {
        let components = uploaderName.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(uploaderName.prefix(2)).uppercased()
        }
    }
    
    var isValid: Bool {
        return !uploaderId.isEmpty && !storagePath.isEmpty
    }
}
