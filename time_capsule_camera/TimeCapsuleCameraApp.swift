import SwiftUI
import Firebase

@main
struct TimeCapsuleCameraApp: App {
    init() {
        FirebaseApp.configure()
    }

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isSignedIn {
                CapsuleListView()
                    .environmentObject(authViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
