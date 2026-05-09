import SwiftUI

// MARK: - App Theme (2026 Futuristic Style)
enum AppTheme {
    // MARK: - Primary Colors (Gradient-ready)
    static let primaryBlue = Color(hex: "007AFF")
    static let primaryPurple = Color(hex: "AF52DE")
    static let primaryCyan = Color(hex: "00D4FF")
    static let primaryPink = Color(hex: "FF2D92")
    
    // MARK: - Gradient Presets
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [primaryCyan, primaryBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [primaryPink, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Background Colors (Dark Mode First)
    static let backgroundPrimary = Color(hex: "0A0A1A")      // Deep navy black
    static let backgroundSecondary = Color(hex: "12122A")   // Slightly lighter
    static let backgroundCard = Color(hex: "1A1A3E")        // Card background
    static let backgroundGlass = Color(hex: "1E1E4A").opacity(0.6)  // Glassmorphism
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0C0")
    static let textAccent = primaryCyan
    
    // MARK: - Status Colors
    static let success = Color(hex: "00E676")
    static let warning = Color(hex: "FFAB00")
    static let error = Color(hex: "FF5252")
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        Color(hex: "00D4FF"),
        Color(hex: "AF52DE"),
        Color(hex: "FF2D92"),
        Color(hex: "00E676"),
        Color(hex: "FFAB00"),
        Color(hex: "7C4DFF"),
        Color(hex: "00BFA5")
    ]
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Glassmorphism Modifier
struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.backgroundGlass)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

// MARK: - Neon Glow Effect
struct NeonGlow: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: 16, x: 0, y: 4)
    }
}

extension View {
    func neonGlow(color: Color = AppTheme.primaryCyan) -> some View {
        modifier(NeonGlow(color: color))
    }
}