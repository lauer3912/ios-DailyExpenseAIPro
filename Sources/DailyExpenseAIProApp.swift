import SwiftUI

@main
struct DailyExpenseAIProApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}

class AppStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var goals: [Goal] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Default categories
        categories = [
            Category(id: UUID(), name: "Food & Dining", icon: "fork.knife", color: .red, type: .expense),
            Category(id: UUID(), name: "Transportation", icon: "car", color: .blue, type: .expense),
            Category(id: UUID(), name: "Shopping", icon: "bag", color: .purple, type: .expense),
            Category(id: UUID(), name: "Entertainment", icon: "ticket", color: .orange, type: .expense),
            Category(id: UUID(), name: "Bills", icon: "doc.text", color: .teal, type: .expense),
            Category(id: UUID(), name: "Healthcare", icon: "bandage", color: .pink, type: .expense),
            Category(id: UUID(), name: "Salary", icon: "dollarsign.circle", color: .green, type: .income),
            Category(id: UUID(), name: "Freelance", icon: "briefcase", color: .mint, type: .income),
            Category(id: UUID(), name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .cyan, type: .income),
        ]
        
        // Default accounts
        accounts = [
            Account(id: UUID(), name: "Cash", balance: 500.0, type: .cash),
            Account(id: UUID(), name: "Checking", balance: 2500.0, type: .checking),
            Account(id: UUID(), name: "Savings", balance: 10000.0, type: .savings),
        ]
        
        // Sample transactions
        transactions = [
            Transaction(id: UUID(), amount: -45.50, category: categories[0], date: Date().addingTimeInterval(-86400), note: "Dinner at restaurant", type: .expense),
            Transaction(id: UUID(), amount: -120.00, category: categories[1], date: Date().addingTimeInterval(-172800), note: "Gas refill", type: .expense),
            Transaction(id: UUID(), amount: 2500.00, category: categories[6], date: Date().addingTimeInterval(-259200), note: "Monthly salary", type: .income),
        ]
    }
    
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
}

// MARK: - Models

enum TransactionType: String, CaseIterable {
    case income, expense
}

enum AccountType: String, CaseIterable {
    case cash, checking, savings, credit, investment
}

struct Category: Identifiable, Equatable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let type: TransactionType
}

struct Account: Identifiable {
    let id: UUID
    var name: String
    var balance: Double
    var type: AccountType
}

struct Transaction: Identifiable {
    let id: UUID
    var amount: Double
    var category: Category
    var date: Date
    var note: String = ""
    let type: TransactionType
}

struct Budget {
    var id: UUID = UUID()
    var category: Category
    var amount: Double
    var spent: Double = 0
}

struct Goal {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double = 0
    var deadline: Date?
}