import SwiftUI

struct CountdownView: View {
    var sealDate: Date
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 4) {
            if timeRemaining > 0 {
                HStack(spacing: 8) {
                    TimeUnit(value: days, label: "Days")
                    Text(":")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    TimeUnit(value: hours, label: "Hours")
                    Text(":")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    TimeUnit(value: minutes, label: "Min")
                    Text(":")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    TimeUnit(value: seconds, label: "Sec")
                }
                .font(.system(.body, design: .monospaced))
            } else {
                HStack {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(.green)
                    Text("UNSEALED!")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .font(.headline)
            }
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            stopTimer()
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
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, sealDate.timeIntervalSince(Date()))
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value, specifier: "%02d")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(minWidth: 32)
    }
}
