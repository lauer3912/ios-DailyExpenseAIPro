import WidgetKit
import SwiftUI
import AppIntents

struct DailyExpenseAIProWidget: Widget {
    let kind: String = "DailyExpenseAIProWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyExpenseAIProWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DailyExpenseAIPro")
        .description("View your current balance and recent transactions.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: 2500.0, recentTransactions: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), balance: 2500.0, recentTransactions: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), balance: 2500.0, recentTransactions: [])
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let recentTransactions: [Transaction]
}

struct DailyExpenseAIProWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("$" + String(format: "%.2f", entry.balance))
                .font(.title3.bold())
            
            if !entry.recentTransactions.isEmpty {
                Divider()
                
                Text("Recent")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.recentTransactions.prefix(2)) { transaction in
                        HStack {
                            Image(systemName: transaction.category.icon)
                                .font(.caption)
                            Text(transaction.category.name)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text((transaction.type == .income ? "+" : "-$") + String(format: "%.2f", abs(transaction.amount)))
                                .font(.caption.bold())
                                .foregroundColor(transaction.type == .income ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct Transaction {
    let id: UUID
    let amount: Double
    let type: TransactionType
    let category: Category
    
    struct Category {
        let name: String
        let icon: String
    }
}

enum TransactionType {
    case income, expense
}

#Preview {
    DailyExpenseAIProWidgetEntryView(entry: SimpleEntry(date: Date(), balance: 2500.0, recentTransactions: []))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
}