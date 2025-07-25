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
    @State private var showInvite: Bool = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadError: String? = nil
    @State private var showUploadError: Bool = false
    @State private var memberDetails: [String: String] = [:] // uid -> displayName
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.gray.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                capsuleHeaderView
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Main content
                if capsule.isUnsealed {
                    unsealedContentView
                } else {
                    sealedContentView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if !capsule.isUnsealed {
                        Button(action: { showPicker = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: { showInvite = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
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
        .onAppear {
            loadClips()
            loadMemberDetails()
        }
        .alert("Upload Error", isPresented: $showUploadError) {
            Button("OK") { showUploadError = false }
        } message: {
            Text(uploadError ?? "Unknown error occurred")
        }
    }
    
    // MARK: - Header View
    private var capsuleHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(capsule.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(capsule.memberIds.count) members")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if clips.count > 0 {
                            Image(systemName: "video.fill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("\(clips.count) clips")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Status badge
                VStack {
                    Text(capsule.isUnsealed ? "UNSEALED" : "SEALED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(capsule.isUnsealed ? Color.green : Color.orange)
                        .cornerRadius(12)
                }
            }
            
            // Member avatars
            if !memberDetails.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(memberDetails.keys), id: \.self) { memberId in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String(memberDetails[memberId]?.prefix(1) ?? "U"))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    )
                                
                                Text(memberDetails[memberId] ?? "Unknown")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Sealed Content View
    private var sealedContentView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Countdown section
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: countdownProgress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: countdownProgress)
                    
                    VStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        
                        CountdownView(sealDate: capsule.sealDate)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Capsule Sealed Until")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(capsule.sealDate.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Upload section
            if isUploading {
                uploadProgressView
            } else {
                VStack(spacing: 16) {
                    Text("Add memories to this capsule")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showPicker = true }) {
                        HStack {
                            Image(systemName: "video.circle.fill")
                                .font(.title2)
                            Text("Add Video Clip")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            // Added clips count
            if clips.count > 0 {
                VStack(spacing: 8) {
                    Text("📹 \(clips.count) clip\(clips.count == 1 ? "" : "s") added")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Text("Your videos will be available when the capsule unseals!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Unsealed Content View
    private var unsealedContentView: some View {
        VStack(spacing: 0) {
            if let player = player, clips.count > 0 {
                // Video player
                VideoPlayer(player: player)
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .bottomLeading) {
                        videoOverlayView
                    }
                    .overlay(alignment: .bottom) {
                        videoControlsView
                    }
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else if clips.isEmpty {
                // No clips state
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No Videos Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("This capsule doesn't have any videos yet. Members can still add videos!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
            } else {
                // Loading state
                VStack {
                    Spacer()
                    ProgressView("Loading videos...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Upload Progress View
    private var uploadProgressView: some View {
        VStack(spacing: 16) {
            Text("Uploading Video...")
                .font(.headline)
                .foregroundColor(.white)
            
            ProgressView(value: uploadProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(width: 200)
            
            Text("\(Int(uploadProgress * 100))%")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(24)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
    
    // MARK: - Video Overlay View
    private var videoOverlayView: some View {
        if clips.indices.contains(currentClipIndex) {
            let clip = clips[currentClipIndex]
            VStack(alignment: .leading, spacing: 4) {
                Text(clip.uploaderName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(clip.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(12)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .padding([.leading, .bottom], 16)
        }
    }
    
    // MARK: - Video Controls View
    private var videoControlsView: some View {
        HStack(spacing: 20) {
            Button(action: previousClip) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .disabled(currentClipIndex <= 0)
            
            Text("\(currentClipIndex + 1) of \(clips.count)")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(minWidth: 80)
            
            Button(action: nextClip) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .disabled(currentClipIndex >= clips.count - 1)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .padding(.bottom, 20)
    }
    
    // MARK: - Computed Properties
    private var countdownProgress: Double {
        let now = Date()
        let total = capsule.sealDate.timeIntervalSince(Date.distantPast)
        let remaining = capsule.sealDate.timeIntervalSince(now)
        return max(0, min(1, 1 - (remaining / total)))
    }
    
    // MARK: - Helper Methods
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
    
    private func loadMemberDetails() {
        for memberId in capsule.memberIds {
            FirebaseManager.shared.db.collection("users").document(memberId).getDocument { document, _ in
                if let data = document?.data(),
                   let displayName = data["displayName"] as? String {
                    DispatchQueue.main.async {
                        self.memberDetails[memberId] = displayName
                    }
                }
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
                defer { group.leave() }
                if let url = url {
                    let item = AVPlayerItem(url: url)
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: item,
                        queue: .main
                    ) { _ in
                        self.nextClip()
                    }
                    items.append(item)
                }
            }
        }
        
        group.notify(queue: .main) {
            self.player = AVQueuePlayer(items: items)
        }
    }
    
    private func uploadVideo(url: URL) {
        guard let user = FirebaseManager.shared.auth.currentUser else { return }
        
        isUploading = true
        uploadProgress = 0.0
        uploadError = nil
        
        FirebaseManager.shared.uploadVideo(
            url: url,
            to: capsule.id,
            progress: { progress in
                self.uploadProgress = progress
            },
            completion: { result in
                DispatchQueue.main.async {
                    self.isUploading = false
                    self.uploadProgress = 0.0
                    
                    switch result {
                    case .success:
                        break // Success handled automatically by listener
                    case .failure(let error):
                        self.uploadError = error.localizedDescription
                        self.showUploadError = true
                    }
                }
            }
        )
    }
    
    private func nextClip() {
        if currentClipIndex < clips.count - 1 {
            currentClipIndex += 1
        }
    }
    
    private func previousClip() {
        if currentClipIndex > 0 {
            currentClipIndex -= 1
        }
    }
}
