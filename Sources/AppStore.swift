import Foundation
import SwiftUI
import Combine

// MARK: - AppStore (Enhanced with Persistence)

class AppStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var goals: [Goal] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var searchText: String = ""
    @Published var selectedCurrency: String = "USD"
    @Published var isPremium: Bool = false

    private let userDefaultsKey = "DailyExpenseAIPro_Data"

    init() {
        loadFromUserDefaults()
        if categories.isEmpty {
            loadDefaultCategories()
        }
        if accounts.isEmpty {
            loadDefaultAccounts()
        }
    }

    // MARK: - StoreKit Sync
    func syncWithStoreKit() async {
        await StoreKitManager.shared.updatePurchasedProducts()
        let storeKitPremium = await StoreKitManager.shared.isPremiumActive
        if storeKitPremium {
            isPremium = true
            saveToUserDefaults()
        }
    }

    // MARK: - Default Data

    private func loadDefaultCategories() {
        categories = [
            Category(id: UUID(), name: "Food & Dining", icon: "fork.knife", color: .red, type: .expense),
            Category(id: UUID(), name: "Transportation", icon: "car", color: .blue, type: .expense),
            Category(id: UUID(), name: "Shopping", icon: "bag", color: .purple, type: .expense),
            Category(id: UUID(), name: "Entertainment", icon: "ticket", color: .orange, type: .expense),
            Category(id: UUID(), name: "Bills", icon: "doc.text", color: .teal, type: .expense),
            Category(id: UUID(), name: "Healthcare", icon: "bandage", color: .pink, type: .expense),
            Category(id: UUID(), name: "Education", icon: "book", color: .indigo, type: .expense),
            Category(id: UUID(), name: "Travel", icon: "airplane", color: .cyan, type: .expense),
            Category(id: UUID(), name: "Groceries", icon: "cart", color: .green, type: .expense),
            Category(id: UUID(), name: "Utilities", icon: "bolt", color: .yellow, type: .expense),
            Category(id: UUID(), name: "Salary", icon: "dollarsign.circle", color: .green, type: .income),
            Category(id: UUID(), name: "Freelance", icon: "briefcase", color: .mint, type: .income),
            Category(id: UUID(), name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .cyan, type: .income),
            Category(id: UUID(), name: "Gift", icon: "gift", color: .pink, type: .income),
            Category(id: UUID(), name: "Other Income", icon: "ellipsis.circle", color: .gray, type: .income),
        ]
    }

    private func loadDefaultAccounts() {
        accounts = [
            Account(id: UUID(), name: "Cash", balance: 500.0, type: .cash, color: .green),
            Account(id: UUID(), name: "Checking", balance: 2500.0, type: .checking, color: .blue),
            Account(id: UUID(), name: "Savings", balance: 10000.0, type: .savings, color: .purple),
            Account(id: UUID(), name: "Credit Card", balance: -500.0, type: .credit, color: .red),
        ]
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        let encoder = JSONEncoder()

        if let transactionData = try? encoder.encode(transactions.map { TransactionCodable($0) }),
           let accountData = try? encoder.encode(accounts.map { AccountCodable($0) }),
           let budgetData = try? encoder.encode(budgets.map { BudgetCodable($0) }),
           let goalData = try? encoder.encode(goals.map { GoalCodable($0) }),
           let recurringData = try? encoder.encode(recurringTransactions.map { RecurringCodable($0) }) {

            UserDefaults.standard.set(transactionData, forKey: userDefaultsKey + "_transactions")
            UserDefaults.standard.set(accountData, forKey: userDefaultsKey + "_accounts")
            UserDefaults.standard.set(budgetData, forKey: userDefaultsKey + "_budgets")
            UserDefaults.standard.set(goalData, forKey: userDefaultsKey + "_goals")
            UserDefaults.standard.set(recurringData, forKey: userDefaultsKey + "_recurring")
            UserDefaults.standard.set(selectedCurrency, forKey: userDefaultsKey + "_currency")
            UserDefaults.standard.set(isPremium, forKey: userDefaultsKey + "_premium")
        }
    }

    func loadFromUserDefaults() {
        let decoder = JSONDecoder()

        if let transactionData = UserDefaults.standard.data(forKey: userDefaultsKey + "_transactions"),
           let decoded = try? decoder.decode([TransactionCodable].self, from: transactionData) {
            transactions = decoded.map { $0.toTransaction(categories: categories) }
        }

        if let accountData = UserDefaults.standard.data(forKey: userDefaultsKey + "_accounts"),
           let decoded = try? decoder.decode([AccountCodable].self, from: accountData) {
            accounts = decoded.map { $0.toAccount() }
        }

        if let budgetData = UserDefaults.standard.data(forKey: userDefaultsKey + "_budgets"),
           let decoded = try? decoder.decode([BudgetCodable].self, from: budgetData) {
            budgets = decoded.map { $0.toBudget(categories: categories) }
        }

        if let goalData = UserDefaults.standard.data(forKey: userDefaultsKey + "_goals"),
           let decoded = try? decoder.decode([GoalCodable].self, from: goalData) {
            goals = decoded.map { $0.toGoal() }
        }

        if let recurringData = UserDefaults.standard.data(forKey: userDefaultsKey + "_recurring"),
           let decoded = try? decoder.decode([RecurringCodable].self, from: recurringData) {
            recurringTransactions = decoded.map { $0.toRecurring(categories: categories) }
        }

        if let currency = UserDefaults.standard.string(forKey: userDefaultsKey + "_currency") {
            selectedCurrency = currency
        }

        isPremium = UserDefaults.standard.bool(forKey: userDefaultsKey + "_premium")
    }

    // MARK: - Computed Properties

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var monthlyExpenses: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return transactions
            .filter { $0.type == .expense && $0.date >= startOfMonth }
            .reduce(0) { $0 + abs($1.amount) }
    }

    var monthlyIncome: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return transactions
            .filter { $0.type == .income && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    var weeklyExpenses: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return transactions
            .filter { $0.type == .expense && $0.date >= startOfWeek }
            .reduce(0) { $0 + abs($1.amount) }
    }

    var todayExpenses: Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return transactions
            .filter { $0.type == .expense && $0.date >= startOfDay }
            .reduce(0) { $0 + abs($1.amount) }
    }

    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return transactions.sorted { $0.date > $1.date }
        }
        return transactions.filter {
            $0.note.localizedCaseInsensitiveContains(searchText) ||
            $0.category.name.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.date > $1.date }
    }

    func transactions(for type: TransactionType) -> [Transaction] {
        transactions.filter { $0.type == type }.sorted { $0.date > $1.date }
    }

    func transactions(for category: Category) -> [Transaction] {
        transactions.filter { $0.category.id == category.id }.sorted { $0.date > $1.date }
    }

    func transactions(from startDate: Date, to endDate: Date) -> [Transaction] {
        transactions.filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }

    func expensesByCategory(in period: DateInterval? = nil) -> [(Category, Double)] {
        let filtered = if let period = period {
            transactions.filter { $0.type == .expense && period.contains($0.date) }
        } else {
            transactions.filter { $0.type == .expense }
        }

        var result: [UUID: Double] = [:]
        for t in filtered {
            result[t.category.id, default: 0] += abs(t.amount)
        }

        return categories
            .filter { $0.type == .expense }
            .map { cat in (cat, result[cat.id] ?? 0) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    func budget(for category: Category) -> Budget? {
        budgets.first { $0.category.id == category.id }
    }

    // MARK: - Transaction Operations

    func addTransaction(_ transaction: Transaction, toAccount account: Account? = nil) {
        transactions.append(transaction)

        if let account = account ?? accounts.first {
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index].balance += transaction.amount
            }
        }
        saveToUserDefaults()
    }

    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveToUserDefaults()
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveToUserDefaults()
    }

    func deleteTransactions(at offsets: IndexSet, from list: [Transaction]) {
        let toDelete = offsets.map { list[$0] }
        for t in toDelete {
            deleteTransaction(t)
        }
    }

    // MARK: - Account Operations

    func addAccount(_ account: Account) {
        accounts.append(account)
        saveToUserDefaults()
    }

    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveToUserDefaults()
        }
    }

    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        saveToUserDefaults()
    }

    func transfer(from source: Account, to destination: Account, amount: Double) {
        guard let srcIndex = accounts.firstIndex(where: { $0.id == source.id }),
              let dstIndex = accounts.firstIndex(where: { $0.id == destination.id }) else { return }

        accounts[srcIndex].balance -= amount
        accounts[dstIndex].balance += amount

        let transferCategory = Category(id: UUID(), name: "Transfer", icon: "arrow.left.arrow.right",
                                        color: .blue, type: .expense)
        let outgoing = Transaction(id: UUID(), amount: -amount, category: transferCategory,
                                   date: Date(), note: "Transfer to \(destination.name)", type: .expense)
        let incoming = Transaction(id: UUID(), amount: amount, category: transferCategory,
                                    date: Date(), note: "Transfer from \(source.name)", type: .income)
        transactions.append(outgoing)
        transactions.append(incoming)
        saveToUserDefaults()
    }

    // MARK: - Budget Operations

    func setBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.category.id == budget.category.id }) {
            budgets[index] = budget
        } else {
            budgets.append(budget)
        }
        saveToUserDefaults()
    }

    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveToUserDefaults()
    }

    func budgetProgress(for budget: Budget) -> Double {
        let spent = spentAmount(for: budget.category, in: .monthly)
        return min(spent / budget.amount, 1.0)
    }

    func spentAmount(for category: Category, in period: BudgetPeriod) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch period {
        case .weekly:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .monthly:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .yearly:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
        }

        return transactions
            .filter { $0.type == .expense && $0.category.id == category.id && $0.date >= startDate }
            .reduce(0) { $0 + abs($1.amount) }
    }

    // MARK: - Goal Operations

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveToUserDefaults()
    }

    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveToUserDefaults()
        }
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func contributeToGoal(_ goal: Goal, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].currentAmount += amount
            saveToUserDefaults()
        }
    }

    // MARK: - Recurring Transactions

    func addRecurringTransaction(_ recurring: RecurringTransaction) {
        recurringTransactions.append(recurring)
        saveToUserDefaults()
    }

    func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
        recurringTransactions.removeAll { $0.id == recurring.id }
        saveToUserDefaults()
    }

    func processRecurringTransactions() {
        let now = Date()
        for recurring in recurringTransactions {
            if let nextDate = recurring.nextDate, nextDate <= now {
                let transaction = Transaction(
                    id: UUID(),
                    amount: recurring.type == .income ? recurring.amount : -recurring.amount,
                    category: recurring.category,
                    date: now,
                    note: recurring.note,
                    type: recurring.type
                )
                let account = accounts.first { $0.id == recurring.accountId }; if let acc = account { addTransaction(transaction, toAccount: acc) }
            }
        }
    }

    // MARK: - Export

    func exportToCSV() -> String {
        var csv = "Date,Type,Category,Amount,Note,Account\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        for t in transactions {
            let accountName = accounts.first { $0.id == t.accountId }?.name ?? ""
            csv += "\(dateFormatter.string(from: t.date)),\(t.type.rawValue),\(t.category.name),\(t.amount),\(t.note),\(accountName)\n"
        }
        return csv
    }

    func importFromCSV(_ csv: String) {
        let lines = csv.split(separator: "\n")
        guard lines.count > 1 else { return }

        for line in lines.dropFirst() {
            let parts = line.split(separator: ",")
            guard parts.count >= 5 else { continue }

            let dateStr = String(parts[0])
            let typeStr = String(parts[1])
            let categoryName = String(parts[2])
            let amountStr = String(parts[3])
            let note = parts.count > 4 ? String(parts[4]) : ""

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

            guard let date = dateFormatter.date(from: dateStr),
                  let amount = Double(amountStr),
                  let type = TransactionType(rawValue: typeStr),
                  let category = categories.first(where: { $0.name == categoryName }) else { continue }

            let transaction = Transaction(
                id: UUID(),
                amount: type == .expense ? -abs(amount) : abs(amount),
                category: category,
                date: date,
                note: note,
                type: type
            )
            transactions.append(transaction)
        }
        saveToUserDefaults()
    }

    // MARK: - Statistics

    func weeklyData(lastWeeks: Int = 8) -> [(String, Double)] {
        let calendar = Calendar.current
        var result: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"

        for i in (0..<lastWeeks).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: Date()),
                  let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)),
                  let end = calendar.date(byAdding: .day, value: 7, to: start) else { continue }

            let weekExpenses = transactions
                .filter { $0.type == .expense && $0.date >= start && $0.date < end }
                .reduce(0) { $0 + abs($1.amount) }

            result.append((formatter.string(from: start), weekExpenses))
        }
        return result
    }

    func monthlyData(lastMonths: Int = 6) -> [(String, Double)] {
        let calendar = Calendar.current
        var result: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for i in (0..<lastMonths).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: Date()),
                  let start = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { continue }

            let monthExpenses = transactions
                .filter { $0.type == .expense && $0.date >= start && $0.date < end }
                .reduce(0) { $0 + abs($1.amount) }

            result.append((formatter.string(from: start), monthExpenses))
        }
        return result
    }
}

