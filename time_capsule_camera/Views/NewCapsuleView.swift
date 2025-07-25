import SwiftUI
import FirebaseFirestore

struct NewCapsuleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sealDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()

    var onCreate: ((Capsule) -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Create New Capsule")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Set a future date to unlock your memories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Form content
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Capsule Name")
                                .font(.headline)
                            TextField("Enter a memorable name", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unseal Date")
                                .font(.headline)
                            
                            DatePicker("Select Date", selection: $sealDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Preview section
                        if !name.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preview")
                                    .font(.headline)
                                
                                HStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 12, height: 12)
                                    
                                    Text(name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { 
                        createCapsule()
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                    .disabled(name.isEmpty || sealDate <= Date())
                    .fontWeight(.semibold)
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
