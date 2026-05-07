import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Wait for app to fully load
        sleep(2)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - iPhone 6.9" Screenshots

    func testiPhone_69_01_Dashboard() throws {
        // Make sure we're on Dashboard (tab 0)
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(1)

        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone_69_Dashboard"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testiPhone_69_02_Transactions() throws {
        // Switch to Transactions tab (tab 1)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)

        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone_69_Transactions"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testiPhone_69_03_AddTransaction() throws {
        // Switch to Add tab (tab 2)
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(1)

        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone_69_AddTransaction"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testiPhone_69_04_Analytics() throws {
        // Switch to Analytics tab (tab 3)
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(1)

        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone_69_Analytics"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testiPhone_69_05_Settings() throws {
        // Switch to Settings tab (tab 4)
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(1)

        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "iPhone_69_Settings"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}