// MARK: - Supporting Types

enum TransactionType: String, Codable, CaseIterable {
    case income, expense
}

enum AccountType: String, Codable, CaseIterable {
    case cash, checking, savings, credit, investment
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly, monthly, yearly
}

struct Category: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let type: TransactionType

    enum CodingKeys: String, CodingKey {
        case id, name, icon, colorName, type
    }

    init(id: UUID, name: String, icon: String, color: Color, type: TransactionType) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        type = try container.decode(TransactionType.self, forKey: .type)

        let colorName = try container.decode(String.self, forKey: .colorName)
        color = Color(colorName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(type, forKey: .type)
        try container.encode(color.description, forKey: .colorName)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var balance: Double
    var type: AccountType
    var color: Color
    var notes: String = ""

    enum CodingKeys: String, CodingKey {
        case id, name, balance, type, colorName, notes
    }

    init(id: UUID = UUID(), name: String, balance: Double, type: AccountType, color: Color, notes: String = "") {
        self.id = id
        self.name = name
        self.balance = balance
        self.type = type
        self.color = color
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        balance = try container.decode(Double.self, forKey: .balance)
        type = try container.decode(AccountType.self, forKey: .type)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""

        let colorName = try container.decode(String.self, forKey: .colorName)
        color = Color(colorName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(balance, forKey: .balance)
        try container.encode(type, forKey: .type)
        try container.encode(notes, forKey: .notes)
        try container.encode(color.description, forKey: .colorName)
    }
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var category: Category
    var date: Date
    var note: String
    let type: TransactionType
    var accountId: UUID?
    var tags: [String] = []

    init(id: UUID = UUID(), amount: Double, category: Category, date: Date, note: String = "", type: TransactionType, accountId: UUID? = nil, tags: [String] = []) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.type = type
        self.accountId = accountId
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, categoryId, categoryName, categoryIcon, categoryColorName, categoryType, date, note, type, accountId, tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        type = try container.decode(TransactionType.self, forKey: .type)
        accountId = try container.decodeIfPresent(UUID.self, forKey: .accountId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []

        let categoryId = try container.decode(UUID.self, forKey: .categoryId)
        let categoryName = try container.decode(String.self, forKey: .categoryName)
        let categoryIcon = try container.decode(String.self, forKey: .categoryIcon)
        let categoryColorName = try container.decode(String.self, forKey: .categoryColorName)
        let categoryType = try container.decode(TransactionType.self, forKey: .categoryType)

        category = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(note, forKey: .note)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(accountId, forKey: .accountId)
        try container.encode(tags, forKey: .tags)

        try container.encode(category.id, forKey: .categoryId)
        try container.encode(category.name, forKey: .categoryName)
        try container.encode(category.icon, forKey: .categoryIcon)
        try container.encode(category.color.description, forKey: .categoryColorName)
        try container.encode(category.type, forKey: .categoryType)
    }
}

struct Budget: Identifiable, Codable {
    var id: UUID = UUID()
    var category: Category
    var amount: Double
    var period: BudgetPeriod = .monthly
    var rollover: Bool = false
    var alertThreshold: Double = 0.8

    enum CodingKeys: String, CodingKey {
        case id, categoryId, categoryName, categoryIcon, categoryColorName, categoryType, amount, period, rollover, alertThreshold
    }

    init(id: UUID = UUID(), category: Category, amount: Double, period: BudgetPeriod = .monthly, rollover: Bool = false, alertThreshold: Double = 0.8) {
        self.id = id
        self.category = category
        self.amount = amount
        self.period = period
        self.rollover = rollover
        self.alertThreshold = alertThreshold
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        period = try container.decodeIfPresent(BudgetPeriod.self, forKey: .period) ?? .monthly
        rollover = try container.decodeIfPresent(Bool.self, forKey: .rollover) ?? false
        alertThreshold = try container.decodeIfPresent(Double.self, forKey: .alertThreshold) ?? 0.8

        let categoryId = try container.decode(UUID.self, forKey: .categoryId)
        let categoryName = try container.decode(String.self, forKey: .categoryName)
        let categoryIcon = try container.decode(String.self, forKey: .categoryIcon)
        let categoryColorName = try container.decode(String.self, forKey: .categoryColorName)
        let categoryType = try container.decode(TransactionType.self, forKey: .categoryType)

        category = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(period, forKey: .period)
        try container.encode(rollover, forKey: .rollover)
        try container.encode(alertThreshold, forKey: .alertThreshold)

        try container.encode(category.id, forKey: .categoryId)
        try container.encode(category.name, forKey: .categoryName)
        try container.encode(category.icon, forKey: .categoryIcon)
        try container.encode(category.color.description, forKey: .categoryColorName)
        try container.encode(category.type, forKey: .categoryType)
    }
}

struct Goal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double = 0
    var deadline: Date?
    var icon: String = "star"
    var color: Color = .mint

    enum CodingKeys: String, CodingKey {
        case id, name, targetAmount, currentAmount, deadline, icon, colorName
    }

    init(id: UUID = UUID(), name: String, targetAmount: Double, currentAmount: Double = 0, deadline: Date? = nil, icon: String = "star", color: Color = .mint) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.icon = icon
        self.color = color
    }

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        targetAmount = try container.decode(Double.self, forKey: .targetAmount)
        currentAmount = try container.decodeIfPresent(Double.self, forKey: .currentAmount) ?? 0
        deadline = try container.decodeIfPresent(Date.self, forKey: .deadline)
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "star"

        let colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? "mint"
        color = Color(colorName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(targetAmount, forKey: .targetAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encodeIfPresent(deadline, forKey: .deadline)
        try container.encode(icon, forKey: .icon)
        try container.encode(color.description, forKey: .colorName)
    }
}

