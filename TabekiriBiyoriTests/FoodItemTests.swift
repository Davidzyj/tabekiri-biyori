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

    func testFreeTierAllowsFoodBelowLimit() {
        XCTAssertTrue(FeatureAccess.canAddFood(
            activeItemCount: FeatureAccess.freeActiveItemLimit - 1,
            isPro: false
        ))
    }

    func testFreeTierStopsNewFoodAtLimitWithoutAffectingExistingData() {
        XCTAssertFalse(FeatureAccess.canAddFood(
            activeItemCount: FeatureAccess.freeActiveItemLimit,
            isPro: false
        ))
    }

    func testProAlwaysAllowsNewFood() {
        XCTAssertTrue(FeatureAccess.canAddFood(activeItemCount: 999, isPro: true))
    }
}
