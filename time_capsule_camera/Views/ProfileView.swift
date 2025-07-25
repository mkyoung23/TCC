import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var isEditingName: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
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
                            Button("Done") { 
                                dismiss() 
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                            
                            Spacer()
                            
                            Text("Profile")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                            
                            Spacer()
                            
                            Button("Save") { 
                                saveProfile() 
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                            .opacity(isEditingName ? 1.0 : 0.0)
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
                            
                            // Profile avatar
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                                    
                                    Text(displayName.prefix(1).uppercased())
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(VintageTheme.sepia)
                                }
                                
                                Text("Vintage Memory Keeper")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(VintageTheme.darkSepia)
                            }
                            
                            // Profile information
                            VStack(spacing: 20) {
                                // Display name section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Display Name")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                    
                                    HStack {
                                        if isEditingName {
                                            TextField("Enter your name", text: $displayName)
                                                .textFieldStyle(VintageTextFieldStyle())
                                        } else {
                                            Text(displayName.isEmpty ? "No name set" : displayName)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(VintageTheme.vintage)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(VintageTheme.sepia.opacity(0.3))
                                                )
                                        }
                                        
                                        Button(isEditingName ? "Cancel" : "Edit") {
                                            if isEditingName {
                                                // Reset to original name
                                                displayName = authViewModel.user?.displayName ?? ""
                                            }
                                            isEditingName.toggle()
                                        }
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                
                                // Email section (read-only)
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Email Address")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(VintageTheme.vintage)
                                    
                                    Text(email)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(VintageTheme.darkSepia)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(VintageTheme.sepia.opacity(0.3))
                                        )
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                
                                // Account actions
                                VStack(spacing: 16) {
                                    Button("Sign Out") {
                                        authViewModel.signOut()
                                    }
                                    .buttonStyle(VintageButtonStyle())
                                    
                                    Button("Delete Account") {
                                        showDeleteConfirmation = true
                                    }
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red, lineWidth: 2)
                                    )
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
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
            .onAppear {
                loadUserData()
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to permanently delete your account? This action cannot be undone and all your memory capsules will be lost.")
            }
        }
    }
    
    private func loadUserData() {
        if let user = authViewModel.user {
            displayName = user.displayName ?? ""
            email = user.email ?? ""
        }
    }
    
    private func saveProfile() {
        guard let user = authViewModel.user else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.commitChanges { error in
            DispatchQueue.main.async {
                if error == nil {
                    isEditingName = false
                }
            }
        }
    }
    
    private func deleteAccount() {
        authViewModel.deleteAccount()
    }
}