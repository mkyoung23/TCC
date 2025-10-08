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
    var body: some View {
        VStack {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Time Capsule Camera")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Version 1.0")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}