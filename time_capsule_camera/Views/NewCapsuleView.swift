import SwiftUI
import FirebaseFirestore

struct NewCapsuleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sealDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()

    var onCreate: ((Capsule) -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Capsule Name")) {
                    TextField("Enter a name", text: $name)
                }

                Section(header: Text("Unseal Date")) {
                    DatePicker("Select Date", selection: $sealDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Capsule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createCapsule() }
                        .disabled(name.isEmpty || sealDate <= Date())
                }
            }
        }
    }

    private func createCapsule() {
        guard let user = authViewModel.user else { return }
        var ref: DocumentReference? = nil
        let data: [String: Any] = [
            "name": name,
            "creatorId": user.uid,
            "memberIds": [user.uid],
            "sealDate": Timestamp(date: sealDate),
            "isUnsealed": false
        ]
        ref = FirebaseManager.shared.db.collection("capsules").addDocument(data: data) { error in
            if error == nil, let ref = ref {
                // update user's capsule list
                FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                    "capsuleIds": FieldValue.arrayUnion([ref.documentID])
                ])
                let capsule = Capsule(id: ref.documentID, data: data)
                onCreate?(capsule)
                dismiss()
            }
        }
    }
}
