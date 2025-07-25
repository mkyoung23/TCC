import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text(isRegistering ? "Sign Up" : "Sign In")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            if isRegistering {
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if authViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(isRegistering ? "Create Account" : "Sign In") {
                    if isRegistering {
                        authViewModel.signUp(email: email, password: password, displayName: displayName)
                    } else {
                        authViewModel.signIn(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || (isRegistering && displayName.isEmpty))
            }
            
            Button(isRegistering ? "Have an account? Sign In" : "No account? Sign Up") {
                isRegistering.toggle()
                authViewModel.errorMessage = nil
            }
            .font(.footnote)
        }
        .padding()
    }
}
