import SwiftUI
import Firebase

@main
struct TimeCapsuleCameraApp: App {
    // Register AppDelegate to handle Firebase setup and push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authViewModel = AuthViewModel()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

    var body: some Scene {
        WindowGroup {
            if showOnboarding && authViewModel.isSignedIn {
                OnboardingView(showOnboarding: $showOnboarding)
            } else if authViewModel.isSignedIn {
                CapsuleListView()
                    .environmentObject(authViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
