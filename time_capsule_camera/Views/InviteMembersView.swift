import SwiftUI
import FirebaseFirestore

struct InviteMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule
    @State private var emailInput = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isInviting = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.1),
                        Color.blue.opacity(0.1)
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
                                        gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.badge.plus.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                            
                            Text("Invite Friends")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Add friends to \"\(capsule.name)\" to share memories together")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Form section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Friend's Email Address", systemImage: "envelope.fill")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Enter email addresses separated by commas", text: $emailInput, axis: .vertical)
                                        .textFieldStyle(InviteTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.emailAddress)
                                    
                                    Text("Separate multiple emails with commas")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 8) {
                                Label("How it works", systemImage: "info.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("1.")
                                            .fontWeight(.semibold)
                                        Text("Friends must have an account with the same email")
                                    }
                                    .font(.subheadline)
                                    
                                    HStack(alignment: .top) {
                                        Text("2.")
                                            .fontWeight(.semibold)
                                        Text("They'll be added to the capsule automatically")
                                    }
                                    .font(.subheadline)
                                    
                                    HStack(alignment: .top) {
                                        Text("3.")
                                            .fontWeight(.semibold)
                                        Text("They can start adding videos right away")
                                    }
                                    .font(.subheadline)
                                }
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Status messages
                        if let errorMessage = errorMessage {
                            MessageCard(
                                message: errorMessage,
                                type: .error,
                                icon: "xmark.circle.fill"
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        if let successMessage = successMessage {
                            MessageCard(
                                message: successMessage,
                                type: .success,
                                icon: "checkmark.circle.fill"
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Invite Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { 
                        dismiss() 
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: inviteMembers) {
                        if isInviting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .scaleEffect(0.8)
                        } else {
                            Text("Invite")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(emailInput.trimmingCharacters(in: .whitespaces).isEmpty || isInviting)
                    .foregroundColor(emailInput.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .green)
                }
            }
        }
    }

    private func inviteMembers() {
        let emails = emailInput.split(separator: ",").map { 
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() 
        }
        
        guard !emails.isEmpty else { return }
        
        isInviting = true
        errorMessage = nil
        successMessage = nil
        
        var notFound: [String] = []
        var invited: [String] = []
        let group = DispatchGroup()

        for email in emails {
            group.enter()
            FirebaseManager.shared.db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments { snapshot, _ in
                    defer { group.leave() }
                    
                    if let doc = snapshot?.documents.first {
                        let uid = doc.documentID
                        
                        // Check if user is already a member
                        if capsule.memberIds.contains(uid) {
                            return // Skip if already a member
                        }
                        
                        // Add to capsule
                        FirebaseManager.shared.db.collection("capsules")
                            .document(capsule.id)
                            .updateData([
                                "memberIds": FieldValue.arrayUnion([uid])
                            ])
                        
                        // Add capsule to user's list
                        FirebaseManager.shared.db.collection("users")
                            .document(uid)
                            .updateData([
                                "capsuleIds": FieldValue.arrayUnion([capsule.id])
                            ])
                        
                        invited.append(String(email))
                    } else {
                        notFound.append(String(email))
                    }
                }
        }

        group.notify(queue: .main) {
            self.isInviting = false
            
            if !invited.isEmpty && notFound.isEmpty {
                // All invited successfully
                self.successMessage = "✅ Successfully invited \(invited.count) friend\(invited.count == 1 ? "" : "s")!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            } else if !invited.isEmpty && !notFound.isEmpty {
                // Some successful, some failed
                self.successMessage = "✅ Invited \(invited.count) friend\(invited.count == 1 ? "" : "s")"
                self.errorMessage = "❌ No account found for: \(notFound.joined(separator: ", "))"
            } else if invited.isEmpty && !notFound.isEmpty {
                // All failed
                self.errorMessage = "❌ No accounts found for: \(notFound.joined(separator: ", "))"
            }
        }
    }
}

// Custom text field style for invites
struct InviteTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Message card component
struct MessageCard: View {
    let message: String
    let type: MessageType
    let icon: String
    
    enum MessageType {
        case success, error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .success: return .green.opacity(0.1)
            case .error: return .red.opacity(0.1)
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(type.color)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(type.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}
