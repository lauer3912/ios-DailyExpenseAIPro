import SwiftUI

struct ExportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var exportedCSV: String = ""
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.mint)
                    .padding(.top, 40)

                // Title
                VStack(spacing: 8) {
                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Export all your transactions, accounts, budgets, and goals as CSV files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Stats
                VStack(spacing: 12) {
                    ExportStatRow(icon: "list.bullet", title: "Transactions", value: "\(store.transactions.count)")
                    ExportStatRow(icon: "creditcard", title: "Accounts", value: "\(store.accounts.count)")
                    ExportStatRow(icon: "chart.pie", title: "Budgets", value: "\(store.budgets.count)")
                    ExportStatRow(icon: "star", title: "Goals", value: "\(store.goals.count)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV Preview (first 5 transactions)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        Text(previewCSV)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 120)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()

                // Export Button
                Button {
                    exportedCSV = store.exportToCSV()
                    showShareSheet = true
                } label: {
                    Label("Export as CSV", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .cornerRadius(16)
                }
                .padding()

                // Info
                Text("Exported data can be imported into spreadsheets or other financial apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [exportedCSV])
            }
        }
    }

    var previewCSV: String {
        let csv = store.exportToCSV()
        let lines = csv.split(separator: "\n")
        return lines.prefix(6).joined(separator: "\n")
    }
}

struct ExportStatRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.mint)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .environmentObject(AppStore())
}