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

    var body: some View {
        VStack {
            if capsule.isUnsealed {
                if let player = player {
                    VideoPlayer(player: player)
                        .overlay(alignment: .bottomLeading) {
                            overlayView
                        }
                        .onDisappear { player.pause() }
                        .onAppear {
                            player.play()
                        }
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
        .navigationBarItems(trailing: capsule.isUnsealed ? nil : Button("Add Clip") {
            showPicker = true
        })
        .sheet(isPresented: $showPicker) {
            VideoPicker { url in
                if let url = url {
                    uploadVideo(url: url)
                }
            }
        }
        .onAppear(perform: loadClips)
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
        for (index, clip) in clips.enumerated() {
            group.enter()
            let storageRef = FirebaseManager.shared.storage.reference(withPath: clip.storagePath)
            storageRef.downloadURL { url, error in
                if let url = url {
                    var clip = clip
                    clip.url = url
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
            self.player = AVQueuePlayer(items: items.sorted { ($0.asset.duration.seconds) < ($1.asset.duration.seconds) })
        }
    }

    private func uploadVideo(url: URL) {
        guard let user = FirebaseManager.shared.auth.currentUser else { return }
        let videoId = UUID().uuidString
        let videoRef = FirebaseManager.shared.storage.reference().child("videos/\(capsule.id)/\(videoId).mp4")
        let uploadTask = videoRef.putFile(from: url, metadata: nil) { metadata, error in
            if let _ = metadata {
                // On successful upload, write metadata to Firestore
                let data: [String: Any] = [
                    "videoId": videoId,
                    "uploaderId": user.uid,
                    "uploaderName": user.displayName ?? "",
                    "storagePath": videoRef.fullPath,
                    "createdAt": Timestamp(date: Date())
                ]
                FirebaseManager.shared.db.collection("capsules").document(capsule.id).collection("videos").document(videoId).setData(data)
            }
        }
        // Optionally observe progress or errors on uploadTask
    }
}
