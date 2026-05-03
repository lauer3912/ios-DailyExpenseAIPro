import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddGoal = false
    @State private var goalToEdit: Goal?
    @State private var showContribute: Bool = false
    @State private var selectedGoal: Goal?

    var body: some View {
        NavigationStack {
            List {
                // Summary
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Saved")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatCurrency(totalSaved))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.mint)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total Target")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatCurrency(totalTarget))
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }

                        // Overall progress
                        VStack(spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 10)
                                        .cornerRadius(5)

                                    Rectangle()
                                        .fill(Color.mint.gradient)
                                        .frame(width: geo.size.width * overallProgress, height: 10)
                                        .cornerRadius(5)
                                }
                            }
                            .frame(height: 10)

                            Text("\(Int(overallProgress * 100))% of total goals achieved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Goals List
                Section {
                    if store.goals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "star")
                                .font(.largeTitle)
                                .foregroundColor(.secondary.opacity(0.5))

                            Text("No Savings Goals")
                                .font(.headline)

                            Text("Create goals to track your savings progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button("Create Goal") {
                                showAddGoal = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(store.goals) { goal in
                            GoalCard(goal: goal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    goalToEdit = goal
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedGoal = goal
                                        showContribute = true
                                    } label: {
                                        Label("Add", systemImage: "plus.circle")
                                    }
                                    .tint(.mint)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.deleteGoal(goal)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } header: {
                    Text("Savings Goals")
                }

                // Quick Stats
                if !store.goals.isEmpty {
                    Section {
                        HStack {
                            StatBox(title: "Active", value: "\(activeGoals)", color: .mint)
                            StatBox(title: "Completed", value: "\(completedGoals)", color: .green)
                            StatBox(title: "Near Goal", value: "\(nearGoalCount)", color: .orange)
                        }
                        .frame(height: 60)
                    }
                }
            }
            .navigationTitle("Savings Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddEditGoalView(goal: nil)
            }
            .sheet(item: $goalToEdit) { goal in
                AddEditGoalView(goal: goal)
            }
            .sheet(isPresented: $showContribute) {
                if let goal = selectedGoal {
                    ContributeToGoalView(goal: goal)
                }
            }
        }
    }

    var totalSaved: Double {
        store.goals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        store.goals.reduce(0) { $0 + $1.targetAmount }
    }

    var overallProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return min(totalSaved / totalTarget, 1.0)
    }

    var activeGoals: Int {
        store.goals.filter { $0.currentAmount < $0.targetAmount }.count
    }

    var completedGoals: Int {
        store.goals.filter { $0.currentAmount >= $0.targetAmount }.count
    }

    var nearGoalCount: Int {
        store.goals.filter { $0.progress >= 0.8 && $0.currentAmount < $0.targetAmount }.count
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct GoalCard: View {
    @EnvironmentObject var store: AppStore
    let goal: Goal

    var isCompleted: Bool {
        goal.currentAmount >= goal.targetAmount
    }

    var daysRemaining: Int? {
        guard let deadline = goal.deadline else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(0, days)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: goal.icon)
                        .frame(width: 28, height: 28)
                        .background(goal.color.opacity(0.12))
                        .foregroundColor(goal.color)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if let deadline = goal.deadline {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                if let days = daysRemaining {
                                    Text("\(days) days left")
                                        .font(.caption2)
                                } else {
                                    Text(formatDate(deadline))
                                        .font(.caption2)
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(goal.currentAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isCompleted ? .green : .primary)

                    Text("of " + formatCurrency(goal.targetAmount))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(isCompleted ? Color.green : goal.color)
                        .frame(width: geo.size.width * goal.progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(goal.progress * 100))% complete")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatCurrency(goal.remainingAmount) + " to go")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Goal Achieved!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AddEditGoalView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let goal: Goal?

    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var currentAmount: String = "0"
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Date().addingTimeInterval(86400 * 30)
    @State private var icon: String = "star"
    @State private var color: Color = .mint

    let icons = ["star", "house", "car", "airplane", "gift", "heart", "book", "graduationcap", "briefcase", "dollarsign.circle", "creditcard", "bag"]
    let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .blue, .indigo, .purple, .pink]

    var isEditing: Bool { goal != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal Name", text: $name)

                    HStack {
                        Text("Target Amount")
                        Spacer()
                        Text("$")
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    if isEditing {
                        HStack {
                            Text("Current Savings")
                            Spacer()
                            Text("$")
                            TextField("0.00", text: $currentAmount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }

                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(icons, id: \.self) { iconName in
                            Image(systemName: iconName)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(icon == iconName ? color : Color(.systemGray5))
                                .foregroundColor(icon == iconName ? .white : .primary)
                                .clipShape(Circle())
                                .onTapGesture {
                                    icon = iconName
                                }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Icon")
                }

                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colors, id: \.self) { col in
                            Circle()
                                .fill(col)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(color == col ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    color = col
                                }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle(isEditing ? "Edit Goal" : "New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
            }
            .onAppear {
                if let goal = goal {
                    name = goal.name
                    targetAmount = String(format: "%.2f", goal.targetAmount)
                    currentAmount = String(format: "%.2f", goal.currentAmount)
                    hasDeadline = goal.deadline != nil
                    deadline = goal.deadline ?? Date().addingTimeInterval(86400 * 30)
                    icon = goal.icon
                    color = goal.color
                }
            }
        }
    }

    func saveGoal() {
        guard let target = Double(targetAmount), target > 0 else { return }
        let current = Double(currentAmount) ?? 0

        let newGoal = Goal(
            id: goal?.id ?? UUID(),
            name: name,
            targetAmount: target,
            currentAmount: isEditing ? current : 0,
            deadline: hasDeadline ? deadline : nil,
            icon: icon,
            color: color
        )

        if isEditing {
            store.updateGoal(newGoal)
        } else {
            store.addGoal(newGoal)
        }
        dismiss()
    }
}

struct ContributeToGoalView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let goal: Goal

    @State private var amount: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Goal info
                VStack(spacing: 8) {
                    Image(systemName: goal.icon)
                        .font(.largeTitle)
                        .frame(width: 80, height: 80)
                        .background(goal.color.opacity(0.12))
                        .foregroundColor(goal.color)
                        .clipShape(Circle())

                    Text(goal.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(formatCurrency(goal.currentAmount) + " of " + formatCurrency(goal.targetAmount))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Progress
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                                .cornerRadius(4)

                            Rectangle()
                                .fill(goal.color)
                                .frame(width: geo.size.width * goal.progress, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(goal.progress * 100))% complete · " + formatCurrency(goal.remainingAmount) + " to go")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                // Amount input
                VStack(spacing: 8) {
                    Text("Add to Savings")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("$")
                            .font(.system(size: 36, weight: .bold))
                        TextField("0", text: $amount)
                            .font(.system(size: 36, weight: .bold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 250)

                    // Quick amounts
                    HStack(spacing: 12) {
                        ForEach([10.0, 25.0, 50.0, 100.0], id: \.self) { quickAmount in
                            Button {
                                amount = String(format: "%.0f", quickAmount)
                            } label: {
                                Text("$" + String(format: "%.0f", quickAmount))
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()

                Spacer()

                // Save button
                Button {
                    if let amt = Double(amount), amt > 0 {
                        store.contributeToGoal(goal, amount: amt)
                    }
                    dismiss()
                } label: {
                    Text("Add Savings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .cornerRadius(16)
                }
                .padding()
                .disabled(amount.isEmpty || Double(amount) == nil)
            }
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

#Preview {
    GoalsView()
        .environmentObject(AppStore())
}