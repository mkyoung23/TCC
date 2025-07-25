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

struct CapsuleRowView: View {
    let capsule: Capsule
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Status indicator
                Circle()
                    .fill(capsule.isUnsealed ? Color.green : Color.orange)
                    .frame(width: 12, height: 12)
                
                Text(capsule.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if capsule.isUnsealed {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("\(capsule.memberIds.count) member\(capsule.memberIds.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: capsule.isUnsealed ? "checkmark.circle" : "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(capsule.isUnsealed ? "Unsealed" : "Unseals \(capsule.sealDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Visual indicator
                if !capsule.isUnsealed {
                    VStack(spacing: 2) {
                        let timeRemaining = capsule.sealDate.timeIntervalSince(Date())
                        let days = Int(timeRemaining) / 86400
                        
                        if days > 0 {
                            Text("\(days)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text(days == 1 ? "day" : "days")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Soon")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(capsule.isUnsealed ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
