import Foundation
import Observation
import StoreKit

enum PurchaseOutcome: Equatable {
    case purchased
    case pending
    case cancelled
    case failed
}

enum RestoreOutcome: Equatable {
    case restored
    case nothingToRestore
    case failed
}

@MainActor
@Observable
final class PurchaseManager {
    static let proProductID = "com.zhouyajie.tabekiribiyori.pro.lifetime"
    static let sharedEntitlementKey = "proLifetimeEntitled"

    private(set) var proProduct: Product?
    private(set) var isPro = false
    private(set) var isLoadingProduct = false
    private(set) var isProcessing = false
    private(set) var hasCheckedEntitlements = false
    private(set) var productLoadFailed = false

    @ObservationIgnored private var updateTask: Task<Void, Never>?
    @ObservationIgnored private var hasPrepared = false

    init() {
        updateTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? verified(result) else { continue }
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }

    deinit {
        updateTask?.cancel()
    }

    func prepare() async {
        guard !hasPrepared else { return }
        hasPrepared = true
        await refreshEntitlements()
        await loadProduct()
    }

    func loadProduct() async {
        guard !isLoadingProduct else { return }
        isLoadingProduct = true
        productLoadFailed = false
        defer { isLoadingProduct = false }

        do {
            proProduct = try await Product.products(for: [Self.proProductID]).first
            productLoadFailed = proProduct == nil
        } catch {
            proProduct = nil
            productLoadFailed = true
        }
    }

    func purchasePro() async -> PurchaseOutcome {
        if proProduct == nil {
            await loadProduct()
        }
        guard let proProduct else { return .failed }

        isProcessing = true
        defer { isProcessing = false }

        do {
            switch try await proProduct.purchase() {
            case let .success(result):
                let transaction = try verified(result)
                guard transaction.productID == Self.proProductID,
                      transaction.productType == .nonConsumable,
                      transaction.revocationDate == nil else {
                    return .failed
                }
                setProEntitlement(true)
                await transaction.finish()
                return .purchased
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    func restorePurchases() async -> RestoreOutcome {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return isPro ? .restored : .nothingToRestore
        } catch {
            return .failed
        }
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result),
                  transaction.productID == Self.proProductID,
                  transaction.productType == .nonConsumable,
                  transaction.revocationDate == nil else {
                continue
            }
            entitled = true
            break
        }
        setProEntitlement(entitled)
        hasCheckedEntitlements = true
    }

    private func setProEntitlement(_ entitled: Bool) {
        isPro = entitled
        UserDefaults(suiteName: WidgetSnapshotService.suite)?
            .set(entitled, forKey: Self.sharedEntitlementKey)
    }

    private func verified<Value>(_ result: VerificationResult<Value>) throws -> Value {
        switch result {
        case let .verified(value):
            return value
        case .unverified:
            throw PurchaseVerificationError.unverified
        }
    }
}

private enum PurchaseVerificationError: Error {
    case unverified
}
