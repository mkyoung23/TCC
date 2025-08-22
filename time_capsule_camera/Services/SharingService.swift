import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class SharingService {
    static let shared = SharingService()
    
    private init() {}
    
    /// Generate a shareable link for the capsule
    func generateShareableLink(for capsule: Capsule) -> URL? {
        // Create a deep link URL that can be shared via text/email
        let baseURL = "https://timecapsulecamera.app/join"
        guard var components = URLComponents(string: baseURL) else { return nil }
        
        components.queryItems = [
            URLQueryItem(name: "capsuleId", value: capsule.id),
            URLQueryItem(name: "name", value: capsule.name)
        ]
        
        return components.url
    }
    
    /// Generate a share message for inviting friends
    func generateShareMessage(for capsule: Capsule, from user: User) -> String {
        let userName = user.displayName ?? "A friend"
        let sealDateString = DateFormatter.localizedString(from: capsule.sealDate, dateStyle: .medium, timeStyle: .short)
        
        return """
        🎬 \(userName) has invited you to join "\(capsule.name)" - a Time Capsule Camera!
        
        We're collecting videos together until \(sealDateString), when we'll all watch them as a group! 
        
        Download the Time Capsule Camera app and join us:
        \(generateShareableLink(for: capsule)?.absoluteString ?? "")
        
        📱 Get the app: [App Store Link]
        """
    }
    
    /// Invite members via email with improved validation
    func inviteMembers(emails: [String], to capsule: Capsule, completion: @escaping (Result<InviteResult, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(SharingError.notAuthenticated))
            return
        }
        
        let validEmails = emails.compactMap { email in
            isValidEmail(email) ? email.lowercased() : nil
        }
        
        guard !validEmails.isEmpty else {
            completion(.failure(SharingError.noValidEmails))
            return
        }
        
        var invited: [String] = []
        var notFound: [String] = []
        var alreadyMembers: [String] = []
        let group = DispatchGroup()
        
        for email in validEmails {
            group.enter()
            
            // Check if user exists
            FirebaseManager.shared.db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments { snapshot, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error checking user: \(error)")
                        notFound.append(email)
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        notFound.append(email)
                        return
                    }
                    
                    let userId = document.documentID
                    
                    // Check if user is already a member
                    if capsule.memberIds.contains(userId) {
                        alreadyMembers.append(email)
                        return
                    }
                    
                    // Add user to capsule
                    self.addUserToCapsule(userId: userId, capsuleId: capsule.id) { success in
                        if success {
                            invited.append(email)
                            // Send notification to the user
                            self.sendInviteNotification(to: userId, capsule: capsule, from: currentUser)
                        } else {
                            notFound.append(email)
                        }
                    }
                }
        }
        
        group.notify(queue: .main) {
            let result = InviteResult(
                invited: invited,
                notFound: notFound,
                alreadyMembers: alreadyMembers
            )
            completion(.success(result))
        }
    }
    
    /// Add user to capsule and update their capsule list
    private func addUserToCapsule(userId: String, capsuleId: String, completion: @escaping (Bool) -> Void) {
        let batch = FirebaseManager.shared.db.batch()
        
        // Add user to capsule members
        let capsuleRef = FirebaseManager.shared.db.collection("capsules").document(capsuleId)
        batch.updateData(["memberIds": FieldValue.arrayUnion([userId])], forDocument: capsuleRef)
        
        // Add capsule to user's capsule list
        let userRef = FirebaseManager.shared.db.collection("users").document(userId)
        batch.updateData(["capsuleIds": FieldValue.arrayUnion([capsuleId])], forDocument: userRef)
        
        batch.commit { error in
            completion(error == nil)
        }
    }
    
    /// Send in-app notification to invited user
    private func sendInviteNotification(to userId: String, capsule: Capsule, from inviter: User) {
        let notificationData: [String: Any] = [
            "type": "capsule_invite",
            "capsuleId": capsule.id,
            "capsuleName": capsule.name,
            "inviterName": inviter.displayName ?? "Someone",
            "inviterId": inviter.uid,
            "timestamp": Timestamp(date: Date()),
            "read": false
        ]
        
        FirebaseManager.shared.db
            .collection("users")
            .document(userId)
            .collection("notifications")
            .addDocument(data: notificationData)
    }
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Supporting Types
struct InviteResult {
    let invited: [String]
    let notFound: [String]
    let alreadyMembers: [String]
}

enum SharingError: Error, LocalizedError {
    case notAuthenticated
    case noValidEmails
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to invite members"
        case .noValidEmails:
            return "Please enter valid email addresses"
        }
    }
}