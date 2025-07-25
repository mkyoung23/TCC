import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var isRegistering: Bool = false

    var body: some View {
        ZStack {
            // Vintage background
            VintageTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Film strip borders
            FilmStripBorder()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Vintage camera icon/title
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
                    
                    Text("Vintage Capsule")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(VintageTheme.vintage)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    
                    Text("Home Video Camera")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(VintageTheme.darkSepia)
                }
                
                Spacer()
                
                // Authentication form with vintage styling
                VStack(spacing: 20) {
                    Text(isRegistering ? "Join the Memory Vault" : "Welcome Back")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(VintageTheme.vintage)

                    TextField("Email", text: $email)
                        .textFieldStyle(VintageTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(VintageTextFieldStyle())
                    
                    if isRegistering {
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(VintageTextFieldStyle())
                    }
                    
                    Button(isRegistering ? "Create Memory Vault" : "Open Vault") {
                        if isRegistering {
                            authViewModel.signUp(email: email, password: password, displayName: displayName)
                        } else {
                            authViewModel.signIn(email: email, password: password)
                        }
                    }
                    .buttonStyle(VintageButtonStyle())
                    
                    Button(isRegistering ? "Already have a vault? Sign In" : "New to memories? Create Vault") {
                        isRegistering.toggle()
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(VintageTheme.vintage)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}
