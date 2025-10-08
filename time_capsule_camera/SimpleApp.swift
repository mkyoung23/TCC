import SwiftUI

@main
struct TimeCapsuleCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showingAlert = false
    @State private var capsuleCount = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()

                    Text("Time Capsule Camera")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Capture moments in time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Stats Card
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.blue)
                        Text("My Capsules")
                            .font(.headline)
                        Spacer()
                        Text("\(capsuleCount)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Next Unlock")
                            .font(.headline)
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        capsuleCount += 1
                        showingAlert = true
                    }) {
                        Label("Create Time Capsule", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // View action
                    }) {
                        Label("View Capsules", systemImage: "photo.stack")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Text("Version 1.0 (Build 2)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
        .alert("Success!", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Time capsule created! This feature will be fully functional in the next update.")
        }
    }
}