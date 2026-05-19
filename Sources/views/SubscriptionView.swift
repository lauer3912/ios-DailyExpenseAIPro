import SwiftUI

// MARK: - IAP Product IDs (must match App Store Connect)
private enum IAPProductID {
    static let monthly = "com.ggsheng.DailyExpenseAIPro.premium_monthly"
    static let yearly = "com.ggsheng.DailyExpenseAIPro.premium_yearly"
}

// MARK: - Price Display (must match App Store Connect)
private enum SubscriptionPrice {
    static let monthlyDisplay = "$4.99/month"
    static let yearlyDisplay = "$39.99/year"
    static let monthlyShort = "$4.99"
    static let yearlyShort = "$39.99"
}

struct SubscriptionView: View {
    @EnvironmentObject var store: AppStore
    @State private var isUnlocking = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedPlan: SubscriptionPlan = .monthly

    enum SubscriptionPlan: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"

        var priceDisplay: String {
            switch self {
            case .monthly: return SubscriptionPrice.monthlyDisplay
            case .yearly: return SubscriptionPrice.yearlyDisplay
            }
        }

        var shortPrice: String {
            switch self {
            case .monthly: return SubscriptionPrice.monthlyShort
            case .yearly: return SubscriptionPrice.yearlyShort
            }
        }

        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 33%"
            }
        }
    }

    private let premiumFeatures = [
        ("chart.pie.fill", "Advanced Analytics", "Detailed charts & insights"),
        ("target", "Budget Goals", "Set and track spending limits"),
        ("flag.fill", "Savings Goals", "Achieve your financial targets"),
        ("repeat", "Recurring Transactions", "Automate your income & expenses"),
        ("square.and.arrow.up", "CSV Export", "Export data for external analysis"),
        ("creditcard.fill", "Unlimited Accounts", "Manage multiple accounts"),
    ]

    private let freeFeatures = [
        ("plus.circle.fill", "Add Transactions", "Record income & expenses"),
        ("list.bullet", "Transaction History", "View all your transactions"),
        ("magnifyingglass", "Search & Filter", "Find transactions easily"),
        ("dollarsign.circle.fill", "Multi-Currency", "Support for USD, CNY, EUR"),
        ("chart.bar.fill", "Basic Analytics", "Simple expense breakdown"),
        ("folder.fill", "Categories", "Organize your spending"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.mint, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        Text("Unlock Premium")
                            .font(.title).fontWeight(.bold)
                    }
                    .padding(.top, 20)

                    // Plan Selector
                    if !store.isPremium {
                        VStack(spacing: 12) {
                            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                                PlanSelector(
                                    plan: plan,
                                    isSelected: selectedPlan == plan,
                                    onTap: { selectedPlan = plan }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Free Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FREE FEATURES")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        ForEach(freeFeatures, id: \.0) { icon, title, desc in
                            FeatureRow(icon: icon, iconColor: .blue, title: title, description: desc, isLocked: false)
                        }
                    }
                    .padding(.horizontal)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Premium Features
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("PREMIUM FEATURES")
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .foregroundColor(.mint)
                                .font(.caption)
                        }

                        ForEach(premiumFeatures, id: \.0) { icon, title, desc in
                            FeatureRow(icon: icon, iconColor: .mint, title: title, description: desc, isLocked: true)
                        }
                    }
                    .padding(.horizontal)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Subscribe Button
                    VStack(spacing: 12) {
                        Button {
                            unlockPremium()
                        } label: {
                            HStack {
                                if isUnlocking {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "crown.fill")
                                }
                                Text(isUnlocking ? "Unlocking..." : "Subscribe Now - \(selectedPlan.shortPrice)/\(selectedPlan == .monthly ? "mo" : "yr")")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.mint, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isUnlocking || store.isPremium)

                        if store.isPremium {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mint)
                                Text("Premium Unlocked!")
                                    .foregroundColor(.mint)
                                    .fontWeight(.medium)
                            }
                        }

                        Button {
                            restorePurchases()
                        } label: {
                            Text("Restore Purchases")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)

                        Text("Cancel anytime. Auto-renews until cancelled.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Restore Purchases", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func unlockPremium() {
        isUnlocking = true

        // TODO: Integrate StoreKit for actual IAP
        // Use StoreKit 2 API:
        // let productIDs = [selectedPlan == .monthly ? IAPProductID.monthly : IAPProductID.yearly]
        // let products = try await Product.products(for: Set(productIDs))
        // let result = try await products.first?.purchase()

        // Simulate network delay for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            store.isPremium = true
            store.saveToUserDefaults()
            isUnlocking = false
            alertMessage = "Congratulations! Premium features unlocked."
            showAlert = true
        }
    }

    private func restorePurchases() {
        // TODO: Integrate StoreKit for actual restore
        // Use StoreKit 2 API:
        // try await Transaction.currentEntitlements

        alertMessage = "No previous purchases found."
        showAlert = true
    }
}

// MARK: - Plan Selector Component
struct PlanSelector: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }

                    Text(plan.priceDisplay)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .mint : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mint : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.subheadline).fontWeight(.medium)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isLocked {
                Image(systemName: "crown.fill")
                    .foregroundColor(.mint)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppStore())
}
