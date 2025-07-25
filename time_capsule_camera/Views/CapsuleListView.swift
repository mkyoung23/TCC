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
                    VStack(spacing: 16) {
                        Image(systemName: "video.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No capsules yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Create your first time capsule to get started!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Create Capsule") {
                            showNewCapsule = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(capsuleViewModel.capsules) { capsule in
                        NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(capsule.name)
                                        .font(.headline)
                                    Spacer()
                                    if capsule.isUnsealed {
                                        Image(systemName: "lock.open.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.orange)
                                    }
                                }
                                Text("\(capsule.memberIds.count) member\(capsule.memberIds.count == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text(capsule.isUnsealed ? "Unsealed" : "Unseals on")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if !capsule.isUnsealed {
                                        Text(capsule.sealDate.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
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
                    Button(action: { showNewCapsule.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewCapsule) {
                NewCapsuleView { capsule in
                    capsuleViewModel.addCapsule(capsule)
                }
            }
            .onAppear {
                if let user = authViewModel.user {
                    capsuleViewModel.fetchCapsules(for: user)
                }
            }
            .onDisappear {
                capsuleViewModel.stopListening()
            }
        }
        .alert("Error", isPresented: .constant(capsuleViewModel.errorMessage != nil)) {
            Button("OK") {
                capsuleViewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = capsuleViewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
