import SwiftUI

struct QuickActionsCard: View {
    @EnvironmentObject var store: AppStore
    @Binding var showTransferSheet: Bool
    @State private var selectedType: TransactionType = .expense

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Income",
                    systemIcon: "plus.circle.fill",
                    color: .green
                ) {
                    selectedType = .income
                }

                QuickActionButton(
                    title: "Expense",
                    systemIcon: "minus.circle.fill",
                    color: .red
                ) {
                    selectedType = .expense
                }

                QuickActionButton(
                    title: "Transfer",
                    systemIcon: "arrow.left.arrow.right.circle.fill",
                    color: .blue
                ) {
                    showTransferSheet = true
                }

                QuickActionButton(
                    title: "Recurring",
                    systemIcon: "repeat.circle.fill",
                    color: .purple
                ) {
                    // handled elsewhere
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let systemIcon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemIcon)
                    .font(.title2)
                    .padding(14)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .clipShape(Circle())

                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct RecentTransactionsCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    TransactionListView()
                } label: {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.mint)
                }
            }

            if store.transactions.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Transactions Yet",
                    message: "Tap the + button to add your first transaction"
                )
            } else {
                ForEach(Array(store.transactions.sorted { $0.date > $1.date }.prefix(5))) { transaction in
                    TransactionRow(transaction: transaction)
                    if transaction.id != store.transactions.sorted(by: { $0.date > $1.date }).prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    private var formattedAmount: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)$" + String(format: "%.2f", abs(transaction.amount))
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: transaction.date, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(transaction.category.color.opacity(0.12))
                .foregroundColor(transaction.category.color)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    if !transaction.note.isEmpty {
                        Text(transaction.note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Text("·")
                            .foregroundColor(.secondary)
                    }
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    QuickActionsCard(showTransferSheet: .constant(false))
        .environmentObject(AppStore())
        .padding()
}