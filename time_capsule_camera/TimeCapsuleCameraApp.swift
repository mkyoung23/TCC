import SwiftUI
import Firebase

@main
struct TimeCapsuleCameraApp: App {
    // Register AppDelegate to handle Firebase setup and push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
