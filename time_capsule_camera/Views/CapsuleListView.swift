import SwiftUI
import FirebaseFirestore

struct CapsuleListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var capsuleViewModel = CapsuleViewModel()
    @State private var showNewCapsule = false

    var body: some View {
        NavigationStack {
            Group {
                if capsuleViewModel.isLoading {
                    ProgressView("Loading capsules...")
                } else if capsuleViewModel.capsules.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "video.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("No capsules yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Create your first time capsule to get started!\nInvite friends and family to capture memories together.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Create Your First Capsule") {
                            showNewCapsule = true
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                } else {
                    List(capsuleViewModel.capsules) { capsule in
                        NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                            CapsuleRowView(capsule: capsule)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Capsules")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        showNewCapsule.toggle()
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewCapsule) {
                NewCapsuleView(onCreate: { capsule in
                    capsuleViewModel.addCapsule(capsule)
                })
            }
        }
        .onAppear {
            capsuleViewModel.loadCapsules()
        }
    }
}