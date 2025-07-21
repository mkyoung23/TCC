import SwiftUI
import FirebaseFirestore

struct CapsuleListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var capsules: [Capsule] = []
    @State private var showNewCapsule = false

    var body: some View {
        NavigationView {
            List(capsules) { capsule in
                NavigationLink(destination: CapsuleDetailView(capsule: capsule)) {
                    VStack(alignment: .leading) {
                        Text(capsule.name)
                            .font(.headline)
                        Text("\(capsule.memberIds.count) members")
                            .font(.subheadline)
                        Text("Unseals on \(capsule.sealDate.formatted(date: .long, time: .shortened))")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("My Capsules")
            .navigationBarItems(leading: Button("Sign Out") {
                authViewModel.signOut()
            }, trailing: Button(action: { showNewCapsule.toggle() }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showNewCapsule) {
                NewCapsuleView { capsule in
                    capsules.append(capsule)
                }
            }
            .onAppear(perform: fetchCapsules)
        }
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
