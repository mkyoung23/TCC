import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.indigo.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated background circles
                ForEach(0..<5) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 50...100))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                            value: UUID()
                        )
                }
                
                VStack(spacing: 32) {
                    // App title and icon
                    VStack(spacing: 16) {
                        // App icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "video.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        Text("Time Capsule")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Capture memories with friends")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Auth form
                    VStack(spacing: 20) {
                        // Form container
                        VStack(spacing: 16) {
                            // Email field
                            CustomTextField(
                                placeholder: "Email",
                                text: $email,
                                systemImage: "envelope.fill"
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            // Password field
                            CustomSecureField(
                                placeholder: "Password",
                                text: $password,
                                systemImage: "lock.fill"
                            )
                            
                            // Display name field (only for registration)
                            if isRegistering {
                                CustomTextField(
                                    placeholder: "Display Name",
                                    text: $displayName,
                                    systemImage: "person.fill"
                                )
                            }
                        }
                        
                        // Action button
                        Button(action: {
                            if isRegistering {
                                authViewModel.signUp(email: email, password: password, displayName: displayName)
                            } else {
                                authViewModel.signIn(email: email, password: password)
                            }
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isRegistering ? "Create Account" : "Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Toggle registration mode
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRegistering.toggle()
                                // Clear fields when switching
                                if !isRegistering {
                                    displayName = ""
                                }
                            }
                        }) {
                            Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 40)
            }
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.showError = false
            }
        } message: {
            Text(authViewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

// Custom text field component
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.7))
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// Custom secure field component
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
