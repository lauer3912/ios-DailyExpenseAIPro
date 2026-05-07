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
                    Image(systemName: "house")
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

            // Add Button
            AddTransactionView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
                .tag(2)

            // Analytics
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Analytics")
                }
                .tag(3)

            // More
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("More")
                }
                .tag(4)
        }
        .tint(Color.mint)
        .sheet(isPresented: $showTransferSheet) {
            TransferView()
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAccounts = false
    @State private var showBudgets = false
    @State private var showGoals = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Summary
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
            .navigationTitle("DailyExpenseAIPro")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAccounts = true
                    } label: {
                        Image(systemName: "creditcard")
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

struct BalanceSummaryCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(formatCurrency(store.totalBalance))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(formatCurrency(store.monthlyIncome))
                        .font(.headline)
                        .foregroundColor(.green)
                }

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(formatCurrency(store.monthlyExpenses))
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(store.weeklyExpenses))
                        .font(.subheadline.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(store.todayExpenses))
                        .font(.subheadline.bold())
                        .foregroundColor(store.todayExpenses > 0 ? .red : .secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", abs(amount))
    }
}

struct QuickStatsRow: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Accounts", value: "\(store.accounts.count)", icon: "creditcard.fill", color: .blue)
            StatCard(title: "Transactions", value: "\(store.transactions.count)", icon: "list.bullet", color: .purple)
            StatCard(title: "Goals", value: "\(store.goals.count)", icon: "star.fill", color: .orange)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}