import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth: Auth
    let db: Firestore
    let storage: Storage

    private init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
    }
}
