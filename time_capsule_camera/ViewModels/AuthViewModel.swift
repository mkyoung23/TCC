import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool
    @Published var user: User?

    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
        guard let self = self else { return }
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.user = user
                }
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: nil)
                // Create Firestore document
                let data: [String: Any] = ["displayName": displayName,
                                           "email": email,
                                           "capsuleIds": []]
                FirebaseManager.shared.db.collection("users").document(user.uid).setData(data)
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.user = user
                }
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.user = nil
        }
    }
}
