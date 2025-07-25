import SwiftUI
import FirebaseFirestore

struct CapsuleListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var capsules: [Capsule] = []
    @State private var showNewCapsule = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back,")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(authViewModel.user?.displayName ?? "User")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            // Profile and sign out
                            Menu {
                                Button("Sign Out", role: .destructive) {
                                    authViewModel.signOut()
                                }
                            } label: {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(authViewModel.user?.displayName?.prefix(1) ?? "U"))
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        
                        // Stats row
                        HStack(spacing: 20) {
                            StatCard(
                                title: "Total Capsules",
                                value: "\(capsules.count)",
                                icon: "cube.box.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Active",
                                value: "\(capsules.filter { !$0.isUnsealed }.count)",
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Unsealed",
                                value: "\(capsules.filter { $0.isUnsealed }.count)",
                                icon: "lock.open.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Capsules list
                    if isLoading {
                        Spacer()
                        ProgressView("Loading your capsules...")
                            .scaleEffect(1.2)
                        Spacer()
                    } else if capsules.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "cube.box")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            VStack(spacing: 8) {
                                Text("No Capsules Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Create your first time capsule and start collecting memories with friends!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            Button(action: { showNewCapsule = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create First Capsule")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                            }
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(capsules) { capsule in
                                    NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                                        CapsuleCard(capsule: capsule)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for floating button
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showNewCapsule = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            )
        }
        .sheet(isPresented: $showNewCapsule) {
            NewCapsuleView { capsule in
                capsules.append(capsule)
            }
        }
        .onAppear(perform: fetchCapsules)
    }

    private func fetchCapsules() {
        guard let user = authViewModel.user else {
            isLoading = false
            return
        }
        
        FirebaseManager.shared.db.collection("capsules")
            .whereField("memberIds", arrayContains: user.uid)
            .order(by: "sealDate")
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("Error fetching capsules: \(error)")
                        return
                    }
                    
                    self.capsules = snapshot?.documents.compactMap { document in
                        Capsule(id: document.documentID, data: document.data())
                    } ?? []
                }
            }
    }
}

// Stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Capsule card component
struct CapsuleCard: View {
    let capsule: Capsule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(capsule.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(capsule.memberIds.count) members")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status indicator
                StatusBadge(isUnsealed: capsule.isUnsealed)
            }
            
            // Countdown or unsealed indicator
            if capsule.isUnsealed {
                HStack {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(.green)
                    Text("Unsealed! Tap to view")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .font(.subheadline)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unseals on")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(capsule.sealDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Mini countdown
                    CountdownView(sealDate: capsule.sealDate)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// Status badge component
struct StatusBadge: View {
    let isUnsealed: Bool
    
    var body: some View {
        Text(isUnsealed ? "Unsealed" : "Sealed")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isUnsealed ? Color.green : Color.orange)
            .cornerRadius(8)
    }
}
