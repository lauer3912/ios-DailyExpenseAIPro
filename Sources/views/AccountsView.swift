import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddAccount = false
    @State private var accountToEdit: Account?

    var body: some View {
        NavigationStack {
            List {
                // Total Balance
                Section {
                    HStack {
                        Text("Total Net Worth")
                            .font(.headline)
                        Spacer()
                        Text(formatCurrency(store.totalBalance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(store.totalBalance >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 8)
                }

                // Asset Accounts
                Section {
                    ForEach(assetAccounts) { account in
                        AccountRow(account: account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                accountToEdit = account
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deleteAccount(account)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }

                    if assetAccounts.isEmpty {
                        Text("No asset accounts")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                } header: {
                    Text("Assets")
                }

                // Liability Accounts
                Section {
                    ForEach(liabilityAccounts) { account in
                        AccountRow(account: account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                accountToEdit = account
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deleteAccount(account)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }

                    if liabilityAccounts.isEmpty {
                        Text("No liability accounts")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                } header: {
                    Text("Liabilities")
                }

                // Summary
                Section {
                    SummaryRow(title: "Total Assets", value: formatCurrency(totalAssets), color: .green)
                    SummaryRow(title: "Total Liabilities", value: formatCurrency(totalLiabilities), color: .red)
                    SummaryRow(title: "Net Worth", value: formatCurrency(store.totalBalance), color: store.totalBalance >= 0 ? .green : .red)
                } header: {
                    Text("Summary")
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddEditAccountView(account: nil) { newAccount in
                    store.addAccount(newAccount)
                }
            }
            .sheet(item: $accountToEdit) { account in
                AddEditAccountView(account: account) { updatedAccount in
                    store.updateAccount(updatedAccount)
                }
            }
        }
    }

    var assetAccounts: [Account] {
        store.accounts.filter { $0.balance >= 0 }
    }

    var liabilityAccounts: [Account] {
        store.accounts.filter { $0.balance < 0 }
    }

    var totalAssets: Double {
        assetAccounts.reduce(0) { $0 + $1.balance }
    }

    var totalLiabilities: Double {
        abs(liabilityAccounts.reduce(0) { $0 + $1.balance })
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(account.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(account.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(account.balance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(account.balance >= 0 ? .green : .red)

                if !account.notes.isEmpty {
                    Text(account.notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", abs(amount))
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct AddEditAccountView: View {
    @Environment(\.dismiss) var dismiss
    let account: Account?
    let onSave: (Account) -> Void

    @State private var name: String = ""
    @State private var balance: String = ""
    @State private var type: AccountType = .checking
    @State private var color: Color = .blue
    @State private var notes: String = ""

    let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .blue, .indigo, .purple, .pink]

    var isEditing: Bool { account != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Account Name", text: $name)

                    HStack {
                        Text("$")
                        TextField("0.00", text: $balance)
                            .keyboardType(.decimalPad)
                    }
                }

                Section {
                    Picker("Account Type", selection: $type) {
                        ForEach(AccountType.allCases, id: \.self) { accType in
                            Text(accType.rawValue.capitalized).tag(accType)
                        }
                    }
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

                Section {
                    TextField("Notes (optional)", text: $notes)
                }
            }
            .navigationTitle(isEditing ? "Edit Account" : "New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let account = account {
                    name = account.name
                    balance = String(format: "%.2f", abs(account.balance))
                    type = account.type
                    color = account.color
                    notes = account.notes
                }
            }
        }
    }

    func saveAccount() {
        let balanceValue = Double(balance) ?? 0
        let isLiability = type == .credit || type == .investment
        let finalBalance = isLiability ? -abs(balanceValue) : balanceValue

        let newAccount = Account(
            id: account?.id ?? UUID(),
            name: name,
            balance: finalBalance,
            type: type,
            color: color,
            notes: notes
        )
        onSave(newAccount)
        dismiss()
    }
}

#Preview {
    AccountsView()
        .environmentObject(AppStore())
}