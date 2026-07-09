import XCTest

final class TabekiriBiyoriUITests: XCTestCase {
    func testAddAndFinishClosedLoop() {
        let app = XCUIApplication()
        app.launch()

        let add = app.buttons["addFirstFoodButton"].exists
            ? app.buttons["addFirstFoodButton"]
            : app.buttons["addFoodButton"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()

        let name = app.textFields["foodNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText("UI Test Tofu")

        let save = app.buttons["saveFoodButton"]
        XCTAssertTrue(save.isEnabled)
        save.tap()

        let row = app.buttons["foodRow_UI Test Tofu"]
        XCTAssertTrue(row.waitForExistence(timeout: 4))
        row.tap()

        let finish = app.buttons["finishFoodButton"]
        XCTAssertTrue(finish.waitForExistence(timeout: 3))
        finish.tap()

        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["UI Test Tofu"].waitForExistence(timeout: 4))
    }
}

