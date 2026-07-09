import StoreKitTest
import XCTest
@testable import TabekiriBiyori

@MainActor
final class PurchaseManagerTests: XCTestCase {
    private var session: SKTestSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        session = try SKTestSession(configurationFileNamed: "Configuration")
        session.disableDialogs = true
        session.clearTransactions()
    }

    override func tearDownWithError() throws {
        session.clearTransactions()
        session = nil
        try super.tearDownWithError()
    }

    func testLifetimeProductCanBePurchasedAndRefunded() async throws {
        let purchased = try await session.buyProduct(identifier: PurchaseManager.proProductID)
        XCTAssertEqual(String(purchased.productID), PurchaseManager.proProductID)

        let transaction = try XCTUnwrap(
            session.allTransactions().first {
                $0.productIdentifier == PurchaseManager.proProductID
            }
        )
        try session.refundTransaction(identifier: transaction.identifier)

        let refunded = try XCTUnwrap(
            session.allTransactions().first {
                $0.identifier == transaction.identifier
            }
        )
        XCTAssertNotNil(refunded.cancelDate)
    }
}
