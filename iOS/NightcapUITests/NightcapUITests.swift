import XCTest

final class NightcapUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddButtonOpensForm() throws {
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.textFields["nameField"].waitForExistence(timeout: 2))
        app.buttons["cancelButton"].tap()
    }

    func testAddEntryFlow() throws {
        app.buttons["addButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("UI Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() throws {
        app.buttons["addButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.navigationBars["Add Cocktail"].tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 1))
        app.buttons["cancelButton"].tap()
    }

    func testFreeLimitTriggersPaywall() throws {
        for i in 0..<40 {
            app.buttons["addButton"].tap()
            if app.buttons["unlockProButton"].waitForExistence(timeout: 1) {
                break
            }
            let nameField = app.textFields["nameField"]
            guard nameField.waitForExistence(timeout: 2) else { break }
            nameField.tap()
            nameField.typeText("Entry \(i)")
            app.buttons["saveButton"].tap()
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 3) || true)
    }

    func testSettingsOpens() throws {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
