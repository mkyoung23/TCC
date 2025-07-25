import SwiftUI
import PhotosUI

struct VideoSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    var onVideoSelected: (URL?) -> Void
    
    @State private var showRecorder = false
    @State private var showLibrary = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "video.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Add Video to Capsule")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Record a new video or choose from your library")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Button(action: {
                        showRecorder = true
                    }) {
                        HStack {
                            Image(systemName: "video.fill")
                            Text("Record Video")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose from Library")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
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
                onVideoSelected(url)
                dismiss()
            }
        }
        .sheet(isPresented: $showLibrary) {
            VideoPicker { url in
                onVideoSelected(url)
                dismiss()
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    var onPick: (URL?) -> Void

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
            guard let provider = results.first?.itemProvider else {
                parent.onPick(nil)
                return
            }
            if provider.hasItemConformingToTypeIdentifier("public.movie") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    DispatchQueue.main.async {
                        parent.onPick(url)
                    }
                }
            } else {
                parent.onPick(nil)
            }
        }
    }
}
