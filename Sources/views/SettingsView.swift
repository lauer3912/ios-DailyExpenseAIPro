import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("currency") private var currency = "USD"
    @State private var showExport = false
    @State private var showImport = false
    @State private var showDeleteAlert = false
    @State private var showAccounts = false
    @State private var showBudgets = false
    @State private var showGoals = false
    @State private var showRecurring = false
    @State private var showSubscription = false

    let currencies = ["USD", "EUR", "GBP", "JPY", "CNY", "CAD", "AUD", "CHF", "INR", "BRL"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                List {
                    // Appearance Section
                    Section {
                        Toggle(isOn: $isDarkMode) {
                            SettingsRow(
                                icon: "moon.fill",
                                iconColor: AppTheme.primaryPurple,
                                title: "Dark Mode"
                            )
                        }
                        .tint(AppTheme.primaryCyan)
                    } header: {
                        Text("Appearance")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Notifications Section
                    Section {
                        Toggle(isOn: $notificationsEnabled) {
                            SettingsRow(
                                icon: "bell.fill",
                                iconColor: AppTheme.warning,
                                title: "Enable Notifications"
                            )
                        }
                        .tint(AppTheme.primaryCyan)

                        if notificationsEnabled {
                            Button {
                                NotificationService.shared.scheduleDailyReminder(at: 20, minute: 0)
                            } label: {
                                SettingsRow(
                                    icon: "bell.badge",
                                    iconColor: AppTheme.primaryCyan,
                                    title: "Test Notification",
                                    showChevron: false
                                )
                            }
                        }
                    } header: {
                        Text("Notifications")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Currency Section
                    Section {
                        Picker(selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .tag(curr)
                            }
                        } label: {
                            SettingsRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: AppTheme.success,
                                title: "Currency"
                            )
                        }
                        .pickerStyle(.menu)
                    } header: {
                        Text("Preferences")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Data Management Section
                    Section {
                        Button {
                            showAccounts = true
                        } label: {
                            HStack {
                                SettingsRow(
                                    icon: "creditcard.fill",
                                    iconColor: AppTheme.primaryBlue,
                                    title: "Manage Accounts"
                                )
                                Spacer()
                                Text("\(store.accounts.count)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            showBudgets = true
                        } label: {
                            HStack {
                                SettingsRow(
                                    icon: "chart.pie.fill",
                                    iconColor: AppTheme.primaryPink,
                                    title: "Manage Budgets"
                                )
                                Spacer()
                                Text("\(store.budgets.count)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            showGoals = true
                        } label: {
                            HStack {
                                SettingsRow(
                                    icon: "star.fill",
                                    iconColor: AppTheme.warning,
                                    title: "Manage Goals"
                                )
                                Spacer()
                                Text("\(store.goals.count)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            showRecurring = true
                        } label: {
                            SettingsRow(
                                icon: "repeat.circle.fill",
                                iconColor: AppTheme.primaryPurple,
                                title: "Recurring Transactions"
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("Data Management")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Import/Export Section
                    Section {
                        Button {
                            showExport = true
                        } label: {
                            SettingsRow(
                                icon: "square.and.arrow.up.fill",
                                iconColor: AppTheme.success,
                                title: "Export Data"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            showImport = true
                        } label: {
                            SettingsRow(
                                icon: "square.and.arrow.down.fill",
                                iconColor: AppTheme.primaryBlue,
                                title: "Import Data"
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("Import / Export")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Subscription Section
                    Section {
                        Button {
                            showSubscription = true
                        } label: {
                            HStack {
                                SettingsRow(
                                    icon: "crown.fill",
                                    iconColor: AppTheme.warning,
                                    title: "Upgrade to Premium"
                                )
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("Subscription")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)

                    // Danger Zone
                    Section {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(AppTheme.error)
                                    .frame(width: 28)
                                Text("Delete All Data")
                                    .foregroundStyle(AppTheme.error)
                            }
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("Danger Zone")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.backgroundCard)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.backgroundSecondary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAccounts) {
                AccountsView()
            }
            .sheet(isPresented: $showBudgets) {
                BudgetsView()
            }
            .sheet(isPresented: $showGoals) {
                GoalsView()
            }
            .sheet(isPresented: $showRecurring) {
                RecurringTransactionsView()
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showExport) {
                ExportView()
            }
            .sheet(isPresented: $showImport) {
                ImportView()
            }
            .alert("Delete All Data", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your accounts, transactions, budgets, and goals. This action cannot be undone.")
            }
        }
    }

    func deleteAllData() {
        store.transactions.removeAll()
        store.accounts.removeAll()
        store.budgets.removeAll()
        store.goals.removeAll()
        store.recurringTransactions.removeAll()
        store.saveToUserDefaults()
    }
}

// MARK: - Futuristic Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}