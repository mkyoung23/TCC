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
    @State private var showUploadSuccess: Bool = false
    @State private var uploadSuccessMessage: String = ""
    @State private var showCelebration: Bool = false
    @State private var hasShownCelebration: Bool = false

    var body: some View {
        VStack {
            // Show upload progress when a video is uploading
            if isUploading {
                VStack(spacing: 12) {
                    HStack {
                        ProgressView(value: uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        Text("\(Int(uploadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                    }
                    .padding(.horizontal)
                    
                    Text("Uploading clip...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: uploadProgress)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Show success message
            if showUploadSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(uploadSuccessMessage)
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .onAppear {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Auto-hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showUploadSuccess = false
                        }
                    }
                }
            }
            if capsule.isUnsealed {
                if let player = player {
                    ZStack {
                        VideoPlayer(player: player)
                            .onDisappear { player.pause() }
                            .onAppear { player.play() }
                        
                        // Enhanced overlay with better design
                        VStack {
                            Spacer()
                            HStack {
                                overlayView
                                Spacer()
                                // Video counter
                                if clips.count > 1 {
                                    Text("\(currentClipIndex + 1) of \(clips.count)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                            }
                            .padding()
                        }
                    }
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading videos...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                }
            } else {
                VStack(spacing: 24) {
                    CountdownView(sealDate: capsule.sealDate)
                    
                    VStack(spacing: 16) {
                        Text("Keep adding memories!")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Videos added now will be revealed when the capsule unseals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Add Video") {
                            showPicker = true
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal)
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
            VideoSelectionView { url in
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
        .overlay {
            if showCelebration {
                CelebrationView()
                    .onTapGesture {
                        withAnimation {
                            showCelebration = false
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CapsuleUnsealed"))) { notification in
            if let capsuleId = notification.userInfo?["capsuleId"] as? String, capsuleId == capsule.id {
                showCelebration = true
            }
        }
        .onChange(of: capsule.isUnsealed) { isUnsealed in
            if isUnsealed && !hasShownCelebration {
                showCelebration = true
                hasShownCelebration = true
            }
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if clips.indices.contains(currentClipIndex) {
            let clip = clips[currentClipIndex]
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(String(clip.uploaderName.prefix(1).uppercased()))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(clip.uploaderName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(clip.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
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
                self.uploadSuccessMessage = "Video uploaded successfully! 🎉"
                self.showUploadSuccess = true
            }
            // Write metadata to Firestore
            let data: [String: Any] = [
                "videoId": videoId,
                "uploaderId": user.uid,
                "uploaderName": user.displayName ?? "Unknown",
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
