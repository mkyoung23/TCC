import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth: Auth
    let db: Firestore
    let storage: Storage

    private init() {
        // FirebaseApp is configured in AppDelegate
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
}
