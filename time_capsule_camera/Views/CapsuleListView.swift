import SwiftUI
import FirebaseFirestore

struct CapsuleListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var capsules: [Capsule] = []
    @State private var showNewCapsule = false
    @State private var showProfile = false

    var body: some View {
        NavigationView {
            ZStack {
                // Vintage background
                VintageTheme.backgroundGradient
                    .ignoresSafeArea()
                
                // Film strip borders
                FilmStripBorder()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Vintage header
                    VStack(spacing: 8) {
                        HStack {
                            // Profile button
                            Button(action: { showProfile = true }) {
                                ZStack {
                                    Circle()
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 35, height: 35)
                                    
                                    Text((authViewModel.user?.displayName?.prefix(1) ?? "U").uppercased())
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(VintageTheme.sepia)
                                }
                            }
                            
                            Spacer()
                            
                            // Vintage camera icon and title
                            HStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(VintageTheme.cameraGradient)
                                        .frame(width: 40, height: 30)
                                    
                                    Circle()
                                        .stroke(VintageTheme.lensRing, lineWidth: 2)
                                        .frame(width: 18, height: 18)
                                }
                                
                                Text("Memory Capsules")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(VintageTheme.vintage)
                            }
                            
                            Spacer()
                            
                            Button("Sign Out") {
                                authViewModel.signOut()
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(VintageTheme.vintage)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Rectangle()
                            .fill(VintageTheme.vintage)
                            .frame(height: 2)
                            .padding(.horizontal, 20)
                    }
                    .background(Color.white.opacity(0.9))
                    
                    // Capsules list
                    if capsules.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Text("No Memory Capsules Yet")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(VintageTheme.vintage)
                            
                            Text("Create your first vintage memory capsule to start capturing moments!")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(VintageTheme.darkSepia)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button("Create Memory Capsule") {
                                showNewCapsule.toggle()
                            }
                            .buttonStyle(VintageButtonStyle())
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(capsules) { capsule in
                                    NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                                        CapsuleCard(capsule: capsule)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Floating action button for new capsule
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showNewCapsule.toggle() }) {
                            ZStack {
                                Circle()
                                    .fill(VintageTheme.vintage)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            )
            .sheet(isPresented: $showNewCapsule) {
                NewCapsuleView { capsule in
                    capsules.append(capsule)
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .onAppear(perform: fetchCapsules)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func fetchCapsules() {
        guard let user = authViewModel.user else { return }
        FirebaseManager.shared.db.collection("capsules")
            .whereField("memberIds", arrayContains: user.uid)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.capsules = documents.map { Capsule(id: $0.documentID, data: $0.data()) }
            }
    }
}

struct CapsuleCard: View {
    let capsule: Capsule
    
    var body: some View {
        VStack(spacing: 0) {
            // Film strip holes at top
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    Circle()
                        .fill(VintageTheme.filmBorder)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 6)
            .background(VintageTheme.sepia)
            
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(capsule.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(VintageTheme.vintage)
                    
                    Spacer()
                    
                    if capsule.isUnsealed {
                        Text("UNSEALED")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                            )
                    } else {
                        Text("SEALED")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.red)
                            )
                    }
                }
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(VintageTheme.darkSepia)
                    Text("\(capsule.memberIds.count) members")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(VintageTheme.darkSepia)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(VintageTheme.darkSepia)
                    Text("Unseals \(capsule.sealDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(VintageTheme.darkSepia)
                }
            }
            .padding(16)
            .background(Color.white)
            
            // Film strip holes at bottom
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    Circle()
                        .fill(VintageTheme.filmBorder)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 6)
            .background(VintageTheme.sepia)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(VintageTheme.vintage, lineWidth: 2)
        )
    }
}
