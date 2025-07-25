import SwiftUI
import FirebaseFirestore

struct InviteMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule
    @State private var emailInput = ""
    @State private var errorMessage: String?
    @State private var isInviting = false

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
                            
                            Text("Invite Friends")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                            
                            Spacer()
                            
                            Button("Send") { 
                                inviteMembers() 
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(emailInput.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : VintageTheme.vintage)
                            .disabled(emailInput.trimmingCharacters(in: .whitespaces).isEmpty || isInviting)
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
                            Spacer(minLength: 30)
                            
                            // Vintage invitation icon
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 80, height: 60)
                                        .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                                    
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(VintageTheme.sepia)
                                }
                                
                                Text("Invite Friends to \"\(capsule.name)\"")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                                    .multilineTextAlignment(.center)
                                
                                Text("Share this memory capsule with friends and family so they can add their own videos")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Email input section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Enter Email Addresses")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                                
                                Text("Separate multiple emails with commas")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                
                                TextField("friend@example.com, family@example.com", text: $emailInput)
                                    .textFieldStyle(VintageTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                            
                            // Error message
                            if let msg = errorMessage {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text("Invitation Error")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text(msg)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            // Loading indicator
                            if isInviting {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: VintageTheme.vintage))
                                        .scaleEffect(1.2)
                                    
                                    Text("Sending Invitations...")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                }
                                .padding(.vertical, 20)
                            }
                            
                            // Info section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(VintageTheme.vintage)
                                    Text("How Invitations Work")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                }
                                
                                Text("• Friends must have a Vintage Capsule account")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                
                                Text("• They'll get access to add videos to this capsule")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                                
                                Text("• Everyone can watch together when it unseals")
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
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func inviteMembers() {
        isInviting = true
        errorMessage = nil
        
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
            isInviting = false
            if notFound.isEmpty {
                dismiss()
            } else {
                errorMessage = "No account found for: " + notFound.joined(separator: ", ")
            }
        }
    }
}
