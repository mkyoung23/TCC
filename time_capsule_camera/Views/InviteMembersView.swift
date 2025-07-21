import SwiftUI
import FirebaseFirestore

struct InviteMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule
    @State private var emailInput = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Invite by email")) {
                    TextField("Emails separated by commas", text: $emailInput)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                if let msg = errorMessage {
                    Section {
                        Text(msg).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Invite Members")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Invite") { inviteMembers() }
                        .disabled(emailInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func inviteMembers() {
        let emails = emailInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        var notFound: [String] = []
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
                } else {
                    notFound.append(String(email))
                }
            }
        }

        group.notify(queue: .main) {
            if notFound.isEmpty {
                dismiss()
            } else {
                errorMessage = "No account found for: " + notFound.joined(separator: ", ")
            }
        }
    }
}
