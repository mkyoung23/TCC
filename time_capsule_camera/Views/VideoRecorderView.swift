import SwiftUI
import AVFoundation
import AVKit

struct VideoRecorderView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onVideoRecorded: (URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoMaximumDuration = 300 // 5 minutes max for better memories
        picker.allowsEditing = true
        picker.cameraCaptureMode = .video
        
        // Set better video quality if available
        if picker.sourceType == .camera {
            picker.cameraDevice = .rear // Default to rear camera for better quality
            picker.cameraFlashMode = .auto // Enable flash when needed
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoRecorderView
        
        init(_ parent: VideoRecorderView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get the video URL - prefer edited version if available
            var videoURL: URL?
            
            if let editedURL = info[.editedMediaURL] as? URL {
                videoURL = editedURL
            } else if let originalURL = info[.mediaURL] as? URL {
                videoURL = originalURL
            }
            
            if let videoURL = videoURL {
                // Validate video before passing it along
                let asset = AVAsset(url: videoURL)
                let duration = asset.duration.seconds
                
                // Check if video is valid (not empty, reasonable duration)
                if duration > 0.1 && duration < 301 { // Between 0.1 seconds and 5 minutes
                    parent.onVideoRecorded(videoURL)
                } else {
                    print("Video validation failed: duration = \(duration)")
                    parent.onVideoRecorded(nil)
                }
            } else {
                parent.onVideoRecorded(nil)
            }
            
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onVideoRecorded(nil)
            parent.isPresented = false
        }
    }
}