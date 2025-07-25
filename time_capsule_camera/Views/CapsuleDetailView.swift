import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import AVKit

struct CapsuleDetailView: View {
    let capsule: Capsule
    @State private var clips: [Clip] = []
    @State private var currentClipIndex: Int = 0
    @State private var player: AVQueuePlayer? = nil
    @State private var showPicker: Bool = false
    @State private var showCameraRecording: Bool = false
    @State private var showInvite: Bool = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadError: String? = nil
    @State private var showUploadError: Bool = false

    var body: some View {
        ZStack {
            // Vintage background
            VintageTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Film strip borders
            FilmStripBorder()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Vintage header
                VStack(spacing: 8) {
                    HStack {
                        Text(capsule.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                        
                        Spacer()
                        
                        if capsule.isUnsealed {
                            Text("UNSEALED")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                )
                        } else {
                            Text("SEALED")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Rectangle()
                        .fill(VintageTheme.vintage)
                        .frame(height: 2)
                        .padding(.horizontal, 20)
                }
                .background(Color.white.opacity(0.9))
                
                // Main content
                if isUploading {
                    VStack(spacing: 16) {
                        Text("Adding Memory to Capsule...")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                        
                        ProgressView(value: uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: VintageTheme.vintage))
                            .padding(.horizontal, 40)
                        
                        Text("\(Int(uploadProgress * 100))% complete")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(VintageTheme.darkSepia)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if capsule.isUnsealed {
                    // Unsealed capsule - show videos
                    if clips.isEmpty {
                        VStack(spacing: 20) {
                            Text("No Memories Found")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                            
                            Text("This capsule is empty. Memories may have been lost to time...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(VintageTheme.darkSepia)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let player = player {
                        VideoPlayer(player: player)
                            .overlay(alignment: .bottomLeading) {
                                overlayView
                            }
                            .onDisappear { player.pause() }
                            .onAppear { player.play() }
                            .clipped()
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: VintageTheme.vintage))
                                .scaleEffect(1.5)
                            
                            Text("Loading Memories...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // Sealed capsule - show countdown and add options
                    ScrollView {
                        VStack(spacing: 24) {
                            Spacer(minLength: 40)
                            
                            // Vintage lock icon
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                                    
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(VintageTheme.sepia)
                                }
                                
                                Text("Memory Capsule Sealed")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                                
                                Text("Unseals on \(capsule.sealDate.formatted(date: .long, time: .shortened))")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            // Countdown
                            CountdownView(sealDate: capsule.sealDate)
                                .padding(.horizontal, 20)
                            
                            // Add memories section
                            VStack(spacing: 16) {
                                Text("Add Your Memories")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                                
                                Text("Capture new moments or add existing videos to this time capsule")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                    .multilineTextAlignment(.center)
                                
                                HStack(spacing: 16) {
                                    Button(action: { showCameraRecording = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(VintageTheme.vintage)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "video.fill")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text("Record Video")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundColor(VintageTheme.vintage)
                                        }
                                    }
                                    
                                    Button(action: { showPicker = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(VintageTheme.darkSepia)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "photo.on.rectangle")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text("Choose Video")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundColor(VintageTheme.vintage)
                                        }
                                    }
                                    
                                    Button(action: { showInvite = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(VintageTheme.lensRing)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "person.2.fill")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text("Invite Friends")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundColor(VintageTheme.vintage)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCameraRecording) {
            CameraRecordingView(isPresented: $showCameraRecording) { url in
                uploadVideo(url: url)
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
            VStack(alignment: .leading, spacing: 4) {
                Text(clip.uploaderName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
                
                Text(clip.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.7))
            )
            .padding([.leading, .bottom], 16)
        }
    }

    private func loadClips() {
        let videosRef = FirebaseManager.shared.db.collection("capsules").document(capsule.id).collection("videos")
        videosRef.order(by: "createdAt").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.clips = documents.map { Clip(id: $0.documentID, data: $0.data()) }
            if capsule.isUnsealed {
                preparePlayer()
            }
        }
    }

    private func preparePlayer() {
        let group = DispatchGroup()
        var items: [AVPlayerItem] = []
        for clip in clips {
            group.enter()
            let storageRef = FirebaseManager.shared.storage.reference(withPath: clip.storagePath)
            storageRef.downloadURL { url, error in
                if let url = url {
                    var updatedClip = clip
                    updatedClip.url = url
                    let item = AVPlayerItem(url: url)
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
                        currentClipIndex = min(currentClipIndex + 1, clips.count - 1)
                    }
                    items.append(item)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.player = AVQueuePlayer(items: items)
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
