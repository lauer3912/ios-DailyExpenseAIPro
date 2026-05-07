import XCTest

final class ScreenshotTests_iPad: XCTestCase {

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

    // MARK: - iPad 13" Screenshots

    private func tapFloatingTabBar(at index: Int) {
        let screenWidth = app.windows.firstMatch.frame.width
        let screenHeight = app.windows.firstMatch.frame.height
        let tabBarHeight: CGFloat = 60.0
        let tabBarY = screenHeight - tabBarHeight - 20
        let tabSpacing: CGFloat = 70.0
        let startX = (screenWidth - (tabSpacing * 4)) / 2
        let targetX = startX + (CGFloat(index) * tabSpacing)
        let targetY = tabBarY + (tabBarHeight / 2)
        let coordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: targetX, dy: targetY))
        coordinate.tap()
        sleep(1)
    }

    private func saveScreenshot(named name: String) {
        let screenshot = app.windows.firstMatch.screenshot()
        let data = screenshot.pngRepresentation
        let path = "/tmp/ipad13_\(name).png"
        try? data.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path) (\(data.count) bytes)")
    }

    func testiPad_13_01_Dashboard() throws {
        tapFloatingTabBar(at: 0)
        saveScreenshot(named: "Dashboard")
    }

    func testiPad_13_02_Transactions() throws {
        tapFloatingTabBar(at: 1)
        saveScreenshot(named: "Transactions")
    }

    func testiPad_13_03_AddTransaction() throws {
        tapFloatingTabBar(at: 2)
        saveScreenshot(named: "AddTransaction")
    }

    func testiPad_13_04_Analytics() throws {
        tapFloatingTabBar(at: 3)
        saveScreenshot(named: "Analytics")
    }

    func testiPad_13_05_Settings() throws {
        tapFloatingTabBar(at: 4)
        saveScreenshot(named: "Settings")
    }

    func testiPad_13_06_Subscription() throws {
        // Go to Settings
        tapFloatingTabBar(at: 4)
        sleep(2)
        // Swipe up multiple times to reach Subscription section
        for _ in 0..<4 {
            app.windows.firstMatch.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
        }
        sleep(1)
        // Try to tap Upgrade to Premium
        let predicate = NSPredicate(format: "label CONTAINS[c] 'Upgrade'")
        let button = app.buttons.element(matching: predicate)
        if button.exists {
            button.tap()
            sleep(2)
        }
        saveScreenshot(named: "Subscription")
    }
}
