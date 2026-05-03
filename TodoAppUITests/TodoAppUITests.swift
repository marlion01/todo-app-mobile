import XCTest

final class TodoAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_launch_showsNavigationTitle() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.navigationBars["Todo"].waitForExistence(timeout: 5),
            "起動時に Todo ナビゲーションバーが表示されること"
        )
    }
}
