import SwiftUI

struct AuthenticationView: View {
    @StateObject private var firebase = FirebaseManager.shared
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showOnboarding = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {
                    // App Logo and Title
                    VStack(spacing: 10) {
                        Image(systemName: "video.bubble.left.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                            .symbolEffect(.pulse)

                        Text("Time Capsule Camera")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Preserve moments together")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)

                    // Form
                    VStack(spacing: 15) {
                        if isSignUp {
                            TextField("Your Name", text: $name)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(.name)
                                .autocapitalization(.words)
                        }

                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.password)
                    }
                    .padding(.horizontal, 30)

                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: handleAuthentication) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading)

                        Button(action: { isSignUp.toggle() }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "New user? Create Account")
                                .font(.callout)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // How it works button
                    Button(action: { showOnboarding = true }) {
                        Label("How it works", systemImage: "questionmark.circle")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
        }
    }

    private func handleAuthentication() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                if isSignUp {
                    guard !name.isEmpty else {
                        errorMessage = "Please enter your name"
                        isLoading = false
                        return
                    }
                    try await firebase.signUp(email: email, password: password, name: name)
                } else {
                    try await firebase.signIn(email: email, password: password)
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0

    let pages = [
        OnboardingPage(
            icon: "video.circle.fill",
            title: "Your Digital Home Videos",
            description: "Remember watching old family videos? The way everyone looked, sounded, laughed? This app captures those moments - but for the future. Record now, watch together later."
        ),
        OnboardingPage(
            icon: "person.3.fill",
            title: "Capture Life Together",
            description: "Create a capsule for any event - birthdays, trips, random Tuesdays. Share a 6-digit code. Everyone records their perspective. It's like having multiple cameras at once."
        ),
        OnboardingPage(
            icon: "lock.fill",
            title: "The Magic of Waiting",
            description: "Set it to unlock in a week, month, or year. You can't peek early. When it opens, you'll see how everyone's hair was different, hear forgotten inside jokes, remember what mattered then."
        ),
        OnboardingPage(
            icon: "play.rectangle.fill",
            title: "Watch Your Time Machine",
            description: "Videos play in order by when they were recorded. See your friend arrive at the party, your kid's first words, that sunset from everyone's angle. Real moments, real voices, real memories."
        )
    ]

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 80))
                                .foregroundColor(.blue)

                            Text(pages[index].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)

                            Spacer()
                        }
                        .padding(.top, 60)
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationBarItems(trailing: Button("Skip") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}