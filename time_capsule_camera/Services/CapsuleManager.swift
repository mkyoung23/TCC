import Foundation
import FirebaseFirestore
import Combine

class CapsuleManager: ObservableObject {
    static let shared = CapsuleManager()
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        startUnsealingTimer()
    }
    
    deinit {
        stopUnsealingTimer()
    }
    
    // MARK: - Automatic Unsealing
    private func startUnsealingTimer() {
        // Check every minute for capsules that should be unsealed
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.checkAndUnsealCapsules()
        }
        
        // Also check immediately
        checkAndUnsealCapsules()
    }
    
    private func stopUnsealingTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkAndUnsealCapsules() {
        let now = Date()
        
        FirebaseManager.shared.db.collection("capsules")
            .whereField("isUnsealed", isEqualTo: false)
            .whereField("sealDate", isLessThanOrEqualTo: Timestamp(date: now))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking capsules for unsealing: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    self.unsealCapsule(documentId: document.documentID)
                }
            }
    }
    
    private func unsealCapsule(documentId: String) {
        FirebaseManager.shared.db.collection("capsules").document(documentId).updateData([
            "isUnsealed": true,
            "unsealedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error unsealing capsule \(documentId): \(error)")
            } else {
                print("✅ Capsule \(documentId) has been unsealed!")
                // Here you could send push notifications to members
                self.notifyCapsuleMembers(capsuleId: documentId)
            }
        }
    }
    
    // MARK: - Notifications
    private func notifyCapsuleMembers(capsuleId: String) {
        // In a real app, this would send push notifications to all members
        // For now, we'll just log it
        print("📱 Would notify members that capsule \(capsuleId) is now unsealed")
        
        // You could implement FCM push notifications here
        // 1. Get all member IDs from the capsule
        // 2. Get their FCM tokens from user documents
        // 3. Send notifications via Firebase Cloud Messaging
    }
    
    // MARK: - Capsule Operations
    func createCapsule(name: String, sealDate: Date, creatorId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let data: [String: Any] = [
            "name": name,
            "creatorId": creatorId,
            "memberIds": [creatorId],
            "sealDate": Timestamp(date: sealDate),
            "isUnsealed": false,
            "createdAt": Timestamp(date: Date())
        ]
        
        FirebaseManager.shared.db.collection("capsules").addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Update user's capsule list
                FirebaseManager.shared.db.collection("users").document(creatorId).updateData([
                    "capsuleIds": FieldValue.arrayUnion([UUID().uuidString])
                ])
                completion(.success("Capsule created successfully"))
            }
        }
    }
    
    func addMemberToCapsule(capsuleId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.db.collection("capsules").document(capsuleId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Also update user's capsule list
            FirebaseManager.shared.db.collection("users").document(userId).updateData([
                "capsuleIds": FieldValue.arrayUnion([capsuleId])
            ]) { userError in
                if let userError = userError {
                    completion(.failure(userError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func removeMemberFromCapsule(capsuleId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.db.collection("capsules").document(capsuleId).updateData([
            "memberIds": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Also remove from user's capsule list
            FirebaseManager.shared.db.collection("users").document(userId).updateData([
                "capsuleIds": FieldValue.arrayRemove([capsuleId])
            ]) { userError in
                if let userError = userError {
                    completion(.failure(userError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}