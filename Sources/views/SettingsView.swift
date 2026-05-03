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

    let currencies = ["USD", "EUR", "GBP", "JPY", "CNY", "CAD", "AUD", "CHF", "INR", "BRL"]

    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(.mint)
                } header: {
                    Text("Appearance")
                }

                // Notifications
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Enable Notifications", systemImage: "bell.fill")
                    }
                    .tint(.mint)

                    if notificationsEnabled {
                        Button {
                            NotificationService.shared.scheduleDailyReminder(at: 20, minute: 0)
                        } label: {
                            Label("Test Notification", systemImage: "bell.badge")
                        }
                    }
                } header: {
                    Text("Notifications")
                }

                // Currency
                Section {
                    Picker(selection: $currency) {
                        ForEach(currencies, id: \.self) { curr in
                            Text(curr).tag(curr)
                        }
                    } label: {
                        Label("Currency", systemImage: "dollarsign.circle")
                    }
                } header: {
                    Text("Preferences")
                }

                // Accounts & Budgets
                Section {
                    Button {
                        showAccounts = true
                    } label: {
                        Label {
                            HStack {
                                Text("Manage Accounts")
                                Spacer()
                                Text("\(store.accounts.count)")
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        showBudgets = true
                    } label: {
                        Label {
                            HStack {
                                Text("Manage Budgets")
                                Spacer()
                                Text("\(store.budgets.count)")
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        showGoals = true
                    } label: {
                        Label {
                            HStack {
                                Text("Savings Goals")
                                Spacer()
                                Text("\(store.goals.count)")
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        showRecurring = true
                    } label: {
                        Label {
                            HStack {
                                Text("Recurring Transactions")
                                Spacer()
                                Text("\(store.recurringTransactions.count)")
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "repeat")
                                .foregroundColor(.purple)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Finance Management")
                }

                // Data
                Section {
                    Button {
                        showExport = true
                    } label: {
                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImport = true
                    } label: {
                        Label("Import Data (CSV)", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Data")
                }

                // Subscription
                Section {
                    HStack {
                        Label("Premium Status", systemImage: "crown.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("Free Plan")
                            .foregroundColor(.secondary)
                    }

                    Button {
                        // Premium purchase
                    } label: {
                        Label("Upgrade to Premium", systemImage: "sparkles")
                            .foregroundColor(.mint)
                    }

                    Button {
                        // Restore
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("Subscription")
                }

                // About
                Section {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }

                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }

                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete all your transactions, accounts, budgets, and goals. This action cannot be undone.")
                }
            }
            .navigationTitle("Settings")
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
            .sheet(isPresented: $showExport) {
                ExportView()
            }
            .sheet(isPresented: $showImport) {
                ImportView()
            }
            .alert("Delete All Data", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Everything", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete ALL your data including transactions, accounts, budgets, and goals. This cannot be undone.")
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

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}