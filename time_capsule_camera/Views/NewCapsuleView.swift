import SwiftUI
import FirebaseFirestore

struct NewCapsuleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sealDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var isCreating: Bool = false

    var onCreate: ((Capsule) -> Void)? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "cube.box.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Create Time Capsule")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Set up a new capsule to collect memories with friends")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Capsule name section
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Capsule Name", systemImage: "tag.fill")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Enter a memorable name", text: $name)
                                        .textFieldStyle(CustomTextFieldStyle())
                                    
                                    Text("Choose a name that represents your group or event")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Seal date section
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Unseal Date", systemImage: "calendar")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    DatePicker(
                                        "Select when to unseal",
                                        selection: $sealDate,
                                        in: Date.now...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    Text("Capsule will automatically unseal on this date")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Preview card
                            if !name.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Preview")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    CapsulePreviewCard(name: name, sealDate: sealDate, memberCount: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { 
                        dismiss() 
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createCapsule) {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(name.isEmpty || sealDate <= Date() || isCreating)
                    .foregroundColor(name.isEmpty || sealDate <= Date() ? .gray : .blue)
                }
            }
        }
    }

    private func createCapsule() {
        guard let user = authViewModel.user else { return }
        
        isCreating = true
        
        let data: [String: Any] = [
            "name": name,
            "creatorId": user.uid,
            "memberIds": [user.uid],
            "sealDate": Timestamp(date: sealDate),
            "isUnsealed": false,
            "createdAt": Timestamp(date: Date())
        ]
        
        FirebaseManager.shared.db.collection("capsules").addDocument(data: data) { error in
            DispatchQueue.main.async {
                self.isCreating = false
                
                if let error = error {
                    print("Error creating capsule: \(error)")
                    return
                }
                
                // Update user's capsule list
                FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                    "capsuleIds": FieldValue.arrayUnion([UUID().uuidString])
                ])
                
                let capsule = Capsule(id: UUID().uuidString, data: data)
                onCreate?(capsule)
                dismiss()
            }
        }
    }
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Capsule preview card
struct CapsulePreviewCard: View {
    let name: String
    let sealDate: Date
    let memberCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(memberCount) member\(memberCount == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("SEALED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Unseals on")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(sealDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
