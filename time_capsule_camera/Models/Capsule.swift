import Foundation
import FirebaseFirestore

struct Capsule: Identifiable {
    let id: String
    var name: String
    var creatorId: String
    var memberIds: [String]
    var sealDate: Date
    var isUnsealed: Bool
    var createdAt: Date
    var unsealedAt: Date?
    
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
        
        self.isUnsealed = data["isUnsealed"] as? Bool ?? false
        
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        if let timestamp = data["unsealedAt"] as? Timestamp {
            self.unsealedAt = timestamp.dateValue()
        } else {
            self.unsealedAt = nil
        }
    }
    
    // Helper computed properties
    var isActive: Bool {
        return !isUnsealed && sealDate > Date()
    }
    
    var timeUntilUnseal: TimeInterval {
        return max(0, sealDate.timeIntervalSince(Date()))
    }
    
    var shouldBeUnsealed: Bool {
        return !isUnsealed && sealDate <= Date()
    }
    
    var statusText: String {
        if isUnsealed {
            return "Unsealed"
        } else if shouldBeUnsealed {
            return "Ready to Unseal"
        } else {
            return "Sealed"
        }
    }
    
    var statusColor: String {
        if isUnsealed {
            return "green"
        } else if shouldBeUnsealed {
            return "orange"
        } else {
            return "blue"
        }
    }
}