struct RecurringTransaction: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: Category
    var note: String
    let type: TransactionType
    var accountId: UUID?
    var frequency: RecurringFrequency = .monthly
    var startDate: Date
    var nextDate: Date?

    enum RecurringFrequency: String, Codable, CaseIterable {
        case daily, weekly, biweekly, monthly, yearly
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, categoryId, categoryName, categoryIcon, categoryColorName, categoryType, note, type, accountId, frequency, startDate, nextDate
    }

    init(id: UUID = UUID(), amount: Double, category: Category, note: String, type: TransactionType, accountId: UUID? = nil, frequency: RecurringFrequency = .monthly, startDate: Date = Date(), nextDate: Date? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.type = type
        self.accountId = accountId
        self.frequency = frequency
        self.startDate = startDate
        self.nextDate = nextDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        type = try container.decode(TransactionType.self, forKey: .type)
        accountId = try container.decodeIfPresent(UUID.self, forKey: .accountId)
        frequency = try container.decodeIfPresent(RecurringFrequency.self, forKey: .frequency) ?? .monthly
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        nextDate = try container.decodeIfPresent(Date.self, forKey: .nextDate)

        let categoryId = try container.decode(UUID.self, forKey: .categoryId)
        let categoryName = try container.decode(String.self, forKey: .categoryName)
        let categoryIcon = try container.decode(String.self, forKey: .categoryIcon)
        let categoryColorName = try container.decode(String.self, forKey: .categoryColorName)
        let categoryType = try container.decode(TransactionType.self, forKey: .categoryType)

        category = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(note, forKey: .note)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(accountId, forKey: .accountId)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(nextDate, forKey: .nextDate)

        try container.encode(category.id, forKey: .categoryId)
        try container.encode(category.name, forKey: .categoryName)
        try container.encode(category.icon, forKey: .categoryIcon)
        try container.encode(category.color.description, forKey: .categoryColorName)
        try container.encode(category.type, forKey: .categoryType)
    }

    func calculateNextDate() -> Date {
        let calendar = Calendar.current
        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: nextDate ?? startDate) ?? startDate
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: nextDate ?? startDate) ?? startDate
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: nextDate ?? startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: nextDate ?? startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: nextDate ?? startDate) ?? startDate
        }
    }
}

