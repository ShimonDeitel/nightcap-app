import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "com.shimondeitel.cocktaillog.pro"

    @Published var isPurchased: Bool = false
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await self?.handle(transaction: transaction)
                }
            }
        }
        Task { await loadProducts() }
        Task { await refreshEntitlement() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.proProductID])
            product = products.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await handle(transaction: transaction)
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlement()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handle(transaction: Transaction) async {
        isPurchased = true
        await transaction.finish()
    }

    func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.proProductID {
                isPurchased = true
                return
            }
        }
        isPurchased = false
    }
}
