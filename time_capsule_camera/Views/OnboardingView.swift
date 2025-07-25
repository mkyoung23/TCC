import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            image: "video.circle.fill",
            title: "Create Time Capsules",
            description: "Set a future date and start adding videos with friends and family. Your memories will be sealed until the chosen time."
        ),
        OnboardingPage(
            image: "person.2.fill",
            title: "Collaborate with Loved Ones",
            description: "Invite friends and family to add their own videos to your capsules. Everyone contributes to the shared memory."
        ),
        OnboardingPage(
            image: "camera.fill",
            title: "Record & Upload",
            description: "Record videos directly in the app or choose from your photo library. Add as many clips as you want!"
        ),
        OnboardingPage(
            image: "lock.open.fill",
            title: "Watch Together",
            description: "When the seal date arrives, all videos are revealed! Watch your collected memories in chronological order."
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack(spacing: 16) {
                if currentPage == pages.count - 1 {
                    Button("Get Started") {
                        withAnimation {
                            showOnboarding = false
                        }
                        // Store that user has seen onboarding
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    HStack {
                        Button("Skip") {
                            withAnimation {
                                showOnboarding = false
                            }
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}