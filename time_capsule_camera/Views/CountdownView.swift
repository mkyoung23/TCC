import SwiftUI

struct CountdownView: View {
    var sealDate: Date
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progressValue)
                
                VStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text("SEALED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            // Time display
            if timeRemaining > 0 {
                VStack(spacing: 8) {
                    Text("Unseals in")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        TimeUnitView(value: days, unit: "DAYS")
                        TimeUnitView(value: hours, unit: "HRS")
                        TimeUnitView(value: minutes, unit: "MIN")
                        TimeUnitView(value: seconds, unit: "SEC")
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("🎉 Unsealed! 🎉")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Your memories are ready to view!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var days: Int {
        Int(timeRemaining) / 86400
    }
    
    private var hours: Int {
        (Int(timeRemaining) % 86400) / 3600
    }
    
    private var minutes: Int {
        (Int(timeRemaining) % 3600) / 60
    }
    
    private var seconds: Int {
        Int(timeRemaining) % 60
    }
    
    private var progressValue: Double {
        let totalDuration: TimeInterval = 365 * 24 * 60 * 60 // 1 year in seconds (adjust as needed)
        return max(0, min(1, 1 - (timeRemaining / totalDuration)))
    }
    
    private func startTimer() {
        updateTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, sealDate.timeIntervalSince(Date()))
    }
}

struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(minWidth: 40)
            
            Text(unit)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
