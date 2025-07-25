import SwiftUI

struct CelebrationView: View {
    @State private var animationAmount = 0.0
    @State private var opacity = 1.0
    @State private var scale = 0.1
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated celebration icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(animationAmount))
                }
                
                Text("Capsule Unsealed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                
                Text("Your memories are ready to watch!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationAmount = 360
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                opacity = 0.5
            }
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // This would be handled by parent view
            }
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces = Array(0..<50).map { _ in ConfettiPiece() }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces.indices, id: \.self) { index in
                    Rectangle()
                        .fill(confettiPieces[index].color)
                        .frame(width: 8, height: 8)
                        .offset(
                            x: confettiPieces[index].x,
                            y: confettiPieces[index].y
                        )
                        .rotationEffect(.degrees(confettiPieces[index].rotation))
                }
            }
            .onAppear {
                for index in confettiPieces.indices {
                    confettiPieces[index].x = Double.random(in: 0...geometry.size.width)
                    confettiPieces[index].y = -10
                    
                    withAnimation(.linear(duration: Double.random(in: 2...4))) {
                        confettiPieces[index].y = geometry.size.height + 50
                        confettiPieces[index].rotation = Double.random(in: 0...360)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece {
    var x: Double = 0
    var y: Double = 0
    var rotation: Double = 0
    var color: Color = [.red, .blue, .green, .yellow, .purple, .orange].randomElement() ?? .red
}