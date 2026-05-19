import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

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

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

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

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = Set(ProductID.allCases.map { p in p.rawValue })
            products = try await Product.products(for: productIDs)
                .sorted { a, b in a.price < b.price }

            if products.isEmpty {
                errorMessage = "No subscription products found."
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

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
                errorMessage = "Purchase is pending."
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

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        await updatePurchasedProducts()
        isLoading = false
    }

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in StoreKit.Transaction.currentEntitlements {
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

    private func listenForTransactions() -> Task<Void, Error> {
        Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
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

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    func product(for id: ProductID) -> Product? {
        products.first { p in p.id == id.rawValue }
    }
}

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
