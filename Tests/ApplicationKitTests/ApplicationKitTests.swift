import XCTest
@testable import ApplicationKit

final class ApplicationKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ApplicationKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
