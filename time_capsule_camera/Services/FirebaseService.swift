import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @Published var capsules: [Capsule] = []
    
    // 1. Create a Capsule for you and friends
    func createCapsule(name: String, unlockDate: Date, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newCapsule = Capsule(
            name: name,
            creatorId: userId,
            unlockDate: unlockDate,
            memberIds: [userId] // Start with just you
        )
        
        do {
            try db.collection("capsules").addDocument(from: newCapsule)
            completion(true)
        } catch {
            print("Error creating capsule: \(error)")
            completion(false)
        }
    }
    
    // 2. Add a Friend (They scan a code or type the ID)
    func joinCapsule(capsuleId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("capsules").document(capsuleId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error joining: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // 3. Upload Video (Goes to everyone's list)
    func uploadVideo(url: URL, to capsule: Capsule, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, let capsuleId = capsule.id else { return }
        
        let filename = "\(UUID().uuidString).mov"
        let ref = storage.reference().child("capsules/\(capsuleId)/\(filename)")
        
        ref.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print("Upload failed: \(error)")
                completion(false)
                return
            }
            
            ref.downloadURL { url, _ in
                guard let downloadURL = url else { return }
                
                // Save record to DB
                let video = CapsuleVideo(
                    uploaderId: userId,
                    videoUrl: downloadURL.absoluteString,
                    timestamp: Date()
                )
                
                do {
                    try self.db.collection("capsules").document(capsuleId).collection("videos").addDocument(from: video)
                    completion(true)
                } catch {
                    completion(false)
                }
            }
        }
    }
}
