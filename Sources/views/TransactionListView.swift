import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var selectedCategory: Category?
    @State private var sortOrder: TransactionSortOrder = .dateDesc
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
    }

    enum TransactionSortOrder: String, CaseIterable {
        case dateDesc = "Newest"
        case dateAsc = "Oldest"
        case amountDesc = "Highest"
        case amountAsc = "Lowest"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search & Filter
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search transactions...", text: $searchText)
                            .textFieldStyle(.plain)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedFilter == .all) {
                                selectedFilter = .all
                            }
                            FilterChip(title: "Income", isSelected: selectedFilter == .income) {
                                selectedFilter = .income
                            }
                            FilterChip(title: "Expense", isSelected: selectedFilter == .expense) {
                                selectedFilter = .expense
                            }

                            Divider()
                                .frame(height: 20)

                            // Category filter dropdown
                            Menu {
                                Button("All Categories") {
                                    selectedCategory = nil
                                }
                                ForEach(store.categories.filter { $0.type == selectedFilter.toType() ?? .expense }) { cat in
                                    Button {
                                        selectedCategory = cat
                                    } label: {
                                        Label(cat.name, systemImage: cat.icon)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    if let cat = selectedCategory {
                                        Image(systemName: cat.icon)
                                        Text(cat.name)
                                    } else {
                                        Text("Category")
                                    }
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(16)
                            }

                            // Sort
                            Menu {
                                ForEach(TransactionSortOrder.allCases, id: \.self) { order in
                                    Button {
                                        sortOrder = order
                                    } label: {
                                        HStack {
                                            Text(order.rawValue)
                                            if sortOrder == order {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(sortOrder.rawValue)
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Transaction List
                if filteredTransactions.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "tray",
                        title: "No Transactions",
                        message: searchText.isEmpty ? "No transactions match your filters" : "No results for \"\(searchText)\""
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.0) { date, transactions in
                            Section {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                transactionToDelete = transaction
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                }
                            } header: {
                                Text(formatSectionDate(date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transactions")
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let t = transactionToDelete {
                        store.deleteTransaction(t)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this transaction? This cannot be undone.")
            }
        }
    }

    var filteredTransactions: [Transaction] {
        var result = store.transactions

        // Apply type filter
        switch selectedFilter {
        case .income:
            result = result.filter { $0.type == .income }
        case .expense:
            result = result.filter { $0.type == .expense }
        case .all:
            break
        }

        // Apply category filter
        if let cat = selectedCategory {
            result = result.filter { $0.category.id == cat.id }
        }

        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.note.localizedCaseInsensitiveContains(searchText) ||
                $0.category.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sort
        switch sortOrder {
        case .dateDesc:
            result.sort { $0.date > $1.date }
        case .dateAsc:
            result.sort { $0.date < $1.date }
        case .amountDesc:
            result.sort { abs($0.amount) > abs($1.amount) }
        case .amountAsc:
            result.sort { abs($0.amount) < abs($1.amount) }
        }

        return result
    }

    var groupedTransactions: [(Date, [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> Date in
            calendar.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

extension TransactionListView.TransactionFilter {
    func toType() -> TransactionType? {
        switch self {
        case .all: return nil
        case .income: return .income
        case .expense: return .expense
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.mint : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TransactionListView()
        .environmentObject(AppStore())
}