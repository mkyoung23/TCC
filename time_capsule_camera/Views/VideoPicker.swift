import SwiftUI
import PhotosUI

struct VideoSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    var onVideoSelected: (URL?, Date?) -> Void
    
    @State private var showRecorder = false
    @State private var showLibrary = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header section
                VStack(spacing: 16) {
                    Image(systemName: "video.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    
                    VStack(spacing: 8) {
                        Text("Add Video to Capsule")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Capture a moment to share when your capsule unseals!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Action buttons
                VStack(spacing: 20) {
                    // Record new video (primary action)
                    Button(action: {
                        showRecorder = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "video.fill")
                                .font(.title2)
                            Text("Record New Video")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Choose from library (secondary action)
                    Button(action: {
                        showLibrary = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Choose from Library")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Info section
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("Videos are ordered by when they were originally taken")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.secondary)
                            Text("Maximum 5 minutes per video")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Add Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRecorder) {
            VideoRecorderView(isPresented: $showRecorder) { url in
                let creationDate = url != nil ? VideoMetadataService.shared.getVideoCreationDate(from: url!) : nil
                onVideoSelected(url, creationDate)
                dismiss()
            }
        }
        .sheet(isPresented: $showLibrary) {
            VideoPicker { url, creationDate in
                onVideoSelected(url, creationDate)
                dismiss()
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    var onPick: (URL?, Date?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker

        init(parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let result = results.first else {
                parent.onPick(nil, nil)
                return
            }
            
            let provider = result.itemProvider
            
            if provider.hasItemConformingToTypeIdentifier("public.movie") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    var creationDate: Date?
                    
                    // Try to get creation date from PHAsset if available
                    if let assetIdentifier = result.assetIdentifier {
                        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                        if let asset = fetchResult.firstObject {
                            creationDate = VideoMetadataService.shared.getVideoCreationDate(from: asset)
                        }
                    }
                    
                    // Fallback to file metadata if PHAsset not available
                    if creationDate == nil && url != nil {
                        creationDate = VideoMetadataService.shared.getVideoCreationDate(from: url!)
                    }
                    
                    DispatchQueue.main.async {
                        parent.onPick(url, creationDate)
                    }
                }
            } else {
                parent.onPick(nil, nil)
            }
        }
    }
}
