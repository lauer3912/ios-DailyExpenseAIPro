import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedPeriod: AnalyticsPeriod = .monthly
    @State private var selectedChartType: ChartType = .pie

    enum AnalyticsPeriod: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
        case yearly = "Year"
    }

    enum ChartType: String, CaseIterable {
        case pie = "Pie"
        case bar = "Bar"
        case line = "Line"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Summary Cards
                    HStack(spacing: 12) {
                        SummaryCard(
                            title: "Total Income",
                            value: formatCurrency(totalIncome),
                            color: .green,
                            icon: "arrow.down.circle.fill"
                        )

                        SummaryCard(
                            title: "Total Expenses",
                            value: formatCurrency(totalExpenses),
                            color: .red,
                            icon: "arrow.up.circle.fill"
                        )
                    }
                    .padding(.horizontal)

                    // Net Balance
                    VStack(spacing: 4) {
                        Text("Net Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(formatCurrency(totalIncome - totalExpenses))
                            .font(.title.bold())
                            .foregroundColor(totalIncome >= totalExpenses ? .green : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Chart Type Selector
                    Picker("Chart", selection: $selectedChartType) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Main Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending by Category")
                            .font(.headline)
                            .padding(.horizontal)

                        switch selectedChartType {
                        case .pie:
                            PieChartView(data: categoryData)
                        case .bar:
                            BarChartView(data: categoryData)
                        case .line:
                            LineChartView(data: trendData)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // Category Breakdown List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(.headline)

                        ForEach(categoryData, id: \.category.id) { item in
                            CategoryBreakdownRow(
                                category: item.category,
                                amount: item.amount,
                                percentage: item.amount / max(totalExpenses, 1)
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // Trend Data
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending Trend")
                            .font(.headline)

                        Chart {
                            ForEach(trendData, id: \.period) { item in
                                BarMark(
                                    x: .value("Period", item.period),
                                    y: .value("Amount", item.amount)
                                )
                                .foregroundStyle(Color.mint.gradient)
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisValueLabel()
                                    .font(.caption2)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let amount = value.as(Double.self) {
                                        Text("$\(Int(amount))")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // Top Spending Days
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Spending Days")
                            .font(.headline)

                        ForEach(topSpendingDays, id: \.date) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatFullDate(item.date))
                                        .font(.subheadline)
                                    Text("\(item.count) transactions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(formatCurrency(item.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Analytics")
        }
    }

    // MARK: - Data Computations

    var totalIncome: Double {
        store.transactions.filter { $0.type == .income && inSelectedPeriod($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        store.transactions.filter { $0.type == .expense && inSelectedPeriod($0.date) }
            .reduce(0) { $0 + abs($1.amount) }
    }

    var categoryData: [(category: Category, amount: Double)] {
        let expenses = store.transactions.filter { $0.type == .expense && inSelectedPeriod($0.date) }
        var result: [UUID: Double] = [:]
        for t in expenses {
            result[t.category.id, default: 0] += abs(t.amount)
        }
        return store.categories
            .filter { $0.type == .expense }
            .map { cat in (cat, result[cat.id] ?? 0) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var trendData: [(period: String, amount: Double)] {
        switch selectedPeriod {
        case .weekly:
            return store.weeklyData(lastWeeks: 8).map { ($0.0, $0.1) }
        case .monthly:
            return store.monthlyData(lastMonths: 6).map { ($0.0, $0.1) }
        case .yearly:
            return store.monthlyData(lastMonths: 12).map { ($0.0, $0.1) }
        }
    }

    var topSpendingDays: [(date: Date, amount: Double, count: Int)] {
        let expenses = store.transactions.filter { $0.type == .expense }
        let calendar = Calendar.current
        var byDay: [Date: (amount: Double, count: Int)] = [:]

        for t in expenses {
            let day = calendar.startOfDay(for: t.date)
            let existing = byDay[day] ?? (0, 0)
            byDay[day] = (existing.amount + abs(t.amount), existing.count + 1)
        }

        return byDay
            .map { (date: $0.key, amount: $0.value.amount, count: $0.value.count) }
            .sorted { $0.amount > $1.amount }
            .prefix(5)
            .map { $0 }
    }

    func inSelectedPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .weekly:
            guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
                  let end = calendar.date(byAdding: .day, value: 7, to: start) else { return false }
            return date >= start && date < end
        case .monthly:
            guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { return false }
            return date >= start && date < end
        case .yearly:
            guard let start = calendar.date(from: calendar.dateComponents([.year], from: now)),
                  let end = calendar.date(byAdding: .year, value: 1, to: start) else { return false }
            return date >= start && date < end
        }
    }

    func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }

    func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Chart Views

struct PieChartView: View {
    let data: [(category: Category, amount: Double)]

    var body: some View {
        if data.isEmpty {
            EmptyChartPlaceholder(message: "No expense data")
        } else {
            Chart(data, id: \.category.id) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .annotation(position: .overlay) {
                    if item.amount / data.reduce(0) { $0 + $1.amount } > 0.08 {
                        Text(formatShort(item.amount))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 250)
            .chartLegend(position: .bottom, alignment: .center, spacing: 16) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(data.prefix(8), id: \.category.id) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 8, height: 8)
                            Text(item.category.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    func formatShort(_ amount: Double) -> String {
        if amount >= 1000 {
            return "$" + String(format: "%.1fK", amount / 1000)
        }
        return "$" + String(format: "%.0f", amount)
    }
}

struct BarChartView: View {
    let data: [(category: Category, amount: Double)]

    var body: some View {
        if data.isEmpty {
            EmptyChartPlaceholder(message: "No expense data")
        } else {
            Chart(data.prefix(8), id: \.category.id) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Category", item.category.name)
                )
                .foregroundStyle(item.category.color.gradient)
                .annotation(position: .trailing) {
                    Text(formatShort(item.amount))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: CGFloat(data.prefix(8).count) * 44 + 40)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }

    func formatShort(_ amount: Double) -> String {
        if amount >= 1000 {
            return "$" + String(format: "%.1fK", amount / 1000)
        }
        return "$" + String(format: "%.0f", amount)
    }
}

struct LineChartView: View {
    let data: [(period: String, amount: Double)]

    var body: some View {
        if data.isEmpty {
            EmptyChartPlaceholder(message: "No trend data")
        } else {
            Chart {
                ForEach(data, id: \.period) { item in
                    LineMark(
                        x: .value("Period", item.period),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.mint.gradient)
                    .symbol(Circle())

                    AreaMark(
                        x: .value("Period", item.period),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.mint.opacity(0.1).gradient)
                }
            }
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryBreakdownRow: View {
    let category: Category
    let amount: Double
    let percentage: Double

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .font(.caption)
                        .frame(width: 24, height: 24)
                        .background(category.color.opacity(0.12))
                        .foregroundColor(category.color)
                        .clipShape(Circle())

                    Text(category.name)
                        .font(.caption)
                }

                Spacer()

                Text("$\(String(format: "%.2f", amount))")
                    .font(.caption)
                    .fontWeight(.medium)

                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * percentage, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyChartPlaceholder: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(AppStore())
}