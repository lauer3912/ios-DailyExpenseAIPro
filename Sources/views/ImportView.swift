import SwiftUI

struct ImportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showFilePicker = false
    @State private var importedText: String = ""
    @State private var parsedTransactions: [Transaction] = []
    @State private var importError: String = ""
    @State private var showPreview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                // Title
                VStack(spacing: 8) {
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Import transactions from a CSV file previously exported from this app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("CSV Format")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Required columns:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Date, Type, Category, Amount, Note, Account")
                            .font(.caption)
                            .foregroundColor(.mint)
                            .padding(8)
                            .background(Color.mint.opacity(0.1))
                            .cornerRadius(8)

                        Text("Example:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("2026-01-15 10:30, expense, Food & Dining, 45.50, Lunch, Cash")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                // File Input
                VStack(spacing: 12) {
                    Button {
                        showFilePicker = true
                    } label: {
                        Label("Select CSV File", systemImage: "doc.badge.plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }

                    Text("or paste CSV content below")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $importedText)
                        .font(.caption)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )

                    if !importedText.isEmpty {
                        Button {
                            parseAndPreview()
                        } label: {
                            Text("Preview Import")
                                .font(.headline)
                                .foregroundColor(.mint)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mint.opacity(0.15))
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)

                // Error
                if !importError.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(importError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        if url.startAccessingSecurityScopedResource() {
                            defer { url.stopAccessingSecurityScopedResource() }
                            if let content = try? String(contentsOf: url, encoding: .utf8) {
                                importedText = content
                                parseAndPreview()
                            }
                        }
                    }
                case .failure(let error):
                    importError = "Failed to read file: \(error.localizedDescription)"
                }
            }
            .sheet(isPresented: $showPreview) {
                ImportPreviewView(parsedTransactions: parsedTransactions) {
                    performImport()
                }
            }
        }
    }

    func parseAndPreview() {
        importError = ""
        parsedTransactions = []

        let lines = importedText.split(separator: "\n")
        guard lines.count > 1 else {
            importError = "CSV must have header row and at least one data row"
            return
        }

        var parsed: [Transaction] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        for line in lines.dropFirst() {
            let parts = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            guard parts.count >= 5 else { continue }

            guard let date = dateFormatter.date(from: parts[0]) ?? parseFlexibleDate(parts[0]) else { continue }
            guard let amount = Double(parts[3]) else { continue }
            guard let type = TransactionType(rawValue: parts[1]) else { continue }

            let categoryName = parts[2]
            let note = parts.count > 4 ? parts[4] : ""

            if let category = store.categories.first(where: { $0.name == categoryName }) {
                let transaction = Transaction(
                    id: UUID(),
                    amount: type == .expense ? -abs(amount) : abs(amount),
                    category: category,
                    date: date,
                    note: note,
                    type: type
                )
                parsed.append(transaction)
            }
        }

        if parsed.isEmpty {
            importError = "No valid transactions found. Check CSV format."
        } else {
            parsedTransactions = parsed
            showPreview = true
        }
    }

    func parseFlexibleDate(_ string: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "MM-dd-yyyy"
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    func performImport() {
        for transaction in parsedTransactions {
            store.transactions.append(transaction)
        }
        store.saveToUserDefaults()
        dismiss()
    }
}

struct ImportPreviewView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let parsedTransactions: [Transaction]
    let onImport: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("\(parsedTransactions.count) transactions will be imported")
                    .font(.headline)
                    .padding(.top)

                List {
                    ForEach(parsedTransactions) { transaction in
                        HStack {
                            Image(systemName: transaction.category.icon)
                                .frame(width: 32, height: 32)
                                .background(transaction.category.color.opacity(0.12))
                                .foregroundColor(transaction.category.color)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(transaction.category.name)
                                    .font(.subheadline)
                                Text(transaction.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(formatCurrency(transaction.amount))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(transaction.type == .income ? .green : .red)
                        }
                    }
                }
                .listStyle(.plain)

                Button {
                    onImport()
                    dismiss()
                } label: {
                    Text("Confirm Import")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Preview Import")
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
        let prefix = amount >= 0 ? "+" : ""
        return prefix + "$" + String(format: "%.2f", abs(amount))
    }
}

#Preview {
    ImportView()
        .environmentObject(AppStore())
}