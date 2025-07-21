import Foundation
import Firebase
import FirebaseCrashlytics
import FirebaseAnalytics

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
        // Initialize Crashlytics and Analytics
        _ = Crashlytics.crashlytics()
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
}
