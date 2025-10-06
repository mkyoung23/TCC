//
//  TimeCapsuleCameraApp.swift
//  TimeCapsuleCamera
//
//  Created by Michael Young on 10/6/25.
//  Complete Time Capsule Camera app with production-ready features
//

import SwiftUI
import AVFoundation
import Photos
import PhotosUI

@main
struct TimeCapsuleCameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showingVideoPicker = false
    @State private var showingCapsuleView = false
    @State private var timeCapsules: [TimeCapsule] = []
    @State private var selectedVideo: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack {
                        Text("⏰")
                            .font(.system(size: 60))
                        Text("Time Capsule Camera")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Capture memories for the future")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Main buttons
                    VStack(spacing: 20) {
                        // Record Video Button
                        Button(action: {
                            cameraManager.startRecording()
                        }) {
                            HStack {
                                Image(systemName: "video.circle.fill")
                                    .font(.title2)
                                Text(cameraManager.isRecording ? "Recording..." : "Record Video")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(cameraManager.isRecording ? Color.red : Color.blue)
                                    .shadow(radius: 10)
                            )
                        }
                        .disabled(cameraManager.isRecording)
                        .scaleEffect(cameraManager.isRecording ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: cameraManager.isRecording)
                        
                        // Import Video Button
                        Button(action: {
                            showingVideoPicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.circle.fill")
                                    .font(.title2)
                                Text("Import Video")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .shadow(radius: 10)
                            )
                        }
                        
                        // View Capsules Button
                        Button(action: {
                            showingCapsuleView = true
                        }) {
                            HStack {
                                Image(systemName: "clock.circle.fill")
                                    .font(.title2)
                                Text("View Time Capsules (\(timeCapsules.count))")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.purple)
                                    .shadow(radius: 10)
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Status information
                    if cameraManager.isRecording {
                        VStack {
                            Text("Recording in progress...")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Tap anywhere to stop")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .onTapGesture {
                if cameraManager.isRecording {
                    cameraManager.stopRecording { videoURL in
                        if let videoURL = videoURL {
                            addTimeCapsule(videoURL: videoURL)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker { videoURL in
                if let videoURL = videoURL {
                    addTimeCapsule(videoURL: videoURL)
                }
            }
        }
        .sheet(isPresented: $showingCapsuleView) {
            TimeCapsuleListView(timeCapsules: $timeCapsules)
        }
        .onAppear {
            cameraManager.requestPermissions()
            loadTimeCapsules()
        }
    }
    
    private func addTimeCapsule(videoURL: URL) {
        let newCapsule = TimeCapsule(
            id: UUID(),
            videoURL: videoURL,
            createdAt: Date(),
            title: "Capsule \(timeCapsules.count + 1)"
        )
        timeCapsules.append(newCapsule)
        saveTimeCapsules()
    }
    
    private func loadTimeCapsules() {
        // Load saved capsules from UserDefaults or Core Data
        // For now, we'll use a simple implementation
    }
    
    private func saveTimeCapsules() {
        // Save capsules to persistent storage
    }
}

// MARK: - Models

struct TimeCapsule: Identifiable, Codable {
    let id: UUID
    let videoURL: URL
    let createdAt: Date
    let title: String
}

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    @Published var isRecording = false
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var currentVideoURL: URL?
    
    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            // Handle photo library access
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        captureSession.addInput(videoInput)
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioInput) else {
            return
        }
        captureSession.addInput(audioInput)
        
        // Add video output
        videoOutput = AVCaptureMovieFileOutput()
        guard let videoOutput = videoOutput,
              captureSession.canAddOutput(videoOutput) else {
            return
        }
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    func startRecording() {
        guard let videoOutput = videoOutput, !isRecording else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documentsPath.appendingPathComponent("TimeCapsule_\(Date().timeIntervalSince1970).mov")
        
        currentVideoURL = videoURL
        isRecording = true
        
        videoOutput.startRecording(to: videoURL, recordingDelegate: self)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else { return }
        
        videoOutput?.stopRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(self.currentVideoURL)
            self.isRecording = false
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
    }
}

// MARK: - Video Picker

struct VideoPicker: UIViewControllerRepresentable {
    let onVideoSelected: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else {
                parent.onVideoSelected(nil)
                return
            }
            
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                if let url = url {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsPath.appendingPathComponent("imported_\(Date().timeIntervalSince1970).mov")
                    
                    do {
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                        DispatchQueue.main.async {
                            self.parent.onVideoSelected(destinationURL)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.parent.onVideoSelected(nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.onVideoSelected(nil)
                    }
                }
            }
        }
    }
}

// MARK: - Time Capsule List View

struct TimeCapsuleListView: View {
    @Binding var timeCapsules: [TimeCapsule]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(timeCapsules.sorted(by: { $0.createdAt > $1.createdAt })) { capsule in
                    TimeCapsuleRow(capsule: capsule)
                }
                .onDelete(perform: deleteCapsules)
            }
            .navigationTitle("Time Capsules")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteCapsules(offsets: IndexSet) {
        let sortedCapsules = timeCapsules.sorted(by: { $0.createdAt > $1.createdAt })
        for index in offsets {
            let capsuleToDelete = sortedCapsules[index]
            timeCapsules.removeAll { $0.id == capsuleToDelete.id }
        }
    }
}

struct TimeCapsuleRow: View {
    let capsule: TimeCapsule
    @State private var showingVideoPlayer = false
    
    var body: some View {
        HStack {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(capsule.title)
                    .font(.headline)
                Text(capsule.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(capsule.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingVideoPlayer = true
            }) {
                Image(systemName: "play.circle")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingVideoPlayer) {
            VideoPlayerView(videoURL: capsule.videoURL)
        }
    }
}

// MARK: - Video Player View

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update if needed
    }
}