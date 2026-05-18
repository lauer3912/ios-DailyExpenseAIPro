import XCTest

final class ScreenshotTests_iPad: XCTestCase {

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

    // MARK: - Tab Navigation Helper (accessibilityIdentifier + NSPredicate + firstMatch)

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

    // MARK: - iPad 13" Screenshots (2048×2732)

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
}