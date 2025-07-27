import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // App logo and title
                VStack(spacing: 16) {
                    Image(systemName: "video.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Time Capsule Camera")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Capture memories to unlock in the future")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)

                // Auth form
                VStack(spacing: 20) {
                    Text(isRegistering ? "Create Account" : "Welcome Back")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        if isRegistering {
                            TextField("Display Name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 12) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2)
                        } else {
                            Button(isRegistering ? "Create Account" : "Sign In") {
                                // Add haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                if isRegistering {
                                    authViewModel.signUp(email: email, password: password, displayName: displayName)
                                } else {
                                    authViewModel.signIn(email: email, password: password)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(email.isEmpty || password.isEmpty || (isRegistering && displayName.isEmpty))
                        }
                        
                        Button(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRegistering.toggle()
                                authViewModel.errorMessage = nil
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}