// MARK: - Codable Wrappers for persistence

private struct TransactionCodable: Codable {
    let id: UUID
    let amount: Double
    let categoryId: UUID
    let categoryName: String
    let categoryIcon: String
    let categoryColorName: String
    let categoryType: TransactionType
    let date: Date
    let note: String
    let type: TransactionType
    let accountId: UUID?
    let tags: [String]

    init(_ t: Transaction) {
        self.id = t.id
        self.amount = t.amount
        self.categoryId = t.category.id
        self.categoryName = t.category.name
        self.categoryIcon = t.category.icon
        self.categoryColorName = t.category.color.description
        self.categoryType = t.category.type
        self.date = t.date
        self.note = t.note
        self.type = t.type
        self.accountId = t.accountId
        self.tags = t.tags
    }

    func toTransaction(categories: [Category]) -> Transaction {
        let cat = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
        return Transaction(id: id, amount: amount, category: cat, date: date, note: note, type: type, accountId: accountId, tags: tags)
    }
}

private struct AccountCodable: Codable {
    let id: UUID
    let name: String
    let balance: Double
    let type: AccountType
    let colorName: String
    let notes: String

    init(_ a: Account) {
        self.id = a.id
        self.name = a.name
        self.balance = a.balance
        self.type = a.type
        self.colorName = a.color.description
        self.notes = a.notes
    }

