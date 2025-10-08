import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isRecording = false
    @State private var showingPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var recordingTime = 0
    @State private var timer: Timer?
    @Binding var capsuleCount: Int

    var body: some View {
        ZStack {
            // Camera preview placeholder
            Rectangle()
                .fill(Color.black)
                .ignoresSafeArea()

            VStack {
                // Top bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()

                    Spacer()

                    if isRecording {
                        HStack {
                            Image(systemName: "record.circle")
                                .foregroundColor(.red)
                            Text(formatTime(recordingTime))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .padding()
                    }
                }

                Spacer()

                // Camera instructions
                if !isRecording {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Camera Preview")
                            .font(.title2)
                            .foregroundColor(.white)

                        Text("Tap the button to record a video message")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }

                Spacer()

                // Bottom controls
                HStack {
                    // Gallery button
                    Button(action: {
                        // Open photo library
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)

                    // Record button
                    Button(action: {
                        toggleRecording()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)

                            Circle()
                                .fill(isRecording ? Color.red : Color.white)
                                .frame(width: isRecording ? 30 : 70, height: isRecording ? 30 : 70)
                                .animation(.easeInOut(duration: 0.2))
                        }
                    }

                    // Settings button
                    Button(action: {
                        // Camera settings
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionMessage)
        }
        .onAppear {
            checkCameraPermission()
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
            // Limit recording to 60 seconds
            if recordingTime >= 60 {
                stopRecording()
                saveCapsule()
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        if recordingTime > 0 {
            saveCapsule()
        }
        recordingTime = 0
    }

    private func saveCapsule() {
        capsuleCount += 1
        presentationMode.wrappedValue.dismiss()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    permissionMessage = "Camera access is required to record time capsule videos."
                    showingPermissionAlert = true
                }
            }
        case .denied, .restricted:
            permissionMessage = "Camera access is required. Please enable it in Settings."
            showingPermissionAlert = true
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}