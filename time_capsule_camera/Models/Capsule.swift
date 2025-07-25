import Foundation
import FirebaseFirestore

struct Capsule: Identifiable {
    let id: String
    var name: String
    var creatorId: String
    var memberIds: [String]
    var sealDate: Date
    var isUnsealed: Bool

    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.creatorId = data["creatorId"] as? String ?? ""
        self.memberIds = data["memberIds"] as? [String] ?? []
        if let timestamp = data["sealDate"] as? Timestamp {
            self.sealDate = timestamp.dateValue()
        } else {
            self.sealDate = Date()
        }
        // Check if capsule should be unsealed based on current time
        let storedIsUnsealed = data["isUnsealed"] as? Bool ?? false
        self.isUnsealed = storedIsUnsealed || self.sealDate <= Date()
    }
}
