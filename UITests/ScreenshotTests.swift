import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 4.0)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Tab Navigation Helper

    func tapTab(identifier: String) {
        // Map identifier to tab index
        // Tab order from debug output: Hub(0), Items(1), Quest(2), Stats(3), Menu(4)
        let identifierToIndex: [String: Int] = [
            "tab_hub": 0,
            "tab_dashboard": 0,
            "tab_items": 1,
            "tab_transactions": 1,
            "tab_quest": 2,
            "tab_add": 2,
            "tab_stats": 3,
            "tab_analytics": 3,
            "tab_menu": 4,
            "tab_settings": 4
        ]
        
        guard let tabIndex = identifierToIndex[identifier] else {
            print("WARNING: Unknown tab identifier: \(identifier)")
            return
        }
        
        // Get all buttons and find the tab bar buttons by index
        // Based on debug output, tab bar buttons are at indices 0-4
        let allButtons = app.buttons
        let buttonCount = allButtons.count
        
        print("Total buttons: \(buttonCount)")
        
        // Tab bar buttons appear at specific indices
        // Use boundBy to get specific button by index
        if tabIndex < buttonCount {
            let button = allButtons.element(boundBy: tabIndex)
            if button.exists {
                let label = button.label
                let buttonId = button.identifier
                print("Tapping tab [\(tabIndex)]: label=\(label), identifier=\(buttonId)")
                button.tap()
                Thread.sleep(forTimeInterval: 3.0)
                print("Successfully tapped tab at index: \(tabIndex)")
            } else {
                print("WARNING: Button at index \(tabIndex) does not exist")
                // Debug: print all buttons
                for i in 0..<min(buttonCount, 15) {
                    let btn = allButtons.element(boundBy: i)
                    if btn.exists {
                        print("  [\(i)] label=\(btn.label) id=\(btn.identifier)")
                    }
                }
            }
        } else {
            print("WARNING: tabIndex \(tabIndex) >= buttonCount \(buttonCount)")
            // Debug: print all buttons
            for i in 0..<min(buttonCount, 15) {
                let btn = allButtons.element(boundBy: i)
                if btn.exists {
                    print("  [\(i)] label=\(btn.label) id=\(btn.identifier)")
                }
            }
        }
    }

    // MARK: - Screenshot Helper

    private func capture(_ name: String) {
        let path = "/tmp/\(name).png"
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path) (\(data.count) bytes)")
    }

    // MARK: - iPhone 6.9" Screenshots (1320x2868)

    func testiPhone_69_01_Hub() throws {
        capture("iPhone_69_portrait_01_Hub")
    }

    func testiPhone_69_02_Transactions() throws {
        tapTab(identifier: "tab_items")
        capture("iPhone_69_portrait_02_Transactions")
    }

    func testiPhone_69_03_Add() throws {
        tapTab(identifier: "tab_quest")
        capture("iPhone_69_portrait_03_Add")
    }

    func testiPhone_69_04_Analytics() throws {
        tapTab(identifier: "tab_stats")
        capture("iPhone_69_portrait_04_Analytics")
    }

    func testiPhone_69_05_Settings() throws {
        tapTab(identifier: "tab_menu")
        capture("iPhone_69_portrait_05_Settings")
    }

    func testiPhone_69_06_Subscription() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 2.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("iPhone_69_portrait_06_Subscription")
    }

    // MARK: - IAP Screenshots

    func testIAP_iPhone_01_SubscriptionLanding() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("IAP_iPhone_01_SubscriptionLanding")
    }

    func testIAP_iPhone_02_PurchaseModal() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let upgradePredicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let upgradeButton = app.buttons.matching(upgradePredicate).firstMatch
        if upgradeButton.exists {
            upgradeButton.tap()
            Thread.sleep(forTimeInterval: 3.0)
        }

        let subscribePredicate = NSPredicate(format: "label CONTAINS[c] 'Subscribe'")
        let subscribeButton = app.buttons.matching(subscribePredicate).firstMatch
        if subscribeButton.exists {
            subscribeButton.tap()
            Thread.sleep(forTimeInterval: 4.0)
        }

        capture("IAP_iPhone_02_PurchaseModal")
    }

    // MARK: - iPad 13" Screenshots (2064x2752)

    func testiPad_13_01_Hub() throws {
        capture("iPad_13_portrait_01_Hub")
    }

    func testiPad_13_02_Transactions() throws {
        tapTab(identifier: "tab_items")
        capture("iPad_13_portrait_02_Transactions")
    }

    func testiPad_13_03_Add() throws {
        tapTab(identifier: "tab_quest")
        capture("iPad_13_portrait_03_Add")
    }

    func testiPad_13_04_Analytics() throws {
        tapTab(identifier: "tab_stats")
        capture("iPad_13_portrait_04_Analytics")
    }

    func testiPad_13_05_Settings() throws {
        tapTab(identifier: "tab_menu")
        capture("iPad_13_portrait_05_Settings")
    }

    func testiPad_13_06_Subscription() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 2.0)
        for _ in 0..<4 {
            app.windows.firstMatch.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
        }
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("iPad_13_portrait_06_Subscription")
    }

    // MARK: - IAP iPad Screenshots

    func testIAP_iPad_01_SubscriptionLanding() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists {
            button.tap()
            Thread.sleep(forTimeInterval: 2.0)
        }
        capture("IAP_iPad_01_SubscriptionLanding")
    }

    func testIAP_iPad_02_PurchaseModal() throws {
        tapTab(identifier: "tab_menu")
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)
        app.windows.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 1.0)

        let upgradePredicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let upgradeButton = app.buttons.matching(upgradePredicate).firstMatch
        if upgradeButton.exists {
            upgradeButton.tap()
            Thread.sleep(forTimeInterval: 3.0)
        }

        let subscribePredicate = NSPredicate(format: "label CONTAINS[c] 'Subscribe'")
        let subscribeButton = app.buttons.matching(subscribePredicate).firstMatch
        if subscribeButton.exists {
            subscribeButton.tap()
            Thread.sleep(forTimeInterval: 4.0)
        }

        capture("IAP_iPad_02_PurchaseModal")
    }
}