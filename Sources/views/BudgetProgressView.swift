import SwiftUI

struct BudgetProgressView: View {
    @EnvironmentObject var store: AppStore
    @State private var showBudgets = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Budget Progress")
                    .font(.headline)

                Spacer()

                Button {
                    showBudgets = true
                } label: {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.mint)
                }
            }

            if store.budgets.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.title)
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("No budgets set")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Create Budget") {
                        showBudgets = true
                    }
                    .font(.caption)
                    .foregroundColor(.mint)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(store.budgets.prefix(3)) { budget in
                    BudgetMiniCard(budget: budget)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showBudgets) {
            BudgetsView()
        }
    }
}

struct BudgetMiniCard: View {
    @EnvironmentObject var store: AppStore
    let budget: Budget

    var spent: Double {
        store.spentAmount(for: budget.category, in: budget.period)
    }

    var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(spent / budget.amount, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: budget.category.icon)
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(budget.category.color.opacity(0.12))
                    .foregroundColor(budget.category.color)
                    .clipShape(Circle())

                Text(budget.category.name)
                    .font(.caption)
                    .lineLimit(1)

                Spacer()

                Text(formatCurrency(spent) + " / " + formatCurrency(budget.amount))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(progress > 1 ? Color.red : budget.category.color)
                        .frame(width: geo.size.width * min(progress, 1), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 4)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.0f", amount)
    }
}

struct GoalsOverviewCard: View {
    @EnvironmentObject var store: AppStore
    @Binding var showGoals: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)

                Spacer()

                Button {
                    showGoals = true
                } label: {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.mint)
                }
            }

            if store.goals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.title)
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("No goals set")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Create Goal") {
                        showGoals = true
                    }
                    .font(.caption)
                    .foregroundColor(.mint)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(store.goals.prefix(2)) { goal in
                    GoalMiniCard(goal: goal)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct GoalMiniCard: View {
    let goal: Goal

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: goal.icon)
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(goal.color.opacity(0.12))
                    .foregroundColor(goal.color)
                    .clipShape(Circle())

                Text(goal.name)
                    .font(.caption)
                    .lineLimit(1)

                Spacer()

                Text(formatCurrency(goal.currentAmount))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(goal.color)
                        .frame(width: geo.size.width * goal.progress, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)

            HStack {
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatCurrency(goal.targetAmount))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.0f", amount)
    }
}

#Preview {
    VStack {
        BudgetProgressView()
        GoalsOverviewCard(showGoals: .constant(false))
    }
    .padding()
    .environmentObject(AppStore())
}