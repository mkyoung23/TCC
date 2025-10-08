import SwiftUI

struct TimeCapsule: Identifiable {
    let id = UUID()
    let date: Date
    let unlockDate: Date
    let title: String
    let thumbnail: String
    var isLocked: Bool {
        Date() < unlockDate
    }
}

struct CapsuleListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var capsules: [TimeCapsule] = [
        TimeCapsule(
            date: Date().addingTimeInterval(-86400 * 30),
            unlockDate: Date().addingTimeInterval(86400 * 335),
            title: "Summer Memories",
            thumbnail: "photo"
        ),
        TimeCapsule(
            date: Date().addingTimeInterval(-86400 * 60),
            unlockDate: Date().addingTimeInterval(86400 * 305),
            title: "Birthday Message",
            thumbnail: "gift"
        ),
        TimeCapsule(
            date: Date().addingTimeInterval(-86400 * 90),
            unlockDate: Date().addingTimeInterval(-86400),
            title: "New Year Goals",
            thumbnail: "star"
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header stats
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(capsules.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Total Capsules")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(capsules.filter { $0.isLocked }.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Locked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(capsules.filter { !$0.isLocked }.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Unlocked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Capsules list
                    VStack(spacing: 15) {
                        ForEach(capsules) { capsule in
                            CapsuleRow(capsule: capsule)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("My Time Capsules")
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    // Filter options
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            )
        }
    }
}

struct CapsuleRow: View {
    let capsule: TimeCapsule

    var body: some View {
        HStack {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(capsule.isLocked ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: capsule.isLocked ? "lock.fill" : capsule.thumbnail)
                    .font(.system(size: 25))
                    .foregroundColor(capsule.isLocked ? .orange : .blue)
            }

            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(capsule.title)
                    .font(.headline)

                Text("Created: \(capsule.date, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if capsule.isLocked {
                    Label("Opens: \(capsule.unlockDate, style: .date)", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Label("Ready to view", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // Action button
            Button(action: {
                if !capsule.isLocked {
                    // Play video
                }
            }) {
                Image(systemName: capsule.isLocked ? "clock.arrow.circlepath" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(capsule.isLocked ? .gray : .blue)
            }
            .disabled(capsule.isLocked)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }