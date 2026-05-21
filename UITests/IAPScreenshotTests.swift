import XCTest

final class IAPScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 2.0)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Navigation Helper

    private func tapTab(identifier: String) {
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
    }

    // MARK: - Screenshot Helper

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path) (\(data.count) bytes)")
    }

    // MARK: - IAP iPhone Screenshots

    /// Captures the subscription landing page (shows premium features)
    func testIAP_iPhone_01_SubscriptionLanding() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.element(matching: predicate)
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("IAP_iPhone_01_SubscriptionLanding")
    }

    /// Captures the purchase modal / subscribe sheet
    func testIAP_iPhone_02_PurchaseModal() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let upgradePredicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let upgradeButton = app.buttons.element(matching: upgradePredicate)
        if upgradeButton.exists {
            upgradeButton.tap()
            Thread.sleep(forTimeInterval: 3.0)
        }

        // Try to tap Subscribe Now button inside subscription view
        let subscribePredicate = NSPredicate(format: "label CONTAINS[c] 'Subscribe'")
        let subscribeButton = app.buttons.element(matching: subscribePredicate)
        if subscribeButton.exists {
            subscribeButton.tap()
            Thread.sleep(forTimeInterval: 4.0)
        }

        capture("IAP_iPhone_02_PurchaseModal")
    }

    // MARK: - IAP iPad Screenshots

    /// Captures the subscription landing page on iPad
    func testIAP_iPad_01_SubscriptionLanding() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.element(matching: predicate)
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("IAP_iPad_01_SubscriptionLanding")
    }

    /// Captures the purchase modal on iPad
    func testIAP_iPad_02_PurchaseModal() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let upgradePredicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let upgradeButton = app.buttons.element(matching: upgradePredicate)
        if upgradeButton.exists {
            upgradeButton.tap()
            Thread.sleep(forTimeInterval: 3.0)
        }

        let subscribePredicate = NSPredicate(format: "label CONTAINS[c] 'Subscribe'")
        let subscribeButton = app.buttons.element(matching: subscribePredicate)
        if subscribeButton.exists {
            subscribeButton.tap()
            Thread.sleep(forTimeInterval: 4.0)
        }

        capture("IAP_iPad_02_PurchaseModal")
    }
}