    func toAccount() -> Account {
        Account(id: id, name: name, balance: balance, type: type, color: Color(colorName), notes: notes)
    }
}

private struct BudgetCodable: Codable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    let categoryIcon: String
    let categoryColorName: String
    let categoryType: TransactionType
    let amount: Double
    let period: BudgetPeriod
    let rollover: Bool
    let alertThreshold: Double

    init(_ b: Budget) {
        self.id = b.id
        self.categoryId = b.category.id
        self.categoryName = b.category.name
        self.categoryIcon = b.category.icon
        self.categoryColorName = b.category.color.description
        self.categoryType = b.category.type
        self.amount = b.amount
        self.period = b.period
        self.rollover = b.rollover
        self.alertThreshold = b.alertThreshold
    }

    func toBudget(categories: [Category]) -> Budget {
        let cat = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
        return Budget(id: id, category: cat, amount: amount, period: period, rollover: rollover, alertThreshold: alertThreshold)
    }
}

private struct GoalCodable: Codable {
    let id: UUID
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let deadline: Date?
    let icon: String
    let colorName: String

    init(_ g: Goal) {
        self.id = g.id
        self.name = g.name
        self.targetAmount = g.targetAmount
        self.currentAmount = g.currentAmount
        self.deadline = g.deadline
        self.icon = g.icon
        self.colorName = g.color.description
    }

