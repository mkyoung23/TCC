import SwiftUI

// Vintage camera color scheme and styling
struct VintageTheme {
    // Vintage color palette
    static let sepia = Color(red: 0.95, green: 0.87, blue: 0.73)
    static let darkSepia = Color(red: 0.8, green: 0.65, blue: 0.4)
    static let vintage = Color(red: 0.6, green: 0.4, blue: 0.2)
    static let filmBorder = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let cameraBody = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let lensRing = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    // Vintage gradients
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [sepia, darkSepia]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cameraGradient = LinearGradient(
        gradient: Gradient(colors: [cameraBody, lensRing]),
        startPoint: .top,
        endPoint: .bottom
    )
}

// Vintage button style
struct VintageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(VintageTheme.vintage)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Vintage text field style
struct VintageTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(VintageTheme.sepia)
                    .stroke(VintageTheme.vintage, lineWidth: 2)
            )
            .foregroundColor(VintageTheme.vintage)
    }
}

// Film strip border view
struct FilmStripBorder: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(VintageTheme.filmBorder)
                .frame(height: 20)
                .overlay(
                    HStack(spacing: 15) {
                        ForEach(0..<8, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                        }
                    }
                )
            Spacer()
            Rectangle()
                .fill(VintageTheme.filmBorder)
                .frame(height: 20)
                .overlay(
                    HStack(spacing: 15) {
                        ForEach(0..<8, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                        }
                    }
                )
        }
    }
}

// Camera viewfinder overlay
struct CameraViewfinderOverlay: View {
    var body: some View {
        ZStack {
            // Outer frame
            RoundedRectangle(cornerRadius: 20)
                .stroke(VintageTheme.lensRing, lineWidth: 4)
                .frame(width: 300, height: 200)
            
            // Corner brackets
            VStack {
                HStack {
                    CornerBracket(position: .topLeft)
                    Spacer()
                    CornerBracket(position: .topRight)
                }
                Spacer()
                HStack {
                    CornerBracket(position: .bottomLeft)
                    Spacer()
                    CornerBracket(position: .bottomRight)
                }
            }
            .frame(width: 280, height: 180)
            
            // Center crosshair
            VStack {
                Rectangle()
                    .fill(VintageTheme.lensRing)
                    .frame(width: 2, height: 20)
                Rectangle()
                    .fill(VintageTheme.lensRing)
                    .frame(width: 20, height: 2)
            }
            
            // Recording indicator (when needed)
            VStack {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .opacity(0.8)
                    Text("REC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: 280, height: 180)
        }
    }
}

struct CornerBracket: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    let position: Position
    
    var body: some View {
        let size: CGFloat = 20
        let thickness: CGFloat = 2
        
        ZStack {
            switch position {
            case .topLeft:
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: size, height: thickness)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: thickness, height: size)
                        Spacer()
                    }
                    Spacer()
                }
            case .topRight:
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: size, height: thickness)
                    }
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: thickness, height: size)
                    }
                    Spacer()
                }
            case .bottomLeft:
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: thickness, height: size)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: size, height: thickness)
                        Spacer()
                    }
                }
            case .bottomRight:
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: thickness, height: size)
                    }
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(VintageTheme.lensRing)
                            .frame(width: size, height: thickness)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
}