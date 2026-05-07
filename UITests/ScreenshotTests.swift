import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        sleep(2)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - iPhone 6.9" Screenshots

    private func saveScreenshot(named name: String) {
        let screenshot = app.windows.firstMatch.screenshot()
        let data = screenshot.pngRepresentation
        let path = "/tmp/iphone69_\(name).png"
        try? data.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path) (\(data.count) bytes)")
    }

    func testiPhone_69_01_Dashboard() throws {
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        saveScreenshot(named: "Dashboard")
    }

    func testiPhone_69_02_Transactions() throws {
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)
        saveScreenshot(named: "Transactions")
    }

    func testiPhone_69_03_AddTransaction() throws {
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(1)
        saveScreenshot(named: "AddTransaction")
    }

    func testiPhone_69_04_Analytics() throws {
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(1)
        saveScreenshot(named: "Analytics")
    }

    func testiPhone_69_05_Settings() throws {
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(1)
        saveScreenshot(named: "Settings")
    }

    func testiPhone_69_06_Subscription() throws {
        // Go to Settings
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        // Swipe up to reach Subscription section
        app.windows.firstMatch.swipeUp()
        sleep(1)
        app.windows.firstMatch.swipeUp()
        sleep(1)
        // Tap Upgrade to Premium
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.element(matching: predicate)
        if button.exists {
            button.tap()
            sleep(2)
        }
        saveScreenshot(named: "Subscription")
    }
}
