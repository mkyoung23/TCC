import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
    }

    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    self.isSignedIn = true
                    self.user = user
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Failed to update profile: \(error.localizedDescription)")
                        }
                    }
                    
                    // Create Firestore document
                    let data: [String: Any] = [
                        "displayName": displayName,
                        "email": email,
                        "capsuleIds": []
                    ]
                    FirebaseManager.shared.db.collection("users").document(user.uid).setData(data) { error in
                        if let error = error {
                            print("Failed to create user document: \(error.localizedDescription)")
                        }
                    }
                    
                    self.isSignedIn = true
                    self.user = user
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
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            }
        }
    }
}
