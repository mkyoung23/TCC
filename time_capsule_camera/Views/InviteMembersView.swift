import SwiftUI
import FirebaseFirestore

struct InviteMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule
    @State private var emailInput = ""
    @State private var errorMessage: String?
    @State private var isInviting = false
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Invite Friends")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Add friends and family to capture memories together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Addresses")
                        .font(.headline)
                    
                    TextField("Enter emails separated by commas", text: $emailInput, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .lineLimit(3...6)
                    
                    Text("Friends must have the app installed to join")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Status messages
                if let successMessage = successMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(successMessage)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if let errorMessage = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if isInviting {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Sending invites...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Invite Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Invite") { 
                        inviteMembers()
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                    .disabled(emailInput.trimmingCharacters(in: .whitespaces).isEmpty || isInviting)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func inviteMembers() {
        isInviting = true
        errorMessage = nil
        successMessage = nil
        
        let emails = emailInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        var notFound: [String] = []
        var invited: [String] = []
        let group = DispatchGroup()

        for email in emails {
            group.enter()
            FirebaseManager.shared.db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, _ in
                defer { group.leave() }
                if let doc = snapshot?.documents.first {
                    let uid = doc.documentID
                    FirebaseManager.shared.db.collection("capsules").document(capsule.id).updateData([
                        "memberIds": FieldValue.arrayUnion([uid])
                    ])
                    FirebaseManager.shared.db.collection("users").document(uid).updateData([
                        "capsuleIds": FieldValue.arrayUnion([capsule.id])
                    ])
                    invited.append(String(email))
                } else {
                    notFound.append(String(email))
                }
            }
        }

        group.notify(queue: .main) {
            isInviting = false
            
            if !invited.isEmpty {
                successMessage = "Invited \(invited.count) friend\(invited.count == 1 ? "" : "s") successfully!"
                
                // Auto-dismiss after showing success
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
            
            if !notFound.isEmpty {
                errorMessage = "No accounts found for: " + notFound.joined(separator: ", ")
            }
        }
    }
}
