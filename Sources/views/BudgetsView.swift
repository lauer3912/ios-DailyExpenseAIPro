import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddBudget = false
    @State private var budgetToEdit: Budget?
    @State private var selectedPeriod: BudgetPeriod = .monthly

    var body: some View {
        NavigationStack {
            List {
                // Overview
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Budgeted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatCurrency(totalBudgeted))
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total Spent")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatCurrency(totalSpent))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(totalSpent > totalBudgeted ? .red : .primary)
                            }
                        }

                        // Overall progress
                        VStack(spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 8)
                                        .cornerRadius(4)

                                    Rectangle()
                                        .fill(overallProgress > 1 ? Color.red : Color.mint)
                                        .frame(width: geo.size.width * min(overallProgress, 1), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)

                            HStack {
                                Text("\(Int(overallProgress * 100))% used")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if overallProgress > 1 {
                                    Text("Over budget by " + formatCurrency(totalSpent - totalBudgeted))
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Period Filter
                Section {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue.capitalized).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Budget Cards
                Section {
                    if filteredBudgets.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.largeTitle)
                                .foregroundColor(.secondary.opacity(0.5))

                            Text("No Budgets Set")
                                .font(.headline)

                            Text("Add budgets to track your spending by category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button("Create Budget") {
                                showAddBudget = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(filteredBudgets) { budget in
                            BudgetCard(budget: budget)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    budgetToEdit = budget
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.deleteBudget(budget)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } header: {
                    Text("Category Budgets")
                }

                // Quick Stats
                if !filteredBudgets.isEmpty {
                    Section {
                        HStack {
                            StatBox(title: "Active", value: "\(filteredBudgets.count)", color: .mint)
                            StatBox(title: "On Track", value: "\(onTrackCount)", color: .green)
                            StatBox(title: "Over", value: "\(overBudgetCount)", color: .red)
                        }
                        .frame(height: 60)
                    }
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddEditBudgetView(budget: nil)
            }
            .sheet(item: $budgetToEdit) { budget in
                AddEditBudgetView(budget: budget)
            }
        }
    }

    var filteredBudgets: [Budget] {
        store.budgets.filter { $0.period == selectedPeriod }
    }

    var totalBudgeted: Double {
        filteredBudgets.reduce(0) { $0 + $1.amount }
    }

    var totalSpent: Double {
        filteredBudgets.reduce(0) { $0 + store.spentAmount(for: $1.category, in: $1.period) }
    }

    var overallProgress: Double {
        guard totalBudgeted > 0 else { return 0 }
        return totalSpent / totalBudgeted
    }

    var onTrackCount: Int {
        filteredBudgets.filter { budget in
            let spent = store.spentAmount(for: budget.category, in: budget.period)
            return spent <= budget.amount
        }.count
    }

    var overBudgetCount: Int {
        filteredBudgets.filter { budget in
            let spent = store.spentAmount(for: budget.category, in: budget.period)
            return spent > budget.amount
        }.count
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct BudgetCard: View {
    @EnvironmentObject var store: AppStore
    let budget: Budget

    var spent: Double {
        store.spentAmount(for: budget.category, in: budget.period)
    }

    var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(spent / budget.amount, 1.5)
    }

    var isOverBudget: Bool {
        spent > budget.amount
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: budget.category.icon)
                        .frame(width: 28, height: 28)
                        .background(budget.category.color.opacity(0.12))
                        .foregroundColor(budget.category.color)
                        .clipShape(Circle())

                    Text(budget.category.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(spent))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isOverBudget ? .red : .primary)

                    Text("of " + formatCurrency(budget.amount))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(isOverBudget ? Color.red : budget.category.color)
                        .frame(width: geo.size.width * min(progress, 1), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(Int(progress * 100))% used")
                    .font(.caption2)
                    .foregroundColor(isOverBudget ? .red : .secondary)

                Spacer()

                if isOverBudget {
                    Text("Over by " + formatCurrency(spent - budget.amount))
                        .font(.caption2)
                        .foregroundColor(.red)
                } else {
                    Text(formatCurrency(budget.amount - spent) + " remaining")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Rollover indicator
            if budget.rollover {
                HStack {
                    Image(systemName: "arrow.repeat")
                        .font(.caption2)
                    Text("Budget rolls over")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AddEditBudgetView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let budget: Budget?

    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var period: BudgetPeriod = .monthly
    @State private var rollover: Bool = false
    @State private var alertThreshold: Double = 0.8

    var isEditing: Bool { budget != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if !isEditing {
                        // Category picker
                        NavigationLink {
                            CategoryPickerView(selectedCategory: $selectedCategory)
                        } label: {
                            HStack {
                                Text("Category")
                                Spacer()
                                if let cat = selectedCategory {
                                    HStack(spacing: 6) {
                                        Image(systemName: cat.icon)
                                            .foregroundColor(cat.color)
                                        Text(cat.name)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("Select")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Amount
                        HStack {
                            Text("Budget Amount")
                            Spacer()
                            Text("$")
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }

                        // Period
                        Picker("Period", selection: $period) {
                            ForEach(BudgetPeriod.allCases, id: \.self) { p in
                                Text(p.rawValue.capitalized).tag(p)
                            }
                        }
                    } else {
                        // Editing mode shows details
                        HStack {
                            Image(systemName: budget!.category.icon)
                                .foregroundColor(budget!.category.color)
                            Text(budget!.category.name)
                        }

                        HStack {
                            Text("Amount")
                            Spacer()
                            Text("$" + String(format: "%.2f", budget!.amount))
                        }

                        HStack {
                            Text("Period")
                            Spacer()
                            Text(budget!.period.rawValue.capitalized)
                        }
                    }
                }

                Section {
                    Toggle("Rollover Unused Budget", isOn: $rollover)
                } footer: {
                    Text("When enabled, any unused budget will carry over to the next period.")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alert Threshold: \(Int(alertThreshold * 100))%")

                        Slider(value: $alertThreshold, in: 0.5...1.0, step: 0.05)
                            .tint(.mint)

                        Text("You'll be notified when spending reaches this percentage of your budget")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Notifications")
                }
            }
            .navigationTitle(isEditing ? "Edit Budget" : "New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isEditing && (selectedCategory == nil || amount.isEmpty))
                }
            }
            .onAppear {
                if let budget = budget {
                    selectedCategory = budget.category
                    amount = String(format: "%.2f", budget.amount)
                    period = budget.period
                    rollover = budget.rollover
                    alertThreshold = budget.alertThreshold
                }
            }
        }
    }

    func saveBudget() {
        guard let category = selectedCategory ?? budget?.category,
              let amountValue = Double(amount), amountValue > 0 else { return }

        let newBudget = Budget(
            id: budget?.id ?? UUID(),
            category: category,
            amount: amountValue,
            period: period,
            rollover: rollover,
            alertThreshold: alertThreshold
        )
        store.setBudget(newBudget)
        dismiss()
    }
}

struct CategoryPickerView: View {
    @EnvironmentObject var store: AppStore
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(store.categories.filter { $0.type == .expense }) { category in
                Button {
                    selectedCategory = category
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .frame(width: 32, height: 32)
                            .background(category.color.opacity(0.12))
                            .foregroundColor(category.color)
                            .clipShape(Circle())

                        Text(category.name)
                            .foregroundColor(.primary)

                        Spacer()

                        if selectedCategory?.id == category.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.mint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Category")
    }
}

#Preview {
    BudgetsView()
        .environmentObject(AppStore())
}