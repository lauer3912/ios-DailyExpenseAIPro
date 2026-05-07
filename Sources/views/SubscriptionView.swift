import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var store: AppStore
    @State private var isUnlocking = false
    @State private var showAlert = false
    @State private var alertMessage = ""

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

                        Text("$0.99/month")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

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
                                Text(isUnlocking ? "Unlocking..." : "Subscribe Now")
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
                            // Restore purchases - for now just show alert
                            alertMessage = "No previous purchases found."
                            showAlert = true
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

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            store.isPremium = true
            store.saveToUserDefaults()
            isUnlocking = false
            alertMessage = "Congratulations! Premium features unlocked."
            showAlert = true
        }
    }
}

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
