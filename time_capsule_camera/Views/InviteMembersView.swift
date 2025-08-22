import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct InviteMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let capsule: Capsule
    @State private var emailInput = ""
    @State private var errorMessage: String?
    @State private var isInviting = false
    @State private var successMessage: String?
    @State private var showShareSheet = false

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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Invite via App")
                        .font(.headline)
                    
                    TextField("Enter emails separated by commas", text: $emailInput, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .lineLimit(3...6)
                    
                    Text("Friends must have the app installed to join")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Share Invitation Link")
                            .font(.headline)
                        
                        Button(action: shareInviteLink) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share via Messages, Email, etc.")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                        }
                        
                        Text("Share this capsule with anyone, even without the app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
        .sheet(isPresented: $showShareSheet) {
            if let user = Auth.auth().currentUser {
                ShareSheet(activityItems: [SharingService.shared.generateShareMessage(for: capsule, from: user)])
            }
        }
    }
    
    private func shareInviteLink() {
        showShareSheet = true
    }

    private func inviteMembers() {
        isInviting = true
        errorMessage = nil
        successMessage = nil
        
        let emails = emailInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        SharingService.shared.inviteMembers(emails: Array(emails), to: capsule) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isInviting = false
                
                switch result {
                case .success(let inviteResult):
                    var messages: [String] = []
                    
                    if !inviteResult.invited.isEmpty {
                        messages.append("✅ Invited \(inviteResult.invited.count) friend\(inviteResult.invited.count == 1 ? "" : "s")")
                    }
                    
                    if !inviteResult.alreadyMembers.isEmpty {
                        messages.append("ℹ️ \(inviteResult.alreadyMembers.count) already member\(inviteResult.alreadyMembers.count == 1 ? "" : "s")")
                    }
                    
                    if !inviteResult.notFound.isEmpty {
                        messages.append("⚠️ \(inviteResult.notFound.count) email\(inviteResult.notFound.count == 1 ? "" : "s") not found")
                    }
                    
                    if !inviteResult.invited.isEmpty {
                        self.successMessage = messages.joined(separator: "\n")
                        // Auto-dismiss after showing success
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.dismiss()
                        }
                    } else if !inviteResult.notFound.isEmpty {
                        self.errorMessage = "No accounts found for: " + inviteResult.notFound.joined(separator: ", ")
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
