import XCTest

final class KMLPlacesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOpenFoldersAndDetails() throws {
        let app = XCUIApplication()
        app.activate()

        // Load test data
        app.buttons["Settings"].firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Use Test Data"]/*[[".otherElements[\"Use Test Data\"].staticTexts",".otherElements.staticTexts[\"Use Test Data\"]",".staticTexts[\"Use Test Data\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["OK"]/*[[".otherElements.buttons[\"OK\"]",".buttons",".buttons[\"OK\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        // Go to list view, open two folders, open details page,
        // assert map, name, and description are present, then go back to the root view
        app/*@START_MENU_TOKEN@*/.buttons["List"]/*[[".buttons.containing(.image, identifier: \"list.bullet\")",".otherElements",".buttons[\"List\"]",".buttons[\"list.bullet\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[1]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons["Businesses Folder"].firstMatch.tap()
        app.buttons["Restaurants Folder"].firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Pi Vegan Pizzeria"]/*[[".buttons.containing(.staticText, identifier: \"Pi Vegan Pizzeria\")",".otherElements.buttons[\"Pi Vegan Pizzeria\"]",".buttons[\"Pi Vegan Pizzeria\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        XCTAssert(app/*@START_MENU_TOKEN@*/.staticTexts["Details Name"]/*[[".scrollViews.staticTexts[\"Pi Vegan Pizzeria\"]",".otherElements.staticTexts[\"Details Name\"]",".staticTexts[\"Details Name\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.exists)
        XCTAssert(app/*@START_MENU_TOKEN@*/.staticTexts["Details Description"]/*[[".otherElements",".staticTexts[\"Pi Vegan Pizzeria serves all plant-based pizza, as well as other dishes like macaroni and cheese. They also have beer on draft.\"]",".staticTexts[\"Details Description\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.exists)
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Restaurants\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Businesses\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Seattle Places\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testMapView() throws {
        let app = XCUIApplication()
        app.activate()

        // Load test data
        app.buttons["Settings"].firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Use Test Data"]/*[[".otherElements[\"Use Test Data\"].staticTexts",".otherElements.staticTexts[\"Use Test Data\"]",".staticTexts[\"Use Test Data\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["OK"]/*[[".otherElements.buttons[\"OK\"]",".buttons",".buttons[\"OK\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        // Go to list and open a folder
        app/*@START_MENU_TOKEN@*/.buttons["List"]/*[[".buttons.containing(.image, identifier: \"list.bullet\")",".otherElements",".buttons[\"List\"]",".buttons[\"list.bullet\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[1]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons["Businesses Folder"].firstMatch.tap()
        app.buttons["Restaurants Folder"].firstMatch.tap()

        // Go to map and assert that only this folder's contents are shown
        app.buttons["Map"].firstMatch.tap()
        XCTAssert(app.maps.firstMatch.exists)
        let annotationButtons = app.buttons.matching(identifier: "Map annotation view button").allElementsBoundByIndex
        XCTAssert(annotationButtons.count == 2)
        XCTAssert(app.otherElements["The Wayward Cafe"].firstMatch.exists)
        XCTAssert(app.otherElements["Pi Vegan Pizzeria"].firstMatch.exists)
        XCTAssertFalse(app.otherElements["Third Place Books"].firstMatch.exists)

        // Tap annotation and assert popover content is shown
        annotationButtons[1].tap()
        XCTAssert(app.staticTexts["Map popover title"].firstMatch.exists)
        XCTAssert(app/*@START_MENU_TOKEN@*/.staticTexts["Map popover description"]/*[[".scrollViews.staticTexts",".otherElements",".staticTexts[\"Pi Vegan Pizzeria serves all plant-based pizza, as well as other dishes like macaroni and cheese. They also have beer on draft.\"]",".staticTexts[\"Map popover description\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.exists)

        // Dismiss popover
        app.scrollViews/*@START_MENU_TOKEN@*/.firstMatch/*[[".containing(.other, identifier: nil).firstMatch",".firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
