import SwiftUI

struct CountdownView: View {
    var sealDate: Date

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let remaining = sealDate.timeIntervalSince(context.date)
            if remaining > 0 {
                Text(timeString(from: remaining))
                    .font(.headline)
            } else {
                Text("Unsealed")
                    .font(.headline)
            }
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, secs)
    }
}
