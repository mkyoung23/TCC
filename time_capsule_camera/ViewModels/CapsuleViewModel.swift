import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class CapsuleViewModel: ObservableObject {
    @Published var capsules: [Capsule] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCapsules(for user: User) {
        isLoading = true
        errorMessage = nil
        
        listener = FirebaseManager.shared.db.collection("capsules")
            .whereField("memberIds", arrayContains: user.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Failed to load capsules: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    var updatedCapsules = documents.map { Capsule(id: $0.documentID, data: $0.data()) }
                    
                    // Check for capsules that should be unsealed
                    for (index, capsule) in updatedCapsules.enumerated() {
                        if !capsule.isUnsealed && capsule.sealDate <= Date() {
                            updatedCapsules[index].isUnsealed = true
                            // Update in Firestore
                            FirebaseManager.shared.db.collection("capsules").document(capsule.id).updateData([
                                "isUnsealed": true
                            ])
                        }
                    }
                    
                    self.capsules = updatedCapsules
                }
            }
    }
    
    func addCapsule(_ capsule: Capsule) {
        capsules.append(capsule)
        
        // Schedule notifications for this capsule
        NotificationManager.shared.scheduleUnsealNotification(for: capsule)
        
        // Schedule reminder notifications (7 days and 1 day before)
        NotificationManager.shared.scheduleReminderNotification(for: capsule, daysBeforeUnseal: 7)
        NotificationManager.shared.scheduleReminderNotification(for: capsule, daysBeforeUnseal: 1)
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}