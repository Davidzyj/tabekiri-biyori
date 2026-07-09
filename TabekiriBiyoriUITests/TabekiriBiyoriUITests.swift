import XCTest

final class TabekiriBiyoriUITests: XCTestCase {
    func testAddAndFinishClosedLoop() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingResetData"]
        app.launch()

        let addButton = app.buttons["addFirstFoodButton"].exists
            ? app.buttons["addFirstFoodButton"]
            : app.buttons["addFoodButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let name = app.textFields["foodNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText("UI Test Tofu")

        let keyboardDone = app.buttons["keyboardDoneButton"]
        XCTAssertTrue(keyboardDone.waitForExistence(timeout: 3))
        keyboardDone.tap()

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

        app.tabBars.buttons.element(boundBy: 2).tap()
        let proButton = app.buttons["openProButton"]
        XCTAssertTrue(proButton.waitForExistence(timeout: 4))
        proButton.tap()
        XCTAssertTrue(app.buttons["restorePurchasesButton"].waitForExistence(timeout: 5))
        let purchaseButton = app.buttons["purchaseProButton"]
        XCTAssertTrue(purchaseButton.waitForExistence(timeout: 5))

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "Pro Page QA"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFreeLimitOpensProAndKeepsExistingFood() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingResetData", "-uiTestingSeedFreeLimit"]
        app.launch()

        let addButton = app.buttons["addFoodButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 6))
        addButton.tap()

        XCTAssertTrue(app.buttons["restorePurchasesButton"].waitForExistence(timeout: 5))
        app.buttons["closeProButton"].tap()
        XCTAssertTrue(app.buttons["foodRow_Seed 1"].waitForExistence(timeout: 5))
    }
}
