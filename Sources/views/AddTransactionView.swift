import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var date: Date = Date()
    @State private var showDatePicker = false
    @State private var showCategoryPicker = false
    @State private var isRecurring = false
    @State private var recurringFrequency: RecurringTransaction.RecurringFrequency = .monthly

    @FocusState private var isAmountFocused: Bool

    var isValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        return selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Type Toggle
                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Amount Input
                    VStack(spacing: 8) {
                        Text("Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(alignment: .center, spacing: 4) {
                            Text("$")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(selectedType == .income ? .green : .red)

                            TextField("0.00", text: $amount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .focused($isAmountFocused)
                                .foregroundColor(selectedType == .income ? .green : .primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Category Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80), spacing: 12)
                        ], spacing: 12) {
                            ForEach(filteredCategories) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Account Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(store.accounts) { account in
                                    AccountButton(
                                        account: account,
                                        isSelected: selectedAccount?.id == account.id
                                    ) {
                                        selectedAccount = account
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.mint)
                                Text(date, style: .date)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        if showDatePicker {
                            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Add a note...", text: $note)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Recurring Toggle
                    Toggle(isOn: $isRecurring) {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.purple)
                            Text("Recurring Transaction")
                                .font(.subheadline)
                        }
                    }
                    .tint(.mint)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    if isRecurring {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker("Frequency", selection: $recurringFrequency) {
                                ForEach(RecurringTransaction.RecurringFrequency.allCases, id: \.self) { freq in
                                    Text(freq.rawValue.capitalized).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                selectedAccount = store.accounts.first
                if let firstCat = filteredCategories.first {
                    selectedCategory = firstCat
                }
            }
        }
    }

    var filteredCategories: [Category] {
        store.categories.filter { $0.type == selectedType }
    }

    func saveTransaction() {
        guard let category = selectedCategory,
              let amountValue = Double(amount), amountValue > 0 else { return }

        let finalAmount = selectedType == .income ? amountValue : -amountValue

        let transaction = Transaction(
            id: UUID(),
            amount: finalAmount,
            category: category,
            date: date,
            note: note,
            type: selectedType,
            accountId: selectedAccount?.id
        )

        store.addTransaction(transaction, toAccount: selectedAccount ?? store.accounts.first)

        if isRecurring {
            let recurring = RecurringTransaction(
                amount: amountValue,
                category: category,
                note: note,
                type: selectedType,
                accountId: selectedAccount?.id,
                frequency: recurringFrequency,
                startDate: date,
                nextDate: date
            )
            store.addRecurringTransaction(recurring)
        }

        dismiss()
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? category.color : category.color.opacity(0.12))
                    .foregroundColor(isSelected ? .white : category.color)
                    .clipShape(Circle())

                Text(category.name)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AccountButton: View {
    let account: Account
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(account.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.caption)
                        .fontWeight(.medium)

                    Text(formatCurrency(account.balance))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.mint.opacity(0.15) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mint : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(AppStore())
}