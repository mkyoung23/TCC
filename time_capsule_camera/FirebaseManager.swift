import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation
import CoreLocation

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    let auth: Auth
    let firestore: Firestore
    let storage: Storage

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var userName = ""

    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()

        // Listen to auth changes
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
            if let user = user {
                self?.fetchUserName(uid: user.uid)
            }
        }
    }

    // MARK: - Authentication

    func signUp(email: String, password: String, name: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)

        // Store user data in Firestore
        try await firestore.collection("users").document(result.user.uid).setData([
            "name": name,
            "email": email,
            "createdAt": Date(),
            "capsules": []
        ])

        self.userName = name
    }

    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try auth.signOut()
        userName = ""
    }

    private func fetchUserName(uid: String) {
        firestore.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                self?.userName = name
            }
        }
    }
}

// MARK: - Capsule Management

extension FirebaseManager {

    struct Capsule: Identifiable, Codable {
        let id: String
        let creatorId: String
        let creatorName: String
        let title: String
        let createdAt: Date
        let unlockDate: Date
        let shareCode: String
        let members: [String] // User IDs
        let videos: [Video]

        var isLocked: Bool {
            Date() < unlockDate
        }
    }

    struct Video: Codable, Identifiable {
        let id: String
        let userId: String
        let userName: String
        let videoUrl: String
        let thumbnailUrl: String?
        let duration: TimeInterval
        let recordedAt: Date
        let location: String?
    }

    func createCapsule(title: String, unlockDate: Date) async throws -> String {
        guard let userId = currentUser?.uid else { throw FirebaseError.notAuthenticated }

        let capsuleId = UUID().uuidString
        let shareCode = String(Int.random(in: 100000...999999)) // 6-digit code

        let capsule = Capsule(
            id: capsuleId,
            creatorId: userId,
            creatorName: userName,
            title: title,
            createdAt: Date(),
            unlockDate: unlockDate,
            shareCode: shareCode,
            members: [userId],
            videos: []
        )

        // Save to Firestore
        try await firestore.collection("capsules").document(capsuleId).setData([
            "id": capsuleId,
            "creatorId": userId,
            "creatorName": userName,
            "title": title,
            "createdAt": Timestamp(date: Date()),
            "unlockDate": Timestamp(date: unlockDate),
            "shareCode": shareCode,
            "members": [userId],
            "videos": []
        ])

        // Add capsule to user's list
        try await firestore.collection("users").document(userId).updateData([
            "capsules": FieldValue.arrayUnion([capsuleId])
        ])

        return shareCode
    }

    func joinCapsule(shareCode: String) async throws {
        guard let userId = currentUser?.uid else { throw FirebaseError.notAuthenticated }

        // Find capsule with share code
        let snapshot = try await firestore.collection("capsules")
            .whereField("shareCode", isEqualTo: shareCode)
            .getDocuments()

        guard let capsuleDoc = snapshot.documents.first else {
            throw FirebaseError.capsuleNotFound
        }

        let capsuleId = capsuleDoc.documentID

        // Add user to capsule members
        try await firestore.collection("capsules").document(capsuleId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])

        // Add capsule to user's list
        try await firestore.collection("users").document(userId).updateData([
            "capsules": FieldValue.arrayUnion([capsuleId])
        ])
    }

    func getUserCapsules() async throws -> [Capsule] {
        guard let userId = currentUser?.uid else { throw FirebaseError.notAuthenticated }

        // Get user's capsule IDs
        let userDoc = try await firestore.collection("users").document(userId).getDocument()
        guard let capsuleIds = userDoc.data()?["capsules"] as? [String] else {
            return []
        }

        // Fetch all capsules
        var capsules: [Capsule] = []
        for capsuleId in capsuleIds {
            let capsuleDoc = try await firestore.collection("capsules").document(capsuleId).getDocument()
            if let data = capsuleDoc.data() {
                let capsule = try self.parseCapsule(from: data)
                capsules.append(capsule)
            }
        }

        return capsules
    }

    private func parseCapsule(from data: [String: Any]) throws -> Capsule {
        guard let id = data["id"] as? String,
              let creatorId = data["creatorId"] as? String,
              let creatorName = data["creatorName"] as? String,
              let title = data["title"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
              let unlockDate = (data["unlockDate"] as? Timestamp)?.dateValue(),
              let shareCode = data["shareCode"] as? String,
              let members = data["members"] as? [String] else {
            throw FirebaseError.invalidData
        }

        // Parse videos if they exist
        let videos: [Video] = []
        // Videos will be parsed separately when needed

        return Capsule(
            id: id,
            creatorId: creatorId,
            creatorName: creatorName,
            title: title,
            createdAt: createdAt,
            unlockDate: unlockDate,
            shareCode: shareCode,
            members: members,
            videos: videos
        )
    }
}

// MARK: - Video Upload

extension FirebaseManager {

    func uploadVideo(to capsuleId: String, videoUrl: URL) async throws -> String {
        guard let userId = currentUser?.uid else { throw FirebaseError.notAuthenticated }

        let videoId = UUID().uuidString
        let videoRef = storage.reference().child("capsules/\(capsuleId)/videos/\(videoId).mov")

        // Upload video
        let videoData = try Data(contentsOf: videoUrl)
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"

        _ = try await videoRef.putDataAsync(videoData, metadata: metadata)
        let downloadUrl = try await videoRef.downloadURL().absoluteString

        // Get actual video metadata
        let asset = AVAsset(url: videoUrl)
        let duration = CMTimeGetSeconds(asset.duration)

        // Try to get actual recording date from video metadata
        var recordedDate = Date()
        if let metadataItem = try await asset.loadMetadata(for: .commonMetadata)
            .first(where: { $0.commonKey == .commonKeyCreationDate }),
           let dateValue = try await metadataItem.load(.dateValue) {
            recordedDate = dateValue
        }

        // Create video document with ACTUAL recording time
        let video: [String: Any] = [
            "id": videoId,
            "userId": userId,
            "userName": userName,
            "videoUrl": downloadUrl,
            "duration": duration,
            "recordedAt": Timestamp(date: recordedDate), // When it was ACTUALLY recorded
            "uploadedAt": Timestamp(date: Date()), // When uploaded
            "location": "Current Location" // Will be set from camera view
        ]

        // Add video to capsule
        try await firestore.collection("capsules").document(capsuleId).updateData([
            "videos": FieldValue.arrayUnion([video])
        ])

        return videoId
    }
}

// MARK: - Errors

enum FirebaseError: LocalizedError {
    case notAuthenticated
    case capsuleNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .capsuleNotFound:
            return "No capsule found with that code"
        case .invalidData:
            return "Invalid data format"
        }
    }
}