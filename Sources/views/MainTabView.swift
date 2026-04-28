import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            ScrollView {
                VStack(spacing: 20) {
                    BalanceSummaryView()
                    QuickActionsView()
                    RecentTransactionsView()
                    BudgetProgressView()
                }
                .padding()
            }
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
                    Image(systemName: "plus")
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
    }
}

struct BalanceSummaryView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Total Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("$" + String(format: "%.2f", store.totalBalance))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 30) {
                VStack {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("+$" + String(format: "%.2f", store.monthlyIncome))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.green)
                }
                VStack {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("-$" + String(format: "%.2f", store.monthlyExpenses))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 16) {
                ActionButton(title: "Add Income", systemIcon: "plus.circle.fill", color: .green)
                ActionButton(title: "Add Expense", systemIcon: "minus.circle.fill", color: .red)
                ActionButton(title: "Transfer", systemIcon: "arrow.left.arrow.right", color: .blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct ActionButton: View {
    let title: String
    let systemIcon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemIcon)
                .font(.title2)
                .padding(12)
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .clipShape(Circle())
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentTransactionsView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to all transactions
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            if store.transactions.prefix(3).isEmpty {
                Text("No transactions yet")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(store.transactions.prefix(3)) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .padding(10)
                .background(transaction.category.color.opacity(0.1))
                .foregroundColor(transaction.category.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
            
            Spacer()
            
            Text((transaction.type == .income ? "+$" : "-$") + String(format: "%.2f", abs(transaction.amount)))
                .font(.subheadline.bold())
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
    }
}

struct BudgetProgressView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budget Progress")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to budgets
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            Text("Monthly Spending")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: min(store.monthlyExpenses / 1000, 1.0))
                .tint(Color.mint)
            
            HStack {
                Text("Spent: $" + String(format: "%.2f", store.monthlyExpenses))
                    .font(.caption)
                Spacer()
                Text("$1,000")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TransactionListView: View {
    @EnvironmentObject var store: AppStore
    @State private var filterType: TransactionType? = nil
    
    var body: some View {
        List {
            // Filter buttons
            HStack {
                FilterButton(title: "All", isSelected: filterType == nil) {
                    filterType = nil
                }
                FilterButton(title: "Income", isSelected: filterType == .income) {
                    filterType = .income
                }
                FilterButton(title: "Expense", isSelected: filterType == .expense) {
                    filterType = .expense
                }
            }
            .listRowBackground(Color.clear)
            
            // Transactions
            ForEach(filteredTransactions) { transaction in
                TransactionRow(transaction: transaction)
                    .listRowSeparator(.hidden)
            }
        }
        .navigationTitle("Transactions")
        .listStyle(.plain)
    }
    
    var filteredTransactions: [Transaction] {
        if let filterType = filterType {
            return store.transactions.filter { $0.type == filterType }
        }
        return store.transactions
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.mint : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var store: AppStore
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Type")) {
                    Picker("", selection: $selectedType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Amount")) {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                }
                
                Section(header: Text("Category")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(store.categories.filter { $0.type == selectedType }) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: category.icon)
                                            .font(.title2)
                                            .padding(12)
                                            .background(
                                                selectedCategory?.id == category.id
                                                    ? category.color
                                                    : category.color.opacity(0.1)
                                            )
                                            .foregroundColor(
                                                selectedCategory?.id == category.id
                                                    ? .white
                                                    : category.color
                                            )
                                            .clipShape(Circle())
                                        Text(category.name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Note")) {
                    TextField("Description", text: $note)
                }
            }
            .navigationTitle("New Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(selectedCategory == nil || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let category = selectedCategory,
              let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            id: UUID(),
            amount: selectedType == .income ? amountValue : -amountValue,
            category: category,
            date: Date(),
            note: note,
            type: selectedType
        )
        
        store.transactions.append(transaction)
        
        // Update account balance
        if let firstAccount = store.accounts.first {
            firstAccount.balance += transaction.amount
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Analytics Coming Soon")
                    .font(.title2)
                    .padding()
                
                // Placeholder charts
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Text("Category Distribution")
                            .foregroundColor(.secondary)
                    )
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Text("Spending Trend")
                            .foregroundColor(.secondary)
                    )
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var isDarkMode = false
    
    var body: some View {
        List {
            Section(header: Text("Appearance")) {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: "moon")
                }
            }
            
            Section(header: Text("Accounts")) {
                ForEach(store.accounts) { account in
                    HStack {
                        Text(account.name)
                        Spacer()
                        Text("$" + String(format: "%.2f", account.balance))
                            .foregroundColor(account.balance >= 0 ? .green : .red)
                    }
                }
            }
            
            Section(header: Text("Budgets")) {
                NavigationLink("Manage Budgets") {
                    Text("Budget Management")
                }
            }
            
            Section(header: Text("Goals")) {
                NavigationLink("Savings Goals") {
                    Text("Goal Management")
                }
            }
            
            Section(header: Text("Subscription")) {
                NavigationLink("Upgrade to Premium") {
                    Text("Premium Features")
                }
                Button("Restore Purchases") {}
            }
            
            Section {
                Button(role: .destructive) {
                    print("Delete all data")
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}