    func toGoal() -> Goal {
        Goal(id: id, name: name, targetAmount: targetAmount, currentAmount: currentAmount, deadline: deadline, icon: icon, color: Color(colorName))
    }
}

private struct RecurringCodable: Codable {
    let id: UUID
    let amount: Double
    let categoryId: UUID
    let categoryName: String
    let categoryIcon: String
    let categoryColorName: String
    let categoryType: TransactionType
    let note: String
    let type: TransactionType
    let accountId: UUID?
    let frequency: RecurringTransaction.RecurringFrequency
    let startDate: Date
    let nextDate: Date?

    init(_ r: RecurringTransaction) {
        self.id = r.id
        self.amount = r.amount
        self.categoryId = r.category.id
        self.categoryName = r.category.name
        self.categoryIcon = r.category.icon
        self.categoryColorName = r.category.color.description
        self.categoryType = r.category.type
        self.note = r.note
        self.type = r.type
        self.accountId = r.accountId
        self.frequency = r.frequency
        self.startDate = r.startDate
        self.nextDate = r.nextDate
    }

    func toRecurring(categories: [Category]) -> RecurringTransaction {
        let cat = Category(id: categoryId, name: categoryName, icon: categoryIcon, color: Color(categoryColorName), type: categoryType)
        return RecurringTransaction(id: id, amount: amount, category: cat, note: note, type: type, accountId: accountId, frequency: frequency, startDate: startDate, nextDate: nextDate)
    }
}