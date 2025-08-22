import SwiftUI
import FirebaseFirestore

struct NewCapsuleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sealDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var selectedPreset: DatePreset? = nil
    @State private var isCustomDate: Bool = false

    var onCreate: ((Capsule) -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Create New Capsule")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Set a future date to unlock your memories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Form content
                    VStack(spacing: 24) {
                        // Capsule Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Capsule Name")
                                .font(.headline)
                            TextField("Enter a memorable name", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                            
                            // Suggestions
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(nameSuggestions, id: \.self) { suggestion in
                                        Button(suggestion) {
                                            name = suggestion
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }

                        // Unseal Date
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When should this capsule unseal?")
                                .font(.headline)
                            
                            // Quick presets
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(datePresets, id: \.id) { preset in
                                    Button(action: {
                                        selectedPreset = preset
                                        sealDate = preset.date
                                        isCustomDate = false
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: preset.icon)
                                                .font(.title2)
                                            Text(preset.title)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            Text(preset.subtitle)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(selectedPreset?.id == preset.id ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                        .foregroundColor(selectedPreset?.id == preset.id ? .blue : .primary)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedPreset?.id == preset.id ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            
                            // Custom date option
                            Button(action: {
                                isCustomDate = true
                                selectedPreset = nil
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Choose Custom Date")
                                    Spacer()
                                    if isCustomDate {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(isCustomDate ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .foregroundColor(isCustomDate ? .blue : .primary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isCustomDate ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                            
                            // Custom date picker
                            if isCustomDate {
                                DatePicker("Select Date", selection: $sealDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Preview section
                        if !name.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preview")
                                    .font(.headline)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 12, height: 12)
                                        
                                        Text(name)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.orange)
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Image(systemName: "person.2.fill")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                                Text("1 member")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            HStack {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                                Text("Unseals \(sealDate.formatted(date: .abbreviated, time: .shortened))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Days countdown
                                        VStack(spacing: 2) {
                                            let timeRemaining = sealDate.timeIntervalSince(Date())
                                            let days = Int(timeRemaining) / 86400
                                            
                                            if days > 0 {
                                                Text("\(days)")
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.orange)
                                                Text(days == 1 ? "day" : "days")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
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
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { 
                        createCapsule()
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                    .disabled(name.isEmpty || sealDate <= Date())
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func createCapsule() {
        guard let user = authViewModel.user else { return }
        var ref: DocumentReference? = nil
        let data: [String: Any] = [
            "name": name,
            "creatorId": user.uid,
            "memberIds": [user.uid],
            "sealDate": Timestamp(date: sealDate),
            "isUnsealed": false
        ]
        ref = FirebaseManager.shared.db.collection("capsules").addDocument(data: data) { error in
            if error == nil, let ref = ref {
                // update user's capsule list
                FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                    "capsuleIds": FieldValue.arrayUnion([ref.documentID])
                ])
                let capsule = Capsule(id: ref.documentID, data: data)
                onCreate?(capsule)
                dismiss()
            }
        }
    }
    
    private var nameSuggestions: [String] {
        ["Family Memories", "Vacation 2025", "Baby's First Year", "Wedding Moments", "Birthday Surprise", "Holiday Fun"]
    }
    
    private var datePresets: [DatePreset] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            DatePreset(
                id: "1month",
                title: "1 Month",
                subtitle: "30 days",
                icon: "calendar.badge.clock",
                date: calendar.date(byAdding: .month, value: 1, to: now) ?? now
            ),
            DatePreset(
                id: "3months",
                title: "3 Months",
                subtitle: "90 days",
                icon: "calendar",
                date: calendar.date(byAdding: .month, value: 3, to: now) ?? now
            ),
            DatePreset(
                id: "6months",
                title: "6 Months",
                subtitle: "Half year",
                icon: "calendar.badge.clock",
                date: calendar.date(byAdding: .month, value: 6, to: now) ?? now
            ),
            DatePreset(
                id: "1year",
                title: "1 Year",
                subtitle: "365 days",
                icon: "calendar.circle",
                date: calendar.date(byAdding: .year, value: 1, to: now) ?? now
            ),
            DatePreset(
                id: "2years",
                title: "2 Years",
                subtitle: "Long term",
                icon: "calendar.circle.fill",
                date: calendar.date(byAdding: .year, value: 2, to: now) ?? now
            ),
            DatePreset(
                id: "5years",
                title: "5 Years",
                subtitle: "Epic wait",
                icon: "star.circle",
                date: calendar.date(byAdding: .year, value: 5, to: now) ?? now
            )
        ]
    }
}

struct DatePreset: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let date: Date
}
