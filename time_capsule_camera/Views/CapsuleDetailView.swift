import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import AVKit

struct CapsuleDetailView: View {
    @State var capsule: Capsule
    @State private var clips: [Clip] = []
    @State private var currentClipIndex: Int = 0
    @State private var player: AVQueuePlayer? = nil
    @State private var showPicker: Bool = false
    @State private var showInvite: Bool = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadError: String? = nil
    @State private var showUploadError: Bool = false

    var body: some View {
        VStack {
            // Show upload progress when a video is uploading
            if isUploading {
                VStack {
                    ProgressView(value: uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                    Text("Uploading clip…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            if capsule.isUnsealed {
                if let player = player {
                    VideoPlayer(player: player)
                        .overlay(alignment: .bottomLeading) {
                            overlayView
                        }
                        .onDisappear { player.pause() }
                        .onAppear { player.play() }
                } else {
                    ProgressView("Loading video…")
                }
            } else {
                VStack(spacing: 16) {
                    Text("Capsule is sealed until \(capsule.sealDate.formatted(date: .long, time: .shortened))")
                    CountdownView(sealDate: capsule.sealDate)
                    Text("You can still add clips!")
                    Button("Add Clip") {
                        showPicker = true
                    }
                }
            }
        }
        .navigationTitle(capsule.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Only show Add Clip button when capsule is sealed
                if !capsule.isUnsealed {
                    Button("Add Clip") {
                        showPicker = true
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Invite") {
                    showInvite = true
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            VideoPicker { url in
                if let url = url {
                    uploadVideo(url: url)
                }
            }
        }
        .sheet(isPresented: $showInvite) {
            InviteMembersView(capsule: capsule)
        }
        .onAppear(perform: loadClips)
        .alert(isPresented: $showUploadError) {
            Alert(
                title: Text("Upload Error"),
                message: Text(uploadError ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if clips.indices.contains(currentClipIndex) {
            let clip = clips[currentClipIndex]
            VStack(alignment: .leading) {
                Text(clip.uploaderName)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(clip.createdAt.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
            .padding([.leading, .bottom], 16)
        }
    }

    private func loadClips() {
        let videosRef = FirebaseManager.shared.db.collection("capsules").document(capsule.id).collection("videos")
        videosRef.order(by: "createdAt").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading clips: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.clips = documents.map { Clip(id: $0.documentID, data: $0.data()) }
            if capsule.isUnsealed {
                preparePlayer()
            }
        }
    }

    private func preparePlayer() {
        guard !clips.isEmpty else { return }
        
        let group = DispatchGroup()
        var items: [AVPlayerItem] = []
        
        for (index, clip) in clips.enumerated() {
            group.enter()
            let storageRef = FirebaseManager.shared.storage.reference(withPath: clip.storagePath)
            storageRef.downloadURL { [weak self] url, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error downloading video URL: \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else { return }
                
                let item = AVPlayerItem(url: url)
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: item,
                    queue: .main
                ) { _ in
                    self?.currentClipIndex = min((self?.currentClipIndex ?? 0) + 1, (self?.clips.count ?? 1) - 1)
                }
                items.append((index, item))
            }
        }
        
        group.notify(queue: .main) {
            // Sort items by original index to maintain order
            let sortedItems = items.sorted { $0.0 < $1.0 }.map { $0.1 }
            self.player = AVQueuePlayer(items: sortedItems)
        }
    }

    private func uploadVideo(url: URL) {
        guard let user = FirebaseManager.shared.auth.currentUser else { return }
        let videoId = UUID().uuidString
        let videoRef = FirebaseManager.shared.storage.reference().child("videos/\(capsule.id)/\(videoId).mp4")

        // Reset upload state
        isUploading = true
        uploadProgress = 0.0
        uploadError = nil
        showUploadError = false

        let uploadTask = videoRef.putFile(from: url, metadata: nil)

        // Observe progress
        uploadTask.observe(.progress) { snapshot in
            if let fraction = snapshot.progress?.fractionCompleted {
                DispatchQueue.main.async {
                    self.uploadProgress = fraction
                }
            }
        }

        // Observe success
        uploadTask.observe(.success) { snapshot in
            DispatchQueue.main.async {
                self.isUploading = false
                self.uploadProgress = 0.0
            }
            // Write metadata to Firestore
            let data: [String: Any] = [
                "videoId": videoId,
                "uploaderId": user.uid,
                "uploaderName": user.displayName ?? "",
                "storagePath": videoRef.fullPath,
                "createdAt": Timestamp(date: Date())
            ]
            FirebaseManager.shared.db.collection("capsules").document(capsule.id).collection("videos").document(videoId).setData(data)
        }

        // Observe failure
        uploadTask.observe(.failure) { snapshot in
            DispatchQueue.main.async {
                self.isUploading = false
                self.uploadError = snapshot.error?.localizedDescription ?? "Failed to upload video."
                self.showUploadError = true
            }
        }
    }
}
