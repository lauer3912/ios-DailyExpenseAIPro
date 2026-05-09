import SwiftUI

// MARK: - Game Style Theme (Cyberpunk RPG)
enum GameTheme {
    // MARK: - Primary Colors
    static let neonCyan = Color(hex: "00FFFF")
    static let neonMagenta = Color(hex: "FF00FF")
    static let neonPurple = Color(hex: "9D00FF")
    static let neonGreen = Color(hex: "00FF66")
    static let neonYellow = Color(hex: "FFFF00")
    static let neonOrange = Color(hex: "FF6600")
    static let neonRed = Color(hex: "FF3333")
    static let neonBlue = Color(hex: "0066FF")
    
    // MARK: - Background Colors
    static let darkBackground = Color(hex: "0D0D1A")
    static let cardBackground = Color(hex: "1A1A2E")
    static let panelBackground = Color(hex: "16213E")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [neonCyan, neonPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let energyGradient = LinearGradient(
        colors: [neonGreen, neonCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let dangerGradient = LinearGradient(
        colors: [neonRed, neonOrange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [neonYellow, neonOrange],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "B0B0C0")
    static let textAccent = neonCyan
    
    // MARK: - XP Level Colors
    static let xpBlue = Color(hex: "00AAFF")
    static let xpPurple = Color(hex: "AA00FF")
    static let xpGold = Color(hex: "FFD700")
    static let xpLegendary = Color(hex: "FF6600")
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        neonCyan, neonMagenta, neonPurple, neonGreen, neonYellow, neonOrange, neonBlue
    ]
    
    // MARK: - Glow Effect
    static func glow(color: Color, radius: CGFloat = 10) -> some View {
        EmptyView().shadow(color: color.opacity(0.8), radius: radius)
    }
}

// MARK: - Level System
struct LevelSystem {
    static func levelForXP(_ xp: Int) -> Int {
        return Int(sqrt(Double(xp) / 100)) + 1
    }
    
    static func xpForLevel(_ level: Int) -> Int {
        return (level - 1) * (level - 1) * 100
    }
    
    static func xpProgress(_ xp: Int) -> Double {
        let level = levelForXP(xp)
        let currentLevelXP = xpForLevel(level)
        let nextLevelXP = xpForLevel(level + 1)
        let xpIntoLevel = xp - currentLevelXP
        let xpNeeded = nextLevelXP - currentLevelXP
        return Double(xpIntoLevel) / Double(xpNeeded)
    }
}

// MARK: - Streak System
struct StreakSystem {
    static func streakTitle(for streak: Int) -> String {
        switch streak {
        case 0..<3: return "Beginner"
        case 3..<7: return "Apprentice"
        case 7..<14: return "Journeyman"
        case 14..<30: return "Expert"
        case 30..<60: return "Master"
        case 60..<100: return "Grand Master"
        default: return "Legend"
        }
    }
    
    static func streakIcon(for streak: Int) -> String {
        switch streak {
        case 0..<3: return "flame"
        case 3..<7: return "flame.fill"
        case 7..<14: return "bolt.fill"
        case 14..<30: return "star.fill"
        case 30..<60: return "crown.fill"
        default: return "sparkles"
        }
    }
}

// MARK: - Game Card Modifier
struct GameCard: ViewModifier {
    let glowColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(GameTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [glowColor.opacity(0.6), glowColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: glowColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func gameCard(glow: Color = GameTheme.neonCyan) -> some View {
        modifier(GameCard(glowColor: glow))
    }
}

// MARK: - XP Progress Bar
struct XPProgressBar: View {
    let level: Int
    let currentXP: Int
    let nextLevelXP: Int
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("LV.\(level)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(levelGradient)
                
                Spacer()
                
                Text("\(currentXP) / \(nextLevelXP) XP")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(GameTheme.textSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(GameTheme.darkBackground)
                    
                    // XP progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(XPBarGradient)
                        .frame(width: geo.size.width * progress)
                        .shadow(color: GameTheme.neonCyan.opacity(0.5), radius: 4)
                    
                    // Shimmer effect
                    HStack(spacing: 2) {
                        ForEach(0..<20, id: \.self) { i in
                            if i % 4 == 0 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 4, height: 12)
                                    .offset(x: geo.size.width * progress - CGFloat(i) * (geo.size.width / 20))
                            }
                        }
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(12)
        .background(GameTheme.cardBackground)
        .cornerRadius(12)
    }
    
    private var levelGradient: LinearGradient {
        if level < 10 {
            return LinearGradient(colors: [GameTheme.xpBlue, GameTheme.neonCyan], startPoint: .leading, endPoint: .trailing)
        } else if level < 25 {
            return LinearGradient(colors: [GameTheme.xpPurple, GameTheme.neonMagenta], startPoint: .leading, endPoint: .trailing)
        } else if level < 50 {
            return LinearGradient(colors: [GameTheme.xpGold, GameTheme.neonOrange], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [GameTheme.xpLegendary, GameTheme.neonRed], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var XPBarGradient: LinearGradient {
        if level < 10 {
            return LinearGradient(colors: [GameTheme.neonCyan, GameTheme.xpBlue], startPoint: .leading, endPoint: .trailing)
        } else if level < 25 {
            return LinearGradient(colors: [GameTheme.neonMagenta, GameTheme.xpPurple], startPoint: .leading, endPoint: .trailing)
        } else if level < 50 {
            return LinearGradient(colors: [GameTheme.neonOrange, GameTheme.xpGold], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [GameTheme.neonRed, GameTheme.xpLegendary], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// MARK: - Energy Bar (Budget Remaining)
struct EnergyBar: View {
    let current: Double
    let max: Double
    let label: String
    
    var progress: Double { min(current / max, 1.0) }
    var isOverBudget: Bool { current > max }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: isOverBudget ? "exclamationmark.triangle.fill" : "bolt.fill")
                    .foregroundStyle(isOverBudget ? GameTheme.neonRed : GameTheme.neonGreen)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(GameTheme.textSecondary)
                
                Spacer()
                
                Text(String(format: "$%.0f / $%.0f", current, max))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(isOverBudget ? GameTheme.neonRed : GameTheme.textPrimary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(GameTheme.darkBackground)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isOverBudget ? GameTheme.dangerGradient : GameTheme.energyGradient)
                        .frame(width: geo.size.width * progress)
                        .shadow(color: (isOverBudget ? GameTheme.neonRed : GameTheme.neonGreen).opacity(0.6), radius: 6)
                }
            }
            .frame(height: 16)
        }
        .padding(12)
        .background(GameTheme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let title: String
    let icon: String
    let unlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(unlocked ? 
                        LinearGradient(colors: [GameTheme.neonYellow, GameTheme.neonOrange], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: unlocked ? GameTheme.neonYellow.opacity(0.5) : .clear, radius: 8)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(unlocked ? GameTheme.darkBackground : GameTheme.textSecondary)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(unlocked ? GameTheme.textPrimary : GameTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 70)
        .opacity(unlocked ? 1.0 : 0.6)
    }
}

// MARK: - Streak Counter
struct StreakCounter: View {
    let streak: Int
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: StreakSystem.streakIcon(for: streak))
                .font(.system(size: 24))
                .foregroundStyle(streak >= 7 ? GameTheme.neonOrange : GameTheme.neonCyan)
                .shadow(color: (streak >= 7 ? GameTheme.neonOrange : GameTheme.neonCyan).opacity(0.6), radius: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.textPrimary)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(GameTheme.textSecondary)
            }
        }
        .padding(12)
        .background(GameTheme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Combo Multiplier
struct ComboMultiplier: View {
    let combo: Int
    
    var body: some View {
        if combo > 1 {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(GameTheme.neonYellow)
                
                Text("x\(combo)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.neonYellow)
                    .shadow(color: GameTheme.neonYellow.opacity(0.8), radius: 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(GameTheme.neonYellow.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(GameTheme.neonYellow.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Game Section Header
struct GameSectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.5), radius: 4)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(GameTheme.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}