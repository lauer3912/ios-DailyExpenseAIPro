import SwiftUI

struct TransferView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var amount: String = ""
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var note: String = ""

    var isValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        guard let from = fromAccount, let to = toAccount else { return false }
        guard from.id != to.id else { return false }
        return from.balance >= amountValue
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Amount
                VStack(spacing: 8) {
                    Text("Transfer Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(alignment: .center, spacing: 4) {
                        Text("$")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)

                        TextField("0.00", text: $amount)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                // From Account
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.accounts) { account in
                                AccountSelectButton(
                                    account: account,
                                    isSelected: fromAccount?.id == account.id
                                ) {
                                    fromAccount = account
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // To Account
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.accounts.filter { $0.id != fromAccount?.id }) { account in
                                AccountSelectButton(
                                    account: account,
                                    isSelected: toAccount?.id == account.id
                                ) {
                                    toAccount = account
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Transfer note...", text: $note)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Preview
                if let from = fromAccount, let to = toAccount, let amountValue = Double(amount), amountValue > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("From")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(from.name)
                                .fontWeight(.medium)
                            Text(formatCurrency(from.balance))
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("To")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(to.name)
                                .fontWeight(.medium)
                            Text(formatCurrency(to.balance))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        HStack {
                            Text("After Transfer")
                                .fontWeight(.medium)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(from.name + ": " + formatCurrency(from.balance - amountValue))
                                    .font(.caption)
                                Text(to.name + ": " + formatCurrency(to.balance + amountValue))
                                    .font(.caption)
                            }
                        }
                    }
                    .font(.caption)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Warning if insufficient
                    if from.balance < amountValue {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Insufficient funds in \(from.name)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                Button {
                    transfer()
                } label: {
                    Text("Transfer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .cornerRadius(16)
                }
                .padding()
                .disabled(!isValid)
            }
            .padding(.top)
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if fromAccount == nil {
                    fromAccount = store.accounts.first
                }
                if toAccount == nil {
                    toAccount = store.accounts.dropFirst().first ?? store.accounts.first
                }
            }
        }
    }

    func transfer() {
        guard let from = fromAccount,
              let to = toAccount,
              let amountValue = Double(amount), amountValue > 0 else { return }

        store.transfer(from: from, to: to, amount: amountValue)
        dismiss()
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

struct AccountSelectButton: View {
    let account: Account
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(account.color)
                    .frame(width: 12, height: 12)

                Text(account.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)

                Text(formatCurrency(account.balance))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.15) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

#Preview {
    TransferView()
        .environmentObject(AppStore())
}