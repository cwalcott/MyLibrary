import XCTest

@MainActor
final class E2ETests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Launch with faked dependencies
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    func testAddToFavorites() throws {
        app.activate()

        // "Foundation" should not be a favorite
        XCTAssertFalse(app.staticTexts["Foundation"].exists)

        // Search for "found"
        app/*@START_MENU_TOKEN@*/.buttons["plus"]/*[[".otherElements[\"plus\"].buttons",".otherElements",".buttons[\"Add\"]",".buttons[\"plus\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.searchFields["Search"].firstMatch/*[[".otherElements.searchFields[\"Search\"].firstMatch",".searchFields",".containing(.button, identifier: \"Clear text\").firstMatch",".containing(.image, identifier: \"magnifyingglass\").firstMatch",".firstMatch",".searchFields[\"Search\"].firstMatch"],[[[-1,5],[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.typeText("Foundation")

        // Add to Favorites
        app/*@START_MENU_TOKEN@*/.buttons["Foundation, Isaac Asimov"]/*[[".buttons",".containing(.staticText, identifier: \"Isaac Asimov\")",".containing(.staticText, identifier: \"Foundation\")",".containing(.image, identifier: nil)",".cells.buttons",".otherElements.buttons[\"Foundation, Isaac Asimov\"]",".buttons[\"Foundation, Isaac Asimov\"]"],[[[-1,6],[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add to Favorites"]/*[[".otherElements.buttons[\"Add to Favorites\"]",".buttons[\"Add to Favorites\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        // "Add to Favorites" should be replaced with "Remove from Favorites"
        XCTAssertFalse(app.buttons["Add to Favorites"].exists)
        XCTAssert(app.buttons["Remove from Favorites"].exists)

        // Foundation should now be in the Favorites list
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Search Books\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Favorite Books\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        XCTAssert(app.staticTexts["Foundation"].exists)
    }

    func testRemoveFavorite() throws {
        app.activate()

        // "The Hobbit" should be a favorite
        XCTAssert(app.staticTexts["The Hobbit"].exists)

        // Navigate to "The Hobbit" details and remove from favorites
        app/*@START_MENU_TOKEN@*/.buttons["The Hobbit, J.R.R. Tolkien"]/*[[".buttons",".containing(.staticText, identifier: \"J.R.R. Tolkien\")",".containing(.staticText, identifier: \"The Hobbit\")",".containing(.image, identifier: nil)",".cells.buttons",".otherElements.buttons[\"The Hobbit, J.R.R. Tolkien\"]",".buttons[\"The Hobbit, J.R.R. Tolkien\"]"],[[[-1,6],[-1,5],[-1,4],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Remove from Favorites"]/*[[".otherElements.buttons[\"Remove from Favorites\"]",".buttons[\"Remove from Favorites\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        // "Remove from Favorites" should be replaced with "Add to Favorites"
        XCTAssertFalse(app/*@START_MENU_TOKEN@*/.buttons["Remove from Favorites"]/*[[".otherElements.buttons[\"Remove from Favorites\"]",".buttons[\"Remove from Favorites\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        XCTAssert(app.buttons["Add to Favorites"].exists)

        // "The Hobbit" should no longer be in the Favorites list
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Back\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        XCTAssertFalse(app.staticTexts["The Hobbit"].exists)
    }
}
