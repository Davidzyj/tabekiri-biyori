import XCTest
@testable import TabekiriBiyori

final class FoodItemTests: XCTestCase {
    func testDaysRemainingUsesCalendarDays() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        let item = FoodItem(name: "Tofu", expiryDate: tomorrow, expiryKind: .useBy, storage: .fridge)
        XCTAssertEqual(item.daysRemaining, 1)
    }

    func testEnumRoundTrips() {
        let item = FoodItem(name: "Bread", expiryDate: .now, expiryKind: .bestBefore, storage: .pantry)
        XCTAssertEqual(item.expiryKind, .bestBefore)
        XCTAssertEqual(item.storage, .pantry)
        XCTAssertEqual(item.outcome, .active)
    }
}

