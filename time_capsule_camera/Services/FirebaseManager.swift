import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Network

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    let auth: Auth
    let db: Firestore
    let storage: Storage
    
    @Published var isOnline: Bool = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        // FirebaseApp is configured in AppDelegate
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        
        configureFirestore()
        setupNetworkMonitoring()
    }
    
    private func configureFirestore() {
        // Configure Firestore settings for optimal performance
        let settings = FirestoreSettings()
        
        // Enable offline persistence
        settings.isPersistenceEnabled = true
        
        // Set cache size (default is 40MB, increase for better offline experience)
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        db.settings = settings
        
        // Enable network for Firestore
        db.enableNetwork { error in
            if let error = error {
                print("Error enabling Firestore network: \(error)")
            } else {
                print("Firestore network enabled successfully")
            }
        }
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
            
            if path.status == .satisfied {
                // Network is available, enable Firestore network
                self?.db.enableNetwork { error in
                    if let error = error {
                        print("Error enabling network: \(error)")
                    }
                }
            } else {
                // Network is unavailable, disable Firestore network to save battery
                self?.db.disableNetwork { error in
                    if let error = error {
                        print("Error disabling network: \(error)")
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    // MARK: - User Management
    
    func createUserProfile(user: User, displayName: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "displayName": displayName,
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "capsuleIds": []
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            completion(error)
        }
    }
    
    // MARK: - Capsule Management
    
    func createCapsule(name: String, sealDate: Date, creatorId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let capsuleData: [String: Any] = [
            "name": name,
            "creatorId": creatorId,
            "memberIds": [creatorId],
            "sealDate": Timestamp(date: sealDate),
            "isUnsealed": false,
            "createdAt": Timestamp(date: Date())
        ]
        
        let capsuleRef = db.collection("capsules").document()
        
        let batch = db.batch()
        batch.setData(capsuleData, forDocument: capsuleRef)
        
        // Add capsule to user's capsuleIds
        let userRef = db.collection("users").document(creatorId)
        batch.updateData(["capsuleIds": FieldValue.arrayUnion([capsuleRef.documentID])], forDocument: userRef)
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(capsuleRef.documentID))
            }
        }
    }
    
    // MARK: - Video Management
    
    func uploadVideo(
        data: Data,
        capsuleId: String,
        metadata: [String: Any],
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let videoId = UUID().uuidString
        let videoRef = storage.reference().child("videos/\(capsuleId)/\(videoId).mp4")
        
        let uploadTask = videoRef.putData(data, metadata: nil)
        
        // Monitor progress
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                let percentage = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                progressHandler(percentage)
            }
        }
        
        // Handle completion
        uploadTask.observe(.success) { _ in
            // Save metadata to Firestore
            var videoMetadata = metadata
            videoMetadata["storagePath"] = videoRef.fullPath
            
            self.db.collection("capsules").document(capsuleId)
                .collection("videos").document(videoId)
                .setData(videoMetadata) { error in
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
    
    deinit {
        monitor.cancel()
    }
}
