import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    @State private var showTransferSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)

            // Transactions
            TransactionListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)

            // Add Button (Center, prominent)
            AddTransactionView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Add")
                }
                .tag(2)

            // Analytics
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Analytics")
                }
                .tag(3)

            // More
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("More")
                }
                .tag(4)
        }
        .tint(AppTheme.primaryCyan)
        .preferredColorScheme(.dark)  // Dark mode by default
    }
}

// MARK: - Dashboard View (Futuristic)
struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAccounts = false
    @State private var showBudgets = false
    @State private var showGoals = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Deep gradient background
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Balance Summary (Hero Card)
                        BalanceSummaryCard()
                        
                        // Quick Stats Row
                        QuickStatsRow()
                        
                        // Quick Actions
                        QuickActionsCard(showTransferSheet: .constant(false))
                        
                        // Recent Transactions
                        RecentTransactionsCard()
                        
                        // Budget Progress
                        BudgetProgressView()
                        
                        // Goals Overview
                        GoalsOverviewCard(showGoals: $showGoals)
                    }
                    .padding()
                }
            }
            .navigationTitle("DailyExpenseAIPro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.backgroundSecondary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAccounts = true
                    } label: {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(AppTheme.primaryCyan)
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
}

// MARK: - Balance Summary Card (Futuristic)
struct BalanceSummaryCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(spacing: 20) {
            // Glowing balance
            VStack(spacing: 8) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(formatCurrency(store.totalBalance))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .neonGlow(color: AppTheme.primaryCyan)
            }
            
            // Income/Expense Row
            HStack(spacing: 30) {
                // Income
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(AppTheme.success)
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Text(formatCurrency(store.monthlyIncome))
                        .font(.headline)
                        .foregroundStyle(AppTheme.success)
                }
                
                // Divider
                RoundedRectangle(cornerRadius: 1)
                    .fill(AppTheme.textSecondary.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                // Expenses
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(AppTheme.error)
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Text(formatCurrency(store.monthlyExpenses))
                        .font(.headline)
                        .foregroundStyle(AppTheme.error)
                }
            }
            
            // Weekly/Today row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(formatCurrency(store.weeklyExpenses))
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.primaryCyan)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(formatCurrency(store.todayExpenses))
                        .font(.subheadline.bold())
                        .foregroundColor(store.todayExpenses > 0 ? AppTheme.error : AppTheme.textSecondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .glassBackground()
    }

    private func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", abs(amount))
    }
}

// MARK: - Quick Stats Row (Futuristic)
struct QuickStatsRow: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Accounts", value: "\(store.accounts.count)", icon: "creditcard.fill", color: AppTheme.primaryBlue)
            StatCard(title: "Transactions", value: "\(store.transactions.count)", icon: "list.bullet", color: AppTheme.primaryPurple)
            StatCard(title: "Goals", value: "\(store.goals.count)", icon: "star.fill", color: AppTheme.primaryPink)
        }
    }
}

// MARK: - Stat Card (Futuristic)
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .neonGlow(color: color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassBackground()
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}