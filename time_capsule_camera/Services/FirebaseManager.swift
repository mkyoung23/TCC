import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    let auth: Auth
    let db: Firestore
    let storage: Storage

    private init() {
        // FirebaseApp is configured in AppDelegate
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // Configure Firestore settings for better performance
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    // MARK: - User Management
    func getCurrentUserDisplayName() -> String {
        return auth.currentUser?.displayName ?? "Unknown User"
    }
    
    // MARK: - Capsule Management
    func fetchUserCapsules(completion: @escaping ([Capsule]) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion([])
            return
        }
        
        db.collection("capsules")
            .whereField("memberIds", arrayContains: userId)
            .order(by: "sealDate")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching capsules: \(error)")
                    completion([])
                    return
                }
                
                let capsules = snapshot?.documents.compactMap { document in
                    Capsule(id: document.documentID, data: document.data())
                } ?? []
                
                completion(capsules)
            }
    }
    
    // MARK: - Video Management
    func uploadVideo(url: URL, to capsuleId: String, progress: @escaping (Double) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        guard let user = auth.currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let videoId = UUID().uuidString
        let videoRef = storage.reference().child("videos/\(capsuleId)/\(videoId).mp4")
        
        let uploadTask = videoRef.putFile(from: url, metadata: nil)
        
        // Observe progress
        uploadTask.observe(.progress) { snapshot in
            if let progressFraction = snapshot.progress?.fractionCompleted {
                DispatchQueue.main.async {
                    progress(progressFraction)
                }
            }
        }
        
        // Handle completion
        uploadTask.observe(.success) { _ in
            // Save video metadata to Firestore
            let videoData: [String: Any] = [
                "videoId": videoId,
                "uploaderId": user.uid,
                "uploaderName": user.displayName ?? "Unknown User",
                "storagePath": videoRef.fullPath,
                "createdAt": Timestamp(date: Date())
            ]
            
            self.db.collection("capsules").document(capsuleId).collection("videos").document(videoId).setData(videoData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(videoId))
                }
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                completion(.failure(error))
            }
        }
    }
}
