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
            ZStack {
                // Vintage background
                VintageTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Vintage header
                    VStack(spacing: 8) {
                        HStack {
                            Button("Cancel") { 
                                dismiss() 
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                            
                            Spacer()
                            
                            Text("New Memory Capsule")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                            
                            Spacer()
                            
                            Button("Create") { 
                                createCapsule() 
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(name.isEmpty || sealDate <= Date() ? .gray : VintageTheme.vintage)
                            .disabled(name.isEmpty || sealDate <= Date())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Rectangle()
                            .fill(VintageTheme.vintage)
                            .frame(height: 2)
                            .padding(.horizontal, 20)
                    }
                    .background(Color.white.opacity(0.9))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Vintage camera icon
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 80, height: 60)
                                        .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                                    
                                    Circle()
                                        .stroke(VintageTheme.lensRing, lineWidth: 3)
                                        .frame(width: 35, height: 35)
                                    
                                    Circle()
                                        .fill(VintageTheme.vintage)
                                        .frame(width: 25, height: 25)
                                }
                                
                                Text("Create a Memory Capsule")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 30)
                            
                            // Form sections
                            VStack(spacing: 20) {
                                // Capsule name section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Capsule Name")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                    
                                    TextField("Enter a memorable name...", text: $name)
                                        .textFieldStyle(VintageTextFieldStyle())
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                
                                // Unseal date section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Unseal Date")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                    
                                    Text("Choose when this capsule will be revealed")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.darkSepia)
                                    
                                    DatePicker(
                                        "Select Date", 
                                        selection: $sealDate, 
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(VintageTheme.vintage)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                
                                // Info section
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(VintageTheme.vintage)
                                        Text("About Memory Capsules")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(VintageTheme.vintage)
                                    }
                                    
                                    Text("• Add videos and memories before the seal date")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.darkSepia)
                                    
                                    Text("• Invite friends and family to contribute")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.darkSepia)
                                    
                                    Text("• Watch all memories together when it unseals")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.darkSepia)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(VintageTheme.sepia.opacity(0.6))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
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
