import SwiftUI
import AVFoundation
import UIKit

struct CameraRecordingView: View {
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingPreview = false
    @State private var recordedVideoURL: URL?
    @Binding var isPresented: Bool
    
    var onVideoRecorded: ((URL) -> Void)?
    
    var body: some View {
        ZStack {
            // Camera preview background
            Color.black
                .ignoresSafeArea()
            
            // Camera preview
            CameraPreview()
                .ignoresSafeArea()
            
            // Vintage overlay and controls
            VStack {
                // Top vintage status bar
                HStack {
                    VStack(alignment: .leading) {
                        Text("VINTAGE CAM")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        if isRecording {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(isRecording ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                                
                                Text(formatTime(recordingTime))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        stopRecording()
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.6))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Vintage viewfinder overlay
                CameraViewfinderOverlay()
                    .opacity(0.8)
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Vintage film info
                    HStack {
                        VStack(alignment: .leading) {
                            Text("KODAK 8mm")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("ASA 64")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text(Date().formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Recording button
                    HStack(spacing: 40) {
                        Spacer()
                        
                        Button(action: {
                            if isRecording {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        }) {
                            ZStack {
                                // Outer ring
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                // Inner button
                                RoundedRectangle(cornerRadius: isRecording ? 8 : 40)
                                    .fill(isRecording ? Color.red : Color.white)
                                    .frame(width: isRecording ? 32 : 64, height: isRecording ? 32 : 64)
                                    .animation(.easeInOut(duration: 0.2), value: isRecording)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            
            // Film grain effect
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.02),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .ignoresSafeArea()
                .blendMode(.overlay)
        }
        .sheet(isPresented: $showingPreview) {
            if let url = recordedVideoURL {
                VideoPreviewView(videoURL: url, onSave: { savedURL in
                    onVideoRecorded?(savedURL)
                    isPresented = false
                }, onRetake: {
                    recordedVideoURL = nil
                    showingPreview = false
                })
            }
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordingTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
        
        // Simulate recording - in real app, start AVCaptureSession recording
        // For now, we'll use the video picker after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This would trigger actual camera recording
        }
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        // Simulate getting recorded video URL
        // In real app, this would come from AVCaptureSession
        // For now, show the video picker for demonstration
        showingPreview = true
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let deciseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, deciseconds)
    }
}

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // In a real implementation, this would set up AVCaptureVideoPreviewLayer
        // For demo purposes, we'll show a placeholder
        let label = UILabel()
        label.text = "Camera Preview\n(Demo Mode)"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview if needed
    }
}

struct VideoPreviewView: View {
    let videoURL: URL
    var onSave: (URL) -> Void
    var onRetake: () -> Void
    
    var body: some View {
        VStack {
            Text("Video Preview")
                .font(.title)
                .padding()
            
            // Video player would go here
            Rectangle()
                .fill(Color.gray)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    Text("Video Preview\n\(videoURL.lastPathComponent)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                )
                .padding()
            
            HStack(spacing: 20) {
                Button("Retake") {
                    onRetake()
                }
                .buttonStyle(VintageButtonStyle())
                
                Button("Save to Capsule") {
                    onSave(videoURL)
                }
                .buttonStyle(VintageButtonStyle())
            }
            .padding()
        }
    }
}