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
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Period Selector (Futuristic)
                        HStack(spacing: 0) {
                            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPeriod = period
                                    }
                                } label: {
                                    Text(period.rawValue)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(selectedPeriod == period ? AppTheme.backgroundPrimary : AppTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedPeriod == period ? 
                                            LinearGradient(colors: [AppTheme.primaryCyan, AppTheme.primaryBlue], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                                        )
                                }
                            }
                        }
                        .background(AppTheme.backgroundCard)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Summary Cards
                        HStack(spacing: 12) {
                            SummaryCard(
                                title: "Total Income",
                                value: formatCurrency(totalIncome),
                                color: AppTheme.success,
                                icon: "arrow.down.circle.fill"
                            )

                            SummaryCard(
                                title: "Total Expenses",
                                value: formatCurrency(totalExpenses),
                                color: AppTheme.error,
                                icon: "arrow.up.circle.fill"
                            )
                        }
                        .padding(.horizontal)

                        // Net Balance (Glowing card)
                        VStack(spacing: 8) {
                            Text("Net Balance")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(formatCurrency(totalIncome - totalExpenses))
                                .font(.title.bold())
                                .foregroundStyle(
                                    totalIncome >= totalExpenses ?
                                    LinearGradient(colors: [AppTheme.success, Color(hex: "00A854")], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [AppTheme.error, Color(hex: "D50000")], startPoint: .top, endPoint: .bottom)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .glassBackground()
                        .padding(.horizontal)

                        // Chart Type Selector
                        HStack(spacing: 0) {
                            ForEach(ChartType.allCases, id: \.self) { type in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedChartType = type
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: chartTypeIcon(type))
                                        Text(type.rawValue)
                                    }
                                    .font(.caption.bold())
                                    .foregroundStyle(selectedChartType == type ? AppTheme.primaryCyan : AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedChartType == type ?
                                        AppTheme.backgroundCard :
                                        Color.clear
                                    )
                                }
                            }
                        }
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Main Chart (Futuristic card)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by Category")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
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
                        .glassBackground()
                        .padding(.horizontal)

                        // Category Breakdown List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Breakdown")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            ForEach(categoryData, id: \.category.id) { item in
                                CategoryBreakdownRow(
                                    category: item.category,
                                    amount: item.amount,
                                    percentage: item.amount / max(totalExpenses, 1)
                                )
                            }
                        }
                        .padding()
                        .glassBackground()
                        .padding(.horizontal)

                        // Trend Chart (Futuristic)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending Trend")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            Chart {
                                ForEach(trendData, id: \.period) { item in
                                    BarMark(
                                        x: .value("Period", item.period),
                                        y: .value("Amount", item.amount)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppTheme.primaryCyan, AppTheme.primaryPurple],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .frame(height: 200)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisValueLabel()
                                        .font(.caption2)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine()
                                        .foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                                    AxisValueLabel {
                                        if let amount = value.as(Double.self) {
                                            Text("$\(Int(amount))")
                                                .font(.caption2)
                                                .foregroundStyle(AppTheme.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .glassBackground()
                        .padding(.horizontal)

                        // Top Spending Days
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Spending Days")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            ForEach(topSpendingDays, id: \.date) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formatFullDate(item.date))
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Text("\(item.count) transactions")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    Text(formatCurrency(item.amount))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppTheme.error)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .glassBackground()
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.backgroundSecondary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func chartTypeIcon(_ type: ChartType) -> String {
        switch type {
        case .pie: return "chart.pie.fill"
        case .bar: return "chart.bar.fill"
        case .line: return "chart.line.uptrend.xyaxis"
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

// MARK: - Futuristic Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .neonGlow(color: color)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(value)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Spacer()
            }
        }
        .padding(16)
        .glassBackground()
    }
}

// MARK: - Category Breakdown Row
struct CategoryBreakdownRow: View {
    let category: Category
    let amount: Double
    let percentage: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Category color dot with glow
                Circle()
                    .fill(category.color)
                    .frame(width: 10, height: 10)
                    .shadow(color: category.color.opacity(0.6), radius: 4)
                
                Text(category.name)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                Text(formatCurrency(amount))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.backgroundSecondary)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [category.color, category.color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(percentage, 1.0))
                        .shadow(color: category.color.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}

// MARK: - Chart Views (Futuristic)

struct PieChartView: View {
    let data: [(category: Category, amount: Double)]

    var body: some View {
        if data.isEmpty {
            EmptyChartPlaceholder(message: "No expense data")
        } else {
            Chart(data, id: \.category.id) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 2.0
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [item.category.color, item.category.color.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .annotation(position: .overlay) {
                    if item.amount / data.reduce(0) { $0 + $1.amount } > 0.08 {
                        Text(formatShort(item.amount))
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
            .frame(height: 250)
            .chartLegend(.hidden)
        }
    }
    
    private func formatShort(_ amount: Double) -> String {
        if amount >= 1000 {
            return "$\(String(format: "%.0f", amount / 1000))k"
        }
        return "$\(String(format: "%.0f", amount))"
    }
}

struct BarChartView: View {
    let data: [(category: Category, amount: Double)]

    var body: some View {
        if data.isEmpty {
            EmptyChartPlaceholder(message: "No expense data")
        } else {
            Chart(data, id: \.category.id) { item in
                BarMark(
                    x: .value("Category", item.category.name),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [item.category.color, item.category.color.opacity(0.6)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)
                .annotation(position: .top) {
                    Text("$\(Int(item.amount))")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
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
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.primaryCyan, AppTheme.primaryPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Period", item.period),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.primaryCyan.opacity(0.3), AppTheme.primaryPurple.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Empty Chart Placeholder
struct EmptyChartPlaceholder: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}