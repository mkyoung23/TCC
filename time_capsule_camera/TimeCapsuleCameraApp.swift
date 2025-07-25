import SwiftUI
import Firebase

@main
struct TimeCapsuleCameraApp: App {
    // Register AppDelegate to handle Firebase setup and push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var capsuleManager = CapsuleManager.shared

    var body: some Scene {
        WindowGroup {
            if authViewModel.isSignedIn {
                CapsuleListView()
                    .environmentObject(authViewModel)
                    .environmentObject(capsuleManager)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
