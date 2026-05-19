import Foundation
import StoreKit

// MARK: - StoreKit Manager (StoreKit 2)
@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Product IDs (must match App Store Connect)
    enum ProductID: String, CaseIterable {
        case monthly = "com.ggsheng.DailyExpenseAIPro.premium_monthly"
        case yearly = "com.ggsheng.DailyExpenseAIPro.premium_yearly"

        var displayName: String {
            switch self {
            case .monthly: return "Premium Monthly"
            case .yearly: return "Premium Yearly"
            }
        }
    }

    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Subscription Status
    var isPremiumActive: Bool {
        purchasedProductIDs.contains(ProductID.monthly.rawValue) ||
        purchasedProductIDs.contains(ProductID.yearly.rawValue)
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = Set(ProductID.allCases.map { $0.rawValue })
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }

            if products.isEmpty {
                errorMessage = "No subscription products found. Please configure in App Store Connect."
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                errorMessage = "Purchase is pending. Please complete payment."
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            throw error
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productType == .autoRenewable {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        purchasedProductIDs = purchased
    }

    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Get Product by ID
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }
}

// MARK: - StoreKit Error
enum StoreKitError: LocalizedError {
    case verificationFailed
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        }
    }
}
