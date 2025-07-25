import SwiftUI

struct CountdownView: View {
    var sealDate: Date

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let remaining = sealDate.timeIntervalSince(context.date)
            if remaining > 0 {
                VStack(spacing: 16) {
                    Text("Time Until Unsealing")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(VintageTheme.vintage)
                    
                    HStack(spacing: 12) {
                        let timeComponents = getTimeComponents(from: remaining)
                        
                        CountdownDigit(value: timeComponents.days, label: "DAYS")
                        CountdownSeparator()
                        CountdownDigit(value: timeComponents.hours, label: "HRS")
                        CountdownSeparator()
                        CountdownDigit(value: timeComponents.minutes, label: "MIN")
                        CountdownSeparator()
                        CountdownDigit(value: timeComponents.seconds, label: "SEC")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            } else {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("UNSEALED!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
    
    private func getTimeComponents(from interval: TimeInterval) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let seconds = Int(interval)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return (days, hours, minutes, secs)
    }
}

struct CountdownDigit: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(VintageTheme.vintage)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(VintageTheme.sepia)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(VintageTheme.vintage, lineWidth: 1)
                        )
                )
            
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(VintageTheme.darkSepia)
        }
    }
}

struct CountdownSeparator: View {
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(VintageTheme.vintage)
                .frame(width: 4, height: 4)
            Circle()
                .fill(VintageTheme.vintage)
                .frame(width: 4, height: 4)
        }
        .padding(.bottom, 16)
    }
}
