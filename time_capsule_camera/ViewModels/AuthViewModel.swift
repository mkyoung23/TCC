import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool
    @Published var user: User?
    @Published var errorMessage: String?

    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
                self?.user = user
            }
        }
    }

    func signIn(email: String, password: String) {
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    self?.isSignedIn = true
                    self?.user = user
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) {
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { _ in
                        // Create Firestore document
                        let data: [String: Any] = [
                            "displayName": displayName,
                            "email": email,
                            "capsuleIds": [],
                            "createdAt": Timestamp(date: Date())
                        ]
                        FirebaseManager.shared.db.collection("users").document(user.uid).setData(data)
                    }
                    
                    self?.isSignedIn = true
                    self?.user = user
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.user = nil
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete user document from Firestore
        FirebaseManager.shared.db.collection("users").document(user.uid).delete()
        
        // Delete the Firebase Auth account
        user.delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isSignedIn = false
                    self?.user = nil
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = "Password reset email sent!"
                }
            }
        }
    }
}
