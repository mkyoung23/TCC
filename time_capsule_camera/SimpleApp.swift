import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TimeCapsuleCameraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebase = FirebaseManager.shared

    var body: some Scene {
        WindowGroup {
            if firebase.isAuthenticated {
                ContentView()
            } else {
                AuthenticationView()
            }
        }
    }
}

struct ContentView: View {
    @State private var showingCamera = false
    @State private var showingCapsuleList = false
    @State private var showingSettings = false
    @State private var capsuleCount = 3
    @State private var nextUnlockDays = 305
    @State private var userName = "Time Traveler"

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {
                    // Header with user greeting
                    VStack(spacing: 8) {
                        Text("Hello, \(userName)!")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                            Text("Time Capsule Camera")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }

                        Text("Preserve today for tomorrow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Quick Stats Dashboard
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            StatCard(
                                icon: "photo.on.rectangle.angled",
                                title: "Total Capsules",
                                value: "\(capsuleCount)",
                                color: .blue
                            )

                            StatCard(
                                icon: "lock.fill",
                                title: "Locked",
                                value: "2",
                                color: .orange
                            )
                        }

                        HStack(spacing: 15) {
                            StatCard(
                                icon: "clock.arrow.circlepath",
                                title: "Next Unlock",
                                value: "\(nextUnlockDays)d",
                                color: .purple
                            )

                            StatCard(
                                icon: "play.circle.fill",
                                title: "Viewable",
                                value: "1",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Featured Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                QuickActionCard(
                                    icon: "video.badge.plus",
                                    title: "Record Now",
                                    subtitle: "60 sec max",
                                    color: .red
                                ) {
                                    showingCamera = true
                                }

                                QuickActionCard(
                                    icon: "calendar.badge.plus",
                                    title: "Schedule",
                                    subtitle: "Future unlock",
                                    color: .orange
                                ) {
                                    // Schedule action
                                }

                                QuickActionCard(
                                    icon: "person.2.fill",
                                    title: "Share",
                                    subtitle: "With friends",
                                    color: .purple
                                ) {
                                    // Share action
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()

                    // Main Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                Text("Create New Time Capsule")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            showingCapsuleList = true
                        }) {
                            HStack {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 20))
                                Text("View My Capsules")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)

                    // Footer
                    HStack {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("Version 1.0 (Build 3)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Spacer()

                        Button(action: {
                            // Help action
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(capsuleCount: $capsuleCount)
        }
        .sheet(isPresented: $showingCapsuleList) {
            CapsuleListView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(userName: $userName)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 90, height: 110)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userName: String
    @State private var notificationsEnabled = true
    @State private var defaultUnlockDuration = 365

    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $userName)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Preferences") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)

                    HStack {
                        Text("Default Unlock Duration")
                        Spacer()
                        Text("\(defaultUnlockDuration) days")
                            .foregroundColor(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (Build 3)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Mike Young")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}