import Foundation
import FirebaseFirestore

struct Clip: Identifiable {
    let id: String
    let uploaderId: String
    let uploaderName: String
    let storagePath: String
    let createdAt: Date
    var url: URL?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.uploaderId = data["uploaderId"] as? String ?? ""
        self.uploaderName = data["uploaderName"] as? String ?? ""
        self.storagePath = data["storagePath"] as? String ?? ""
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        self.url = nil
    }
}
