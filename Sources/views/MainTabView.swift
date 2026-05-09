import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    @State private var showTransferSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard (Quest Hub)
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Hub")
                }
                .tag(0)

            // Transactions (Inventory)
            TransactionListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.fill")
                    Text("Items")
                }
                .tag(1)

            // Add Button (Quest Entry)
            AddTransactionView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Quest")
                }
                .tag(2)

            // Analytics (Stats)
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(3)

            // More (Menu)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Menu")
                }
                .tag(4)
        }
        .tint(GameTheme.neonCyan)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dashboard View (Quest Hub)
struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAccounts = false
    @State private var showBudgets = false
    @State private var showGoals = false

    // Game stats (derived from real data)
    var totalXP: Int { Int(abs(store.totalBalance)) * 10 }
    var currentLevel: Int { LevelSystem.levelForXP(totalXP) }
    var xpProgress: Double { LevelSystem.xpProgress(totalXP) }
    var streak: Int { calculateStreak() }
    var combo: Int { streak > 2 ? streak : 1 }

    var body: some View {
        NavigationStack {
            ZStack {
                GameTheme.darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Player Stats Header
                        PlayerStatsHeader()
                        
                        // XP Progress Bar
                        XPProgressBar(
                            level: currentLevel,
                            currentXP: totalXP,
                            nextLevelXP: LevelSystem.xpForLevel(currentLevel + 1),
                            progress: xpProgress
                        )
                        .padding(.horizontal)
                        
                        // Energy Bar (Budget)
                        EnergyBar(
                            current: store.monthlyExpenses,
                            max: store.monthlyBudget > 0 ? store.monthlyBudget : 3000,
                            label: "Daily Energy"
                        )
                        .padding(.horizontal)
                        
                        // Quick Stats Row
                        HStack(spacing: 12) {
                            StatCardGame(
                                title: "Gold",
                                value: formatCurrency(store.totalBalance),
                                icon: "dollarsign.circle.fill",
                                color: GameTheme.neonYellow
                            )
                            StatCardGame(
                                title: "Streak",
                                value: "\(streak)",
                                icon: StreakSystem.streakIcon(for: streak),
                                color: streak >= 7 ? GameTheme.neonOrange : GameTheme.neonCyan
                            )
                            StatCardGame(
                                title: "Combo",
                                value: "x\(combo)",
                                icon: "bolt.fill",
                                color: GameTheme.neonMagenta
                            )
                        }
                        .padding(.horizontal)
                        
                        // Quick Actions (Quests)
                        QuickActionsCard(showTransferSheet: .constant(false))
                        
                        // Recent Transactions (Loot Log)
                        RecentTransactionsCard()
                        
                        // Budget Progress (Mission Progress)
                        BudgetProgressView()
                        
                        // Goals Overview (Achievements)
                        GoalsOverviewCard(showGoals: $showGoals)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Quest Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GameTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAccounts = true
                    } label: {
                        Image(systemName: "backpack.fill")
                            .foregroundColor(GameTheme.neonCyan)
                    }
                }
            }
            .sheet(isPresented: $showAccounts) {
                AccountsView()
            }
            .sheet(isPresented: $showBudgets) {
                BudgetsView()
            }
            .sheet(isPresented: $showGoals) {
                GoalsView()
            }
        }
    }
    
    private func calculateStreak() -> Int {
        // Simple streak: consecutive days with transactions
        let calendar = Calendar.current
        var streak = 0
        let sorted = store.transactions.sorted { $0.date > $1.date }
        var lastDate: Date?
        
        for transaction in sorted {
            let day = calendar.startOfDay(for: transaction.date)
            if let last = lastDate {
                let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: last), to: day).day ?? 0
                if diff <= 1 {
                    streak += 1
                } else {
                    break
                }
            } else {
                streak = 1
            }
            lastDate = day
        }
        return streak
    }

    private func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.0f", abs(amount))
    }
}

// MARK: - Player Stats Header
struct PlayerStatsHeader: View {
    @EnvironmentObject var store: AppStore
    
    var totalXP: Int { Int(abs(store.totalBalance)) * 10 }
    var currentLevel: Int { LevelSystem.levelForXP(totalXP) }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [GameTheme.neonCyan, GameTheme.neonPurple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: GameTheme.neonCyan.opacity(0.5), radius: 10)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(GameTheme.darkBackground)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("FINANCE HERO")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(GameTheme.textPrimary)
                
                Text("Level \(currentLevel) \(levelTitle)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(levelColor)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("\(totalXP) Total XP")
                        .font(.system(size: 10))
                }
                .foregroundStyle(GameTheme.textSecondary)
            }
            
            Spacer()
            
            // Rank badge
            VStack(spacing: 4) {
                Image(systemName: rankIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(rankColor)
                    .shadow(color: rankColor.opacity(0.5), radius: 6)
                
                Text(rankTitle)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(rankColor)
            }
        }
        .padding(16)
        .gameCard(glow: GameTheme.neonCyan)
        .padding(.horizontal)
    }
    
    var levelTitle: String {
        switch currentLevel {
        case 0..<5: return "Novice"
        case 5..<10: return "Apprentice"
        case 10..<20: return "Journeyman"
        case 20..<30: return "Expert"
        case 30..<50: return "Master"
        default: return "Legend"
        }
    }
    
    var levelColor: LinearGradient {
        switch currentLevel {
        case 0..<5: return LinearGradient(colors: [GameTheme.neonCyan, GameTheme.xpBlue], startPoint: .leading, endPoint: .trailing)
        case 5..<10: return LinearGradient(colors: [GameTheme.xpBlue, GameTheme.xpPurple], startPoint: .leading, endPoint: .trailing)
        case 10..<20: return LinearGradient(colors: [GameTheme.xpPurple, GameTheme.neonMagenta], startPoint: .leading, endPoint: .trailing)
        case 20..<30: return LinearGradient(colors: [GameTheme.neonMagenta, GameTheme.xpGold], startPoint: .leading, endPoint: .trailing)
        default: return LinearGradient(colors: [GameTheme.xpGold, GameTheme.xpLegendary], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var rankTitle: String {
        switch currentLevel {
        case 0..<5: return "E"
        case 5..<10: return "D"
        case 10..<20: return "C"
        case 20..<30: return "B"
        case 30..<50: return "A"
        default: return "S"
        }
    }
    
    var rankIcon: String {
        switch currentLevel {
        case 0..<5: return "shield.fill"
        case 5..<10: return "shield.fill"
        case 10..<20: return "star.fill"
        case 20..<30: return "crown.fill"
        default: return "sparkles"
        }
    }
    
    var rankColor: Color {
        switch currentLevel {
        case 0..<5: return GameTheme.neonCyan
        case 5..<10: return GameTheme.xpBlue
        case 10..<20: return GameTheme.xpPurple
        case 20..<30: return GameTheme.neonMagenta
        default: return GameTheme.xpGold
        }
    }
}

// MARK: - Stat Card Game Style
struct StatCardGame: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.5), radius: 6)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(GameTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(GameTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .gameCard(glow: color)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}