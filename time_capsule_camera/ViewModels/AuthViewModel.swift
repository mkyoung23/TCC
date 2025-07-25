import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

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
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Please fill in all fields")
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.showErrorMessage(error.localizedDescription)
                } else if let user = result?.user {
                    self?.isSignedIn = true
                    self?.user = user
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            showErrorMessage("Please fill in all fields")
            return
        }
        
        guard password.count >= 6 else {
            showErrorMessage("Password must be at least 6 characters")
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.showErrorMessage(error.localizedDescription)
                } else if let user = result?.user {
                    // Update profile
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { profileError in
                        if let profileError = profileError {
                            print("Error updating profile: \(profileError)")
                        }
                    }
                    
                    // Create Firestore user document
                    let userData: [String: Any] = [
                        "displayName": displayName,
                        "email": email,
                        "capsuleIds": [],
                        "createdAt": Timestamp(date: Date())
                    ]
                    
                    FirebaseManager.shared.db.collection("users").document(user.uid).setData(userData) { firestoreError in
                        if let firestoreError = firestoreError {
                            print("Error creating user document: \(firestoreError)")
                        }
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
            }
        } catch {
            showErrorMessage("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
