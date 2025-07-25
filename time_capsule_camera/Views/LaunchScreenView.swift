import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Vintage background
            VintageTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Vintage camera icon
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(VintageTheme.cameraGradient)
                        .frame(width: 120, height: 90)
                        .shadow(color: .black.opacity(0.4), radius: 15, x: 8, y: 8)
                    
                    Circle()
                        .stroke(VintageTheme.lensRing, lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(VintageTheme.vintage)
                        .frame(width: 35, height: 35)
                }
                
                VStack(spacing: 8) {
                    Text("Vintage Capsule")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(VintageTheme.vintage)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    
                    Text("Home Video Camera")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(VintageTheme.darkSepia)
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VintageTheme.vintage))
                        .scaleEffect(1.2)
                    
                    Text("Loading memories...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(VintageTheme.darkSepia)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}