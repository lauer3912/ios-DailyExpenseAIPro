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
}