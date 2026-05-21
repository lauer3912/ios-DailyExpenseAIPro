import XCTest

final class ScreenshotTests: XCTestCase {

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

    // MARK: - Tab Navigation Helper

    func tapTab(identifier: String) {
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        } else {
            print("WARNING: Could not find tab button: \(identifier)")
        }
    }

    // MARK: - Screenshot Helper

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path) (\(data.count) bytes)")
    }

    // MARK: - iPhone 6.9" Screenshots (1320×2868)

    func testiPhone_69_01_Hub() throws {
        capture("iPhone_69_portrait_01_Hub")
    }

    func testiPhone_69_02_Items() throws {
        tapTab(identifier: "tab_items")
        capture("iPhone_69_portrait_02_Items")
    }

    func testiPhone_69_03_Quest() throws {
        tapTab(identifier: "tab_quest")
        capture("iPhone_69_portrait_03_Quest")
    }

    func testiPhone_69_04_Stats() throws {
        tapTab(identifier: "tab_stats")
        capture("iPhone_69_portrait_04_Stats")
    }

    func testiPhone_69_05_Menu() throws {
        tapTab(identifier: "tab_menu")
        capture("iPhone_69_portrait_05_Menu")
    }

    func testiPhone_69_06_Subscription() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 2.0)
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
        capture("iPhone_69_portrait_06_Subscription")
    }

    // MARK: - IAP Screenshots

    /// Captures the subscription landing page on iPhone (shows premium features)
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

    /// Captures the purchase modal / subscribe sheet on iPhone
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

    // MARK: - iPad 13" Screenshots (2064×2752)

    func testiPad_13_01_Hub() throws {
        capture("iPad_13_portrait_01_Hub")
    }

    func testiPad_13_02_Items() throws {
        tapTab(identifier: "tab_items")
        capture("iPad_13_portrait_02_Items")
    }

    func testiPad_13_03_Quest() throws {
        tapTab(identifier: "tab_quest")
        capture("iPad_13_portrait_03_Quest")
    }

    func testiPad_13_04_Stats() throws {
        tapTab(identifier: "tab_stats")
        capture("iPad_13_portrait_04_Stats")
    }

    func testiPad_13_05_Menu() throws {
        tapTab(identifier: "tab_menu")
        capture("iPad_13_portrait_05_Menu")
    }

    func testiPad_13_06_Subscription() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 2.0)
        for _ in 0..<4 {
            app.windows.firstMatch.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
        }
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.element(matching: predicate)
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("iPad_13_portrait_06_Subscription")
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