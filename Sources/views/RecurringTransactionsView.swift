import SwiftUI

struct RecurringTransactionsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddRecurring = false
    @State private var recurringToEdit: RecurringTransaction?

    var body: some View {
        NavigationStack {
            List {
                if store.recurringTransactions.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "repeat")
                                .font(.largeTitle)
                                .foregroundColor(.secondary.opacity(0.5))

                            Text("No Recurring Transactions")
                                .font(.headline)

                            Text("Set up recurring transactions for regular income or expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button("Add Recurring") {
                                showAddRecurring = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                } else {
                    Section {
                        ForEach(store.recurringTransactions) { recurring in
                            RecurringRow(recurring: recurring)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    recurringToEdit = recurring
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.deleteRecurringTransaction(recurring)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text("Active Recurring Transactions")
                    }
                }
            }
            .navigationTitle("Recurring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddRecurring = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddRecurring) {
                AddRecurringView(recurring: nil)
            }
            .sheet(item: $recurringToEdit) { recurring in
                AddRecurringView(recurring: recurring)
            }
        }
    }
}

struct RecurringRow: View {
    let recurring: RecurringTransaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: recurring.category.icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(recurring.category.color.opacity(0.12))
                .foregroundColor(recurring.category.color)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(recurring.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .font(.caption2)
                    Text(recurring.frequency.rawValue.capitalized)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                if !recurring.note.isEmpty {
                    Text(recurring.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(recurring.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(recurring.type == .income ? .green : .red)

                Text(recurring.type == .income ? "Income" : "Expense")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct AddRecurringView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let recurring: RecurringTransaction?

    @State private var amount: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var note: String = ""
    @State private var frequency: RecurringTransaction.RecurringFrequency = .monthly

    var isEditing: Bool { recurring != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Amount")
                        Spacer()
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(RecurringTransaction.RecurringFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue.capitalized).tag(freq)
                        }
                    }
                } header: {
                    Text("Schedule")
                }

                Section {
                    if !isEditing {
                        // Category
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
                                }
                            }
                        }

                        // Account
                        Picker("Account", selection: $selectedAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(store.accounts) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                    }
                }

                Section {
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle(isEditing ? "Edit Recurring" : "New Recurring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecurring()
                    }
                    .disabled(amount.isEmpty)
                }
            }
            .onAppear {
                if let recurring = recurring {
                    amount = String(format: "%.2f", recurring.amount)
                    selectedType = recurring.type
                    selectedCategory = recurring.category
                    selectedAccount = store.accounts.first { $0.id == recurring.accountId }
                    note = recurring.note
                    frequency = recurring.frequency
                }
            }
        }
    }

    func saveRecurring() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }

        let newRecurring = RecurringTransaction(
            id: recurring?.id ?? UUID(),
            amount: amountValue,
            category: selectedCategory ?? recurring!.category,
            note: note,
            type: selectedType,
            accountId: selectedAccount?.id,
            frequency: frequency,
            startDate: Date(),
            nextDate: Date()
        )

        if isEditing {
            store.deleteRecurringTransaction(recurring!)
            store.addRecurringTransaction(newRecurring)
        } else {
            store.addRecurringTransaction(newRecurring)
        }
        dismiss()
    }
}

#Preview {
    RecurringTransactionsView()
        .environmentObject(AppStore())
}